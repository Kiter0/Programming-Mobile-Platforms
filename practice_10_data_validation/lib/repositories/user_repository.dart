import '../database/database_helper.dart';
import '../models/user.dart';
import '../services/user_sanitizer.dart';
import '../validators/user_validator.dart';

class UserRepository {
  final DatabaseHelper databaseHelper;

  UserRepository({required this.databaseHelper});

  Future<User> addUser({
    required String name,
    required String email,
    required String phone,
  }) async {
    // Спочатку очищуємо введені дані.
    final sanitizedName = UserSanitizer.sanitizeName(name);
    final sanitizedEmail = UserSanitizer.sanitizeEmail(email);
    final sanitizedPhone = UserSanitizer.sanitizePhone(phone);

    // Перевіряємо очищені дані.
    final errors = UserValidator.validateUser(
      name: sanitizedName,
      email: sanitizedEmail,
      phone: sanitizedPhone,
    );

    if (errors.isNotEmpty) {
      throw UserValidationException(errors);
    }

    // Створюємо модель лише після успішної перевірки.
    final user = User(
      name: sanitizedName,
      email: sanitizedEmail,
      phone: sanitizedPhone,
    );

    // Зберігаємо користувача в SQLite.
    try {
      final id = await databaseHelper.insertUser(user.toMap());
      return user.copyWith(id: id);
    } catch (e) {
      throw UserRepositoryException(
        'Не вдалося зберегти користувача: $e',
      );
    }
  }

  Future<List<User>> getUsers() async {
    try {
      final maps = await databaseHelper.getUsers();
      return maps.map(User.fromMap).toList();
    } catch (e) {
      throw UserRepositoryException(
        'Не вдалося завантажити користувачів: $e',
      );
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await databaseHelper.deleteUser(id);
    } catch (e) {
      throw UserRepositoryException(
        'Не вдалося видалити користувача: $e',
      );
    }
  }
}

class UserValidationException implements Exception {
  final Map<String, String> errors;

  UserValidationException(this.errors);

  @override
  String toString() => errors.values.join('\n');
}

class UserRepositoryException implements Exception {
  final String message;

  UserRepositoryException(this.message);

  @override
  String toString() => message;
}
