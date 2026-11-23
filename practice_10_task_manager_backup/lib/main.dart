import 'package:flutter/material.dart';

import 'database/hive_manager.dart';
import 'repositories/task_repository.dart';
import 'screens/backups_screen.dart';
import 'screens/dashboard_screen.dart';
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
      home: MainNavigation(
        repository: repository,
        backupService: backupService,
        analyticsService: analyticsService,
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  final TaskRepository repository;
  final BackupService backupService;
  final AnalyticsService analyticsService;

  const MainNavigation({
    super.key,
    required this.repository,
    required this.backupService,
    required this.analyticsService,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  int _dataVersion = 0;

  void _refreshData() {
    setState(() {
      _dataVersion++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        key: ValueKey('home_$_dataVersion'),
        repository: widget.repository,
      ),
      DashboardScreen(
        key: ValueKey('dashboard_$_dataVersion'),
        analyticsService: widget.analyticsService,
      ),
      BackupsScreen(
        key: ValueKey('backups_$_dataVersion'),
        backupService: widget.backupService,
        onDataChanged: _refreshData,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.task_alt_outlined),
            selectedIcon: Icon(Icons.task_alt),
            label: 'Задачі',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Аналітика',
          ),
          NavigationDestination(
            icon: Icon(Icons.backup_outlined),
            selectedIcon: Icon(Icons.backup),
            label: 'Backup',
          ),
        ],
      ),
    );
  }
}
