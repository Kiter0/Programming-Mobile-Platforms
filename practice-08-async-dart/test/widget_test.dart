// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practice_08_async_dart/main.dart';

void main() {
  testWidgets('Менеджер завантажень обробляє початкове завантаження', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Менеджер завантажень'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Просуваємо тестовий час, щоб завершився запит на 1,2 секунди.
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump();

    // Сервіс може успішно повернути файли або згенерувати помилку.
    final hasFiles = find.text('Завантажити всі').evaluate().isNotEmpty;
    final hasRetryButton = find.text('Спробувати ще раз').evaluate().isNotEmpty;

    expect(
      hasFiles || hasRetryButton,
      isTrue,
      reason: 'Має відобразитися список файлів або кнопка повторної спроби.',
    );

    // Даємо віджету обробити завершення асинхронних операцій.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
