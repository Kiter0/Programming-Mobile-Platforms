import 'package:flutter/material.dart';

import '../models/user_settings.dart';
import '../services/preferences_manager.dart';
import '../utils/settings_exporter.dart';
import '../widgets/appearance_section.dart';
import '../widgets/categories_section.dart';
import '../widgets/notifications_section.dart';
import '../widgets/profile_section.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.preferences,
    required this.settings,
    required this.onSettingsChanged,
  });

  final PreferencesManager preferences;
  final UserSettings settings;
  final ValueChanged<UserSettings> onSettingsChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late UserSettings _settings;
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _settings = widget.settings;
    _nameController = TextEditingController(text: _settings.name);
    _emailController = TextEditingController(text: _settings.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _updateSettings(UserSettings updated) async {
    if (!mounted) return;

    setState(() {
      _settings = updated;
      _isSaving = true;
    });

    widget.onSettingsChanged(updated);

    try {
      await widget.preferences.updateSettings(updated);

      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Налаштування збережено'),
            duration: Duration(seconds: 1),
          ),
        );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Помилка збереження: $error')));
    }
  }

  Future<void> _resetSettings() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Скинути налаштування?'),
        content: const Text(
          'Усі поточні налаштування буде замінено значеннями за замовчуванням.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Скасувати'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Скинути'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await widget.preferences.resetSettings();

      if (!mounted) return;

      final defaults = UserSettings.defaults;

      setState(() {
        _settings = defaults;
        _nameController.text = defaults.name;
        _emailController.text = defaults.email;
      });

      widget.onSettingsChanged(defaults);

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Налаштування скинуто')));
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Помилка скидання: $error')));
    }
  }

  Future<void> _addCategory() async {
    String categoryName = '';

    final category = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Нова категорія'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Назва категорії',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            categoryName = value.trim();
          },
          onSubmitted: (value) {
            Navigator.pop(dialogContext, value.trim());
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Скасувати'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext, categoryName);
            },
            child: const Text('Додати'),
          ),
        ],
      ),
    );

    if (!mounted || category == null || category.isEmpty) {
      return;
    }

    if (_settings.favoriteCategories.contains(category)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Така категорія вже існує')));
      return;
    }

    await _updateSettings(
      _settings.copyWith(
        favoriteCategories: [..._settings.favoriteCategories, category],
      ),
    );
  }

  void _exportSettings() {
    final jsonString = SettingsExporter.toJson(_settings);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Експорт налаштувань (JSON)'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              jsonString,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрити'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Менеджер налаштувань'),
        actions: [
          IconButton(
            tooltip: 'Експорт JSON',
            onPressed: _exportSettings,
            icon: const Icon(Icons.code),
          ),
          IconButton(
            tooltip: 'Скинути налаштування',
            onPressed: _resetSettings,
            icon: const Icon(Icons.restore),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(_settings.compactMode ? 10 : 16),
          children: [
            if (_isSaving) const LinearProgressIndicator(),

            ProfileSection(
              settings: _settings,
              nameController: _nameController,
              emailController: _emailController,
              onSettingsChanged: _updateSettings,
              compact: _settings.compactMode,
            ),

            AppearanceSection(
              settings: _settings,
              onSettingsChanged: _updateSettings,
              compact: _settings.compactMode,
            ),

            NotificationsSection(
              settings: _settings,
              onSettingsChanged: _updateSettings,
              compact: _settings.compactMode,
            ),

            CategoriesSection(
              settings: _settings,
              onSettingsChanged: _updateSettings,
              onAddCategory: _addCategory,
              compact: _settings.compactMode,
            ),

            const SizedBox(height: 8),
            Center(
              child: Text(
                'Зміни зберігаються автоматично',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
