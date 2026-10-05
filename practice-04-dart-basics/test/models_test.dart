import 'package:dart_basics_rudenko/models/person.dart';
import 'package:dart_basics_rudenko/models/student.dart';
import 'package:dart_basics_rudenko/models/university.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

void main() {
  group('Student', () {
    test('fullName поєднує імʼя та прізвище', () {
      expect(makeStudent().fullName, 'Анна Коваль');
    });

    test('role повертає Student', () {
      expect(makeStudent().role, 'Student');
    });

    test('age: день народження сьогодні вже враховано', () {
      final now = DateTime.now();
      final student = makeStudent(
        birthDate: DateTime(now.year - 20, now.month, now.day),
      );
      expect(student.age, 20);
    });

    test('age: день народження ще не настав', () {
      final now = DateTime.now();
      // день народження завтра, тож вік ще на рік менший
      final student = makeStudent(
        birthDate: DateTime(now.year - 20, now.month, now.day + 1),
      );
      expect(student.age, 19);
    });

    test('gpa без оцінок дорівнює 0', () {
      expect(makeStudent().gpa, 0);
    });

    test('gpa це середнє арифметичне оцінок', () {
      final student = makeStudent(
        courses: ['C1', 'C2'],
        grades: {'C1': 90, 'C2': 70},
      );
      expect(student.gpa, 80);
    });

    test('enrollInCourse не додає той самий курс двічі', () {
      final student = makeStudent();
      student.enrollInCourse('C1');
      student.enrollInCourse('C1');
      expect(student.enrolledCourses, ['C1']);
    });

    test('addGrade зберігає оцінку для записаного курсу', () {
      final student = makeStudent(courses: ['C1']);
      student.addGrade('C1', 85);
      expect(student.grades['C1'], 85);
    });

    test('addGrade кидає StateError, якщо студент не записаний на курс', () {
      final student = makeStudent();
      expect(() => student.addGrade('C1', 85), throwsStateError);
    });

    test('addGrade кидає ArgumentError для оцінки поза межами 0-100', () {
      final student = makeStudent(courses: ['C1']);
      expect(() => student.addGrade('C1', 101), throwsArgumentError);
      expect(() => student.addGrade('C1', -1), throwsArgumentError);
    });

    test('getPassedCourses: межа складання 60 включно', () {
      final student = makeStudent(
        courses: ['C1', 'C2', 'C3'],
        grades: {'C1': 60, 'C2': 59.9, 'C3': 95},
      );
      expect(student.getPassedCourses(), unorderedEquals(['C1', 'C3']));
    });

    test('toJson та fromJson повертають еквівалентний обʼєкт', () {
      final student = makeStudent(
        courses: ['C1'],
        grades: {'C1': 88.5},
        skills: ['dart'],
      );
      final copy = Student.fromJson(student.toJson());
      expect(copy.toJson(), equals(student.toJson()));
      expect(copy.fullName, student.fullName);
    });

    test('fromJson приймає цілі числа в оцінках і відсутні списки', () {
      final student = Student.fromJson({
        'id': 'S9',
        'firstName': 'Іван',
        'lastName': 'Мельник',
        'birthDate': '2004-11-02T00:00:00.000',
        'grades': {'C1': 85},
      });
      expect(student.grades['C1'], 85.0);
      expect(student.enrolledCourses, isEmpty);
      expect(student.skills, isEmpty);
    });

    test('toString містить імʼя та GPA', () {
      final text = makeStudent().toString();
      expect(text, contains('Анна Коваль'));
      expect(text, contains('GPA: 0.0'));
    });
  });

  group('Course', () {
    test('hasPrerequisites відрізняє курси з передумовами', () {
      expect(makeCourse('C1').hasPrerequisites(), isFalse);
      expect(
        makeCourse('C2', prerequisites: ['C1']).hasPrerequisites(),
        isTrue,
      );
    });

    test('canStudentEnroll: курс без передумов доступний', () {
      expect(makeCourse('C1').canStudentEnroll(makeStudent()), isTrue);
    });

    test('canStudentEnroll: не можна, поки передумова не складена', () {
      final course = makeCourse('C2', prerequisites: ['C1']);
      final failed = makeStudent(courses: ['C1'], grades: {'C1': 55});
      expect(course.canStudentEnroll(makeStudent()), isFalse);
      expect(course.canStudentEnroll(failed), isFalse);
    });

    test('canStudentEnroll: можна після складання передумови', () {
      final course = makeCourse('C2', prerequisites: ['C1']);
      final passed = makeStudent(courses: ['C1'], grades: {'C1': 75});
      expect(course.canStudentEnroll(passed), isTrue);
    });

    test('canStudentEnroll: не можна записатися вдруге', () {
      final student = makeStudent(courses: ['C1']);
      expect(makeCourse('C1').canStudentEnroll(student), isFalse);
    });

    test('toString показує передумови або "немає"', () {
      expect(makeCourse('C1').toString(), contains('передумови: немає'));
      expect(
        makeCourse('C2', prerequisites: ['C1']).toString(),
        contains('передумови: C1'),
      );
    });
  });

  group('Person, Professor і поліморфізм', () {
    test('Professor має role Professor', () {
      expect(makeProfessor().role, 'Professor');
    });

    test('assignCourse не дублює курси, removeCourse прибирає', () {
      final professor = makeProfessor();
      professor.assignCourse('C1');
      professor.assignCourse('C1');
      expect(professor.taughtCourses, ['C1']);
      expect(professor.teaches('C1'), isTrue);
      professor.removeCourse('C1');
      expect(professor.teaches('C1'), isFalse);
    });

    test(
      'список Person поводиться по-різному залежно від справжнього типу',
      () {
        final List<Person> people = [makeStudent(), makeProfessor()];
        expect(people.map((p) => p.role), ['Student', 'Professor']);
        expect(people.every((p) => p.fullName.isNotEmpty), isTrue);
      },
    );

    test('Professor.toString містить імʼя та кафедру', () {
      final text = makeProfessor().toString();
      expect(text, contains('Олег Петренко'));
      expect(text, contains('Інформатика'));
    });
  });

  group('University', () {
    late University university;

    // setUp виконується перед КОЖНИМ тестом: тести не залежать один від одного
    setUp(() {
      university = University(name: 'Тестовий університет');
      university.addCourse(makeCourse('C1'));
      university.addCourse(makeCourse('C2', prerequisites: ['C1']));
      university.addStudent(makeStudent(id: 'S1'));
      university.addStudent(
        makeStudent(id: 'S2', firstName: 'Іван', lastName: 'Мельник'),
      );
    });

    test('addStudent відхиляє дублікат id', () {
      expect(
        () => university.addStudent(makeStudent(id: 'S1')),
        throwsArgumentError,
      );
    });

    test('findStudentById знаходить студента або повертає null', () {
      expect(university.findStudentById('S2')?.fullName, 'Іван Мельник');
      expect(university.findStudentById('S404'), isNull);
    });

    test(
      'removeStudent видаляє студента, а для невідомого id кидає помилку',
      () {
        university.removeStudent('S1');
        expect(university.findStudentById('S1'), isNull);
        expect(() => university.removeStudent('S1'), throwsArgumentError);
      },
    );

    test('addProfessor додає викладача та відхиляє дублікат id', () {
      university.addProfessor(makeProfessor());
      expect(university.professors.length, 1);
      expect(
        () => university.addProfessor(makeProfessor()),
        throwsArgumentError,
      );
    });

    test('addCourse відхиляє дублікат id', () {
      expect(() => university.addCourse(makeCourse('C1')), throwsArgumentError);
    });

    test('findCourseById знаходить курс або повертає null', () {
      expect(university.findCourseById('C2')?.name, 'Курс C2');
      expect(university.findCourseById('C404'), isNull);
    });

    test('enrollStudent записує студента на курс', () {
      university.enrollStudent('S1', 'C1');
      expect(university.findStudentById('S1')!.enrolledCourses, ['C1']);
    });

    test('enrollStudent кидає StateError, якщо передумова не виконана', () {
      expect(() => university.enrollStudent('S1', 'C2'), throwsStateError);
    });

    test('enrollStudent дозволяє курс після складання передумови', () {
      university.enrollStudent('S1', 'C1');
      university.findStudentById('S1')!.addGrade('C1', 80);
      university.enrollStudent('S1', 'C2');
      expect(university.getStudentsByCourse('C2').map((s) => s.id), ['S1']);
    });

    test(
      'enrollStudent кидає ArgumentError для невідомого студента чи курсу',
      () {
        expect(
          () => university.enrollStudent('S404', 'C1'),
          throwsArgumentError,
        );
        expect(
          () => university.enrollStudent('S1', 'C404'),
          throwsArgumentError,
        );
      },
    );

    test('getStudentsByCourse повертає лише записаних', () {
      university.enrollStudent('S2', 'C1');
      expect(university.getStudentsByCourse('C1').map((s) => s.id), ['S2']);
      expect(university.getStudentsByCourse('C2'), isEmpty);
    });

    test('getAvailableCoursesForStudent враховує передумови', () {
      final available = university.getAvailableCoursesForStudent('S1');
      expect(available.map((c) => c.id), ['C1']);
    });

    test(
      'getAvailableCoursesForStudent кидає ArgumentError для невідомого id',
      () {
        expect(
          () => university.getAvailableCoursesForStudent('S404'),
          throwsArgumentError,
        );
      },
    );

    test('allPeople обʼєднує студентів і викладачів', () {
      university.addProfessor(makeProfessor());
      expect(university.allPeople.map((p) => p.role), [
        'Student',
        'Student',
        'Professor',
      ]);
    });

    test('generateStatistics рахує кількості, середній GPA і найкращого', () {
      university.enrollStudent('S1', 'C1');
      university.enrollStudent('S2', 'C1');
      university.findStudentById('S1')!.addGrade('C1', 90);
      university.findStudentById('S2')!.addGrade('C1', 70);

      final stats = university.generateStatistics();
      expect(stats['studentsCount'], 2);
      expect(stats['coursesCount'], 2);
      expect(stats['enrollmentsTotal'], 2);
      expect(stats['averageGpa'], 80.0);
      expect(stats['topStudent'], 'Анна Коваль');
    });

    test('generateStatistics для університету без оцінок', () {
      final stats = university.generateStatistics();
      expect(stats['averageGpa'], 0.0);
      expect(stats['topStudent'], '—');
    });
  });
}
