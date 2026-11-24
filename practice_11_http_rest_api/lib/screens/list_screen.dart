import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/api_service.dart';
import '../widgets/user_card.dart';
import '../widgets/error_widget.dart';

class ListScreen extends StatefulWidget {
  final ApiService apiService;

  const ListScreen({
    super.key,
    required this.apiService,
  });

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  late Future<List<User>> _usersFuture;
  List<User> _users = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _usersFuture = _loadUsers();
  }

  Future<List<User>> _loadUsers() async {
    final users = await widget.apiService.getUsers();

    if (mounted) {
      setState(() {
        _users = users;
      });
    }

    return users;
  }

  void _refreshUsers() {
    setState(() {
      _usersFuture = _loadUsers();
    });
  }

  List<User> get _filteredUsers {
    if (_searchQuery.isEmpty) return _users;

    return _users.where((user) {
      return user.name.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
    }).toList();
  }

  Future<void> _openUserDetails(User user) async {
    final result = await Navigator.pushNamed(
      context,
      '/details',
      arguments: user,
    );

    if (!mounted) return;

    if (result is User) {
      setState(() {
        final index = _users.indexWhere(
          (item) => item.id == result.id,
        );

        if (index != -1) {
          _users[index] = result;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Дані користувача оновлено'),
        ),
      );
    } else if (result is Map && result['action'] == 'delete') {
      setState(() {
        _users.removeWhere(
          (item) => item.id == result['id'],
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Користувача видалено'),
        ),
      );
    }
  }

  Future<void> _openCreateScreen() async {
    final result = await Navigator.pushNamed(
      context,
      '/create',
    );

    if (!mounted) return;

    if (result is User) {
      setState(() {
        _users.insert(0, result);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Користувача додано'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Менеджер користувачів',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Пошук за іменем...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<User>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return ErrorDisplayWidget(
                    message: snapshot.error.toString(),
                    onRetry: _refreshUsers,
                  );
                }

                final users = _filteredUsers;

                if (users.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      _refreshUsers();
                      await _usersFuture;
                    },
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 120),
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            _searchQuery.isEmpty
                                ? 'Список користувачів порожній'
                                : 'Користувачів не знайдено',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _refreshUsers();
                    await _usersFuture;
                  },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: 4, bottom: 80),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];

                      return UserCard(
                        user: user,
                        onTap: () => _openUserDetails(user),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateScreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}
