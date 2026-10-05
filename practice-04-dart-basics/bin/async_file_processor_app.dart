import 'dart:io';

import 'package:dart_basics_rudenko/utils/async_file_processor.dart';

Future<void> main() async {
  const inputPath = 'output/students.json';
  const outputPath = 'output/processed_students.json';
  final processor = AsyncFileProcessor();

  print('=== Асинхронний обробник файлів ===');

  try {
    // 1. Read
    final stopwatch = Stopwatch()..start();
    final students = await processor.readStudents(inputPath);
    print(
      '1. Прочитано ${students.length} студентів з $inputPath '
      '(${stopwatch.elapsedMilliseconds} мс)',
    );

    // 2. Process: порівнюємо три способи
    print(
      '\n2. Обробка (затримка ${processor.processingDelay.inMilliseconds} мс '
      'на студента):',
    );

    stopwatch.reset();
    await processor.processSequential(students);
    final sequentialMs = stopwatch.elapsedMilliseconds;
    print('   послідовно:        $sequentialMs мс');

    stopwatch.reset();
    await processor.processInBatches(students, batchSize: 4);
    final batchMs = stopwatch.elapsedMilliseconds;
    print('   пакетами по 4:     $batchMs мс');

    stopwatch.reset();
    final results = await processor.processParallel(students);
    final parallelMs = stopwatch.elapsedMilliseconds;
    print('   паралельно:        $parallelMs мс');

    final speedup = sequentialMs / parallelMs;
    print('   прискорення паралельної обробки: x${speedup.toStringAsFixed(1)}');

    // 3. Write
    stopwatch.reset();
    await processor.writeResults(results, outputPath);
    print(
      '\n3. Результати записано в $outputPath '
      '(${stopwatch.elapsedMilliseconds} мс)',
    );

    // Підсумок за категоріями
    final byLevel = <String, int>{};
    for (final row in results) {
      byLevel.update(
        row['level'] as String,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }
    print('\nПідсумок за категоріями:');
    byLevel.forEach((level, count) => print('  $level: $count'));
  } on FileSystemException catch (e) {
    print('Помилка файлу: ${e.message}: ${e.path}');
    print('Спочатку запустіть: dart run bin/task5_async.dart');
    exit(1);
  } on FormatException catch (e) {
    print('Файл пошкоджений, некоректний JSON: ${e.message}');
    exit(1);
  }
}
