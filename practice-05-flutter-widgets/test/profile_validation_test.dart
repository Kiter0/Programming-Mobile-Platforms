import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:practice_05_flutter_widgets/models/user.dart';
import 'package:practice_05_flutter_widgets/screens/profile_screen.dart';
import 'package:practice_05_flutter_widgets/utils/app_state.dart';

void main() {
  group('Profile validation tests', () {
    testWidgets('rejects invalid email', (WidgetTester tester) async {
      final appState = AppState();

      appState.setUser(
        const User(
          name: 'Тестовий користувач',
          email: 'test@example.com',
          avatarUrl: '',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ProfileScreen(
            appState: appState,
          ),
        ),
      );

      await tester.pump();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      final emailField = find.byType(TextField).at(1);

      await tester.enterText(emailField, 'invalid-email');

      await tester.tap(find.text('Зберегти'));
      await tester.pump();

      expect(
        find.text('Введіть коректне ім’я та email'),
        findsOneWidget,
      );

      expect(appState.currentUser?.email, 'test@example.com');
    });

    testWidgets('accepts valid email', (WidgetTester tester) async {
      final appState = AppState();

      appState.setUser(
        const User(
          name: 'Тестовий користувач',
          email: 'test@example.com',
          avatarUrl: '',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ProfileScreen(
            appState: appState,
          ),
        ),
      );

      await tester.pump();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      final emailField = find.byType(TextField).at(1);

      await tester.enterText(emailField, 'new@example.com');

      await tester.tap(find.text('Зберегти'));
      await tester.pump();

      expect(appState.currentUser?.email, 'new@example.com');
    });
  });
}