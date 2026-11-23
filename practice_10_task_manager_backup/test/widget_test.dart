import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:practice_10_task_manager_backup/main.dart';
import 'package:practice_10_task_manager_backup/database/hive_manager.dart';
import 'package:practice_10_task_manager_backup/repositories/task_repository.dart';
import 'package:practice_10_task_manager_backup/services/analytics_service.dart';
import 'package:practice_10_task_manager_backup/services/backup_service.dart';
import 'package:practice_10_task_manager_backup/models/task.dart';
import 'package:practice_10_task_manager_backup/models/task_adapter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    Hive.init('./test_hive');

    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(TaskAdapter());
    }

    await Hive.openBox<Task>(HiveManager.tasksBoxName);
  });

  tearDownAll(() async {
    await Hive.close();
  });

  testWidgets('Застосунок запускається', (tester) async {
    final repository = TaskRepository();

    await tester.pumpWidget(
      MyApp(
        repository: repository,
        backupService: BackupService(repository),
        analyticsService: AnalyticsService(repository),
      ),
    );

    expect(find.text('Менеджер завдань'), findsOneWidget);
  });
}
