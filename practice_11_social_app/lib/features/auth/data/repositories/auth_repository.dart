import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:practice_11_social_app/core/error/app_exception.dart';
import 'package:practice_11_social_app/core/network/api_endpoints.dart';
import 'package:practice_11_social_app/core/storage/cache_service.dart';
import 'package:practice_11_social_app/features/auth/data/models/user_model.dart';

/// Репозиторій авторизації: вхід, отримання профілю (/auth/me) та робота з JWT
class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;
  final CacheService _cacheService;

  AuthRepository({
    required Dio dio,
    required FlutterSecureStorage storage,
    required CacheService cacheService,
  })  : _dio = dio,
        _storage = storage,
        _cacheService = cacheService;

  /// Авторизація через POST /auth/login та збереження JWT у SecureStorage
  Future<UserModel> login(String username, String password) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {
          'username': username.trim(),
          'password': password.trim(),
          'expiresInMins': 60,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final accessToken = data['accessToken'] as String?;
      final refreshToken = data['refreshToken'] as String?;

      if (accessToken != null) {
        await _storage.write(key: 'access_token', value: accessToken);
      }
      if (refreshToken != null) {
        await _storage.write(key: 'refresh_token', value: refreshToken);
      }

      final user = UserModel.fromJson(data);
      await _cacheService.cache('current_user', user.toJson());
      return user;
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  /// Отримання поточного користувача через GET /auth/me (із кешем для offline)
  Future<UserModel?> getCurrentUser() async {
    final token = await _storage.read(key: 'access_token');
    if (token == null || token.isEmpty) return null;

    if (await _cacheService.isOnline()) {
      try {
        final response = await _dio.get(ApiEndpoints.me);
        final user = UserModel.fromJson(response.data as Map<String, dynamic>);
        await _cacheService.cache('current_user', user.toJson());
        return user;
      } on DioException catch (e) {
        final cached = await _cacheService.getCached('current_user');
        if (cached != null) {
          return UserModel.fromJson(cached as Map<String, dynamic>);
        }
        throw AppException.fromDioException(e);
      }
    } else {
      final cached = await _cacheService.getCached('current_user');
      if (cached != null) {
        return UserModel.fromJson(cached as Map<String, dynamic>);
      }
      return null;
    }
  }

  /// Вихід з акаунта: видалення токенів та локального кешу
  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _cacheService.clearAll();
  }
}