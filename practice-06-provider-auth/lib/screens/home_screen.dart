
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/auth_model.dart';
import '../models/profile_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;

      final auth = context.read<AuthModel>();

      context.read<ProfileModel>().loadProfile(
            name: auth.userName ?? '',
            email: auth.email ?? '',
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мій профіль'),
        actions: [
          IconButton(
            tooltip: 'Вийти',
            onPressed: () {
              context.read<AuthModel>().logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 48,
                child: Icon(Icons.person, size: 52),
              ),
              const SizedBox(height: 20),
              Text(
                'Вітаємо!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                profile.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(profile.email),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Редагування профілю додамо на наступному етапі',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text('Редагувати профіль'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  context.read<AuthModel>().logout();
                },
                icon: const Icon(Icons.logout),
                label: const Text('Вийти'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}