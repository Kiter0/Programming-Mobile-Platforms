import 'package:flutter/material.dart';

import '../utils/app_state.dart';
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
    final user = appState.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Профіль'),
        ),
        body: const Center(
          child: Text('Користувача не знайдено'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профіль'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Редагування профілю'),
                  ),
                );
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
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
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
        borderRadius: BorderRadius.circular(16),
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