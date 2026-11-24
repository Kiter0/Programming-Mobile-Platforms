import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    final message = getErrorMessage(err);

    debugPrint('API ERROR: $message');

    handler.next(err);
  }

  static String getErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Час очікування з’єднання вичерпано';

      case DioExceptionType.sendTimeout:
        return 'Не вдалося відправити запит';

      case DioExceptionType.receiveTimeout:
        return 'Сервер не відповідає';
      
      case DioExceptionType.transformTimeout:
        return 'Час обробки відповіді вичерпано';
        
      case DioExceptionType.badResponse:
        return 'Помилка сервера: ${error.response?.statusCode}';

      case DioExceptionType.cancel:
        return 'Запит скасовано';

      case DioExceptionType.connectionError:
        return 'Немає підключення до інтернету';

      case DioExceptionType.badCertificate:
        return 'Помилка сертифіката безпеки';

      case DioExceptionType.unknown:
        return 'Невідома мережева помилка';
    }
  }
}
