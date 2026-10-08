import 'package:flutter/material.dart';

import '../state/counter_scope.dart';
import '../widgets/history_badge.dart';
import '../widgets/history_list.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('build: HistoryScreen');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Історія'),
        actions: const [HistoryBadge()],
      ),
      body: const HistoryList(),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: OutlinedButton(
            onPressed: () => CounterScope.read(context).clearHistory(),
            child: const Text('Очистити історію'),
          ),
        ),
      ),
    );
  }
}