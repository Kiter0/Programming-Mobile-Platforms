import 'package:flutter/material.dart';

import '../models/user_settings.dart';
import 'settings_section.dart';

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
    required this.onAddCategory,
    this.compact = false,
  });

  final UserSettings settings;
  final ValueChanged<UserSettings> onSettingsChanged;
  final VoidCallback onAddCategory;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'Улюблені категорії',
      icon: Icons.favorite_outline,
      compact: compact,
      children: [
        if (settings.favoriteCategories.isEmpty)
          const Text('Категорій поки немає.')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: settings.favoriteCategories.map((category) {
              return InputChip(
                label: Text(category),
                onDeleted: () {
                  final categories = [...settings.favoriteCategories]
                    ..remove(category);

                  onSettingsChanged(
                    settings.copyWith(favoriteCategories: categories),
                  );
                },
              );
            }).toList(),
          ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onAddCategory,
          icon: const Icon(Icons.add),
          label: const Text('Додати категорію'),
        ),
      ],
    );
  }
}
