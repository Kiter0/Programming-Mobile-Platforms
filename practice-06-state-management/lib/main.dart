import 'package:flutter/material.dart';

import 'screens/counter_screen.dart';
import 'state/counter_model.dart';
import 'state/counter_scope.dart';

void main() => runApp(const CounterApp());

class CounterApp extends StatefulWidget {
  const CounterApp({super.key});

  @override
  State<CounterApp> createState() => _CounterAppState();
}

class _CounterAppState extends State<CounterApp> {
  final CounterModel _model = CounterModel(); // створюємо один раз, не в build

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CounterScope(
      model: _model, // над MaterialApp: бачать обидва екрани
      child: MaterialApp(
        title: 'Лічильник з історією',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: const CounterScreen(),
      ),
    );
  }
}