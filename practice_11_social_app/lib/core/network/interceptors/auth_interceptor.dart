import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:practice_11_social_app/core/network/api_endpoints.dart';

/// 1-й Interceptor: додає Bearer JWT до заголовків та виконує refresh при 401
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final VoidCallback? onSessionExpired;

  // Окремий Dio без інтерсепторів для запиту refresh, щоб уникнути рекурсії
  final Dio _refreshDio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      headers: {'Content-Type': 'application/json'},
    ),
  );

  AuthInterceptor(this._storage, {this.onSessionExpired});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: 'access_token');
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final isAuthEndpoint = err.requestOptions.path.contains(ApiEndpoints.login) ||
        err.requestOptions.path.contains(ApiEndpoints.refresh);

    // Якщо токен протерміновано (401), пробуємо оновити його через refreshToken
    if (isUnauthorized && !isAuthEndpoint) {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          final refreshResponse = await _refreshDio.post(
            ApiEndpoints.refresh,
            data: {
              'refreshToken': refreshToken,
              'expiresInMins': 30,
            },
          );

          final newAccessToken = refreshResponse.data['accessToken'] as String?;
          final newRefreshToken =
              refreshResponse.data['refreshToken'] as String?;

          if (newAccessToken != null) {
            await _storage.write(key: 'access_token', value: newAccessToken);
            if (newRefreshToken != null) {
              await _storage.write(
                key: 'refresh_token',
                value: newRefreshToken,
              );
            }

            // Повторюємо початковий запит із новим accessToken
            final retryOptions = err.requestOptions;
            retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            final clonedResponse = await _refreshDio.fetch(retryOptions);
            return handler.resolve(clonedResponse);
          }
        } catch (_) {
          // Якщо refresh не вдався — очищуємо токени і сповіщаємо UI про вихід
          await _storage.delete(key: 'access_token');
          await _storage.delete(key: 'refresh_token');
          onSessionExpired?.call();
        }
      }
    }

    handler.next(err);
  }
}