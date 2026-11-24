import 'package:dio/dio.dart';

import '../core/token_storage.dart';

class AuthService {
  final Dio dio;
  final TokenStorage tokenStorage;

  AuthService({
    required this.dio,
    required this.tokenStorage,
  });

  // Реєстрація користувача.
  Future<void> register({
    required String email,
    required String password,
  }) async {
    final response = await dio.post(
      '/register',
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = response.data as Map<String, dynamic>;

    final accessToken = data['token'] ?? data['access_token'];
    final refreshToken = data['refreshToken'] ??
        data['refresh_token'] ??
        accessToken;

    if (accessToken == null) {
      throw Exception('Сервер не повернув токен авторизації');
    }

    await tokenStorage.saveTokens(
      accessToken: accessToken.toString(),
      refreshToken: refreshToken.toString(),
    );
  }

  // Авторизація користувача.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    final response = await dio.post(
      '/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = response.data as Map<String, dynamic>;

    final accessToken = data['token'] ?? data['access_token'];
    final refreshToken = data['refreshToken'] ??
        data['refresh_token'] ??
        accessToken;

    if (accessToken == null) {
      throw Exception('Сервер не повернув токен авторизації');
    }

    await tokenStorage.saveTokens(
      accessToken: accessToken.toString(),
      refreshToken: refreshToken.toString(),
    );
  }

  // Вихід з акаунта.
  Future<void> logout() async {
    await tokenStorage.clearTokens();
  }

  // Перевірка наявності збереженої авторизації.
  Future<bool> isAuthenticated() async {
    return tokenStorage.hasTokens();
  }
}
