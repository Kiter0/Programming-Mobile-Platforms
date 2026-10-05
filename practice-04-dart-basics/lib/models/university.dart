import 'course.dart';
import 'person.dart';
import 'student.dart';

/// Викладач: інший нащадок Person зі своїми полями
class Professor extends Person {
  final String department;
  final List<String> taughtCourses;
  final double salary;

  Professor({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.birthDate,
    required this.department,
    required this.salary,
    List<String>? taughtCourses,
  }) : taughtCourses = taughtCourses ?? [];

  @override
  String get role => 'Professor';

  //  Специфічні методи викладача

  void assignCourse(String courseId) {
    if (!taughtCourses.contains(courseId)) {
      taughtCourses.add(courseId);
    }
  }

  void removeCourse(String courseId) {
    taughtCourses.remove(courseId);
  }

  bool teaches(String courseId) => taughtCourses.contains(courseId);

  @override
  String toString() {
    return 'Professor(id: $id, $fullName, кафедра: $department, '
        'курсів: ${taughtCourses.length})';
  }
}

/// Університет: зберігає студентів, викладачів і курси та керує ними
class University {
  final String name;
  final List<Student> students;
  final List<Professor> professors;
  final List<Course> courses;

  University({
    required this.name,
    List<Student>? students,
    List<Professor>? professors,
    List<Course>? courses,
  })  : students = students ?? [],
        professors = professors ?? [],
        courses = courses ?? [];

  /// Усі люди університету в одному списку (основа для поліморфізму)
  List<Person> get allPeople => [...students, ...professors];

  // CRUD: студенти 

  void addStudent(Student student) {
    if (findStudentById(student.id) != null) {
      throw ArgumentError('Студент з id ${student.id} уже існує');
    }
    students.add(student);
  }

  void removeStudent(String studentId) {
    final before = students.length;
    students.removeWhere((s) => s.id == studentId);
    if (students.length == before) {
      throw ArgumentError('Студента з id $studentId не знайдено');
    }
  }

  Student? findStudentById(String id) {
    for (final student in students) {
      if (student.id == id) {
        return student;
      }
    }
    return null;
  }

  //  Викладачі та курси 

  void addProfessor(Professor professor) {
    if (professors.any((p) => p.id == professor.id)) {
      throw ArgumentError('Викладач з id ${professor.id} уже існує');
    }
    professors.add(professor);
  }

  void addCourse(Course course) {
    if (findCourseById(course.id) != null) {
      throw ArgumentError('Курс з id ${course.id} уже існує');
    }
    courses.add(course);
  }

  Course? findCourseById(String id) {
    for (final course in courses) {
      if (course.id == id) {
        return course;
      }
    }
    return null;
  }

  //  Бізнес-логіка 

  /// Записує студента на курс, лише якщо виконані всі передумови
  void enrollStudent(String studentId, String courseId) {
    final student = findStudentById(studentId);
    final course = findCourseById(courseId);
    if (student == null) {
      throw ArgumentError('Студента з id $studentId не знайдено');
    }
    if (course == null) {
      throw ArgumentError('Курс з id $courseId не знайдено');
    }
    if (!course.canStudentEnroll(student)) {
      throw StateError(
          '${student.fullName} не може записатися на "${course.name}"');
    }
    student.enrollInCourse(courseId);
  }

  List<Student> getStudentsByCourse(String courseId) {
    return students
        .where((s) => s.enrolledCourses.contains(courseId))
        .toList();
  }

  List<Course> getAvailableCoursesForStudent(String studentId) {
    final student = findStudentById(studentId);
    if (student == null) {
      throw ArgumentError('Студента з id $studentId не знайдено');
    }
    return courses.where((c) => c.canStudentEnroll(student)).toList();
  }

  Map<String, dynamic> generateStatistics() {
    // у середньому GPA враховуємо лише студентів, які мають оцінки
    final graded = students.where((s) => s.grades.isNotEmpty).toList();
    final averageGpa = graded.isEmpty
        ? 0.0
        : graded.fold<double>(0, (sum, s) => sum + s.gpa) / graded.length;

    Student? top;
    if (graded.isNotEmpty) {
      top = graded.reduce((a, b) => a.gpa >= b.gpa ? a : b);
    }

    return {
      'university': name,
      'studentsCount': students.length,
      'professorsCount': professors.length,
      'coursesCount': courses.length,
      'enrollmentsTotal':
          students.fold<int>(0, (sum, s) => sum + s.enrolledCourses.length),
      'averageGpa': double.parse(averageGpa.toStringAsFixed(2)),
      'topStudent': top?.fullName ?? '—',
    };
  }
}