import 'package:flutter/material.dart';
import 'package:practice_11_social_app/core/error/app_exception.dart';
import 'package:practice_11_social_app/features/auth/data/repositories/auth_repository.dart';
import 'package:practice_11_social_app/features/auth/domain/entities/user_entity.dart';

/// State management авторизації (Provider)
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  UserEntity? _user;
  bool _isLoading = false;
  bool _isInitializing = true;
  String? _error;

  AuthProvider(this._authRepository);

  UserEntity? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  bool get isAuthenticated => _user != null;
  String? get error => _error;

  /// Автоматичний вхід при запуску додатка, якщо є збережений JWT
  Future<void> checkAuthStatus() async {
    _isInitializing = true;
    notifyListeners();

    try {
      _user = await _authRepository.getCurrentUser();
    } catch (_) {
      _user = null;
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  /// Вхід за логіном і паролем
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authRepository.login(username, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Примусовий або ручний вихід із сесії
  Future<void> logout() async {
    await _authRepository.logout();
    _user = null;
    _error = null;
    notifyListeners();
  }
}