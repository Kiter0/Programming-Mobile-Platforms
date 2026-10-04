import 'package:flutter/material.dart';

import '../widgets/contact_card.dart';

/// Єдиний екран застосунку — візитівка.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onToggleTheme});

  /// Функція, яку викликає кнопка. Сама зміна теми відбувається в main.dart.
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Візитівка розробника')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 56,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.person,
                size: 56,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 16),
            Text('Олександр Петренко', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(
              'Мобільний розробник (Flutter)',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            const ContactCard(icon: Icons.email, text: 'oleksandr@example.com'),
            const ContactCard(icon: Icons.phone, text: '+380 12 345 67 89'),
            const ContactCard(
              icon: Icons.language,
              text: 'github.com/your-name',
            ),
            const ContactCard(icon: Icons.location_on, text: 'Київ, Україна'),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onToggleTheme,
              icon: const Icon(Icons.brightness_6),
              label: const Text('Змінити тему'),
            ),
          ],
        ),
      ),
    );
  }
}
