import 'package:flutter/material.dart';

import '../widgets/counter_controls.dart';
import '../widgets/counter_display.dart';
import '../widgets/history_badge.dart';
import 'history_screen.dart';

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int _step = 1; // ефемерний стан залишається в setState

  @override
  Widget build(BuildContext context) {
    debugPrint('build: CounterScreen');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Лічильник'),
        actions: [
          HistoryBadge(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const HistoryScreen()),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CounterDisplay(),
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
            CounterControls(step: _step),
          ],
        ),
      ),
    );
  }
}