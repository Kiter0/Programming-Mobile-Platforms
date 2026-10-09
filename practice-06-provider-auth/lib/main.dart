
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/auth_model.dart';
import 'models/profile_model.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/fake_auth_api.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthModel>(
          create: (_) => AuthModel(FakeAuthApi()),
        ),
        ChangeNotifierProvider<ProfileModel>(
          create: (_) => ProfileModel(FakeAuthApi()),
        ),
      ],
      child: const AuthApp(),
    ),
  );
}

class AuthApp extends StatelessWidget {
  const AuthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Авторизація та профіль',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.select<AuthModel, bool>(
      (auth) => auth.isLoggedIn,
    );

    if (isLoggedIn) {
      return const HomeScreen();
    }

    return const LoginScreen();
  }
}