import 'person.dart';

/// Студент університету
class Student extends Person {
  final List<String> enrolledCourses;
  final Map<String, double> grades; // id курсу -> оцінка (0-100)
  final List<String> skills;

  Student({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.birthDate,
    List<String>? enrolledCourses,
    Map<String, double>? grades,
    List<String>? skills,
  }) : enrolledCourses = enrolledCourses ?? [],
       grades = grades ?? {},
       skills = skills ?? [];

  @override
  String get role => 'Student';
  //  Getters

  /// Середня оцінка за 100-бальною шкалою (0, якщо оцінок ще немає)
  double get gpa {
    if (grades.isEmpty) {
      return 0;
    }
    final sum = grades.values.fold<double>(0, (acc, g) => acc + g);
    return sum / grades.length;
  }

  //  Methods

  void enrollInCourse(String courseId) {
    if (!enrolledCourses.contains(courseId)) {
      enrolledCourses.add(courseId);
    }
  }

  void addGrade(String courseId, double grade) {
    if (!enrolledCourses.contains(courseId)) {
      throw StateError('Студент $fullName не записаний на курс $courseId');
    }
    if (grade < 0 || grade > 100) {
      throw ArgumentError('Оцінка має бути в межах 0-100, отримано $grade');
    }
    grades[courseId] = grade;
  }

  /// Курси, які студент склав (оцінка >= 60)
  List<String> getPassedCourses() {
    return grades.entries
        .where((entry) => entry.value >= 60)
        .map((entry) => entry.key)
        .toList();
  }

  @override
  String toString() {
    return 'Student(id: $id, $fullName, вік: $age, '
        'курсів: ${enrolledCourses.length}, GPA: ${gpa.toStringAsFixed(1)})';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'birthDate': birthDate.toIso8601String(), // DateTime -> рядок
      'enrolledCourses': enrolledCourses,
      'grades': grades,
      'skills': skills,
    };
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      enrolledCourses: List<String>.from(
        json['enrolledCourses'] as List? ?? [],
      ),
      // у JSON числа можуть бути int або double, тому через num
      grades: (json['grades'] as Map<String, dynamic>? ?? {}).map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
      skills: List<String>.from(json['skills'] as List? ?? []),
    );
  }
}
