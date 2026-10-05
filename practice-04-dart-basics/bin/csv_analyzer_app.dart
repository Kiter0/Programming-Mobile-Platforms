import 'dart:io';

import 'package:dart_basics_rudenko/models/course.dart';
import 'package:dart_basics_rudenko/models/student.dart';
import 'package:dart_basics_rudenko/models/university.dart';
import 'package:dart_basics_rudenko/utils/csv_loader.dart';
import 'package:dart_basics_rudenko/utils/data_processor.dart';

final StringBuffer _report = StringBuffer();

/// Друкує рядок у консоль і додає його до тексту звіту
void say(String line) {
  print(line);
  _report.writeln(line);
}

void main() {
  const inputPath = 'data/students.csv';
  const outputPath = 'output/analysis_report.txt';

  final file = File(inputPath);
  if (!file.existsSync()) {
    print('Файл $inputPath не знайдено. Запускайте програму з кореня проєкту.');
    return;
  }

  //  Вхід 
  final stopwatch = Stopwatch()..start();
  final List<Student> students;
  try {
    students = CsvLoader.parseStudents(file.readAsStringSync());
  } on FormatException catch (e) {
    print('Помилка у CSV: ${e.message}');
    return;
  }
  final loadMicros = stopwatch.elapsedMicroseconds;
  stopwatch.reset();

  say('=== Аналіз даних студентів (джерело: $inputPath) ===');
  say('Завантажено студентів: ${students.length}');

  //  Обробка та вивід 
  say('\n--- Рейтинг за GPA ---');
  final ranking = DataProcessor.sortStudentsByGPA(students);
  for (var i = 0; i < ranking.length; i++) {
    say('${i + 1}. ${ranking[i]['name']}: ${ranking[i]['gpa']}');
  }

  say('\n--- Розподіл усіх оцінок ---');
  final buckets = <String, int>{
    '0-59': 0,
    '60-69': 0,
    '70-79': 0,
    '80-89': 0,
    '90-100': 0,
  };
  for (final grade in students.expand((s) => s.grades.values)) {
    final key = grade < 60
        ? '0-59'
        : grade < 70
            ? '60-69'
            : grade < 80
                ? '70-79'
                : grade < 90
                    ? '80-89'
                    : '90-100';
    buckets[key] = buckets[key]! + 1;
  }
  buckets.forEach((range, count) {
    say('${range.padLeft(6)} | ${'█' * count} $count');
  });

  say('\n--- Середні оцінки за курсами ---');
  final averages = DataProcessor.calculateAverageGradesByCourse(students);
  for (final courseId in averages.keys.toList()..sort()) {
    say('$courseId: ${averages[courseId]!.toStringAsFixed(1)}');
  }

  say('\n--- Навички ---');
  final skills = DataProcessor.getUniqueSkills(students);
  say('Унікальних навичок: ${skills.length}');
  final skillCount = <String, int>{};
  for (final student in students) {
    for (final skill in student.skills) {
      skillCount.update(skill, (count) => count + 1, ifAbsent: () => 1);
    }
  }
  final popular = skillCount.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  for (final entry in popular) {
    say('  ${entry.key}: ${entry.value} студ.');
  }

  say('\n--- Групи за роком народження ---');
  final groups = DataProcessor.groupStudentsByYear(students);
  for (final year in groups.keys.toList()..sort()) {
    say('$year: ${groups[year]!.map((s) => s.fullName).join(', ')}');
  }

  say('\n--- Студенти з несданими курсами (оцінка < 60) ---');
  final atRisk =
      students.where((s) => s.grades.values.any((g) => g < 60)).toList();
  if (atRisk.isEmpty) {
    say('Таких немає');
  } else {
    for (final student in atRisk) {
      final failed = student.grades.entries
          .where((e) => e.value < 60)
          .map((e) => '${e.key}: ${e.value}')
          .join(', ');
      say('${student.fullName} ($failed)');
    }
  }

  say('\n--- Звіт за курсами ---');
  final university = University(
    name: 'CSV-університет',
    students: students,
    courses: [
      Course(
          id: 'C1',
          name: 'Основи програмування',
          description: '',
          credits: 5,
          instructor: 'Петренко'),
      Course(
          id: 'C2',
          name: 'Мобільна розробка',
          description: '',
          credits: 6,
          instructor: 'Шевченко'),
      Course(
          id: 'C3',
          name: 'Бази даних',
          description: '',
          credits: 4,
          instructor: 'Петренко'),
      Course(
          id: 'C4',
          name: 'Flutter-практикум',
          description: '',
          credits: 5,
          instructor: 'Шевченко'),
    ],
  );
  for (final row in DataProcessor.generateReport(university)) {
    say('${row['courseId']} ${row['courseName']}: '
        'записано ${row['enrolled']}, середня ${row['averageGrade']}, '
        'склали ${row['passRate']}%');
  }

  say('\nСпільні курси всіх студентів: '
      '${DataProcessor.findCommonCourses(students)}');

  //  Продуктивність 
  final processMicros = stopwatch.elapsedMicroseconds;
  say('\n--- Продуктивність ---');
  say('Читання та розбір CSV: $loadMicros мкс');
  say('Обробка та формування звіту (з виводом): $processMicros мкс');

  // Вихід у файл 
  Directory('output').createSync(recursive: true);
  File(outputPath).writeAsStringSync(_report.toString());
  print('\nЗвіт збережено: $outputPath');
}