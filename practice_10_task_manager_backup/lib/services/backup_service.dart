import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../models/task.dart';
import '../repositories/task_repository.dart';

class BackupService {
  static const String _backupDirectoryName = 'task_backups';
  static const String _lastBackupDateKey = 'last_backup_date';

  final TaskRepository _repository;

  BackupService(this._repository);

  // Отримання папки для резервних копій.
  Future<Directory> get _backupDirectory async {
    try {
      final appDirectory = await getApplicationDocumentsDirectory();

      final directory = Directory('${appDirectory.path}/$_backupDirectoryName');

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      return directory;
    } catch (error) {
      throw Exception('Не вдалося отримати папку backup: $error');
    }
  }

  // Експорт усіх задач у JSON-файл.
  Future<File> exportBackup() async {
    try {
      final tasks = _repository.getAllTasks();

      final backupData = {
        'version': 1,
        'createdAt': DateTime.now().toIso8601String(),
        'tasks': tasks.map((task) => task.toJson()).toList(),
      };

      final directory = await _backupDirectory;
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');

      final file = File('${directory.path}/backup_$timestamp.json');

      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(backupData),
      );

      return file;
    } catch (error) {
      throw Exception('Не вдалося створити backup: $error');
    }
  }

  // Вибір JSON-файлу та імпорт задач.
  Future<int?> importBackup() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (files.isEmpty) {
        return null;
      }

      final selectedFile = files.first;
      final bytes = await selectedFile.readAsBytes();
      final content = utf8.decode(bytes);

      final decoded = jsonDecode(content);

      if (decoded is! Map<String, dynamic> || decoded['tasks'] is! List) {
        throw const FormatException('Некоректний формат backup-файлу.');
      }

      final tasksJson = decoded['tasks'] as List;

      final tasks = tasksJson.map((item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Некоректний формат задачі.');
        }

        return Task.fromJson(item);
      }).toList();

      // Перевірка пріоритетів перед імпортом.
      for (final task in tasks) {
        if (!{'low', 'medium', 'high'}.contains(task.priority)) {
          throw const FormatException('Невідомий пріоритет задачі.');
        }
      }

      // Збереження поточних даних для можливого відновлення.
      final currentTasks = _repository.getAllTasks();

      try {
        await _repository.deleteAllTasks();

        for (final task in tasks) {
          await _repository.addTask(task);
        }
      } catch (error) {
        // Відкат змін у разі помилки імпорту.
        await _repository.deleteAllTasks();

        for (final task in currentTasks) {
          await _repository.addTask(task);
        }

        rethrow;
      }

      return tasks.length;
    } on FormatException {
      rethrow;
    } catch (error) {
      throw Exception('Не вдалося імпортувати backup: $error');
    }
  }

  // Отримання списку резервних копій.
  Future<List<File>> getBackupFiles() async {
    try {
      final directory = await _backupDirectory;

      final files = directory
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.json'))
          .toList();

      files.sort(
        (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
      );

      return files;
    } catch (error) {
      throw Exception('Не вдалося отримати список backup-файлів: $error');
    }
  }

  // Видалення резервної копії.
  Future<void> deleteBackup(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (error) {
      throw Exception('Не вдалося видалити backup: $error');
    }
  }

  // Автоматичний backup один раз на день.
  Future<File?> createDailyBackup() async {
    try {
      final preferences = await _getPreferencesFile();
      final today = _dateKey(DateTime.now());

      if (await preferences.exists()) {
        final lastDate = (await preferences.readAsString()).trim();

        if (lastDate == today) {
          return null;
        }
      }

      final file = await exportBackup();

      await preferences.writeAsString(today);

      return file;
    } catch (error) {
      throw Exception('Не вдалося створити щоденний backup: $error');
    }
  }

  Future<File> _getPreferencesFile() async {
    final directory = await getApplicationDocumentsDirectory();

    return File('${directory.path}/$_lastBackupDateKey.txt');
  }

  String _dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}
