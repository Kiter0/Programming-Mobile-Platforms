import 'package:flutter/material.dart';

import '../state/counter_scope.dart';

class HistoryBadge extends StatelessWidget {
  final VoidCallback? onPressed;

  const HistoryBadge({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    debugPrint('build: HistoryBadge');
    final count = CounterScope.of(context).historyCount;
    final badge = Badge(
      label: Text('$count'),
      child: const Icon(Icons.history),
    );
    if (onPressed == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: badge,
      );
    }
    return IconButton(tooltip: 'Історія', onPressed: onPressed, icon: badge);
  }
}