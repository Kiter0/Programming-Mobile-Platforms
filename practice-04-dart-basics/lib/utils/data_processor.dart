import '../models/student.dart';
import '../models/university.dart';
import 'text_analyzer.dart';

/// Обробка колекцій: List, Set, Map та складні звіти
class DataProcessor {
  //  Робота зі списками (List)

  static List<int> filterEvenNumbers(List<int> numbers) {
    return numbers.where((n) => n.isEven).toList();
  }

  static Map<String, int> countWords(String text) {
    return TextAnalyzer.wordFrequency(text);
  }

  /// Студенти за спаданням GPA (вхідний список не змінюється)
  static List<Map<String, dynamic>> sortStudentsByGPA(List<Student> students) {
    final sorted = List<Student>.from(students)
      ..sort((a, b) => b.gpa.compareTo(a.gpa));
    return sorted
        .map((s) => {
              'id': s.id,
              'name': s.fullName,
              'gpa': double.parse(s.gpa.toStringAsFixed(2)),
            })
        .toList();
  }

  //  Робота з множинами (Set) 

  /// Усі різні навички всіх студентів
  static Set<String> getUniqueSkills(List<Student> students) {
    return students.expand((s) => s.skills).toSet();
  }

  /// Курси, на які записані ВСІ студенти зі списку (перетин множин)
  static Set<String> findCommonCourses(List<Student> students) {
    if (students.isEmpty) {
      return {};
    }
    var common = students.first.enrolledCourses.toSet();
    for (final student in students.skip(1)) {
      common = common.intersection(student.enrolledCourses.toSet());
    }
    return common;
  }

  //  Робота з відображеннями (Map) 

  /// Групування за роком народження
  static Map<String, List<Student>> groupStudentsByYear(
      List<Student> students) {
    final groups = <String, List<Student>>{};
    for (final student in students) {
      final year = student.birthDate.year.toString();
      groups.putIfAbsent(year, () => []).add(student);
    }
    return groups;
  }

  /// Середня оцінка за кожним курсом
  static Map<String, double> calculateAverageGradesByCourse(
      List<Student> students) {
    final sums = <String, double>{};
    final counts = <String, int>{};
    for (final student in students) {
      for (final entry in student.grades.entries) {
        sums.update(entry.key, (sum) => sum + entry.value,
            ifAbsent: () => entry.value);
        counts.update(entry.key, (count) => count + 1, ifAbsent: () => 1);
      }
    }
    return sums.map((courseId, sum) => MapEntry(courseId, sum / counts[courseId]!));
  }

  //  Складна обробка 

  /// Звіт по кожному курсу університету, найкращі середні оцінки зверху
  static List<Map<String, dynamic>> generateReport(University university) {
    final report = <Map<String, dynamic>>[];

    for (final course in university.courses) {
      final enrolled = university.getStudentsByCourse(course.id);
      final grades = enrolled
          .where((s) => s.grades.containsKey(course.id))
          .map((s) => s.grades[course.id]!)
          .toList();

      final passed = grades.where((g) => g >= 60).length;
      final average = grades.isEmpty
          ? 0.0
          : grades.fold<double>(0, (sum, g) => sum + g) / grades.length;
      final passRate = grades.isEmpty ? 0.0 : passed / grades.length * 100;

      report.add({
        'courseId': course.id,
        'courseName': course.name,
        'instructor': course.instructor,
        'enrolled': enrolled.length,
        'graded': grades.length,
        'averageGrade': double.parse(average.toStringAsFixed(1)),
        'passRate': double.parse(passRate.toStringAsFixed(1)),
      });
    }

    report.sort((a, b) =>
        (b['averageGrade'] as double).compareTo(a['averageGrade'] as double));
    return report;
  }
}