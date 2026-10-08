import 'package:flutter/material.dart';

class HistoryBadge extends StatelessWidget {
  final int count;
  final VoidCallback? onPressed;

  const HistoryBadge({super.key, required this.count, this.onPressed});

  @override
  Widget build(BuildContext context) {
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