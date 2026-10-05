import 'dart:io';

import 'package:dart_basics_rudenko/models/student.dart';
import 'package:dart_basics_rudenko/utils/math_utils.dart';

final StringBuffer _report = StringBuffer();

/// Накопичує результати, щоб вони не оптимізувались компілятором "в нуль"
int sink = 0;

void say(String line) {
  print(line);
  _report.writeln(line);
}

/// Середній час виконання в мікросекундах
double measure(void Function() action, {int runs = 5}) {
  action(); // прогрів: перший запуск повільніший
  final stopwatch = Stopwatch()..start();
  for (var i = 0; i < runs; i++) {
    action();
  }
  return stopwatch.elapsedMicroseconds / runs;
}

String formatTime(double micros) {
  return micros >= 1000
      ? '${(micros / 1000).toStringAsFixed(2)} мс'
      : '${micros.toStringAsFixed(1)} мкс';
}

void main() {
  say('=== Бенчмарки продуктивності ===');
  say('Час залежить від комп\'ютера. Режим: dart run (JIT).');

  //  1. Фібоначчі
  say('\n--- 1. fibonacci(30): рекурсія, мемоїзація, цикл ---');
  const n = 30;
  final values = {
    FibonacciCalculator.recursive(n),
    FibonacciCalculator.memoized(n),
    FibonacciCalculator.iterative(n),
  };
  say(
    'Результати збігаються: ${values.length == 1} (значення ${values.first})',
  );

  final recursiveTime = measure(
    () => sink += FibonacciCalculator.recursive(n),
    runs: 3,
  );
  final memoTime = measure(
    () => sink += FibonacciCalculator.memoized(n),
    runs: 1000,
  );
  final iterTime = measure(
    () => sink += FibonacciCalculator.iterative(n),
    runs: 1000,
  );
  say('Наївна рекурсія: ${formatTime(recursiveTime)}');
  say(
    'Мемоїзація:      ${formatTime(memoTime)} '
    '(швидше в ${(recursiveTime / memoTime).toStringAsFixed(0)} разів)',
  );
  say(
    'Цикл:            ${formatTime(iterTime)} '
    '(швидше в ${(recursiveTime / iterTime).toStringAsFixed(0)} разів)',
  );

  //  2. Пошук студента \
  say('\n--- 2. Пошук студента за id серед 5000: List чи Map ---');
  final students = List.generate(
    5000,
    (i) => Student(
      id: 'S$i',
      firstName: 'Студент',
      lastName: '№$i',
      birthDate: DateTime(2004, 1, 1),
    ),
  );
  final idsToFind = List.generate(500, (i) => 'S${i * 10}');

  final listTime = measure(() {
    for (final id in idsToFind) {
      sink += students.firstWhere((s) => s.id == id).id.length;
    }
  });
  final buildTime = measure(() {
    final index = {for (final s in students) s.id: s};
    sink += index.length;
  });
  final index = {for (final s in students) s.id: s};
  final lookupTime = measure(() {
    for (final id in idsToFind) {
      sink += index[id]!.id.length;
    }
  });
  say('List.firstWhere, 500 пошуків: ${formatTime(listTime)}');
  say('Map: побудова індексу (1 раз): ${formatTime(buildTime)}');
  say(
    'Map: 500 пошуків:              ${formatTime(lookupTime)} '
    '(швидше в ${(listTime / lookupTime).toStringAsFixed(0)} разів)',
  );
  say(
    'Висновок: індекс окупається, коли пошуків багато. Для одного '
    'пошуку лінійний прохід простіший і дешевший.',
  );

  //  3. Рядки
  say('\n--- 3. Склеювання 20000 рядків: += чи StringBuffer ---');
  final plusTime = measure(() {
    var text = '';
    for (var i = 0; i < 20000; i++) {
      text += 'рядок $i\n';
    }
    sink += text.length;
  });
  final bufferTime = measure(() {
    final buffer = StringBuffer();
    for (var i = 0; i < 20000; i++) {
      buffer.write('рядок $i\n');
    }
    sink += buffer.length;
  });
  say('Оператор +=:   ${formatTime(plusTime)}');
  say(
    'StringBuffer:  ${formatTime(bufferTime)} '
    '(швидше в ${(plusTime / bufferTime).toStringAsFixed(1)} разів)',
  );

  Directory('docs').createSync(recursive: true);
  File('docs/benchmark_report.txt').writeAsStringSync(_report.toString());
  print('\nЗвіт збережено: docs/benchmark_report.txt');
}
