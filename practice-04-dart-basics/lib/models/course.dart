import 'student.dart';

/// Навчальний курс
class Course {
  final String id;
  final String name;
  final String description;
  final int credits;
  final String instructor;
  final List<String> prerequisites; // id курсів, які треба скласти раніше

  Course({
    required this.id,
    required this.name,
    required this.description,
    required this.credits,
    required this.instructor,
    List<String>? prerequisites,
  }) : prerequisites = prerequisites ?? [];

  bool hasPrerequisites() => prerequisites.isNotEmpty;

  /// Студент може записатися, якщо ще не записаний
  /// і склав усі курси-передумови (оцінка >= 60)
  bool canStudentEnroll(Student student) {
    if (student.enrolledCourses.contains(id)) {
      return false;
    }
    final passed = student.getPassedCourses();
    return prerequisites.every((p) => passed.contains(p));
  }

  @override
  String toString() {
    final prereq = hasPrerequisites() ? prerequisites.join(', ') : 'немає';
    return 'Course($id: $name, кредитів: $credits, '
        'викладач: $instructor, передумови: $prereq)';
  }
}