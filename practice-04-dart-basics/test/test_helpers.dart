import 'package:dart_basics_rudenko/models/course.dart';
import 'package:dart_basics_rudenko/models/student.dart';
import 'package:dart_basics_rudenko/models/university.dart';

/// Допоміжні функції: швидко створюють тестові об'єкти зі значеннями за замовчуванням
Student makeStudent({
  String id = 'S1',
  String firstName = 'Анна',
  String lastName = 'Коваль',
  DateTime? birthDate,
  List<String>? courses,
  Map<String, double>? grades,
  List<String>? skills,
}) {
  return Student(
    id: id,
    firstName: firstName,
    lastName: lastName,
    birthDate: birthDate ?? DateTime(2005, 3, 14),
    enrolledCourses: courses,
    grades: grades,
    skills: skills,
  );
}

Course makeCourse(String id, {List<String>? prerequisites}) {
  return Course(
    id: id,
    name: 'Курс $id',
    description: 'Опис',
    credits: 5,
    instructor: 'Петренко',
    prerequisites: prerequisites,
  );
}

Professor makeProfessor({String id = 'P1'}) {
  return Professor(
    id: id,
    firstName: 'Олег',
    lastName: 'Петренко',
    birthDate: DateTime(1978, 5, 20),
    department: 'Інформатика',
    salary: 35000,
  );
}