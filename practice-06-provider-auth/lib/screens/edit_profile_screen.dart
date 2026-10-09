
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/profile_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  int _consumerBuildCount = 0;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final profile = context.read<ProfileModel>();
    _nameController.text = profile.name;
    _emailController.text = profile.email;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final profile = context.read<ProfileModel>();

    final success = await profile.updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Профіль успішно оновлено'),
        ),
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редагування профілю'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CircleAvatar(
                    radius: 42,
                    child: Icon(Icons.person, size: 44),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Ім’я користувача',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if ((value ?? '').trim().length < 2) {
                        return 'Ім’я має містити щонайменше 2 символи';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      final email = value?.trim() ?? '';
                      final pattern =
                          RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

                      if (!pattern.hasMatch(email)) {
                        return 'Введіть коректний email';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Consumer<ProfileModel>(
                    builder: (context, profile, child) {
                      debugPrint(
                        'EditProfile Consumer build #${++_consumerBuildCount}',
                      );
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (profile.errorMessage != null) ...[
                            Text(
                              profile.errorMessage!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: profile.isLoading
                                  ? null
                                  : _saveProfile,
                              child: const Text('Повторити'),
                            ),
                            const SizedBox(height: 8),
                          ],
                          if (profile.successMessage != null) ...[
                            Text(
                              profile.successMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          FilledButton.icon(
                            onPressed:
                                profile.isLoading ? null : _saveProfile,
                            icon: profile.isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save),
                            label: Text(
                              profile.isLoading
                                  ? 'Збереження...'
                                  : 'Зберегти зміни',
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}