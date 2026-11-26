import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:practice_11_social_app/core/network/api_endpoints.dart';
import 'package:practice_11_social_app/core/network/interceptors/auth_interceptor.dart';
import 'package:practice_11_social_app/core/network/interceptors/logging_interceptor.dart';
import 'package:practice_11_social_app/core/network/interceptors/retry_interceptor.dart';

/// Єдиний налаштований екземпляр Dio із трьома обов'язковими interceptors
class DioClient {
  late final Dio dio;

  DioClient({
    required FlutterSecureStorage storage,
    VoidCallback? onSessionExpired,
  }) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Підключення 3 interceptors: Auth, Logging та Retry
    dio.interceptors.addAll([
      AuthInterceptor(storage, onSessionExpired: onSessionExpired),
      LoggingInterceptor(),
      RetryInterceptor(dio, maxRetries: 2),
    ]);
  }
}