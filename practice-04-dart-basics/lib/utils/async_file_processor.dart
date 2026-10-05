import 'dart:convert';
import 'dart:io';

import '../models/student.dart';

/// Асинхронний обробник файлів: читання JSON -> обробка -> запис результатів
class AsyncFileProcessor {
  /// Імітація "важкої" обробки одного студента 
  final Duration processingDelay;

  AsyncFileProcessor({
    this.processingDelay = const Duration(milliseconds: 100),
  });

  //  Read 

  Future<List<Student>> readStudents(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw FileSystemException('Файл не знайдено', path);
    }
    final decoded = jsonDecode(await file.readAsString()) as List<dynamic>;
    return decoded
        .map((item) => Student.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  //  Process

  Future<Map<String, dynamic>> processStudent(Student student) async {
    await Future.delayed(processingDelay);

    final total = student.grades.length;
    final passed = student.getPassedCourses().length;
    final level = student.grades.isEmpty
        ? 'немає оцінок'
        : switch (student.gpa) {
            >= 90 => 'відмінно',
            >= 75 => 'добре',
            >= 60 => 'задовільно',
            _ => 'ризик відрахування',
          };

    return {
      'id': student.id,
      'name': student.fullName,
      'gpa': double.parse(student.gpa.toStringAsFixed(2)),
      'passedCourses': passed,
      'failedCourses': total - passed,
      'level': level,
    };
  }

  /// По одному: кожен студент чекає завершення попереднього
  Future<List<Map<String, dynamic>>> processSequential(
      List<Student> students) async {
    final results = <Map<String, dynamic>>[];
    for (final student in students) {
      results.add(await processStudent(student));
    }
    return results;
  }

  /// Усі одночасно: Future.wait запускає всі обробки разом
  Future<List<Map<String, dynamic>>> processParallel(List<Student> students) {
    return Future.wait(students.map(processStudent));
  }

  /// Пакетами: у кожному пакеті паралельно, але пакети йдуть по черзі.
  /// Так обмежують навантаження, коли записів тисячі.
  Future<List<Map<String, dynamic>>> processInBatches(
    List<Student> students, {
    int batchSize = 4,
  }) async {
    final results = <Map<String, dynamic>>[];
    for (var i = 0; i < students.length; i += batchSize) {
      final batch = students.skip(i).take(batchSize);
      results.addAll(await Future.wait(batch.map(processStudent)));
    }
    return results;
  }

  //  Write 

  Future<void> writeResults(
      List<Map<String, dynamic>> results, String path) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    const encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString(encoder.convert(results));
  }
}