import 'package:hive/hive.dart';

import '../database/hive_manager.dart';
import '../models/task.dart';

class TaskRepository {
  Box<Task> get _box => HiveManager.tasksBox;

  // Отримання всіх задач.
  List<Task> getAllTasks() {
    try {
      return _box.values.toList();
    } catch (error) {
      throw Exception('Не вдалося отримати задачі: $error');
    }
  }

  // Отримання задач із фільтрацією та сортуванням.
  List<Task> getTasks({
    String? priority,
    bool? isCompleted,
    bool sortByDueDate = true,
  }) {
    try {
      var tasks = getAllTasks();

      if (priority != null && priority != 'all') {
        tasks = tasks.where((task) => task.priority == priority).toList();
      }

      if (isCompleted != null) {
        tasks = tasks.where((task) => task.isCompleted == isCompleted).toList();
      }

      if (sortByDueDate) {
        tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      }

      return tasks;
    } catch (error) {
      throw Exception('Не вдалося відфільтрувати задачі: $error');
    }
  }

  // Додавання нової задачі.
  Future<void> addTask(Task task) async {
    try {
      await _box.add(task);
    } catch (error) {
      throw Exception('Не вдалося додати задачу: $error');
    }
  }

  // Оновлення існуючої задачі.
  Future<void> updateTask(Task task) async {
    try {
      if (!task.isInBox) {
        throw StateError('Задача не збережена у сховищі.');
      }

      await task.save();
    } catch (error) {
      throw Exception('Не вдалося оновити задачу: $error');
    }
  }

  // Видалення задачі.
  Future<void> deleteTask(Task task) async {
    try {
      if (!task.isInBox) {
        throw StateError('Задача не збережена у сховищі.');
      }

      await task.delete();
    } catch (error) {
      throw Exception('Не вдалося видалити задачу: $error');
    }
  }

  // Зміна статусу виконання задачі.
  Future<void> toggleTaskCompletion(Task task) async {
    try {
      task.isCompleted = !task.isCompleted;
      task.completedAt = task.isCompleted ? DateTime.now() : null;

      await task.save();
    } catch (error) {
      throw Exception('Не вдалося змінити статус задачі: $error');
    }
  }

  // Додавання підзадачі.
  Future<void> addSubtask(Task task, String subtask) async {
    try {
      final value = subtask.trim();

      if (value.isEmpty) return;

      task.subtasks = [...task.subtasks, value];
      await task.save();
    } catch (error) {
      throw Exception('Не вдалося додати підзадачу: $error');
    }
  }

  // Видалення підзадачі за індексом.
  Future<void> removeSubtask(Task task, int index) async {
    try {
      if (index < 0 || index >= task.subtasks.length) {
        throw RangeError('Некоректний індекс підзадачі.');
      }

      final subtasks = List<String>.from(task.subtasks);
      subtasks.removeAt(index);

      task.subtasks = subtasks;
      await task.save();
    } catch (error) {
      throw Exception('Не вдалося видалити підзадачу: $error');
    }
  }

  // Видалення всіх задач.
  Future<void> deleteAllTasks() async {
    try {
      await _box.clear();
    } catch (error) {
      throw Exception('Не вдалося видалити всі задачі: $error');
    }
  }
}
