import 'package:flutter/material.dart';

import 'database/hive_manager.dart';
import 'repositories/task_repository.dart';
import 'screens/home_screen.dart';
import 'services/analytics_service.dart';
import 'services/backup_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveManager.initialize();

  final repository = TaskRepository();
  final backupService = BackupService(repository);
  final analyticsService = AnalyticsService(repository);

  // Перевірка необхідності щоденного резервного копіювання.
  try {
    final backup = await backupService.createDailyBackup();

    if (backup != null) {
      debugPrint('Автоматичний backup створено: ${backup.path}');
    }
  } catch (error) {
    debugPrint('Помилка автоматичного backup: $error');
  }

  runApp(
    MyApp(
      repository: repository,
      backupService: backupService,
      analyticsService: analyticsService,
    ),
  );
}

class MyApp extends StatelessWidget {
  final TaskRepository repository;
  final BackupService backupService;
  final AnalyticsService analyticsService;

  const MyApp({
    super.key,
    required this.repository,
    required this.backupService,
    required this.analyticsService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Менеджер завдань',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: Color(0xFFF5F6FA),
          elevation: 0,
        ),
      ),
      home: HomeScreen(repository: repository),
    );
  }
}
