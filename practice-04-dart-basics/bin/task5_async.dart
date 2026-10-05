import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_basics_rudenko/models/student.dart';
import 'package:dart_basics_rudenko/utils/csv_loader.dart';

void main() async {
  print('=== Асинхронне програмування в Dart ===');
  await demonstrateFutures();
  await demonstrateStreams();
  await demonstrateFileOperations();
}

//  Асинхронні функції 

/// Імітація запиту до сервера: відповідь приходить через 1 секунду
Future<String> fetchStudentData(String studentId) async {
  await Future.delayed(const Duration(seconds: 1));
  if (studentId.isEmpty) {
    throw ArgumentError('id не може бути порожнім');
  }
  if (studentId == 'S404') {
    throw Exception('Студента $studentId не знайдено на сервері');
  }
  return jsonEncode({'id': studentId, 'name': 'Студент $studentId'});
}

/// Читає JSON-файл зі списком студентів
Future<List<Student>> loadStudentsFromFile(String filename) async {
  final file = File(filename);
  if (!await file.exists()) {
    throw FileSystemException('Файл не знайдено', filename);
  }
  final content = await file.readAsString();
  final decoded = jsonDecode(content) as List<dynamic>;
  return decoded
      .map((item) => Student.fromJson(item as Map<String, dynamic>))
      .toList();
}

/// Записує студентів у JSON-файл (папку створює, якщо її немає)
Future<void> saveStudentsToFile(List<Student> students, String filename) async {
  final file = File(filename);
  await file.parent.create(recursive: true);
  const encoder = JsonEncoder.withIndent('  '); // красивий відступ у файлі
  final json = encoder.convert(students.map((s) => s.toJson()).toList());
  await file.writeAsString(json);
}

/// Генератор потоку: async* + yield віддають студентів по одному з паузою
Stream<Student> studentStream({int count = 5}) async* {
  const names = ['Анна', 'Іван', 'Олена', 'Максим', 'Дарина', 'Тарас'];
  for (var i = 0; i < count; i++) {
    await Future.delayed(const Duration(milliseconds: 300));
    yield Student(
      id: 'G${i + 1}',
      firstName: names[i % names.length],
      lastName: 'Потоковий',
      birthDate: DateTime(2003 + i % 3, 1 + i % 12, 10),
      grades: {'C1': 60.0 + i * 8},
    );
  }
}

/// Створює тестових студентів для перевірки продуктивності
List<Student> generateStudents(int count) {
  return List.generate(
    count,
    (i) => Student(
      id: 'G${i + 1}',
      firstName: 'Студент',
      lastName: '№${i + 1}',
      birthDate: DateTime(2000 + i % 6, 1 + i % 12, 1 + i % 28),
      skills: ['dart'],
      enrolledCourses: ['C1'],
      grades: {'C1': 50.0 + i % 50},
    ),
  );
}

//  Демонстрації

Future<void> demonstrateFutures() async {
  print('\n--- Future ---');
  final ids = ['S1', 'S2', 'S3'];
  final stopwatch = Stopwatch()..start();

  // Послідовно: кожен запит чекає завершення попереднього
  for (final id in ids) {
    await fetchStudentData(id);
  }
  final sequentialMs = stopwatch.elapsedMilliseconds;

  // Паралельно: усі запити стартують одразу, Future.wait чекає на всі
  stopwatch.reset();
  final results = await Future.wait(ids.map(fetchStudentData));
  final parallelMs = stopwatch.elapsedMilliseconds;

  print('Отримано ${results.length} відповіді, перша: ${results.first}');
  print('Послідовно: $sequentialMs мс, паралельно: $parallelMs мс');

  // Обробка помилок: try / on / finally
  try {
    await fetchStudentData('S404');
  } on Exception catch (e) {
    print('Помилка: $e');
  } finally {
    print('finally виконується завжди');
  }

  // Таймаут: якщо відповідь довша за 300 мс, кидається TimeoutException
  try {
    await fetchStudentData('S1').timeout(const Duration(milliseconds: 300));
  } on TimeoutException {
    print('Таймаут: сервер не відповів за 300 мс');
  }

  // Той самий Future у стилі .then
  final length = await fetchStudentData('S2').then((data) => data.length);
  print('then: довжина відповіді = $length символів');
}

Future<void> demonstrateStreams() async {
  print('\n--- Stream ---');

  // 1. await for: обробляємо елементи в міру надходження
  print('await for:');
  await for (final student in studentStream(count: 3)) {
    print('  отримано ${student.fullName}, GPA ${student.gpa}');
  }

  // 2. listen: реакція на дані, помилки та завершення потоку
  final done = Completer<void>();
  studentStream(count: 2).listen(
    (student) => print('listen: ${student.fullName}'),
    onError: (Object e) => print('listen: помилка $e'),
    onDone: () {
      print('listen: потік завершився');
      done.complete();
    },
  );
  await done.future; // чекаємо, поки спрацює onDone

  // 3. Операції над потоком: where, map, take, fold
  final strong = await studentStream(count: 6)
      .where((s) => s.gpa >= 76)
      .map((s) => s.fullName)
      .toList();
  print('GPA >= 76: $strong');

  final firstTwo = await studentStream().take(2).map((s) => s.id).toList();
  print('take(2): $firstTwo');

  final total =
      await studentStream(count: 4).fold<double>(0, (sum, s) => sum + s.gpa);
  print('Сума GPA перших чотирьох: $total');
}

Future<void> demonstrateFileOperations() async {
  print('\n--- Робота з файлами ---');
  const csvPath = 'data/students.csv';
  const jsonPath = 'output/students.json';
  final stopwatch = Stopwatch()..start();

  // 1. Читаємо CSV асинхронно
  final students = CsvLoader.parseStudents(await File(csvPath).readAsString());
  print('Прочитано з CSV: ${students.length} студентів '
      '(${stopwatch.elapsedMilliseconds} мс)');

  // 2. Зберігаємо у JSON
  stopwatch.reset();
  await saveStudentsToFile(students, jsonPath);
  print('Збережено у $jsonPath (${stopwatch.elapsedMilliseconds} мс)');

  // 3. Читаємо JSON назад і перевіряємо, що дані не втрачені
  stopwatch.reset();
  final loaded = await loadStudentsFromFile(jsonPath);
  print('Завантажено з JSON: ${loaded.length} студентів '
      '(${stopwatch.elapsedMilliseconds} мс)');
  print('Перший після завантаження: ${loaded.first}');

  // 4. Потокове читання: файл береться частинами, а не весь одразу
  final lineCount = await File(csvPath)
      .openRead()
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .length;
  print('Рядків у CSV (потоково): $lineCount');

  // 5. Обробка помилок файлів
  try {
    await loadStudentsFromFile('output/missing.json');
  } on FileSystemException catch (e) {
    print('Помилка: ${e.message}: ${e.path}');
  }

  final broken = File('output/broken.json');
  await broken.writeAsString('{ це не JSON');
  try {
    await loadStudentsFromFile(broken.path);
  } on FormatException catch (e) {
    print('Помилка формату JSON: ${e.message}');
  } finally {
    await broken.delete(); // тимчасовий файл прибираємо
  }

  // 6. Продуктивність: великий файл
  final big = generateStudents(5000);
  const bigPath = 'output/students_big.json';

  stopwatch.reset();
  await saveStudentsToFile(big, bigPath);
  final saveMs = stopwatch.elapsedMilliseconds;

  stopwatch.reset();
  final bigLoaded = await loadStudentsFromFile(bigPath);
  final loadMs = stopwatch.elapsedMilliseconds;
  print('5000 студентів: запис $saveMs мс, читання $loadMs мс '
      '(перевірка: ${bigLoaded.length})');

  // Порівняння: 5 читань файлу послідовно та паралельно
  stopwatch.reset();
  for (var i = 0; i < 5; i++) {
    await File(bigPath).readAsString();
  }
  final seqMs = stopwatch.elapsedMilliseconds;

  stopwatch.reset();
  await Future.wait(List.generate(5, (_) => File(bigPath).readAsString()));
  final parMs = stopwatch.elapsedMilliseconds;
  print('5 читань файлу: послідовно $seqMs мс, паралельно $parMs мс');

  await File(bigPath).delete(); // великий файл у репозиторій не потрібен
}