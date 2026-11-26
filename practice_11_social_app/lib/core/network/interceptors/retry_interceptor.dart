import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// 3-й Interceptor: автоматичний повтор запиту при тимчасових тайм-аутах/збоях
class RetryInterceptor extends Interceptor {
  final Dio _dio;
  final int maxRetries;

  RetryInterceptor(this._dio, {this.maxRetries = 2});

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final shouldRetry = err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError;

    final currentAttempt = (err.requestOptions.extra['retry_attempt'] as int?) ?? 0;

    if (shouldRetry && currentAttempt < maxRetries) {
      final nextAttempt = currentAttempt + 1;
      err.requestOptions.extra['retry_attempt'] = nextAttempt;

      debugPrint(
        '[HTTP RETRY] Спроба $nextAttempt/$maxRetries для ${err.requestOptions.path}',
      );

      // Експоненційна затримка перед повтором
      await Future.delayed(Duration(milliseconds: 500 * nextAttempt));

      try {
        final response = await _dio.fetch(err.requestOptions);
        return handler.resolve(response);
      } on DioException catch (retryError) {
        return handler.next(retryError);
      }
    }

    handler.next(err);
  }
}