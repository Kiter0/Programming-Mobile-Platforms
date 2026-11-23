import 'package:flutter/material.dart';

import '../models/user.dart';
import '../repositories/user_repository.dart';
import '../widgets/user_form.dart';

class HomeScreen extends StatefulWidget {
  final UserRepository repository;

  const HomeScreen({
    super.key,
    required this.repository,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<User> _users = [];
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final users = await widget.repository.getUsers();

      if (!mounted) return;

      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadError = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addUser({
    required String name,
    required String email,
    required String phone,
  }) async {
    try {
      await widget.repository.addUser(
        name: name,
        email: email,
        phone: phone,
      );

      await _loadUsers();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Користувача успішно збережено'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );

      rethrow;
    }
  }

  Future<void> _deleteUser(User user) async {
    if (user.id == null) return;

    try {
      await widget.repository.deleteUser(user.id!);
      await _loadUsers();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Користувача видалено'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Validation'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadUsers,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            UserForm(onSubmit: _addUser),
            const SizedBox(height: 24),
            const Text(
              'Збережені користувачі',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_loadError != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        _loadError!,
                        style: const TextStyle(color: Colors.red),
                      ),
                      TextButton(
                        onPressed: _loadUsers,
                        child: const Text('Спробувати ще раз'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_users.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text('Поки що користувачів немає'),
                  ),
                ),
              )
            else
              ..._users.map(
                (user) => Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(user.name),
                    subtitle: Text(
                      '${user.email}\n${user.phone}',
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      onPressed: () => _deleteUser(user),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
