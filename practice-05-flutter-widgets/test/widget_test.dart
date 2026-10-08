// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:practice_05_flutter_widgets/main.dart';
import 'package:practice_05_flutter_widgets/utils/app_state.dart';

void main() {
  testWidgets('Mobile Widgets App loads', (WidgetTester tester) async {
    final appState = AppState();

    await tester.pumpWidget(
      MobileWidgetsApp(
        appState: appState,
      ),
    );

    await tester.pump();

    expect(find.text('Flutter Widgets'), findsOneWidget);
    expect(find.text('Практична робота №5'), findsOneWidget);
    expect(find.text('Custom Widgets'), findsOneWidget);
    expect(find.text('Button Components'), findsOneWidget);
    expect(find.text('Stateful Widget'), findsOneWidget);
  });
}