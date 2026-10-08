import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:practice_05_flutter_widgets/main.dart';
import 'package:practice_05_flutter_widgets/models/user.dart';
import 'package:practice_05_flutter_widgets/screens/products_screen.dart';
import 'package:practice_05_flutter_widgets/screens/profile_screen.dart';
import 'package:practice_05_flutter_widgets/utils/app_state.dart';

void main() {
  testWidgets(
    'user can navigate from home to products and profile',
    (WidgetTester tester) async {
      final appState = AppState();

      appState.setUser(
        const User(
          name: 'Тестовий користувач',
          email: 'test@example.com',
          avatarUrl: '',
        ),
      );

      await tester.pumpWidget(
        MobileWidgetsApp(
          appState: appState,
        ),
      );

      await tester.pump();

      // Перевірка головного екрана.
      expect(find.text('Flutter Widgets'), findsOneWidget);
      expect(find.text('Практична робота №5'), findsOneWidget);

      // Перехід до товарів.
      await tester.tap(find.byTooltip('Товари'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(ProductsScreen), findsOneWidget);
      expect(find.text('Products'), findsOneWidget);

      // Повернення на головний екран.
      final productsContext =
          tester.element(find.byType(ProductsScreen));

      Navigator.of(productsContext).pop();

      // Чекаємо завершення анімації переходу.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Flutter Widgets'), findsOneWidget);

      // Перевіряємо, що кнопка профілю вже доступна для натискання.
      expect(find.byTooltip('Профіль'), findsOneWidget);

      // Перехід до профілю.
      await tester.tap(find.byTooltip('Профіль'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.text('Профіль'), findsOneWidget);
      expect(find.text('Тестовий користувач'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
    },
  );
}