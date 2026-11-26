import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Сервіс перевірки стану мережі та локального кешування API-відповідей у Hive
class CacheService {
  static const String _boxName = 'api_cache_box';

  /// Ініціалізація Hive при старті додатка
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(_boxName);
  }

  Box<String> get _box => Hive.box<String>(_boxName);

  /// Перевірка наявності мережевого інтерфейсу через connectivity_plus
  Future<bool> isOnline() async {
    final results = await Connectivity().checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  /// Збереження відповіді API в локальний кеш у вигляді JSON-рядка
  Future<void> cache(String key, dynamic data) async {
    final payload = jsonEncode({
      'timestamp': DateTime.now().toIso8601String(),
      'data': data,
    });
    await _box.put(key, payload);
  }

  /// Отримання закешованих даних за ключем (повертає null, якщо кешу немає)
  Future<dynamic> getCached(String key) async {
    final raw = _box.get(key);
    if (raw == null) return null;
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded['data'];
  }

  /// Очищення всього кешу (наприклад, при виході з акаунта)
  Future<void> clearAll() async {
    await _box.clear();
  }
}