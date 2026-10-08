import 'package:flutter_test/flutter_test.dart';

import 'package:practice_05_flutter_widgets/models/product.dart';
import 'package:practice_05_flutter_widgets/models/user.dart';
import 'package:practice_05_flutter_widgets/utils/app_state.dart';

void main() {
  group('AppState tests', () {
    const user = User(
      name: 'Тестовий користувач',
      email: 'test@example.com',
      avatarUrl: '',
    );

    final product = Product(
      id: 1,
      name: 'Test Product',
      description: 'Test description',
      price: 99.99,
      imageUrl: '',
    );

    test('sets current user', () {
      final appState = AppState();

      appState.setUser(user);

      expect(appState.currentUser, user);
    });

    test('adds product to cart', () {
      final appState = AppState();

      appState.addToCart(product);

      expect(appState.cartCount, 1);
    });

    test('removes product from cart', () {
      final appState = AppState();

      appState.addToCart(product);
      appState.removeFromCart();

      expect(appState.cartCount, 0);
    });

    test('cart count cannot become negative', () {
      final appState = AppState();

      appState.removeFromCart();

      expect(appState.cartCount, 0);
    });

    test('clears cart', () {
      final appState = AppState();

      appState.addToCart(product);
      appState.addToCart(product);

      appState.clearCart();

      expect(appState.cartCount, 0);
    });

    test('toggles favorite product', () {
      final appState = AppState();

      expect(appState.isFavorite(product), isFalse);

      appState.toggleFavorite(product);

      expect(appState.isFavorite(product), isTrue);

      appState.toggleFavorite(product);

      expect(appState.isFavorite(product), isFalse);
    });

    test('rejects product with negative price', () {
      final appState = AppState();

      final invalidProduct = Product(
        id: 2,
        name: 'Invalid Product',
        description: 'Invalid price',
        price: -10,
        imageUrl: '',
      );

      expect(
        () => appState.addToCart(invalidProduct),
        throwsA(isA<ArgumentError>()),
      );

      expect(appState.cartCount, 0);
    });
  });
}