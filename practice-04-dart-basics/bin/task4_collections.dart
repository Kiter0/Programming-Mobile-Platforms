import 'package:dart_basics_rudenko/models/student.dart';
import 'package:dart_basics_rudenko/utils/data_processor.dart';

void main() {
  print('=== Колекції та обробка даних у Dart ===');
  demonstrateLists();
  demonstrateSets();
  demonstrateMaps();
  demonstrateAdvancedOperations();
}

void demonstrateLists() {
  print('\n--- List ---');
  final numbers = [12, 7, 3, 18, 5, 9, 14, 1];
  print('Початковий: $numbers');

  // [...numbers] робить копію, щоб sort не змінив оригінал
  final ascending = [...numbers]..sort();
  final descending = [...numbers]..sort((a, b) => b.compareTo(a));
  print('За зростанням: $ascending');
  print('За спаданням: $descending');

  print('Парні (DataProcessor): ${DataProcessor.filterEvenNumbers(numbers)}');
  print('where (> 8): ${numbers.where((n) => n > 8).toList()}');
  print('map (x2): ${numbers.map((n) => n * 2).toList()}');
  print('fold (сума): ${numbers.fold<int>(0, (acc, n) => acc + n)}');
  print('reduce (максимум): ${numbers.reduce((a, b) => a > b ? a : b)}');
  print(
    'take(3): ${numbers.take(3).toList()}, '
    'skip(5): ${numbers.skip(5).toList()}',
  );
  print(
    'any (> 17): ${numbers.any((n) => n > 17)}, '
    'every (> 0): ${numbers.every((n) => n > 0)}',
  );
  print('firstWhere (> 10): ${numbers.firstWhere((n) => n > 10)}');
  print('indexOf(18): ${numbers.indexOf(18)}');
  print('generate (квадрати): ${List.generate(5, (i) => i * i)}');

  final names = ['Олена', 'Іван', 'Максим', 'Анна'];
  names.sort((a, b) => a.length.compareTo(b.length)); // за довжиною імені
  print('Імена за довжиною: $names');
}

void demonstrateSets() {
  print('\n--- Set ---');
  final frontend = {'dart', 'flutter', 'html', 'css'};
  final backend = {'dart', 'sql', 'docker'};

  print('Об\'єднання: ${frontend.union(backend)}');
  print('Перетин: ${frontend.intersection(backend)}');
  print('Різниця (frontend - backend): ${frontend.difference(backend)}');
  print('Містить flutter: ${frontend.contains('flutter')}');
  print('Містить dart і css: ${frontend.containsAll({'dart', 'css'})}');

  // Найпростіший спосіб прибрати дублікати зі списку
  final withDuplicates = [1, 2, 2, 3, 3, 3];
  final unique = withDuplicates.toSet();
  print('Список: $withDuplicates, унікальні: $unique');
}

void demonstrateMaps() {
  print('\n--- Map ---');
  final stock = <String, int>{'яблука': 10, 'груші': 4, 'сливи': 0};
  stock['банани'] = 7;
  stock.update('груші', (v) => v + 6); // збільшити існуюче значення
  stock.putIfAbsent('вишні', () => 12); // додати, лише якщо ключа немає
  stock.remove('сливи');
  print('Map: $stock');
  print('Ключі: ${stock.keys.toList()}, значення: ${stock.values.toList()}');
  print('Є яблука: ${stock.containsKey('яблука')}');

  // map перетворює кожну пару, Map.fromEntries збирає нову Map із відфільтрованих
  final labels = stock.map(
    (key, value) => MapEntry(key, value >= 10 ? 'багато' : 'мало'),
  );
  print('Позначки: $labels');
  final many = Map.fromEntries(stock.entries.where((e) => e.value >= 10));
  print('Де >= 10: $many');

  // Map не вміє сортуватись, тому сортуємо список її пар
  final byValue = stock.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  print('За кількістю (спадання):');
  for (final entry in byValue) {
    print('  ${entry.key}: ${entry.value}');
  }

  print(
    'Частота слів: '
    '${DataProcessor.countWords('Dart це Dart і Flutter це Dart')}',
  );
}

/// Повертає запис (record): кращого та гіршого студента за GPA
(Student, Student) findBestAndWorst(List<Student> students) {
  final sorted = [...students]..sort((a, b) => b.gpa.compareTo(a.gpa));
  return (sorted.first, sorted.last);
}

void demonstrateAdvancedOperations() {
  print('\n--- Складні перетворення ---');
  final students = [
    Student(
      id: 'S1',
      firstName: 'Анна',
      lastName: 'Коваль',
      birthDate: DateTime(2005, 3, 14),
      skills: ['dart', 'git'],
      enrolledCourses: ['C1', 'C2'],
      grades: {'C1': 90, 'C2': 95},
    ),
    Student(
      id: 'S2',
      firstName: 'Іван',
      lastName: 'Мельник',
      birthDate: DateTime(2004, 11, 2),
      skills: ['dart', 'sql'],
      enrolledCourses: ['C1', 'C3'],
      grades: {'C1': 55, 'C3': 70},
    ),
    Student(
      id: 'S3',
      firstName: 'Олена',
      lastName: 'Бондар',
      birthDate: DateTime(2005, 7, 25),
      skills: ['flutter'],
      enrolledCourses: ['C1', 'C2'],
      grades: {'C1': 82, 'C2': 78},
    ),
    Student(
      id: 'S4',
      firstName: 'Максим',
      lastName: 'Лисенко',
      birthDate: DateTime(2003, 1, 9),
      enrolledCourses: ['C3'],
      grades: {'C3': 68},
    ),
  ];

  print('Рейтинг за GPA:');
  for (final row in DataProcessor.sortStudentsByGPA(students)) {
    print('  ${row['name']}: ${row['gpa']}');
  }

  print('Унікальні навички: ${DataProcessor.getUniqueSkills(students)}');
  print('Спільні курси всіх: ${DataProcessor.findCommonCourses(students)}');
  print(
    'Спільні курси перших трьох: '
    '${DataProcessor.findCommonCourses(students.take(3).toList())}',
  );

  print('За роком народження:');
  DataProcessor.groupStudentsByYear(students).forEach((year, group) {
    print('  $year: ${group.map((s) => s.fullName).toList()}');
  });

  print('Середні оцінки за курсами:');
  DataProcessor.calculateAverageGradesByCourse(students)
      .forEach((courseId, average) {
        print('  $courseId: ${average.toStringAsFixed(1)}');
      });

  // Вкладені колекції: Map, де значення є списком Map
  final byCourse = <String, List<Map<String, dynamic>>>{};
  for (final student in students) {
    for (final entry in student.grades.entries) {
      byCourse.putIfAbsent(entry.key, () => []).add({
        'student': student.fullName,
        'grade': entry.value,
      });
    }
  }
  print('Оцінки за курсами (від найвищої):');
  byCourse.forEach((courseId, rows) {
    rows.sort((a, b) => (b['grade'] as double).compareTo(a['grade'] as double));
    final text = rows.map((r) => '${r['student']} (${r['grade']})').join(', ');
    print('  $courseId: $text');
  });

  // Власне сортування за двома ключами: спершу за кількістю складених курсів,
  // а за рівності за прізвищем
  final custom = [...students]
    ..sort((a, b) {
      final byPassed = b.getPassedCourses().length.compareTo(
        a.getPassedCourses().length,
      );
      return byPassed != 0 ? byPassed : a.lastName.compareTo(b.lastName);
    });
  print(
    'За кількістю складених курсів: '
    '${custom.map((s) => s.lastName).toList()}',
  );

  // collection for + collection if (Dart 3)
  final strong = [
    for (final s in students)
      if (s.gpa >= 80) s.fullName,
  ];
  print('Студенти з GPA >= 80: $strong');

  // Record і деструктуризація
  final (best, worst) = findBestAndWorst(students);
  print('Найкращий: ${best.fullName}, найслабший: ${worst.fullName}');
}
