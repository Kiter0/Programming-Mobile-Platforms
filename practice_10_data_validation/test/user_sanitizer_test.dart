import 'package:flutter_test/flutter_test.dart';
import 'package:practice_10_data_validation/services/user_sanitizer.dart';

void main() {
  group('UserSanitizer - name sanitization', () {
    test('Removes leading and trailing spaces', () {
      expect(
        UserSanitizer.sanitizeName('  Іван Петренко  '),
        'Іван Петренко',
      );
    });

    test('Replaces multiple spaces with one', () {
      expect(
        UserSanitizer.sanitizeName('Іван    Петренко'),
        'Іван Петренко',
      );
    });
  });

  group('UserSanitizer - email sanitization', () {
    test('Removes spaces and converts email to lowercase', () {
      expect(
        UserSanitizer.sanitizeEmail(' IVAN@GMAIL.COM '),
        'ivan@gmail.com',
      );
    });
  });

  group('UserSanitizer - phone sanitization', () {
    test('Removes spaces, brackets and dashes', () {
      expect(
        UserSanitizer.sanitizePhone('+38 (099) 123-45-67'),
        '+380991234567',
      );
    });

    test('Keeps phone number without plus sign', () {
      expect(
        UserSanitizer.sanitizePhone('099-123-45-67'),
        '0991234567',
      );
    });
  });
}
