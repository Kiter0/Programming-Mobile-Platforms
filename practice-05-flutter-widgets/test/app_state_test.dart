import 'package:flutter_test/flutter_test.dart';

import 'package:practice_05_flutter_widgets/models/product.dart';
import 'package:practice_05_flutter_widgets/models/user.dart';
import 'package:practice_05_flutter_widgets/utils/app_state.dart';

void main() {
  group('AppState tests', () {
    late AppState appState;

    const product = Product(
      id: 1,
      name: 'Навушники',
      description: 'Бездротові навушники',
      price: 59.99,
      imageUrl: 'https://example.com/headphones.jpg',
    );

    const user = User(
      name: 'Олексій',
      email: 'oleksii@example.com',
      avatarUrl: 'https://example.com/avatar.jpg',
    );

    setUp(() {
      appState = AppState();
    });

    test('initial state is correct', () {
      expect(appState.currentUser, isNull);
      expect(appState.favorites, isEmpty);
      expect(appState.cartCount, 0);
      expect(appState.isFavorite(product), false);
    });

    test('setUser updates current user', () {
      appState.setUser(user);

      expect(appState.currentUser, user);
      expect(appState.currentUser?.name, 'Олексій');
      expect(appState.currentUser?.email, 'oleksii@example.com');
    });

    test('toggleFavorite adds and removes product', () {
      appState.toggleFavorite(product);

      expect(appState.isFavorite(product), true);
      expect(appState.favorites.length, 1);

      appState.toggleFavorite(product);

      expect(appState.isFavorite(product), false);
      expect(appState.favorites, isEmpty);
    });

    test('addToCart increases cart count', () {
      appState.addToCart(product);
      appState.addToCart(product);

      expect(appState.cartCount, 2);
    });

    test('removeFromCart decreases cart count', () {
      appState.addToCart(product);
      appState.addToCart(product);

      appState.removeFromCart();

      expect(appState.cartCount, 1);
    });

    test('removeFromCart does not make count negative', () {
      appState.removeFromCart();

      expect(appState.cartCount, 0);
    });

    test('clearCart resets cart count', () {
      appState.addToCart(product);
      appState.addToCart(product);
      appState.addToCart(product);

      appState.clearCart();

      expect(appState.cartCount, 0);
    });
  });
}