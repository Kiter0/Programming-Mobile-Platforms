import 'package:flutter/material.dart';

import '../state/counter_scope.dart';

class CounterControls extends StatelessWidget {
  final int step;

  const CounterControls({super.key, required this.step});

  void _show(BuildContext context, String? error) {
    if (error == null) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(error)));
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('build: CounterControls');
    final model = CounterScope.read(context); // без підписки
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        FilledButton.icon(
          onPressed: () => _show(context, model.decrement(step)),
          icon: const Icon(Icons.remove),
          label: const Text('Мінус'),
        ),
        FilledButton.icon(
          onPressed: () => _show(context, model.increment(step)),
          icon: const Icon(Icons.add),
          label: const Text('Плюс'),
        ),
        OutlinedButton(
          onPressed: () => _show(context, model.reset()),
          child: const Text('Скинути'),
        ),
      ],
    );
  }
}