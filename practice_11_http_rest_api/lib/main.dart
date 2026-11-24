import 'package:flutter/material.dart';

import 'screens/create_edit_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/list_screen.dart';
import 'services/api_service.dart';
import 'models/user.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();

    return MaterialApp(
      title: 'User Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
      ),
      home: ListScreen(apiService: apiService),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/details':
            final user = settings.arguments as User;

            return MaterialPageRoute(
              builder: (_) => DetailScreen(
                user: user,
                apiService: apiService,
              ),
            );

          case '/create':
            return MaterialPageRoute(
              builder: (_) => CreateEditScreen(
                apiService: apiService,
              ),
            );

          case '/edit':
            final user = settings.arguments as User;

            return MaterialPageRoute(
              builder: (_) => CreateEditScreen(
                apiService: apiService,
                user: user,
              ),
            );

          default:
            return null;
        }
      },
    );
  }
}