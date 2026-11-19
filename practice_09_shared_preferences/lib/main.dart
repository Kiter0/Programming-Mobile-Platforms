import 'package:flutter/material.dart';

import 'models/user_settings.dart';
import 'screens/settings_screen.dart';
import 'services/preferences_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await PreferencesManager.getInstance();
  final settings = await preferences.readSettings();

  runApp(SettingsApp(preferences: preferences, initialSettings: settings));
}

class SettingsApp extends StatefulWidget {
  const SettingsApp({
    super.key,
    required this.preferences,
    required this.initialSettings,
  });

  final PreferencesManager preferences;
  final UserSettings initialSettings;

  @override
  State<SettingsApp> createState() => _SettingsAppState();
}

class _SettingsAppState extends State<SettingsApp> {
  late UserSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.initialSettings;
  }

  void _updateSettings(UserSettings settings) {
    setState(() {
      _settings = settings;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = switch (_settings.theme) {
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
      AppThemeMode.system => ThemeMode.system,
    };

    final fontScale = _settings.fontSize / 16;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Менеджер налаштувань',
      themeMode: themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(fontScale)),
          child: child!,
        );
      },
      home: SettingsScreen(
        preferences: widget.preferences,
        settings: _settings,
        onSettingsChanged: _updateSettings,
      ),
    );
  }
}
