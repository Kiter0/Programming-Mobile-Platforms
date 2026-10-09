
import 'package:flutter/foundation.dart';

import '../services/fake_auth_api.dart';

class AuthModel extends ChangeNotifier {
  AuthModel(this._api);

  final FakeAuthApi _api;

  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _email;
  String? _userName;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get email => _email;
  String? get userName => _userName;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    if (_isLoading) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _api.login(
        email: email,
        password: password,
      );

      _email = user['email'];
      _userName = user['name'];
      _isLoggedIn = true;

      return true;
    } catch (error) {
      _errorMessage = error is Exception
          ? error.toString().replaceFirst('Exception: ', '')
          : 'Сталася невідома помилка';

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _isLoggedIn = false;
    _email = null;
    _userName = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;

    _errorMessage = null;
    notifyListeners();
  }
}