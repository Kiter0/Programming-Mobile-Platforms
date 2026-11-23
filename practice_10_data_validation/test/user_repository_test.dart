import 'package:flutter_test/flutter_test.dart';
import 'package:practice_10_data_validation/database/database_helper.dart';
import 'package:practice_10_data_validation/repositories/user_repository.dart';

class FakeDatabaseHelper extends DatabaseHelper {
  final List<Map<String, dynamic>> users = [];
  bool shouldFail = false;
  int nextId = 1;

    FakeDatabaseHelper() : super.forTesting();

  @override
  Future<int> insertUser(Map<String, dynamic> user) async {
    if (shouldFail) {
      throw Exception('Database error');
    }

    final id = nextId++;
    users.add({...user, 'id': id});
    return id;
  }

  @override
  Future<List<Map<String, dynamic>>> getUsers() async {
    if (shouldFail) {
      throw Exception('Database error');
    }

    return List.from(users);
  }

  @override
  Future<int> deleteUser(int id) async {
    if (shouldFail) {
      throw Exception('Database error');
    }

    users.removeWhere((user) => user['id'] == id);
    return 1;
  }
}

void main() {
  late FakeDatabaseHelper database;
  late UserRepository repository;

  setUp(() {
    database = FakeDatabaseHelper();
    repository = UserRepository(databaseHelper: database);
  });

  group('UserRepository - adding users', () {
    test('Sanitizes and saves valid user data', () async {
      final user = await repository.addUser(
        name: '  Іван   Петренко  ',
        email: ' IVAN@GMAIL.COM ',
        phone: '+38 (099) 123-45-67',
      );

      expect(user.id, 1);
      expect(user.name, 'Іван Петренко');
      expect(user.email, 'ivan@gmail.com');
      expect(user.phone, '+380991234567');
      expect(database.users.length, 1);
    });

    test('Rejects invalid user data', () async {
      expect(
        () => repository.addUser(
          name: 'A',
          email: 'wrong-email',
          phone: '123',
        ),
        throwsA(isA<UserValidationException>()),
      );

      expect(database.users, isEmpty);
    });

    test('Handles database errors when saving', () async {
      database.shouldFail = true;

      expect(
        () => repository.addUser(
          name: 'Іван Петренко',
          email: 'ivan@gmail.com',
          phone: '+380991234567',
        ),
        throwsA(isA<UserRepositoryException>()),
      );
    });
  });

  group('UserRepository - retrieving users', () {
    test('Returns saved users', () async {
      await repository.addUser(
        name: 'Іван Петренко',
        email: 'ivan@gmail.com',
        phone: '+380991234567',
      );

      final users = await repository.getUsers();

      expect(users.length, 1);
      expect(users.first.name, 'Іван Петренко');
    });

    test('Handles database errors when retrieving users', () async {
      database.shouldFail = true;

      expect(
        repository.getUsers,
        throwsA(isA<UserRepositoryException>()),
      );
    });
  });

  group('UserRepository - deleting users', () {
    test('Deletes a user', () async {
      final user = await repository.addUser(
        name: 'Іван Петренко',
        email: 'ivan@gmail.com',
        phone: '+380991234567',
      );

      await repository.deleteUser(user.id!);

      expect(database.users, isEmpty);
    });

    test('Handles database errors when deleting', () async {
      database.shouldFail = true;

      expect(
        () => repository.deleteUser(1),
        throwsA(isA<UserRepositoryException>()),
      );
    });
  });
}
