// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:practice_07_navigation/main.dart';

void main() {
  testWidgets('Cinema app displays the movie poster list', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CinemaApp());
    await tester.pumpAndSettle();

    expect(find.text('Кіноафіша'), findsOneWidget);
    expect(find.text('Інтерстеллар'), findsOneWidget);
    expect(find.text('Початок'), findsOneWidget);
  });
}
