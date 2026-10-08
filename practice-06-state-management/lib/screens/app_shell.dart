import 'package:flutter/material.dart';

import '../models/history_entry.dart';
import 'counter_screen.dart';
import 'history_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _value = 0;
  List<HistoryEntry> _history = const [];
  bool _showHistory = false;

  /// Повертає текст помилки або null, якщо зміна виконана.
  String? _change(HistoryAction action, int step) {
    final next = switch (action) {
      HistoryAction.increment => _value + step,
      HistoryAction.decrement => _value - step,
      HistoryAction.reset => 0,
    };
    if (next < 0) return 'Значення не може бути меншим за 0';
    if (next == _value) return null; // «Скинути» при нулі не пишемо в історію

    setState(() {
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
    });
    return null;
  }

  void _clearHistory() => setState(() => _history = const []);
  void _openHistory() => setState(() => _showHistory = true);
  void _closeHistory() => setState(() => _showHistory = false);

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: _showHistory ? 1 : 0,
      sizing: StackFit.expand,
      children: [
        CounterScreen(
          value: _value,
          historyCount: _history.length,
          onChange: _change,
          onOpenHistory: _openHistory,
        ),
        HistoryScreen(
          history: _history,
          onClear: _clearHistory,
          onBack: _closeHistory,
        ),
      ],
    );
  }
}