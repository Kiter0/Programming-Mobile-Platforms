import 'dart:io';

import 'package:dart_basics_rudenko/utils/text_analyzer.dart';

void main() {
  print('=== Текстовий аналізатор ===');
  stdout.write('Введіть текст (Enter — взяти приклад): ');
  var text = stdin.readLineSync() ?? '';

  if (text.trim().isEmpty) {
    text =
        'Dart — це мова для Flutter. Flutter використовує Dart! '
        'Чи легко вивчити Dart? Так, легко.';
    print('Використано приклад: $text');
  }

  print('\n--- Результати ---');
  print('Символів (з пробілами): ${TextAnalyzer.countCharacters(text)}');
  print(
    'Символів (без пробілів): '
    '${TextAnalyzer.countCharacters(text, withSpaces: false)}',
  );
  print('Слів: ${TextAnalyzer.countWords(text)}');
  print('Речень: ${TextAnalyzer.countSentences(text)}');
  print('Найдовше слово: ${TextAnalyzer.longestWord(text)}');
  print(
    'Середня довжина слова: '
    '${TextAnalyzer.averageWordLength(text).toStringAsFixed(2)}',
  );

  print('\nНайчастіші слова:');
  for (final entry in TextAnalyzer.topWords(text, limit: 3)) {
    print('  ${entry.key}: ${entry.value}');
  }
}
