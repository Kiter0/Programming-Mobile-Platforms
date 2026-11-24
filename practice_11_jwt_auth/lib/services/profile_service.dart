import 'package:dio/dio.dart';

import '../models/user.dart';

class ProfileService {
  final Dio dio;

  ProfileService({required this.dio});

  // Отримання профілю користувача.
  Future<User> getProfile(int userId) async {
    final response = await dio.get('/users/$userId');

    final data = response.data['data'] as Map<String, dynamic>;

    return User.fromJson(data);
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

    final data = response.data as Map<String, dynamic>;

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
    await dio.put(
      '/users/$userId',
      data: {
        'password': newPassword,
      },
    );
  }
}