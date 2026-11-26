import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:practice_11_social_app/core/storage/cache_service.dart';
import 'package:practice_11_social_app/features/auth/data/repositories/auth_repository.dart';
import 'package:practice_11_social_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:practice_11_social_app/features/auth/presentation/screens/login_screen.dart';

void main() {
  testWidgets('LoginScreen renders correctly', (WidgetTester tester) async {
    final authProvider = AuthProvider(
      AuthRepository(
        dio: Dio(),
        storage: const FlutterSecureStorage(),
        cacheService: CacheService(),
      ),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: authProvider,
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    expect(find.text('MiniSocial'), findsOneWidget);
    expect(find.text('Увійти'), findsOneWidget);
  });
}