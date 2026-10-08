import 'package:flutter/material.dart';

import 'models/user.dart';
import 'screens/home_screen.dart';
import 'screens/products_screen.dart';
import 'screens/profile_screen.dart';
import 'utils/app_state.dart';
import 'utils/themes.dart';

void main() {
  final appState = AppState();

  appState.setUser(
    const User(
      name: 'Олексій',
      email: 'oleksii@example.com',
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
    ),
  );

  runApp(
    MobileWidgetsApp(
      appState: appState,
    ),
  );
}

class MobileWidgetsApp extends StatelessWidget {
  final AppState appState;

  const MobileWidgetsApp({
    super.key,
    required this.appState,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mobile Widgets App',
      theme: AppThemes.lightTheme,
      home: HomeScreen(
        appState: appState,
      ),
      routes: {
        '/products': (context) => ProductsScreen(
              appState: appState,
            ),
        '/profile': (context) => ProfileScreen(
              appState: appState,
            ),
      },
    );
  }
}