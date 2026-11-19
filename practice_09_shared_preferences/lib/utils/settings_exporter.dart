import 'dart:convert';

import '../models/user_settings.dart';

class SettingsExporter {
  static String toJson(UserSettings settings) {
    final data = {
      'profile': {
        'name': settings.name,
        'email': settings.email,
        'age': settings.age,
        'registrationDate': settings.registrationDate,
      },
      'appearance': {
        'theme': settings.theme.name,
        'fontSize': settings.fontSize,
        'language': settings.language,
        'compactMode': settings.compactMode,
      },
      'notifications': {
        'push': settings.pushNotifications,
        'email': settings.emailNotifications,
        'sound': settings.soundNotifications,
        'reminderFrequency': settings.reminderFrequency,
      },
      'favoriteCategories': settings.favoriteCategories,
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }
}
