import 'package:flutter/material.dart';

import 'database/database_helper.dart';
import 'repositories/user_repository.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final repository = UserRepository(
    databaseHelper: DatabaseHelper.instance,
  );

  runApp(DataValidationApp(repository: repository));
}

class DataValidationApp extends StatelessWidget {
  final UserRepository repository;

  const DataValidationApp({
    super.key,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Data Validation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
      ),
      home: HomeScreen(repository: repository),
    );
  }
}
