import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const MobileWidgetsApp());
}

class MobileWidgetsApp extends StatelessWidget {
  const MobileWidgetsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mobile Widgets App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}