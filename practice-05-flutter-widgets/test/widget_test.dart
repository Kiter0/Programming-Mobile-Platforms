// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:practice_05_flutter_widgets/models/product.dart';
import 'package:practice_05_flutter_widgets/models/user.dart';
import 'package:practice_05_flutter_widgets/utils/app_state.dart';
import 'package:practice_05_flutter_widgets/widgets/custom_button.dart';
import 'package:practice_05_flutter_widgets/widgets/product_card.dart';
import 'package:practice_05_flutter_widgets/widgets/profile_widget.dart';

void main() {
  group('CustomButton tests', () {
    testWidgets('displays button text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Тестова кнопка',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Тестова кнопка'), findsOneWidget);
    });

    testWidgets('calls onPressed callback', (WidgetTester tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Натиснути',
              onPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Натиснути'));
      await tester.pump();

      expect(pressed, isTrue);
    });
  });

  group('ProfileWidget tests', () {
    const user = User(
      name: 'Тестовий користувач',
      email: 'test@example.com',
      avatarUrl: 'https://example.com/avatar.jpg',
    );

    testWidgets('displays user information', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileWidget(
              user: user,
            ),
          ),
        ),
      );

      expect(find.text('Тестовий користувач'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('calls edit callback', (WidgetTester tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileWidget(
              user: user,
              onEditPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();

      expect(pressed, isTrue);
    });
  });

  group('ProductCard tests', () {
    final product = Product(
      id: 1,
      name: 'Test Product',
      description: 'Test description',
      price: 99.99,
      imageUrl: 'https://example.com/product.jpg',
    );

    testWidgets('displays product information', (WidgetTester tester) async {
      final appState = AppState();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(
              product: product,
              appState: appState,
            ),
          ),
        ),
      );

      expect(find.text('Test Product'), findsOneWidget);
      expect(find.text('Test description'), findsOneWidget);
      expect(find.text('\$99.99'), findsOneWidget);
      expect(find.text('До кошика'), findsOneWidget);
    });

    testWidgets('adds product to cart', (WidgetTester tester) async {
      final appState = AppState();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(
              product: product,
              appState: appState,
            ),
          ),
        ),
      );

      await tester.tap(find.text('До кошика'));
      await tester.pump();

      expect(appState.cartCount, 1);
      expect(
        find.text('Test Product додано до кошика'),
        findsOneWidget,
      );
    });

    testWidgets('toggles favorite state', (WidgetTester tester) async {
      final appState = AppState();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(
              product: product,
              appState: appState,
            ),
          ),
        ),
      );

      expect(appState.isFavorite(product), isFalse);

      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump();

      expect(appState.isFavorite(product), isTrue);
    });
  });
}