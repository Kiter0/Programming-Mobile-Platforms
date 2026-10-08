import 'package:flutter/material.dart';

import 'models/user.dart';
import 'screens/products_screen.dart';
import 'utils/app_state.dart';

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
    return AnimatedBuilder(
      animation: appState,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Mobile Widgets App',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
            ),
            useMaterial3: true,
          ),
          home: ProductsScreen(
            appState: appState,
          ),
        );
      },
    );
  }
}