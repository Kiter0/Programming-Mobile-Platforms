import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// 2-й Interceptor: логування вихідних запитів, відповідей та помилок
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('[HTTP REQ] ${options.method} ${options.uri}');
    if (options.queryParameters.isNotEmpty) {
      debugPrint('  Query: ${options.queryParameters}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
      '[HTTP RES] ${response.statusCode} ${response.requestOptions.uri}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      '[HTTP ERR] ${err.response?.statusCode ?? 'NO_STATUS'} '
      '${err.requestOptions.uri} -> ${err.message}',
    );
    handler.next(err);
  }
}