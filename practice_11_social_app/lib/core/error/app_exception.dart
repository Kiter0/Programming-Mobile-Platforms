import 'package:dio/dio.dart';

/// Єдиний клас винятків додатка для зрозумілого відображення помилок в UI
class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, {this.statusCode});

  /// Перетворення технічної помилки Dio на людиночитне повідомлення
  factory AppException.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppException('Час очікування відповіді від сервера вичерпано');
      case DioExceptionType.connectionError:
        return AppException('Відсутнє інтернет-з\'єднання');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        String serverMsg = 'Помилка сервера ($statusCode)';
        if (data is Map<String, dynamic> && data['message'] != null) {
          serverMsg = data['message'].toString();
        }
        return AppException(serverMsg, statusCode: statusCode);
      case DioExceptionType.cancel:
        return AppException('Запит було скасовано');
      default:
        return AppException('Невідома мережева помилка');
    }
  }

  @override
  String toString() => message;
}