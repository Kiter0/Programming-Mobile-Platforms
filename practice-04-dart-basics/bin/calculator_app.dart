import 'dart:io';

import 'package:dart_basics_rudenko/utils/calculator.dart';

void main() {
  print('=== Консольний калькулятор ===');

  while (true) {
    print('\nОперації: +  -  *  /  %  ^  sqrt   (exit — вихід)');
    stdout.write('Оберіть операцію: ');
    final operation = stdin.readLineSync()?.trim() ?? 'exit';

    if (operation == 'exit') {
      print('До побачення!');
      break;
    }

    final a = readNumber('Перше число: ');
    // sqrt потребує лише одного числа
    final b = operation == 'sqrt' ? 0.0 : readNumber('Друге число: ');

    try {
      final result = Calculator.calculate(operation, a, b);
      print('Результат: $result');
    } on ArgumentError catch (e) {
      print('Помилка: ${e.message}');
    }
  }
}

/// Просить число, доки користувач не введе коректне
double readNumber(String prompt) {
  while (true) {
    stdout.write(prompt);
    final input = stdin.readLineSync();
    final value = double.tryParse(input?.replaceAll(',', '.') ?? '');
    if (value != null) {
      return value;
    }
    print('Це не число, спробуйте ще раз.');
  }
}
