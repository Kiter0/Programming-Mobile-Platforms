import 'package:flutter/material.dart';

import '../models/user_settings.dart';
import 'settings_section.dart';

class NotificationsSection extends StatelessWidget {
  const NotificationsSection({
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
      title: 'Сповіщення',
      icon: Icons.notifications_outlined,
      compact: compact,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Push-сповіщення'),
          value: settings.pushNotifications,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(pushNotifications: value));
          },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Email-сповіщення'),
          value: settings.emailNotifications,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(emailNotifications: value));
          },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Звукові сповіщення'),
          value: settings.soundNotifications,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(soundNotifications: value));
          },
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          initialValue: settings.reminderFrequency,
          decoration: const InputDecoration(
            labelText: 'Частота нагадувань',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 1, child: Text('1 раз на день')),
            DropdownMenuItem(value: 2, child: Text('2 рази на день')),
            DropdownMenuItem(value: 3, child: Text('3 рази на день')),
            DropdownMenuItem(value: 7, child: Text('Щотижня')),
          ],
          onChanged: (value) {
            if (value != null) {
              onSettingsChanged(settings.copyWith(reminderFrequency: value));
            }
          },
        ),
      ],
    );
  }
}
