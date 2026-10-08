import 'package:flutter/material.dart';

import '../state/counter_scope.dart';

class CounterDisplay extends StatelessWidget {
  const CounterDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('build: CounterDisplay');
    final value = CounterScope.of(context).value;
    return Text('$value', style: Theme.of(context).textTheme.displayLarge);
  }
}