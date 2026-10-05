/// Аналіз тексту: слова, символи, речення, частота слів
class TextAnalyzer {
  // \w у Dart не розпізнає кирилицю, тому використовуємо \p{L} (будь-яка літера Unicode).
  // Апостроф дозволений, щоб слова на кшталт "м'який" не розпадалися.
  static final RegExp _wordPattern = RegExp(r"[\p{L}\p{N}'’]+", unicode: true);

  static List<String> extractWords(String text) {
    return _wordPattern
        .allMatches(text.toLowerCase())
        .map((match) => match.group(0)!)
        .toList();
  }

  static int countWords(String text) => extractWords(text).length;

  static int countCharacters(String text, {bool withSpaces = true}) {
    return withSpaces ? text.length : text.replaceAll(RegExp(r'\s'), '').length;
  }

  static int countSentences(String text) {
    return text
        .split(RegExp(r'[.!?]+'))
        .where((part) => part.trim().isNotEmpty)
        .length;
  }

  static Map<String, int> wordFrequency(String text) {
    final frequency = <String, int>{};
    for (final word in extractWords(text)) {
      // update збільшує лічильник, а якщо слова ще немає, ставить 1
      frequency.update(word, (count) => count + 1, ifAbsent: () => 1);
    }
    return frequency;
  }

  static List<MapEntry<String, int>> topWords(String text, {int limit = 3}) {
    final entries = wordFrequency(text).entries.toList()
      ..sort((a, b) {
        // спершу за частотою (спадання), при рівності за алфавітом
        if (a.value != b.value) {
          return b.value.compareTo(a.value);
        }
        return a.key.compareTo(b.key);
      });
    return entries.take(limit).toList();
  }

  static String longestWord(String text) {
    final words = extractWords(text);
    if (words.isEmpty) {
      return '';
    }
    return words.reduce((a, b) => b.length > a.length ? b : a);
  }

  static double averageWordLength(String text) {
    final words = extractWords(text);
    if (words.isEmpty) {
      return 0;
    }
    final totalLength = words.fold<int>(0, (sum, w) => sum + w.length);
    return totalLength / words.length;
  }
}