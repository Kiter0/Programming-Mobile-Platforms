
import 'package:flutter/foundation.dart';

import '../services/fake_auth_api.dart';

class ProfileModel extends ChangeNotifier {
  ProfileModel(this._api);

  final FakeAuthApi _api;

  String _name = '';
  String _email = '';

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  String get name => _name;
  String get email => _email;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<void> loadProfile({
    required String name,
    required String email,
  }) async {
    _name = name;
    _email = email;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
  }) async {
    if (_isLoading) return false;

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final updatedUser = await _api.updateProfile(
        name: name,
        email: email,
      );

      _name = updatedUser['name']!;
      _email = updatedUser['email']!;
      _successMessage = 'Профіль успішно оновлено';

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

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}