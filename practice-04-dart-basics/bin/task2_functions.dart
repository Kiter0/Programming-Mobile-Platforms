void main() {
  print('=== Демонстрація функцій Dart ===');
  testBasicFunctions();
  testAdvancedFunctions();
  testFunctionalProgramming();
}

//  1. Звичайні функції 

int calculateSum(int a, int b) {
  return a + b;
}

double calculateAverage(List<double> numbers) {
  if (numbers.isEmpty) {
    return 0; // щоб не ділити на нуль
  }
  double sum = 0;
  for (final n in numbers) {
    sum += n;
  }
  return sum / numbers.length;
}

// Стрілкова функція: короткий запис, коли в тілі лише один вираз
int square(int x) => x * x;

//  2. Іменовані та необов'язкові параметри 

// {} означає іменовані параметри; middleName необов'язковий, uppercase має значення за замовчуванням
String formatName(
  String firstName,
  String lastName, {
  String? middleName,
  bool uppercase = false,
}) {
  final parts = <String>[firstName];
  if (middleName != null) {
    parts.add(middleName);
  }
  parts.add(lastName);
  final result = parts.join(' ');
  return uppercase ? result.toUpperCase() : result;
}

// [] означає необов'язковий позиційний параметр
String greet(String name, [String greeting = 'Привіт']) {
  return '$greeting, $name!';
}

// Функція як параметр: operation можна передати ззовні
int applyTwice(int Function(int) operation, int value) {
  return operation(operation(value));
}

//  3. Замикання (closures)

// Повертає функцію, яка "пам'ятає" змінну count
int Function() makeCounter() {
  int count = 0;
  return () {
    count++;
    return count;
  };
}

// Кожна повернена функція пам'ятає свій factor
int Function(int) makeMultiplier(int factor) {
  return (int x) => x * factor;
}

// 4. Рекурсивні функції 

int fibonacci(int n) {
  if (n < 0) {
    throw ArgumentError('n має бути не менше 0');
  }
  if (n <= 1) {
    return n; // базовий випадок: fib(0) = 0, fib(1) = 1
  }
  return fibonacci(n - 1) + fibonacci(n - 2);
}

int factorial(int n) {
  if (n < 0) {
    throw ArgumentError('n має бути не менше 0');
  }
  if (n <= 1) {
    return 1; // базовий випадок
  }
  return n * factorial(n - 1);
}

//  Демонстрації

void testBasicFunctions() {
  print('\n--- Звичайні функції ---');
  print('calculateSum(3, 4) = ${calculateSum(3, 4)}');
  print('calculateAverage([4.0, 5.0, 9.0]) = '
      '${calculateAverage([4.0, 5.0, 9.0])}');
  print('calculateAverage([]) = ${calculateAverage([])}');
  print('square(5) = ${square(5)}');
  print('factorial(5) = ${factorial(5)}');
  print('Фібоначчі (перші 10): ${List.generate(10, fibonacci)}');
}

void testAdvancedFunctions() {
  print('\n--- Іменовані та необов\'язкові параметри ---');
  print(formatName('Іван', 'Петренко'));
  print(formatName('Іван', 'Петренко', middleName: 'Олегович'));
  print(formatName('Іван', 'Петренко', uppercase: true));
  print(greet('Анна'));
  print(greet('Анна', 'Вітаю'));
  print('applyTwice(square, 3) = ${applyTwice(square, 3)}');
  print('applyTwice(x + 10, 1) = ${applyTwice((x) => x + 10, 1)}');
}

void testFunctionalProgramming() {
  print('\n--- Функціональне програмування ---');
  final numbers = [1, 2, 3, 4, 5, 6];

  // map перетворює кожен елемент, where залишає лише ті, що підходять
  final squares = numbers.map((n) => n * n).toList();
  final evens = numbers.where((n) => n.isEven).toList();
  print('квадрати: $squares');
  print('парні: $evens');

  // fold має початкове значення (0), reduce бере перший елемент як початок
  final sum = numbers.fold<int>(0, (acc, n) => acc + n);
  final product = numbers.reduce((a, b) => a * b);
  print('сума через fold: $sum, добуток через reduce: $product');

  // Ланцюжок викликів
  final words = ['dart', 'flutter', 'code', 'mobile', 'app'];
  final result =
      words.where((w) => w.length > 3).map((w) => w.toUpperCase()).toList();
  print('слова довші за 3 літери (великими): $result');

  // Замикання
  final counter = makeCounter();
  print('лічильник: ${counter()}, ${counter()}, ${counter()}');
  final triple = makeMultiplier(3);
  final double5 = makeMultiplier(5);
  print('triple(7) = ${triple(7)}, double5(7) = ${double5(7)}');
}