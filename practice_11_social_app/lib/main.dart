import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:practice_11_social_app/core/network/dio_client.dart';
import 'package:practice_11_social_app/core/storage/cache_service.dart';
import 'package:practice_11_social_app/features/auth/data/repositories/auth_repository.dart';
import 'package:practice_11_social_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:practice_11_social_app/features/auth/presentation/screens/login_screen.dart';
import 'package:practice_11_social_app/features/posts/data/repositories/posts_repository.dart';
import 'package:practice_11_social_app/features/posts/presentation/providers/posts_provider.dart';
import 'package:practice_11_social_app/features/posts/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ініціалізація локального сховища Hive для offline-кешування
  await CacheService.init();

  const secureStorage = FlutterSecureStorage();
  final cacheService = CacheService();

  late AuthProvider authProvider;

  // Ініціалізація Dio з 3 interceptors (Auth + Refresh, Logging, Retry)
  final dioClient = DioClient(
    storage: secureStorage,
    onSessionExpired: () => authProvider.logout(),
  );

  final authRepository = AuthRepository(
    dio: dioClient.dio,
    storage: secureStorage,
    cacheService: cacheService,
  );

  final postsRepository = PostsRepository(
    dio: dioClient.dio,
    cacheService: cacheService,
  );

  authProvider = AuthProvider(authRepository)..checkAuthStatus();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => PostsProvider(postsRepository)),
      ],
      child: const MiniSocialApp(),
    ),
  );
}

class MiniSocialApp extends StatelessWidget {
  const MiniSocialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MiniSocial - ПР №11',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isInitializing) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return auth.isAuthenticated
              ? const HomeScreen()
              : const LoginScreen();
        },
      ),
    );
  }
}