import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/error_interceptor.dart';
import '../core/token_storage.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService authService;
  final TokenStorage tokenStorage;

  AuthProvider({
    required this.authService,
    required this.tokenStorage,
  });

  bool _isLoading = false;
  bool _isAuthenticated = false;
  bool _rememberMe = true;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  bool get rememberMe => _rememberMe;
  String? get errorMessage => _errorMessage;

  // Зміна налаштування Remember me.
  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  // Перевірка збереженої сесії під час запуску.
  Future<void> checkAuthStatus() async {
    final preferences = await SharedPreferences.getInstance();
    final shouldRemember = preferences.getBool('remember_me') ?? false;

    if (!shouldRemember) {
      await tokenStorage.clearTokens();
      _isAuthenticated = false;
    } else {
      _isAuthenticated = await authService.isAuthenticated();
    }

    notifyListeners();
  }

  // Збереження налаштування Remember me.
  Future<void> _saveRememberPreference() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('remember_me', _rememberMe);
  }

  // Авторизація користувача.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    try {
      await authService.login(
        email: email,
        password: password,
      );

      await _saveRememberPreference();

      _isAuthenticated = true;
      _errorMessage = null;

      return true;
    } catch (error) {
      _errorMessage = _getErrorMessage(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Реєстрація користувача.
  Future<bool> register({
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    try {
      await authService.register(
        email: email,
        password: password,
      );

      await _saveRememberPreference();

      _isAuthenticated = true;
      _errorMessage = null;

      return true;
    } catch (error) {
      _errorMessage = _getErrorMessage(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Вихід з акаунта.
  Future<void> logout() async {
    _setLoading(true);

    try {
      await authService.logout();

      final preferences = await SharedPreferences.getInstance();
      await preferences.remove('remember_me');

      _isAuthenticated = false;
      _rememberMe = true;
      _errorMessage = null;
    } finally {
      _setLoading(false);
    }
  }

  // Очищення повідомлення про помилку.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _getErrorMessage(Object error) {
    if (error is DioException) {
      return ErrorInterceptor.getErrorMessage(error);
    }

    return error.toString().replaceFirst('Exception: ', '');
  }
}