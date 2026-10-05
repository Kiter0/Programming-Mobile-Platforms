import 'dart:math';

/// Калькулятор: усі операції зібрані у статичних методах
class Calculator {
  static double add(double a, double b) => a + b;

  static double subtract(double a, double b) => a - b;

  static double multiply(double a, double b) => a * b;

  static double divide(double a, double b) {
    if (b == 0) {
      throw ArgumentError('Ділення на нуль неможливе');
    }
    return a / b;
  }

  static double modulo(double a, double b) {
    if (b == 0) {
      throw ArgumentError('Остача від ділення на нуль неможлива');
    }
    return a % b;
  }

  static double power(double base, double exponent) {
    return pow(base, exponent).toDouble();
  }

  static double squareRoot(double a) {
    if (a < 0) {
      throw ArgumentError('Корінь з від\'ємного числа не визначений');
    }
    return sqrt(a);
  }

  /// Вибирає операцію за символом. Для sqrt другий операнд не використовується.
  static double calculate(String operation, double a, [double b = 0]) {
    // switch-вираз (Dart 3): кожна гілка повертає значення
    return switch (operation) {
      '+' => add(a, b),
      '-' => subtract(a, b),
      '*' => multiply(a, b),
      '/' => divide(a, b),
      '%' => modulo(a, b),
      '^' => power(a, b),
      'sqrt' => squareRoot(a),
      _ => throw ArgumentError('Невідома операція: $operation'),
    };
  }
}