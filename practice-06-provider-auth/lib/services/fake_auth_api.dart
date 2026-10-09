
import 'dart:math';

class FakeAuthApi {
  final Random _random = Random();

  static const String testEmail = 'student@example.com';
  static const String testPassword = 'Flutter123!';

  Future<Map<String, String>> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(
      Duration(milliseconds: 1000 + _random.nextInt(1001)),
    );

    if (email.trim().toLowerCase() != testEmail ||
        password != testPassword) {
      throw Exception('Невірний email або пароль');
    }

    return {
      'name': 'Студент Flutter',
      'email': testEmail,
    };
  }

  Future<Map<String, String>> updateProfile({
    required String name,
    required String email,
  }) async {
    await Future<void>.delayed(
      Duration(milliseconds: 1000 + _random.nextInt(1001)),
    );

    if (_random.nextInt(5) == 0) {
      throw Exception('Не вдалося зберегти профіль. Спробуйте ще раз.');
    }

    return {
      'name': name.trim(),
      'email': email.trim(),
    };
  }
}