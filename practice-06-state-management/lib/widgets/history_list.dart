import 'package:flutter/material.dart';

import '../state/counter_scope.dart';

String _two(int n) => n.toString().padLeft(2, '0');

String formatTime(DateTime t) =>
    '${_two(t.day)}.${_two(t.month)}.${t.year} '
    '${_two(t.hour)}:${_two(t.minute)}:${_two(t.second)}';

class HistoryList extends StatelessWidget {
  const HistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('build: HistoryList');
    final history = CounterScope.of(context).history;
    if (history.isEmpty) {
      return const Center(child: Text('Історія порожня'));
    }
    return ListView.builder(
      itemCount: history.length,
      itemBuilder: (context, index) {
        final e = history[history.length - 1 - index];
        return ListTile(
          title: Text('${e.actionLabel}: ${e.before} → ${e.after}'),
          subtitle: Text(formatTime(e.time)),
        );
      },
    );
  }
}