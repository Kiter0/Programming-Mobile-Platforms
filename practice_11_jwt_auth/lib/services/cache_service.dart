import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class CacheService {
  static const String _profileKey = 'cached_profile';

  // Збереження профілю в локальному кеші.
  Future<void> saveProfile(User user) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      _profileKey,
      jsonEncode(user.toJson()),
    );
  }

  // Отримання профілю з локального кешу.
  Future<User?> getProfile() async {
    final preferences = await SharedPreferences.getInstance();
    final cachedData = preferences.getString(_profileKey);

    if (cachedData == null) {
      return null;
    }

    final data = jsonDecode(cachedData) as Map<String, dynamic>;

    return User.fromJson(data);
  }

  // Видалення кешованого профілю.
  Future<void> clearCache() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_profileKey);
  }
}