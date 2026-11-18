enum AppThemeMode { light, dark, system }

class UserSettings {
  const UserSettings({
    this.name = 'Alex Johnson',
    this.email = 'alex@example.com',
    this.age = 20,
    this.registrationDate = '2026-11-19',
    this.theme = AppThemeMode.system,
    this.fontSize = 16.0,
    this.language = 'Українська',
    this.compactMode = false,
    this.pushNotifications = true,
    this.emailNotifications = true,
    this.soundNotifications = true,
    this.reminderFrequency = 2,
    this.favoriteCategories = const ['Технології', 'Навчання'],
  });

  final String name;
  final String email;
  final int age;
  final String registrationDate;

  final AppThemeMode theme;
  final double fontSize;
  final String language;
  final bool compactMode;

  final bool pushNotifications;
  final bool emailNotifications;
  final bool soundNotifications;
  final int reminderFrequency;

  final List<String> favoriteCategories;

  UserSettings copyWith({
    String? name,
    String? email,
    int? age,
    String? registrationDate,
    AppThemeMode? theme,
    double? fontSize,
    String? language,
    bool? compactMode,
    bool? pushNotifications,
    bool? emailNotifications,
    bool? soundNotifications,
    int? reminderFrequency,
    List<String>? favoriteCategories,
  }) {
    return UserSettings(
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      registrationDate: registrationDate ?? this.registrationDate,
      theme: theme ?? this.theme,
      fontSize: fontSize ?? this.fontSize,
      language: language ?? this.language,
      compactMode: compactMode ?? this.compactMode,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      soundNotifications: soundNotifications ?? this.soundNotifications,
      reminderFrequency: reminderFrequency ?? this.reminderFrequency,
      favoriteCategories: favoriteCategories ?? this.favoriteCategories,
    );
  }

  static UserSettings get defaults => const UserSettings();
}
