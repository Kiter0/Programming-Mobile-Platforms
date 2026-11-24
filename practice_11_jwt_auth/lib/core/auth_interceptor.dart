import 'package:dio/dio.dart';

import 'token_storage.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorage tokenStorage;
  final Dio dio;

  AuthInterceptor(this.tokenStorage, this.dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenStorage.getAccessToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    // Перевіряємо, чи сервер повернув помилку 401.
    if (response.statusCode != 401 ||
        response.requestOptions.extra['auth_retry'] == true) {
      return handler.next(response);
    }

    try {
      final refreshToken = await tokenStorage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        await tokenStorage.clearTokens();
        return handler.next(response);
      }

      // Окремий Dio, щоб уникнути повторного виклику interceptor.
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: dio.options.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      final refreshResponse = await refreshDio.post(
        '/refresh',
        data: {
          'refreshToken': refreshToken,
        },
      );

      final data = refreshResponse.data as Map<String, dynamic>;

      final newAccessToken =
          data['accessToken'] ?? data['access_token'] ?? data['token'];

      final newRefreshToken =
          data['refreshToken'] ?? data['refresh_token'] ?? refreshToken;

      if (newAccessToken == null || newAccessToken.toString().isEmpty) {
        await tokenStorage.clearTokens();
        return handler.next(response);
      }

      // Зберігаємо оновлені токени.
      await tokenStorage.saveTokens(
        accessToken: newAccessToken.toString(),
        refreshToken: newRefreshToken.toString(),
      );

      // Повторюємо початковий запит.
      final requestOptions = response.requestOptions;

      requestOptions.headers['Authorization'] =
          'Bearer ${newAccessToken.toString()}';

      requestOptions.extra['auth_retry'] = true;

      final retryResponse = await dio.fetch(requestOptions);

      return handler.resolve(retryResponse);
    } catch (_) {
      await tokenStorage.clearTokens();
      return handler.next(response);
    }
  }
}
