import 'dart:io';

/// Читає coverage/lcov.info, друкує покриття по файлах і зберігає звіт у docs/
void main() {
  final file = File('coverage/lcov.info');
  if (!file.existsSync()) {
    print('Немає coverage/lcov.info. Спочатку виконайте:');
    print('  dart pub global run coverage:test_with_coverage');
    exit(1);
  }

  final report = StringBuffer('=== Звіт про покриття коду тестами ===\n');
  String? current;
  var found = 0;
  var hit = 0;
  var totalFound = 0;
  var totalHit = 0;

  for (final line in file.readAsLinesSync()) {
    if (line.startsWith('SF:')) {
      current = line.substring(3); // шлях до файлу
    } else if (line.startsWith('LF:')) {
      found = int.parse(line.substring(3)); // усього рядків коду
    } else if (line.startsWith('LH:')) {
      hit = int.parse(line.substring(3)); // рядків, виконаних тестами
    } else if (line == 'end_of_record' && current != null) {
      final percent = found == 0 ? 100.0 : hit / found * 100;
      report.writeln('${percent.toStringAsFixed(1).padLeft(6)}%  '
          '($hit/$found)  $current');
      totalFound += found;
      totalHit += hit;
    }
  }

  final totalPercent = totalFound == 0 ? 100.0 : totalHit / totalFound * 100;
  report.writeln('-' * 50);
  report.writeln('ЗАГАЛОМ: ${totalPercent.toStringAsFixed(1)}% '
      '($totalHit з $totalFound рядків)');

  print(report);
  Directory('docs').createSync(recursive: true);
  File('docs/coverage_report.txt').writeAsStringSync(report.toString());
  print('Звіт збережено: docs/coverage_report.txt');
}