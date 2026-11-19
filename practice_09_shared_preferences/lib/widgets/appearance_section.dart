import 'package:flutter/material.dart';

import '../models/user_settings.dart';
import 'settings_section.dart';

class AppearanceSection extends StatelessWidget {
  const AppearanceSection({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
    this.compact = false,
  });

  final UserSettings settings;
  final ValueChanged<UserSettings> onSettingsChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'Зовнішній вигляд',
      icon: Icons.palette_outlined,
      compact: compact,
      children: [
        const Text('Тема застосунку'),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<AppThemeMode>(
            segments: const [
              ButtonSegment(
                value: AppThemeMode.light,
                label: Text('Світла'),
                icon: Icon(Icons.light_mode),
              ),
              ButtonSegment(
                value: AppThemeMode.dark,
                label: Text('Темна'),
                icon: Icon(Icons.dark_mode),
              ),
              ButtonSegment(
                value: AppThemeMode.system,
                label: Text('Системна'),
                icon: Icon(Icons.settings_brightness),
              ),
            ],
            selected: {settings.theme},
            onSelectionChanged: (selection) {
              onSettingsChanged(settings.copyWith(theme: selection.first));
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Розмір шрифту'),
            Text('${settings.fontSize.round()} px'),
          ],
        ),
        Slider(
          value: settings.fontSize,
          min: 12,
          max: 24,
          divisions: 12,
          label: settings.fontSize.round().toString(),
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(fontSize: value));
          },
        ),
        DropdownButtonFormField<String>(
          initialValue: settings.language,
          decoration: const InputDecoration(
            labelText: 'Мова',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'Українська', child: Text('Українська')),
            DropdownMenuItem(value: 'English', child: Text('English')),
            DropdownMenuItem(value: 'Polski', child: Text('Polski')),
          ],
          onChanged: (value) {
            if (value != null) {
              onSettingsChanged(settings.copyWith(language: value));
            }
          },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Компактний режим'),
          subtitle: const Text('Зменшені відступи між елементами'),
          value: settings.compactMode,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(compactMode: value));
          },
        ),
      ],
    );
  }
}
