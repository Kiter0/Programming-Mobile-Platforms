import 'package:dart_basics_rudenko/models/course.dart';
import 'package:dart_basics_rudenko/models/student.dart';

void main() {
  final student = Student(
    id: 'S1',
    firstName: 'Анна',
    lastName: 'Коваль',
    birthDate: DateTime(2005, 3, 14),
    skills: ['dart', 'git'],
  );

  final basics = Course(
    id: 'C1',
    name: 'Основи програмування',
    description: 'Вступний курс',
    credits: 5,
    instructor: 'Петренко',
  );
  final advanced = Course(
    id: 'C2',
    name: 'Мобільна розробка',
    description: 'Flutter та Dart',
    credits: 6,
    instructor: 'Шевченко',
    prerequisites: ['C1'],
  );

  print(student);
  print(basics);
  print(advanced);
  print('Може на C2 до складання C1? ${advanced.canStudentEnroll(student)}');

  student.enrollInCourse('C1');
  student.addGrade('C1', 85);
  print('Може на C2 після C1 (85)? ${advanced.canStudentEnroll(student)}');
  print('Склав: ${student.getPassedCourses()}');

  // Перевірка JSON: об'єкт -> Map -> новий об'єкт
  final copy = Student.fromJson(student.toJson());
  print('Після JSON: $copy');

  // Перевірка помилок
  try {
    student.addGrade('C2', 90); // не записаний на C2
  } on StateError catch (e) {
    print('Помилка: ${e.message}');
  }
  try {
    student.addGrade('C1', 150); // оцінка поза межами
  } on ArgumentError catch (e) {
    print('Помилка: ${e.message}');
  }
}