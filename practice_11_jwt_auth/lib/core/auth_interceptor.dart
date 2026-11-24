import 'package:dio/dio.dart';

import 'token_storage.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorage tokenStorage;
  final Dio dio;

  AuthInterceptor(this.tokenStorage, this.dio);

  // Публічні маршрути ReqRes, яким не потрібна авторизація.
  bool _isPublicEndpoint(RequestOptions options) {
    final path = options.path;

    return path == '/login' ||
        path == '/register' ||
        path.startsWith('/users/');
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isPublicEndpoint(options)) {
      return handler.next(options);
    }

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
    final requestOptions = response.requestOptions;

    // Для публічних маршрутів оновлення токена не потрібне.
    if (_isPublicEndpoint(requestOptions) ||
        response.statusCode != 401 ||
        requestOptions.extra['auth_retry'] == true) {
      return handler.next(response);
    }

    try {
      final refreshToken = await tokenStorage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        await tokenStorage.clearTokens();
        return handler.next(response);
      }

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

      if (newAccessToken == null ||
          newAccessToken.toString().isEmpty) {
        await tokenStorage.clearTokens();
        return handler.next(response);
      }

      await tokenStorage.saveTokens(
        accessToken: newAccessToken.toString(),
        refreshToken: newRefreshToken.toString(),
      );

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
