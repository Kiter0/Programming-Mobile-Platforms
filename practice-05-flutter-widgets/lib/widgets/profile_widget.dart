import 'package:flutter/material.dart';
import '../models/user.dart';

class ProfileWidget extends StatelessWidget {
  final User user;
  final VoidCallback? onEditPressed;
  final bool isCompact;

  const ProfileWidget({
    super.key,
    required this.user,
    this.onEditPressed,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 16 : 24),
        child: isCompact
            ? _buildCompactProfile(theme)
            : _buildExpandedProfile(theme),
      ),
    );
  }

  Widget _buildCompactProfile(ThemeData theme) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundImage: NetworkImage(user.avatarUrl),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                user.email,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onEditPressed,
          icon: const Icon(Icons.edit),
        ),
      ],
    );
  }

  Widget _buildExpandedProfile(ThemeData theme) {
    return Column(
      children: [
        CircleAvatar(
          radius: 55,
          backgroundImage: NetworkImage(user.avatarUrl),
        ),
        const SizedBox(height: 16),
        Text(
          user.name,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          user.email,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onEditPressed,
            icon: const Icon(Icons.edit),
            label: const Text('Редагувати профіль'),
          ),
        ),
      ],
    );
  }
}