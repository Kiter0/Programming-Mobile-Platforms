import 'dart:convert';
import 'dart:io';

import 'package:dart_basics_rudenko/models/university.dart';
import 'package:dart_basics_rudenko/utils/async_file_processor.dart';
import 'package:dart_basics_rudenko/utils/calculator.dart';
import 'package:dart_basics_rudenko/utils/csv_loader.dart';
import 'package:dart_basics_rudenko/utils/data_processor.dart';
import 'package:dart_basics_rudenko/utils/math_utils.dart';
import 'package:dart_basics_rudenko/utils/text_analyzer.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

void main() {
  group('Calculator', () {
    test('базові операції', () {
      expect(Calculator.add(2, 3), 5);
      expect(Calculator.subtract(2, 3), -1);
      expect(Calculator.multiply(4, 2.5), 10);
      expect(Calculator.divide(7, 2), 3.5);
      expect(Calculator.modulo(7, 2), 1);
      expect(Calculator.power(2, 10), 1024);
      expect(Calculator.squareRoot(9), 3);
    });

    test('ділення на нуль кидає ArgumentError', () {
      expect(() => Calculator.divide(1, 0), throwsArgumentError);
      expect(() => Calculator.modulo(1, 0), throwsArgumentError);
    });

    test('корінь з від\'ємного числа кидає ArgumentError', () {
      expect(() => Calculator.squareRoot(-4), throwsArgumentError);
    });

    test('calculate вибирає операцію за символом', () {
      expect(Calculator.calculate('+', 1, 2), 3);
      expect(Calculator.calculate('*', 3, 4), 12);
      expect(Calculator.calculate('sqrt', 16), 4);
    });

    test('calculate кидає ArgumentError для невідомої операції', () {
      expect(() => Calculator.calculate('?', 1, 2), throwsArgumentError);
    });
  });

  group('TextAnalyzer', () {
    test('countWords рахує слова з кирилицею', () {
      expect(TextAnalyzer.countWords('Привіт, світе! Привіт'), 3);
      expect(TextAnalyzer.countWords(''), 0);
    });

    test('wordFrequency ігнорує регістр', () {
      expect(TextAnalyzer.wordFrequency('Dart dart DART це'),
          {'dart': 3, 'це': 1});
    });

    test('countCharacters з пробілами та без', () {
      expect(TextAnalyzer.countCharacters('a b'), 3);
      expect(TextAnalyzer.countCharacters('a b', withSpaces: false), 2);
    });

    test('countSentences рахує за . ! ?', () {
      expect(TextAnalyzer.countSentences('Привіт. Як справи? Добре!'), 3);
    });

    test('longestWord та averageWordLength', () {
      expect(TextAnalyzer.longestWord('a bb ccc'), 'ccc');
      expect(TextAnalyzer.longestWord(''), '');
      expect(TextAnalyzer.averageWordLength('ab abcd'), 3.0);
      expect(TextAnalyzer.averageWordLength(''), 0);
    });

    test('topWords сортує за частотою, а за рівності за алфавітом', () {
      final top = TextAnalyzer.topWords('b a a c c', limit: 2);
      expect(top.map((e) => '${e.key}:${e.value}'), ['a:2', 'c:2']);
    });
  });

  group('DataProcessor', () {
    test('filterEvenNumbers', () {
      expect(DataProcessor.filterEvenNumbers([1, 2, 3, 4, 5, 6]), [2, 4, 6]);
      expect(DataProcessor.filterEvenNumbers([]), isEmpty);
    });

    test('countWords використовує TextAnalyzer', () {
      expect(DataProcessor.countWords('Dart це dart'), {'dart': 2, 'це': 1});
    });

    test('sortStudentsByGPA сортує за спаданням і не змінює вхідний список', () {
      final low = makeStudent(
          id: 'S1', firstName: 'Низький', courses: ['C1'], grades: {'C1': 60});
      final high = makeStudent(
          id: 'S2', firstName: 'Високий', courses: ['C1'], grades: {'C1': 95});
      final input = [low, high];

      final result = DataProcessor.sortStudentsByGPA(input);

      expect(result.map((r) => r['id']), ['S2', 'S1']);
      expect(input.first.id, 'S1'); // порядок вхідного списку не змінився
    });

    test('getUniqueSkills обʼєднує навички без дублікатів', () {
      final students = [
        makeStudent(skills: ['dart', 'git']),
        makeStudent(id: 'S2', skills: ['dart', 'sql']),
      ];
      expect(DataProcessor.getUniqueSkills(students), {'dart', 'git', 'sql'});
    });

    test('findCommonCourses повертає перетин курсів', () {
      final students = [
        makeStudent(courses: ['C1', 'C2']),
        makeStudent(id: 'S2', courses: ['C1', 'C3']),
      ];
      expect(DataProcessor.findCommonCourses(students), {'C1'});
      expect(DataProcessor.findCommonCourses([]), isEmpty);
    });

    test('groupStudentsByYear групує за роком народження', () {
      final students = [
        makeStudent(id: 'S1', birthDate: DateTime(2005, 1, 1)),
        makeStudent(id: 'S2', birthDate: DateTime(2005, 6, 1)),
        makeStudent(id: 'S3', birthDate: DateTime(2004, 1, 1)),
      ];
      final groups = DataProcessor.groupStudentsByYear(students);
      expect(groups.keys, unorderedEquals(['2005', '2004']));
      expect(groups['2005']!.length, 2);
      expect(groups['2004']!.length, 1);
    });

    test('calculateAverageGradesByCourse', () {
      final students = [
        makeStudent(courses: ['C1', 'C2'], grades: {'C1': 90, 'C2': 80}),
        makeStudent(id: 'S2', courses: ['C1'], grades: {'C1': 70}),
      ];
      final averages = DataProcessor.calculateAverageGradesByCourse(students);
      expect(averages['C1'], 80);
      expect(averages['C2'], 80);
    });

    test('generateReport рахує записаних, середню оцінку та % складення', () {
      final university = University(
        name: 'Тест',
        courses: [makeCourse('C1')],
        students: [
          makeStudent(id: 'S1', courses: ['C1'], grades: {'C1': 90}),
          makeStudent(id: 'S2', courses: ['C1'], grades: {'C1': 50}),
        ],
      );
      final row = DataProcessor.generateReport(university).single;
      expect(row['courseId'], 'C1');
      expect(row['enrolled'], 2);
      expect(row['graded'], 2);
      expect(row['averageGrade'], 70.0);
      expect(row['passRate'], 50.0);
    });
  });

  group('CsvLoader', () {
    const csv = '''
id,firstName,lastName,birthDate,skills,grades
S1,Анна,Коваль,2005-03-14,dart;git,C1:90;C2:95
S2,Іван,Мельник,2004-11-02,,C1:55
''';

    test('parseStudents читає студентів, навички та оцінки', () {
      final students = CsvLoader.parseStudents(csv);
      expect(students.length, 2);
      expect(students.first.skills, ['dart', 'git']);
      expect(students.first.grades, {'C1': 90.0, 'C2': 95.0});
      expect(students.first.enrolledCourses, ['C1', 'C2']);
      expect(students.last.skills, isEmpty);
    });

    test('рядок з іншою кількістю колонок кидає FormatException', () {
      const broken = 'header\nS1,Анна,Коваль,2005-03-14,dart';
      expect(() => CsvLoader.parseStudents(broken), throwsFormatException);
    });

    test('некоректна оцінка кидає FormatException', () {
      const broken = 'header\nS1,Анна,Коваль,2005-03-14,dart,C1-90';
      expect(() => CsvLoader.parseStudents(broken), throwsFormatException);
    });
  });

    group('FibonacciCalculator', () {
    const expected = [0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55];

    test('усі три реалізації дають правильні перші числа', () {
      for (var n = 0; n < expected.length; n++) {
        expect(FibonacciCalculator.recursive(n), expected[n]);
        expect(FibonacciCalculator.memoized(n), expected[n]);
        expect(FibonacciCalculator.iterative(n), expected[n]);
      }
    });

    test('memoized та iterative збігаються для великого n', () {
      expect(FibonacciCalculator.memoized(50), 12586269025);
      expect(FibonacciCalculator.iterative(50), 12586269025);
    });

    test('від\'ємне або надто велике n кидає ArgumentError', () {
      expect(() => FibonacciCalculator.recursive(-1), throwsArgumentError);
      expect(() => FibonacciCalculator.memoized(-1), throwsArgumentError);
      expect(() => FibonacciCalculator.iterative(93), throwsArgumentError);
    });
  });

  group('AsyncFileProcessor', () {
    // нульова затримка, щоб тести виконувались миттєво
    final processor = AsyncFileProcessor(processingDelay: Duration.zero);

    test('processStudent визначає категорію за GPA', () async {
      final excellent = await processor
          .processStudent(makeStudent(courses: ['C1'], grades: {'C1': 95}));
      expect(excellent['level'], 'відмінно');
      expect(excellent['passedCourses'], 1);
      expect(excellent['failedCourses'], 0);

      final risk = await processor.processStudent(
          makeStudent(id: 'S2', courses: ['C1'], grades: {'C1': 40}));
      expect(risk['level'], 'ризик відрахування');
      expect(risk['failedCourses'], 1);

      final none = await processor.processStudent(makeStudent(id: 'S3'));
      expect(none['level'], 'немає оцінок');
    });

    test('три способи обробки дають однаковий результат у тому ж порядку',
        () async {
      final students = List.generate(
        7,
        (i) => makeStudent(
            id: 'S$i', courses: ['C1'], grades: {'C1': 50.0 + i * 8}),
      );
      final sequential = await processor.processSequential(students);
      final batches = await processor.processInBatches(students, batchSize: 3);
      final parallel = await processor.processParallel(students);

      expect(batches, equals(sequential));
      expect(parallel, equals(sequential));
    });

    test('readStudents читає JSON-файл', () async {
      final dir = Directory.systemTemp.createTempSync('dart_basics_test_');
      addTearDown(() => dir.deleteSync(recursive: true));
      final path = '${dir.path}/students.json';

      final students = [makeStudent(courses: ['C1'], grades: {'C1': 88})];
      await File(path)
          .writeAsString(jsonEncode(students.map((s) => s.toJson()).toList()));

      final loaded = await processor.readStudents(path);
      expect(loaded.single.toJson(), students.single.toJson());
    });

    test('writeResults створює вкладені папки та записує JSON', () async {
      final dir = Directory.systemTemp.createTempSync('dart_basics_test_');
      addTearDown(() => dir.deleteSync(recursive: true));
      final path = '${dir.path}/nested/out.json';

      await processor.writeResults([
        {'id': 'S1', 'level': 'добре'}
      ], path);

      final decoded = jsonDecode(await File(path).readAsString()) as List;
      expect(decoded.single['id'], 'S1');
    });

    test('readStudents для відсутнього файлу кидає FileSystemException', () {
      expect(processor.readStudents('no/such/file.json'),
          throwsA(isA<FileSystemException>()));
    });
  });
}