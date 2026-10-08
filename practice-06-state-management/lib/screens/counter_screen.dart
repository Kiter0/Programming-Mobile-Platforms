import 'package:flutter/material.dart';

import '../models/history_entry.dart';
import '../widgets/history_badge.dart';

typedef ChangeCallback = String? Function(HistoryAction action, int step);

class CounterScreen extends StatefulWidget {
  final int value;
  final int historyCount;
  final ChangeCallback onChange;
  final VoidCallback onOpenHistory;

  const CounterScreen({
    super.key,
    required this.value,
    required this.historyCount,
    required this.onChange,
    required this.onOpenHistory,
  });

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int _step = 1; // ефемерний стан: потрібен лише цьому екрану

  void _apply(HistoryAction action) {
    final error = widget.onChange(action, _step);
    if (error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Лічильник'),
        actions: [
          HistoryBadge(
            count: widget.historyCount,
            onPressed: widget.onOpenHistory,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${widget.value}',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 24),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1, label: Text('1')),
                ButtonSegment(value: 5, label: Text('5')),
                ButtonSegment(value: 10, label: Text('10')),
              ],
              selected: {_step},
              onSelectionChanged: (s) => setState(() => _step = s.first),
            ),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: () => _apply(HistoryAction.decrement),
                  icon: const Icon(Icons.remove),
                  label: const Text('Мінус'),
                ),
                FilledButton.icon(
                  onPressed: () => _apply(HistoryAction.increment),
                  icon: const Icon(Icons.add),
                  label: const Text('Плюс'),
                ),
                OutlinedButton(
                  onPressed: () => _apply(HistoryAction.reset),
                  child: const Text('Скинути'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}