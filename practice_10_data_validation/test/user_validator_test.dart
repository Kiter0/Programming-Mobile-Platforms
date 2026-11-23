import 'package:flutter_test/flutter_test.dart';
import 'package:practice_10_data_validation/validators/user_validator.dart';

void main() {
  group('UserValidator - name validation', () {
    test('Accepts a valid name', () {
      expect(UserValidator.validateName('Іван Петренко'), isNull);
    });

    test('Rejects an empty name', () {
      expect(
        UserValidator.validateName('   '),
        isNotNull,
      );
    });

    test('Rejects a name that is too short', () {
      expect(
        UserValidator.validateName('A'),
        isNotNull,
      );
    });
  });

  group('UserValidator - email validation', () {
    test('Accepts a valid email', () {
      expect(
        UserValidator.validateEmail('ivan@gmail.com'),
        isNull,
      );
    });

    test('Rejects an invalid email', () {
      expect(
        UserValidator.validateEmail('wrong-email'),
        isNotNull,
      );
    });

    test('Rejects an empty email', () {
      expect(
        UserValidator.validateEmail(''),
        isNotNull,
      );
    });
  });

  group('UserValidator - phone validation', () {
    test('Accepts a valid phone number', () {
      expect(
        UserValidator.validatePhone('+380991234567'),
        isNull,
      );
    });

    test('Rejects a short phone number', () {
      expect(
        UserValidator.validatePhone('123'),
        isNotNull,
      );
    });
  });

  group('UserValidator - complete user validation', () {
    test('Returns no errors for valid user data', () {
      final errors = UserValidator.validateUser(
        name: 'Іван Петренко',
        email: 'ivan@gmail.com',
        phone: '+380991234567',
      );

      expect(errors, isEmpty);
    });

    test('Returns errors for invalid user data', () {
      final errors = UserValidator.validateUser(
        name: '',
        email: 'wrong-email',
        phone: '123',
      );

      expect(errors.length, 3);
      expect(errors.containsKey('name'), isTrue);
      expect(errors.containsKey('email'), isTrue);
      expect(errors.containsKey('phone'), isTrue);
    });
  });
}
