import 'package:hive_flutter/hive_flutter.dart';

import '../models/task.dart';
import '../models/task_adapter.dart';

class HiveManager {
  static const String tasksBoxName = 'tasks';

  static Future<void> initialize() async {
    try {
      await Hive.initFlutter();

      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(TaskAdapter());
      }

      if (!Hive.isBoxOpen(tasksBoxName)) {
        await Hive.openBox<Task>(tasksBoxName);
      }
    } catch (error) {
      throw Exception('Не вдалося ініціалізувати Hive: $error');
    }
  }

  static Box<Task> get tasksBox {
    if (!Hive.isBoxOpen(tasksBoxName)) {
      throw StateError('Сховище задач ще не відкрите.');
    }

    return Hive.box<Task>(tasksBoxName);
  }

  static Future<void> close() async {
    try {
      await Hive.close();
    } catch (error) {
      throw Exception('Не вдалося закрити Hive: $error');
    }
  }
}
