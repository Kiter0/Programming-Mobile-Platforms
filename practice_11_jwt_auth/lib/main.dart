import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dio/dio.dart';
import 'core/dio_client.dart';
import 'core/token_storage.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'services/auth_service.dart';
import 'widgets/loading_widget.dart';

late final DioClient dioClient;
late final AuthService authService;
late final TokenStorage tokenStorage;

Dio get appDio => dioClient.dio;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tokenStorage = TokenStorage();
  dioClient = DioClient(tokenStorage);

  authService = AuthService(
    dio: dioClient.dio,
    tokenStorage: tokenStorage,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(
        authService: authService,
        tokenStorage: tokenStorage,
      )..checkAuthStatus(),
      child: const JwtAuthApp(),
    ),
  );
}

class JwtAuthApp extends StatelessWidget {
  const JwtAuthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JWT Authentication',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
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
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isLoading) {
      return const Scaffold(
        body: LoadingWidget(
          message: 'Перевірка авторизації...',
        ),
      );
    }

    if (authProvider.isAuthenticated) {
      return const ProfileScreen();
    }

    return const LoginScreen();
  }
}
