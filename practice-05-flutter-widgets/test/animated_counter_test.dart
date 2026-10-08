import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:practice_05_flutter_widgets/widgets/animated_counter.dart';

void main() {
  testWidgets('AnimatedCounter renders correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AnimatedCounter(
            initialValue: 5,
            maxValue: 10,
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(AnimatedCounter), findsOneWidget);
    expect(find.text('Animated Counter'), findsOneWidget);
    expect(find.text('5 / 10'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('AnimatedCounter increments value', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AnimatedCounter(
            initialValue: 2,
            maxValue: 10,
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('2 / 10'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('3 / 10'), findsOneWidget);
  });

  testWidgets('AnimatedCounter decrements value', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AnimatedCounter(
            initialValue: 5,
            maxValue: 10,
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('5 / 10'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('4 / 10'), findsOneWidget);
  });

  testWidgets('AnimatedCounter does not exceed maximum value', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AnimatedCounter(
            initialValue: 10,
            maxValue: 10,
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('10 / 10'), findsOneWidget);
    expect(
      find.text('Максимальне значення досягнуто!'),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('10 / 10'), findsOneWidget);
  });
}