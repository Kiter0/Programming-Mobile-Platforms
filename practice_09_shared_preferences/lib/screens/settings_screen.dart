import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/user_settings.dart';
import '../services/preferences_manager.dart';

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

  bool get _compact => _settings.compactMode;

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
    setState(() {
      _settings = updated;
      _isSaving = true;
    });

    widget.onSettingsChanged(updated);

    try {
      await widget.preferences.updateSettings(updated);

      if (!mounted) return;
      setState(() => _isSaving = false);

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
      setState(() => _isSaving = false);

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
      final defaults = UserSettings.defaults;

      setState(() {
        _settings = defaults;
        _nameController.text = defaults.name;
        _emailController.text = defaults.email;
      });

      widget.onSettingsChanged(defaults);

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Налаштування скинуто')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Помилка скидання: $error')));
    }
  }

  void _exportSettings() {
    final jsonString = const JsonEncoder.withIndent('  ').convert({
      'profile': {
        'name': _settings.name,
        'email': _settings.email,
        'age': _settings.age,
        'registrationDate': _settings.registrationDate,
      },
      'appearance': {
        'theme': _settings.theme.name,
        'fontSize': _settings.fontSize,
        'language': _settings.language,
        'compactMode': _settings.compactMode,
      },
      'notifications': {
        'push': _settings.pushNotifications,
        'email': _settings.emailNotifications,
        'sound': _settings.soundNotifications,
        'reminderFrequency': _settings.reminderFrequency,
      },
      'favoriteCategories': _settings.favoriteCategories,
    });

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

  Future<void> _addCategory() async {
    final controller = TextEditingController();

    final category = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Нова категорія'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Назва категорії',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) => Navigator.pop(context, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Скасувати'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Додати'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (category == null ||
        category.isEmpty ||
        _settings.favoriteCategories.contains(category)) {
      return;
    }

    await _updateSettings(
      _settings.copyWith(
        favoriteCategories: [..._settings.favoriteCategories, category],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: _compact ? 10 : 16),
      child: Padding(
        padding: EdgeInsets.all(_compact ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 10),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            SizedBox(height: _compact ? 8 : 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _numberPicker() {
    return Row(
      children: [
        const Expanded(child: Text('Вік')),
        IconButton(
          tooltip: 'Зменшити вік',
          onPressed: _settings.age > 1
              ? () =>
                    _updateSettings(_settings.copyWith(age: _settings.age - 1))
              : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text(
          '${_settings.age}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        IconButton(
          tooltip: 'Збільшити вік',
          onPressed: _settings.age < 120
              ? () =>
                    _updateSettings(_settings.copyWith(age: _settings.age + 1))
              : null,
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
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
          padding: EdgeInsets.all(_compact ? 10 : 16),
          children: [
            if (_isSaving) const LinearProgressIndicator(),

            _sectionCard(
              title: 'Профіль користувача',
              icon: Icons.person_outline,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Ім’я',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) =>
                      _updateSettings(_settings.copyWith(name: value)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) =>
                      _updateSettings(_settings.copyWith(email: value)),
                ),
                const SizedBox(height: 8),
                _numberPicker(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Дата реєстрації'),
                  subtitle: Text(_settings.registrationDate),
                  leading: const Icon(Icons.calendar_today),
                ),
              ],
            ),

            _sectionCard(
              title: 'Зовнішній вигляд',
              icon: Icons.palette_outlined,
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
                    selected: {_settings.theme},
                    onSelectionChanged: (selection) {
                      _updateSettings(
                        _settings.copyWith(theme: selection.first),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Розмір шрифту'),
                    Text('${_settings.fontSize.round()} px'),
                  ],
                ),
                Slider(
                  value: _settings.fontSize,
                  min: 12,
                  max: 24,
                  divisions: 12,
                  label: _settings.fontSize.round().toString(),
                  onChanged: (value) {
                    _updateSettings(_settings.copyWith(fontSize: value));
                  },
                ),
                DropdownButtonFormField<String>(
                  initialValue: _settings.language,
                  decoration: const InputDecoration(
                    labelText: 'Мова',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Українська',
                      child: Text('Українська'),
                    ),
                    DropdownMenuItem(value: 'English', child: Text('English')),
                    DropdownMenuItem(value: 'Polski', child: Text('Polski')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      _updateSettings(_settings.copyWith(language: value));
                    }
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Компактний режим'),
                  subtitle: const Text('Зменшені відступи між елементами'),
                  value: _settings.compactMode,
                  onChanged: (value) {
                    _updateSettings(_settings.copyWith(compactMode: value));
                  },
                ),
              ],
            ),

            _sectionCard(
              title: 'Сповіщення',
              icon: Icons.notifications_outlined,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Push-сповіщення'),
                  value: _settings.pushNotifications,
                  onChanged: (value) {
                    _updateSettings(
                      _settings.copyWith(pushNotifications: value),
                    );
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Email-сповіщення'),
                  value: _settings.emailNotifications,
                  onChanged: (value) {
                    _updateSettings(
                      _settings.copyWith(emailNotifications: value),
                    );
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Звукові сповіщення'),
                  value: _settings.soundNotifications,
                  onChanged: (value) {
                    _updateSettings(
                      _settings.copyWith(soundNotifications: value),
                    );
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  initialValue: _settings.reminderFrequency,
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
                      _updateSettings(
                        _settings.copyWith(reminderFrequency: value),
                      );
                    }
                  },
                ),
              ],
            ),

            _sectionCard(
              title: 'Улюблені категорії',
              icon: Icons.favorite_outline,
              children: [
                if (_settings.favoriteCategories.isEmpty)
                  const Text('Категорій поки немає.')
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _settings.favoriteCategories.map((category) {
                      return InputChip(
                        label: Text(category),
                        onDeleted: () {
                          final categories = [..._settings.favoriteCategories]
                            ..remove(category);

                          _updateSettings(
                            _settings.copyWith(favoriteCategories: categories),
                          );
                        },
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _addCategory,
                  icon: const Icon(Icons.add),
                  label: const Text('Додати категорію'),
                ),
              ],
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
