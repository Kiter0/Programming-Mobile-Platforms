import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/history_entry.dart';

class CounterModel extends ChangeNotifier {
  int _value = 0;
  List<HistoryEntry> _history = const [];

  int get value => _value;
  int get historyCount => _history.length;
  UnmodifiableListView<HistoryEntry> get history =>
      UnmodifiableListView(_history);

  /// Усі три методи повертають текст помилки або null.
  String? increment(int step) => _apply(HistoryAction.increment, _value + step);
  String? decrement(int step) => _apply(HistoryAction.decrement, _value - step);
  String? reset() => _apply(HistoryAction.reset, 0);

  String? _apply(HistoryAction action, int next) {
    if (next < 0) return 'Значення не може бути меншим за 0';
    if (next == _value) return null;
    _history = [
      ..._history,
      HistoryEntry(
        time: DateTime.now(),
        action: action,
        before: _value,
        after: next,
      ),
    ];
    _value = next;
    notifyListeners();
    return null;
  }

  void clearHistory() {
    if (_history.isEmpty) return;
    _history = const [];
    notifyListeners();
  }
}