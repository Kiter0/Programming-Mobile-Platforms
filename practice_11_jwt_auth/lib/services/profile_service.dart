import 'package:dio/dio.dart';

import '../models/user.dart';

class ProfileService {
  final Dio dio;

  ProfileService({required this.dio});

  // Отримання профілю користувача.
  Future<User> getProfile(int userId) async {
    final response = await dio.get('/users/$userId');

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw Exception(
        'Сервер повернув помилку ${response.statusCode}',
      );
    }

    final responseData = response.data;

    if (responseData is! Map<String, dynamic>) {
      throw Exception('Сервер повернув некоректні дані профілю');
    }

    final userData = responseData['data'];

    if (userData is! Map<String, dynamic>) {
      throw Exception('У відповіді сервера відсутні дані користувача');
    }

    return User.fromJson(userData);
  }

  // Оновлення профілю користувача.
  Future<User> updateProfile({
    required int userId,
    required User user,
  }) async {
    final response = await dio.put(
      '/users/$userId',
      data: {
        'email': user.email,
        'first_name': user.firstName,
        'last_name': user.lastName,
      },
    );

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw Exception(
        'Не вдалося оновити профіль: ${response.statusCode}',
      );
    }

    final data = response.data;

    if (data is! Map<String, dynamic>) {
      throw Exception('Сервер повернув некоректну відповідь');
    }

    return user.copyWith(
      email: data['email'] as String? ?? user.email,
      firstName: data['first_name'] as String? ?? user.firstName,
      lastName: data['last_name'] as String? ?? user.lastName,
    );
  }

  // Демонстраційний запит зміни пароля.
  Future<void> changePassword({
    required int userId,
    required String newPassword,
  }) async {
    final response = await dio.put(
      '/users/$userId',
      data: {
        'password': newPassword,
      },
    );

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw Exception(
        'Не вдалося змінити пароль: ${response.statusCode}',
      );
    }
  }
}
