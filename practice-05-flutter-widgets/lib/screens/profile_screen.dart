
import 'package:flutter/material.dart';

import '../models/user.dart';
import '../utils/app_state.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/profile_widget.dart';

class ProfileScreen extends StatelessWidget {
  final AppState appState;

  const ProfileScreen({
    super.key,
    required this.appState,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профіль'),
      ),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, child) {
          final user = appState.currentUser;

          if (user == null) {
            return const Center(
              child: Text('Користувача не знайдено'),
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(
                  AppConstants.screenPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Мій профіль',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Інформація про користувача',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ProfileWidget(
                      user: user,
                      onEditPressed: () {
                        _showEditProfileDialog(context, user);
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildInfoCard(
                      icon: Icons.favorite,
                      title: 'Обране',
                      value: appState.favorites.length.toString(),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.shopping_cart,
                      title: 'Товарів у кошику',
                      value: appState.cartCount.toString(),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'До товарів',
                      style: CustomButtonStyle.primary,
                      icon: const Icon(Icons.shopping_bag),
                      onPressed: () {
                        Navigator.pushNamed(context, '/products');
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditProfileDialog(
    BuildContext context,
    User user,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return _EditProfileDialog(
          user: user,
          appState: appState,
        );
      },
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(
          AppConstants.cardRadius,
        ),
        border: Border.all(
          color: Colors.blue.shade100,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditProfileDialog extends StatefulWidget {
  final User user;
  final AppState appState;

  const _EditProfileDialog({
    required this.user,
    required this.appState,
  });

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.user.name,
    );

    _emailController = TextEditingController(
      text: widget.user.email,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();

    super.dispose();
  }

  void _saveProfile() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    final emailOk =
        RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

    if (name.isEmpty || !emailOk) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Введіть коректне ім’я та email'),
        ),
      );
      return;
    }

    widget.appState.setUser(
      User(
        name: name,
        email: email,
        avatarUrl: widget.user.avatarUrl,
      ),
    );

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Профіль успішно оновлено'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Редагування профілю'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Імʼя',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Скасувати'),
        ),
        ElevatedButton(
          onPressed: _saveProfile,
          child: const Text('Зберегти'),
        ),
      ],
    );
  }
}
