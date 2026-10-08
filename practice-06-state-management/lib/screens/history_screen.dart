import 'package:flutter/material.dart';

import '../models/history_entry.dart';
import '../widgets/history_badge.dart';

String _two(int n) => n.toString().padLeft(2, '0');

String formatTime(DateTime t) =>
    '${_two(t.day)}.${_two(t.month)}.${t.year} '
    '${_two(t.hour)}:${_two(t.minute)}:${_two(t.second)}';

class HistoryScreen extends StatelessWidget {
  final List<HistoryEntry> history;
  final VoidCallback onClear;
  final VoidCallback onBack;

  const HistoryScreen({
    super.key,
    required this.history,
    required this.onClear,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: onBack),
        title: const Text('Історія'),
        actions: [HistoryBadge(count: history.length)],
      ),
      body: history.isEmpty
          ? const Center(child: Text('Історія порожня'))
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                // список зберігаємо від старих до нових, читаємо з кінця
                final e = history[history.length - 1 - index];
                return ListTile(
                  title: Text('${e.actionLabel}: ${e.before} → ${e.after}'),
                  subtitle: Text(formatTime(e.time)),
                );
              },
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: OutlinedButton(
            onPressed: history.isEmpty ? null : onClear,
            child: const Text('Очистити історію'),
          ),
        ),
      ),
    );
  }
}