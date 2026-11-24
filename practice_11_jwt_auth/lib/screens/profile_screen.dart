import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'login_screen.dart';
import '../models/user.dart';
import '../services/cache_service.dart';
import '../services/profile_service.dart';
import '../providers/auth_provider.dart';
import '../main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  User? _user;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  String? _error;

  late final ProfileService _profileService;
  late final CacheService _cacheService;

  @override
  void initState() {
    super.initState();

    _profileService = ProfileService(dio: appDio);
    _cacheService = CacheService();

    _loadProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      // Спочатку показуємо кешований профіль.
      final cachedUser = await _cacheService.getProfile();

      if (cachedUser != null && mounted) {
        _setUser(cachedUser);
        setState(() {
          _isLoading = false;
        });
      }

      // Завантажуємо актуальні дані з API.
      final user = await _profileService.getProfile(2);

      await _cacheService.saveProfile(user);

      if (!mounted) return;

      _setUser(user);

      setState(() {
        _isLoading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = 'Не вдалося завантажити профіль: $error';
      });
    }
  }

  void _setUser(User user) {
    _user = user;
    _firstNameController.text = user.firstName ?? '';
    _lastNameController.text = user.lastName ?? '';
    _emailController.text = user.email;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _user == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedUser = _user!.copyWith(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
      );

      final result = await _profileService.updateProfile(
        userId: _user!.id ?? 2,
        user: updatedUser,
      );

      await _cacheService.saveProfile(result);

      if (!mounted) return;

      setState(() {
        _user = result;
        _isEditing = false;
        _isSaving = false;
      });

      _showMessage('Профіль успішно оновлено');
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showMessage('Помилка оновлення: $error');
    }
  }

  Future<void> _changePassword() async {
    final newPassword = _passwordController.text;

    if (newPassword.length < 6) {
      _showMessage('Пароль повинен містити щонайменше 6 символів');
      return;
    }

    try {
      await _profileService.changePassword(
        userId: _user?.id ?? 2,
        newPassword: newPassword,
      );

      _passwordController.clear();

      if (!mounted) return;

      Navigator.pop(context);
      _showMessage('Запит на зміну пароля виконано');
    } catch (error) {
      _showMessage('Помилка зміни пароля: $error');
    }
  }

  Future<void> _showChangePasswordDialog() async {
    _passwordController.clear();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Зміна пароля'),
          content: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Новий пароль',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Скасувати'),
            ),
            ElevatedButton(
              onPressed: _changePassword,
              child: const Text('Змінити'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Вихід з акаунта'),
          content: const Text('Ви дійсно хочете вийти?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Скасувати'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Вийти'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    await context.read<AuthProvider>().logout();
    await _cacheService.clearCache();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Профіль')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_error ?? 'Профіль недоступний'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadProfile,
                  child: const Text('Спробувати ще раз'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мій профіль'),
        actions: [
          IconButton(
            onPressed: _logout,
            tooltip: 'Вийти',
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundImage: _user!.avatar != null
                        ? NetworkImage(_user!.avatar!)
                        : null,
                    child: _user!.avatar == null
                        ? const Icon(Icons.person, size: 48)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _user!.fullName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _user!.email,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),

                  TextFormField(
                    controller: _firstNameController,
                    enabled: _isEditing,
                    decoration: const InputDecoration(
                      labelText: 'Ім’я',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _lastNameController,
                    enabled: _isEditing,
                    decoration: const InputDecoration(
                      labelText: 'Прізвище',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _emailController,
                    enabled: _isEditing,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Введіть email';
                      }

                      if (!RegExp(
                        r'^[^@]+@[^@]+\.[^@]+$',
                      ).hasMatch(value.trim())) {
                        return 'Некоректний email';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton.icon(
                    onPressed: _isSaving
                        ? null
                        : _isEditing
                            ? _saveProfile
                            : () {
                                setState(() {
                                  _isEditing = true;
                                });
                              },
                    icon: Icon(
                      _isEditing ? Icons.save : Icons.edit,
                    ),
                    label: Text(
                      _isSaving
                          ? 'Збереження...'
                          : _isEditing
                              ? 'Зберегти зміни'
                              : 'Редагувати профіль',
                    ),
                  ),

                  if (_isEditing)
                    TextButton(
                      onPressed: () {
                        _setUser(_user!);
                        setState(() {
                          _isEditing = false;
                        });
                      },
                      child: const Text('Скасувати редагування'),
                    ),

                  const SizedBox(height: 12),

                  OutlinedButton.icon(
                    onPressed: _showChangePasswordDialog,
                    icon: const Icon(Icons.lock_reset),
                    label: const Text('Змінити пароль'),
                  ),

                  const SizedBox(height: 12),

                  OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Вийти з акаунта'),
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
