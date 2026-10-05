import 'dart:math';

void main() {
  print('=== Демонстрація змінних і типів Dart ===');
  demonstrateNumbers();
  demonstrateStrings();
  demonstrateBooleans();
  demonstrateCollections();
  demonstrateNullSafety();
}

void demonstrateNumbers() {
  print('\n--- Числа ---');
  int age = 20;
  double price = 99.99;
  num anything = 5; // num може зберігати і int, і double
  anything = 5.5;

  print('int: $age, double: $price, num: $anything');
  print('int + double = ${age + price}'); // результат завжди double
  print('7 / 2 = ${7 / 2}'); // звичайне ділення дає double
  print('7 ~/ 2 = ${7 ~/ 2}'); // цілочисельне ділення
  print('7 % 2 = ${7 % 2}'); // остача від ділення
  print('2 у степені 10 = ${pow(2, 10)}');

  // Перетворення типів
  int parsed = int.parse('42');
  double parsedDouble = double.parse('3.14');
  int? broken = int.tryParse('abc'); // замість помилки поверне null
  print('parse: $parsed, $parsedDouble, tryParse("abc"): $broken');
  print('3.7.toInt() = ${3.7.toInt()}, округлення = ${3.7.round()}');
  print('число пі з 2 знаками: ${3.14159.toStringAsFixed(2)}');
}

void demonstrateStrings() {
  print('\n--- Рядки ---');
  String name = 'Dart';
  print('Інтерполяція: $name, довжина: ${name.length}');

  // Багаторядковий рядок у потрійних лапках
  String multi = '''
Перший рядок
Другий рядок''';
  print(multi);

  print('Escape-символи: табуляція\tтут, зворотний слеш \\, лапка \'ок\'');
  print(r'Raw-рядок: \n не переносить рядок');

  String s = '  Hello, Dart World!  ';
  String t = s.trim(); // прибирає пробіли по краях
  print('trim: "$t"');
  print('верхній регістр: ${t.toUpperCase()}');
  print('містить Dart: ${t.contains('Dart')}');
  print('заміна: ${t.replaceAll('Dart', 'Flutter')}');
  print('розбиття: ${t.split(', ')}');
  print('substring(0, 5): ${t.substring(0, 5)}');
  print('"ab" * 3 = ${'ab' * 3}'); // повторення рядка
}

void demonstrateBooleans() {
  print('\n--- Логічні значення ---');
  bool isStudent = true;
  bool hasLaptop = false;
  int score = 75;

  print('І (&&): ${isStudent && hasLaptop}');
  print('АБО (||): ${hasLaptop || isStudent}');
  print('НЕ (!): ${!isStudent}');
  print('score >= 60: ${score >= 60}');

  // Тернарний оператор: умова ? якщо_так : якщо_ні
  String result = score >= 60 ? 'склав' : 'не склав';
  print('Результат: $result');
}

void demonstrateCollections() {
  print('\n--- Колекції ---');
  List<int> numbers = [5, 3, 8, 1];
  numbers.add(10);
  numbers.remove(3);
  numbers.sort();
  print('List: $numbers, перший: ${numbers.first}, довжина: ${numbers.length}');

  Set<String> tags = {'dart', 'flutter'};
  tags.add('dart'); // дублікат не додасться: Set зберігає лише унікальні значення
  tags.add('mobile');
  tags.add('mobile');
  print('Set: $tags, містить dart: ${tags.contains('dart')}');

  Map<String, int> ages = {'Anna': 20, 'Ivan': 22};
  ages['Olga'] = 21;
  print('Map: $ages, Ivan: ${ages['Ivan']}');
  ages.forEach((key, value) => print('  $key -> $value'));
}

// Повертає String? : або рядок, або null
String? findNickname(bool exists) => exists ? 'Sasha' : null;

void demonstrateNullSafety() {
  print('\n--- Null Safety ---');
  String? nickname = findNickname(false); // може бути null
  print('nickname: $nickname');
  print('довжина або 0: ${nickname?.length ?? 0}'); // оператори ?. та ??

  nickname ??= 'guest'; // присвоїти, лише якщо зараз null
  print('після ??=: $nickname');

  // ! означає "гарантую, що тут не null"; якщо це не так, програма впаде
  String found = findNickname(true)!;
  print('з оператором !: $found');

  late String config; // значення буде присвоєно пізніше
  config = 'loaded';
  print('late: $config');

  printUser(name: 'Anna');
  printUser(name: 'Ivan', city: 'Kyiv');
}

// required робить іменований параметр обов'язковим
void printUser({required String name, String? city}) {
  print('Користувач: $name, місто: ${city ?? 'невідоме'}');
}