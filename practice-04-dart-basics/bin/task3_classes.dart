import 'package:dart_basics_rudenko/models/course.dart';
import 'package:dart_basics_rudenko/models/person.dart';
import 'package:dart_basics_rudenko/models/student.dart';
import 'package:dart_basics_rudenko/models/university.dart';

void main() {
  print('=== Демонстрація системи управління університетом ===');
  runUniversityDemo();
}

void printSection(String title) => print('\n--- $title ---');

void runUniversityDemo() {
  // 1. Створюємо університет
  printSection('1. Університет');
  final university = University(name: 'Технічний університет');
  print('Створено: ${university.name}');

  // 2. Додаємо викладачів і студентів
  printSection('2. Викладачі та студенти');
  final petrenko = Professor(
    id: 'P1',
    firstName: 'Олег',
    lastName: 'Петренко',
    birthDate: DateTime(1978, 5, 20),
    department: 'Інформатика',
    salary: 35000,
  );
  final shevchenko = Professor(
    id: 'P2',
    firstName: 'Марія',
    lastName: 'Шевченко',
    birthDate: DateTime(1985, 9, 3),
    department: 'Програмна інженерія',
    salary: 38000,
  );
  university.addProfessor(petrenko);
  university.addProfessor(shevchenko);

  final anna = Student(
    id: 'S1',
    firstName: 'Анна',
    lastName: 'Коваль',
    birthDate: DateTime(2005, 3, 14),
    skills: ['dart', 'git'],
  );
  final ivan = Student(
    id: 'S2',
    firstName: 'Іван',
    lastName: 'Мельник',
    birthDate: DateTime(2004, 11, 2),
    skills: ['dart', 'sql'],
  );
  final olena = Student(
    id: 'S3',
    firstName: 'Олена',
    lastName: 'Бондар',
    birthDate: DateTime(2005, 7, 25),
    skills: ['flutter'],
  );
  final maksym = Student(
    id: 'S4',
    firstName: 'Максим',
    lastName: 'Лисенко',
    birthDate: DateTime(2003, 1, 9),
  );
  for (final student in [anna, ivan, olena, maksym]) {
    university.addStudent(student);
  }
  university.professors.forEach(print);
  university.students.forEach(print);

  // 3. Створюємо курси
  printSection('3. Курси');
  university.addCourse(
    Course(
      id: 'C1',
      name: 'Основи програмування',
      description: 'Вступний курс',
      credits: 5,
      instructor: petrenko.fullName,
    ),
  );
  university.addCourse(
    Course(
      id: 'C2',
      name: 'Мобільна розробка',
      description: 'Flutter та Dart',
      credits: 6,
      instructor: shevchenko.fullName,
      prerequisites: ['C1'],
    ),
  );
  university.addCourse(
    Course(
      id: 'C3',
      name: 'Бази даних',
      description: 'SQL та проєктування',
      credits: 4,
      instructor: petrenko.fullName,
    ),
  );
  university.addCourse(
    Course(
      id: 'C4',
      name: 'Flutter-практикум',
      description: 'Проєкт у команді',
      credits: 5,
      instructor: shevchenko.fullName,
      prerequisites: ['C2'],
    ),
  );
  petrenko
    ..assignCourse('C1')
    ..assignCourse('C3');
  shevchenko
    ..assignCourse('C2')
    ..assignCourse('C4');
  university.courses.forEach(print);

  // 4. Записуємо студентів на курси
  printSection('4. Запис на курси');
  university.enrollStudent('S1', 'C1');
  university.enrollStudent('S1', 'C3');
  university.enrollStudent('S2', 'C1');
  university.enrollStudent('S3', 'C1');
  university.enrollStudent('S4', 'C3');
  print(
    'На C1 записані: '
    '${university.getStudentsByCourse('C1').map((s) => s.fullName).toList()}',
  );

  try {
    university.enrollStudent('S2', 'C2'); // передумова C1 ще не складена
  } on StateError catch (e) {
    print('Помилка запису: ${e.message}');
  }

  // 5. Додаємо оцінки
  printSection('5. Оцінки');
  anna.addGrade('C1', 90);
  anna.addGrade('C3', 75);
  ivan.addGrade('C1', 55); // нижче 60, курс не склав
  olena.addGrade('C1', 82);
  maksym.addGrade('C3', 68);
  for (final student in university.students) {
    print(
      '${student.fullName}: ${student.grades}, '
      'склав: ${student.getPassedCourses()}',
    );
  }

  printSection('Доступні курси після оцінок');
  for (final id in ['S1', 'S2']) {
    final names = university
        .getAvailableCoursesForStudent(id)
        .map((c) => c.name)
        .toList();
    print('${university.findStudentById(id)!.fullName}: $names');
  }

  university.enrollStudent('S1', 'C2'); // тепер Анна може на C2
  anna.addGrade('C2', 95);
  print(
    'Після C2 Анні доступні: '
    '${university.getAvailableCoursesForStudent('S1').map((c) => c.name).toList()}',
  );

  // 6. Статистика
  printSection('6. Статистика');
  university.generateStatistics().forEach((key, value) {
    print('  $key: $value');
  });

  // Поліморфізм: один список, різні типи
  printSection('Поліморфізм: усі люди університету');
  for (final Person person in university.allPeople) {
    print('${person.role}: ${person.fullName}, ${person.age} р.');
    if (person is Student) {
      print('    GPA: ${person.gpa.toStringAsFixed(1)}');
    } else if (person is Professor) {
      print(
        '    кафедра: ${person.department}, курси: ${person.taughtCourses}',
      );
    }
  }

  // CRUD: видалення та помилки
  printSection('CRUD: видалення та помилки');
  university.removeStudent('S4');
  print('Після видалення S4: знайдено = ${university.findStudentById('S4')}');
  try {
    university.removeStudent('S4');
  } on ArgumentError catch (e) {
    print('Помилка: ${e.message}');
  }
  try {
    university.addStudent(anna); // такий id уже існує
  } on ArgumentError catch (e) {
    print('Помилка: ${e.message}');
  }
}
