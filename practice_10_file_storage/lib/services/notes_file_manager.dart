
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/note.dart';

class NotesFileManager {
  static const String _directoryName = 'notes';
  static const String _fileExtension = '.txt';

  Future<Directory> get _notesDirectory async {
    final appDirectory = await getApplicationDocumentsDirectory();

    final directory = Directory(
      '${appDirectory.path}/$_directoryName',
    );

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return directory;
  }

  String _sanitizeFileName(String name) {
    final sanitized = name
        .trim()
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_');

    return sanitized.isEmpty ? 'Нова_нотатка' : sanitized;
  }

  Future<File> _getFile(String fileName) async {
    final directory = await _notesDirectory;
    return File('${directory.path}/$fileName');
  }

  // Створення нової нотатки.
  Future<Note> createNote(String title, String content) async {
    try {
      final safeName = _sanitizeFileName(title);
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final fileName = '${safeName}_$timestamp$_fileExtension';
      final file = await _getFile(fileName);

      await file.writeAsString(content);

      return Note(
        fileName: fileName,
        title: title.trim(),
        content: content,
        lastModified: await file.lastModified(),
      );
    } catch (e) {
      throw Exception('Не вдалося створити нотатку: $e');
    }
  }

  // Читання вмісту нотатки.
  Future<String> readNote(String fileName) async {
    try {
      final file = await _getFile(fileName);

      if (!await file.exists()) {
        throw Exception('Файл нотатки не знайдено');
      }

      return await file.readAsString();
    } catch (e) {
      throw Exception('Не вдалося прочитати нотатку: $e');
    }
  }

  // Оновлення вмісту нотатки.
  Future<void> updateNote(String fileName, String content) async {
    try {
      final file = await _getFile(fileName);

      if (!await file.exists()) {
        throw Exception('Файл нотатки не знайдено');
      }

      await file.writeAsString(content);
    } catch (e) {
      throw Exception('Не вдалося оновити нотатку: $e');
    }
  }

  // Видалення нотатки.
  Future<void> deleteNote(String fileName) async {
    try {
      final file = await _getFile(fileName);

      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Не вдалося видалити нотатку: $e');
    }
  }

  // Перейменування нотатки.
  Future<Note> renameNote(String oldFileName, String newTitle) async {
    try {
      final oldFile = await _getFile(oldFileName);

      if (!await oldFile.exists()) {
        throw Exception('Файл нотатки не знайдено');
      }

      final safeName = _sanitizeFileName(newTitle);
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final newFileName = '${safeName}_$timestamp$_fileExtension';
      final newFile = await oldFile.rename(
        '${oldFile.parent.path}/$newFileName',
      );

      return Note(
        fileName: newFileName,
        title: newTitle.trim(),
        content: await newFile.readAsString(),
        lastModified: await newFile.lastModified(),
      );
    } catch (e) {
      throw Exception('Не вдалося перейменувати нотатку: $e');
    }
  }

  // Отримання списку всіх нотаток.
  Future<List<Note>> getAllNotes() async {
    try {
      final directory = await _notesDirectory;

      // listSync() отримує вміст директорії.
      final files = directory
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith(_fileExtension))
          .toList();

      final notes = <Note>[];

      for (final file in files) {
        final fileName = file.uri.pathSegments.last;
        final title = fileName.substring(
          0,
          fileName.length - _fileExtension.length,
        );

        notes.add(
          Note(
            fileName: fileName,
            title: title,
            content: await file.readAsString(),
            lastModified: await file.lastModified(),
          ),
        );
      }

      notes.sort(
        (a, b) => b.lastModified.compareTo(a.lastModified),
      );

      return notes;
    } catch (e) {
      throw Exception('Не вдалося отримати список нотаток: $e');
    }
  }

  // Отримання розміру файлу в байтах.
  Future<int> getNoteSize(String fileName) async {
    try {
      final file = await _getFile(fileName);

      if (!await file.exists()) {
        return 0;
      }

      return await file.length();
    } catch (e) {
      throw Exception('Не вдалося отримати розмір файлу: $e');
    }
  }

  // Отримання дати останньої модифікації.
  Future<DateTime> getNoteLastModified(String fileName) async {
    try {
      final file = await _getFile(fileName);
      return await file.lastModified();
    } catch (e) {
      throw Exception('Не вдалося отримати дату зміни: $e');
    }
  }

  // Експорт нотатки у JSON.
  Future<String> exportNoteToJson(String fileName) async {
    try {
      final file = await _getFile(fileName);

      if (!await file.exists()) {
        throw Exception('Файл нотатки не знайдено');
      }

      final note = Note(
        fileName: fileName,
        title: fileName.replaceAll(_fileExtension, ''),
        content: await file.readAsString(),
        lastModified: await file.lastModified(),
      );

      final jsonData = {
        'fileName': note.fileName,
        'title': note.title,
        'content': note.content,
        'lastModified': note.lastModified.toIso8601String(),
      };

      return const JsonEncoder.withIndent('  ').convert(jsonData);
    } catch (e) {
      throw Exception('Не вдалося експортувати нотатку: $e');
    }
  }

  // Пошук нотаток за назвою або вмістом.
  Future<List<Note>> searchNotes(String query) async {
    final notes = await getAllNotes();
    final normalizedQuery = query.toLowerCase().trim();

    if (normalizedQuery.isEmpty) {
      return notes;
    }

    return notes.where((note) {
      return note.title.toLowerCase().contains(normalizedQuery) ||
          note.content.toLowerCase().contains(normalizedQuery);
    }).toList();
  }

  // Фільтрація нотаток за датою.
  Future<List<Note>> filterNotesByDate(DateTime date) async {
    final notes = await getAllNotes();

    return notes.where((note) {
      return note.lastModified.year == date.year &&
          note.lastModified.month == date.month &&
          note.lastModified.day == date.day;
    }).toList();
  }
}
