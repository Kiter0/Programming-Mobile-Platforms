import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_settings.dart';

class PreferencesManager {
  static PreferencesManager? _instance;
  static SharedPreferences? _prefs;

  PreferencesManager._();

  static Future<PreferencesManager> getInstance() async {
    if (_instance != null) {
      return _instance!;
    }

    _prefs ??= await SharedPreferences.getInstance();
    _instance ??= PreferencesManager._();

    return _instance!;
  }

  static const String _nameKey = 'profile_name';
  static const String _emailKey = 'profile_email';
  static const String _ageKey = 'profile_age';
  static const String _registrationDateKey = 'registration_date';

  static const String _themeKey = 'theme';
  static const String _fontSizeKey = 'font_size';
  static const String _languageKey = 'language';
  static const String _compactModeKey = 'compact_mode';

  static const String _pushKey = 'push_notifications';
  static const String _emailNotificationsKey = 'email_notifications';
  static const String _soundKey = 'sound_notifications';
  static const String _reminderFrequencyKey = 'reminder_frequency';

  static const String _categoriesKey = 'favorite_categories';

  SharedPreferences get _storage => _prefs!;

  // CREATE: створення налаштувань, якщо їх ще немає.
  Future<void> createSettings(UserSettings settings) async {
    try {
      if (_storage.containsKey(_nameKey)) {
        throw StateError('Налаштування вже існують.');
      }

      await updateSettings(settings);
    } catch (error) {
      throw Exception('Не вдалося створити налаштування: $error');
    }
  }

  // READ: отримання всіх збережених налаштувань.
  Future<UserSettings> readSettings() async {
    try {
      if (!_storage.containsKey(_nameKey)) {
        return UserSettings.defaults;
      }

      final themeName = _storage.getString(_themeKey) ?? 'system';

      return UserSettings(
        name: _storage.getString(_nameKey) ?? '',
        email: _storage.getString(_emailKey) ?? '',
        age: _storage.getInt(_ageKey) ?? 20,
        registrationDate: _storage.getString(_registrationDateKey) ?? '',
        theme: AppThemeMode.values.firstWhere(
          (mode) => mode.name == themeName,
          orElse: () => AppThemeMode.system,
        ),
        fontSize: _storage.getDouble(_fontSizeKey) ?? 16.0,
        language: _storage.getString(_languageKey) ?? 'Українська',
        compactMode: _storage.getBool(_compactModeKey) ?? false,
        pushNotifications: _storage.getBool(_pushKey) ?? true,
        emailNotifications: _storage.getBool(_emailNotificationsKey) ?? true,
        soundNotifications: _storage.getBool(_soundKey) ?? true,
        reminderFrequency: _storage.getInt(_reminderFrequencyKey) ?? 2,
        favoriteCategories:
            _storage.getStringList(_categoriesKey) ??
            UserSettings.defaults.favoriteCategories,
      );
    } catch (error) {
      throw Exception('Не вдалося прочитати налаштування: $error');
    }
  }

  // UPDATE: збереження та оновлення всіх налаштувань.
  Future<void> updateSettings(UserSettings settings) async {
    try {
      await _storage.setString(_nameKey, settings.name);
      await _storage.setString(_emailKey, settings.email);
      await _storage.setInt(_ageKey, settings.age);
      await _storage.setString(_registrationDateKey, settings.registrationDate);

      await _storage.setString(_themeKey, settings.theme.name);
      await _storage.setDouble(_fontSizeKey, settings.fontSize);
      await _storage.setString(_languageKey, settings.language);
      await _storage.setBool(_compactModeKey, settings.compactMode);

      await _storage.setBool(_pushKey, settings.pushNotifications);
      await _storage.setBool(
        _emailNotificationsKey,
        settings.emailNotifications,
      );
      await _storage.setBool(_soundKey, settings.soundNotifications);
      await _storage.setInt(_reminderFrequencyKey, settings.reminderFrequency);

      await _storage.setStringList(_categoriesKey, settings.favoriteCategories);
    } catch (error) {
      throw Exception('Не вдалося зберегти налаштування: $error');
    }
  }

  // DELETE: видалення всіх налаштувань.
  Future<void> deleteSettings() async {
    try {
      final keys = [
        _nameKey,
        _emailKey,
        _ageKey,
        _registrationDateKey,
        _themeKey,
        _fontSizeKey,
        _languageKey,
        _compactModeKey,
        _pushKey,
        _emailNotificationsKey,
        _soundKey,
        _reminderFrequencyKey,
        _categoriesKey,
      ];

      for (final key in keys) {
        await _storage.remove(key);
      }
    } catch (error) {
      throw Exception('Не вдалося видалити налаштування: $error');
    }
  }

  // Скидання до типових налаштувань.
  Future<void> resetSettings() async {
    try {
      await updateSettings(UserSettings.defaults);
    } catch (error) {
      throw Exception('Не вдалося скинути налаштування: $error');
    }
  }
}
