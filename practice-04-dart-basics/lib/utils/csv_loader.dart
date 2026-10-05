import '../models/student.dart';

/// Читання студентів із тексту у форматі CSV
class CsvLoader {
  /// Очікує заголовок у першому рядку та 6 колонок:
  /// id, firstName, lastName, birthDate, skills, grades
  static List<Student> parseStudents(String content) {
    final lines = content
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final students = <Student>[];
    for (final line in lines.skip(1)) {
      // skip(1) пропускає рядок із заголовком
      final parts = line.split(',');
      if (parts.length != 6) {
        throw FormatException(
          'Очікувалось 6 колонок, а знайдено ${parts.length}: $line',
        );
      }

      final grades = <String, double>{};
      if (parts[5].isNotEmpty) {
        for (final pair in parts[5].split(';')) {
          final courseAndGrade = pair.split(':');
          if (courseAndGrade.length != 2) {
            throw FormatException('Некоректна оцінка "$pair" у рядку: $line');
          }
          grades[courseAndGrade[0]] = double.parse(courseAndGrade[1]);
        }
      }

      students.add(
        Student(
          id: parts[0],
          firstName: parts[1],
          lastName: parts[2],
          birthDate: DateTime.parse(parts[3]),
          skills: parts[4].isEmpty ? [] : parts[4].split(';'),
          // записаним вважаємо студента на кожен курс, за який є оцінка
          enrolledCourses: grades.keys.toList(),
          grades: grades,
        ),
      );
    }
    return students;
  }
}
