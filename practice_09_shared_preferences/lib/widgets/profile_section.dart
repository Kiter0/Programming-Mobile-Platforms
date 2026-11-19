import 'package:flutter/material.dart';

import '../models/user_settings.dart';
import 'settings_section.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({
    super.key,
    required this.settings,
    required this.nameController,
    required this.emailController,
    required this.onSettingsChanged,
    this.compact = false,
  });

  final UserSettings settings;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final ValueChanged<UserSettings> onSettingsChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'Профіль користувача',
      icon: Icons.person_outline,
      compact: compact,
      children: [
        TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Ім’я',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(name: value));
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email_outlined),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(email: value));
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Expanded(child: Text('Вік')),
            IconButton(
              tooltip: 'Зменшити вік',
              onPressed: settings.age > 1
                  ? () => onSettingsChanged(
                      settings.copyWith(age: settings.age - 1),
                    )
                  : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text(
              '${settings.age}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            IconButton(
              tooltip: 'Збільшити вік',
              onPressed: settings.age < 120
                  ? () => onSettingsChanged(
                      settings.copyWith(age: settings.age + 1),
                    )
                  : null,
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Дата реєстрації'),
          subtitle: Text(settings.registrationDate),
          leading: const Icon(Icons.calendar_today),
        ),
      ],
    );
  }
}
