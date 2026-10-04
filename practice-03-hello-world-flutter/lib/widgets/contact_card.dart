import 'package:flutter/material.dart';
/// Картка одного контакту: іконка + підпис.
class ContactCard extends StatelessWidget {
  const ContactCard({
    super.key,
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(text, style: theme.textTheme.bodyLarge),
      ),
    );
  }
}