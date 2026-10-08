import 'package:flutter/widgets.dart';

import 'counter_model.dart';

class CounterScope extends InheritedNotifier<CounterModel> {
  const CounterScope({
    super.key,
    required CounterModel model,
    required super.child,
  }) : super(notifier: model);

  /// Підписується на зміни: викликати в build().
  static CounterModel of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CounterScope>();
    assert(scope != null, 'CounterScope not found in context');
    return scope!.notifier!;
  }

  /// Без підписки: для обробників натискань (onPressed).
  static CounterModel read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<CounterScope>();
    assert(scope != null, 'CounterScope not found in context');
    return scope!.notifier!;
  }
}