import 'package:flutter/material.dart';
import 'package:practice_11_social_app/features/posts/presentation/screens/create_post_screen.dart';
import 'package:practice_11_social_app/features/posts/presentation/screens/feed_tab.dart';
import 'package:practice_11_social_app/features/posts/presentation/screens/profile_tab.dart';
import 'package:practice_11_social_app/features/posts/presentation/screens/search_tab.dart';

/// Головний екран із BottomNavigationBar: Стрічка | Пошук | Профіль
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    FeedTab(),
    SearchTab(),
    ProfileTab(),
  ];

  final List<String> _titles = const [
    'Стрічка постів',
    'Пошук',
    'Мій профіль',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
      ),
      body: _tabs[_currentIndex],
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreatePostScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Пост'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dynamic_feed_outlined),
            selectedIcon: Icon(Icons.dynamic_feed),
            label: 'Стрічка',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Пошук',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Профіль',
          ),
        ],
      ),
    );
  }
}