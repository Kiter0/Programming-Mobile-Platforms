import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../models/user.dart';

class AppState extends ChangeNotifier {
  User? _currentUser;
  final List<Product> _favorites = [];
  int _cartCount = 0;

  User? get currentUser => _currentUser;

  List<Product> get favorites => List.unmodifiable(_favorites);

  int get cartCount => _cartCount;

  bool isFavorite(Product product) {
    return _favorites.any(
      (item) => item.id == product.id,
    );
  }

  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void toggleFavorite(Product product) {
    final index = _favorites.indexWhere(
      (item) => item.id == product.id,
    );

    if (index >= 0) {
      _favorites.removeAt(index);
    } else {
      _favorites.add(product);
    }

    notifyListeners();
  }

  void addToCart(Product product) {
  if (product.price < 0) {
    throw ArgumentError(
      'Ціна товару не може бути від’ємною',
    );
  }

  _cartCount++;
  notifyListeners();
}

  void removeFromCart() {
    if (_cartCount > 0) {
      _cartCount--;
      notifyListeners();
    }
  }

  void clearCart() {
    _cartCount = 0;
    notifyListeners();
  }
}