import 'package:flutter/material.dart';

import 'router.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const CinemaApp());
}

class CinemaApp extends StatefulWidget {
  const CinemaApp({super.key});

  @override
  State<CinemaApp> createState() => _CinemaAppState();
}

class _CinemaAppState extends State<CinemaApp> {
  late final AuthService _auth;
  late final router = createRouter(_auth);

  @override
  void initState() {
    super.initState();
    _auth = AuthService();
  }

  @override
  void dispose() {
    router.dispose();
    _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Cinema',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(centerTitle: false),
      ),
      routerConfig: router,
    );
  }
}
