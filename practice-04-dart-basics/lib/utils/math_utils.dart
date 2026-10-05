/// Три реалізації чисел Фібоначчі для порівняння продуктивності
class FibonacciCalculator {
  /// Найбільше n, для якого результат ще вміщується в 64-бітний int
  static const int maxN = 92;

  /// Наївна рекурсія: кожен виклик породжує ще два, тому складність O(2^n)
  static int recursive(int n) {
    _check(n);
    if (n <= 1) {
      return n;
    }
    return recursive(n - 1) + recursive(n - 2);
  }

  /// Рекурсія з мемоїзацією: кожне значення рахується один раз, O(n)
  static int memoized(int n, [Map<int, int>? cache]) {
    _check(n);
    cache ??= {};
    if (n <= 1) {
      return n;
    }
    final cached = cache[n];
    if (cached != null) {
      return cached;
    }
    final result = memoized(n - 1, cache) + memoized(n - 2, cache);
    cache[n] = result;
    return result;
  }

  /// Цикл без рекурсії: O(n) за часом і O(1) за памʼяттю
  static int iterative(int n) {
    _check(n);
    if (n == 0) {
      return 0;
    }
    var previous = 0;
    var current = 1;
    for (var i = 2; i <= n; i++) {
      final next = previous + current;
      previous = current;
      current = next;
    }
    return current;
  }

  static void _check(int n) {
    if (n < 0) {
      throw ArgumentError('n має бути не менше 0');
    }
    if (n > maxN) {
      throw ArgumentError('n має бути не більше $maxN (інакше переповнення int)');
    }
  }
}