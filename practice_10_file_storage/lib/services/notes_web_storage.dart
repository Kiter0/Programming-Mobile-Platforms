
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/note.dart';

class NotesWebStorage {
  static const String _storageKey = 'saved_notes';

  Future<List<Map<String, dynamic>>> _readData() async {
    final preferences = await SharedPreferences.getInstance();
    final jsonString = preferences.getString(_storageKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(jsonString) as List;

    return decoded
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<void> _saveData(List<Map<String, dynamic>> data) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      _storageKey,
      jsonEncode(data),
    );
  }

  Note _toNote(Map<String, dynamic> data) {
    return Note(
      fileName: data['fileName'] as String,
      title: data['title'] as String,
      content: data['content'] as String,
      lastModified: DateTime.parse(data['lastModified'] as String),
    );
  }

  // Створення нотатки.
  Future<Note> createNote(String title, String content) async {
    try {
      final data = await _readData();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final fileName = 'note_$timestamp.txt';

      final note = Note(
        fileName: fileName,
        title: title.trim(),
        content: content,
        lastModified: DateTime.now(),
      );

      data.add({
        'fileName': note.fileName,
        'title': note.title,
        'content': note.content,
        'lastModified': note.lastModified.toIso8601String(),
      });

      await _saveData(data);

      return note;
    } catch (e) {
      throw Exception('Не вдалося створити нотатку: $e');
    }
  }

  // Читання нотатки.
  Future<String> readNote(String fileName) async {
    try {
      final data = await _readData();

      final note = data.firstWhere(
        (item) => item['fileName'] == fileName,
        orElse: () => throw Exception('Нотатку не знайдено'),
      );

      return note['content'] as String;
    } catch (e) {
      throw Exception('Не вдалося прочитати нотатку: $e');
    }
  }

  // Оновлення вмісту.
  Future<void> updateNote(String fileName, String content) async {
    try {
      final data = await _readData();

      final index = data.indexWhere(
        (item) => item['fileName'] == fileName,
      );

      if (index == -1) {
        throw Exception('Нотатку не знайдено');
      }

      data[index]['content'] = content;
      data[index]['lastModified'] = DateTime.now().toIso8601String();

      await _saveData(data);
    } catch (e) {
      throw Exception('Не вдалося оновити нотатку: $e');
    }
  }

  // Видалення нотатки.
  Future<void> deleteNote(String fileName) async {
    try {
      final data = await _readData();

      data.removeWhere(
        (item) => item['fileName'] == fileName,
      );

      await _saveData(data);
    } catch (e) {
      throw Exception('Не вдалося видалити нотатку: $e');
    }
  }

  // Перейменування нотатки.
  Future<Note> renameNote(String oldFileName, String newTitle) async {
    try {
      final data = await _readData();

      final index = data.indexWhere(
        (item) => item['fileName'] == oldFileName,
      );

      if (index == -1) {
        throw Exception('Нотатку не знайдено');
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newFileName = 'note_$timestamp.txt';

      data[index]['fileName'] = newFileName;
      data[index]['title'] = newTitle.trim();
      data[index]['lastModified'] = DateTime.now().toIso8601String();

      await _saveData(data);

      return _toNote(data[index]);
    } catch (e) {
      throw Exception('Не вдалося перейменувати нотатку: $e');
    }
  }

  // Отримання всіх нотаток.
  Future<List<Note>> getAllNotes() async {
    try {
      final data = await _readData();
      final notes = data.map(_toNote).toList();

      notes.sort(
        (a, b) => b.lastModified.compareTo(a.lastModified),
      );

      return notes;
    } catch (e) {
      throw Exception('Не вдалося отримати список нотаток: $e');
    }
  }

  // Отримання розміру вмісту нотатки.
  Future<int> getNoteSize(String fileName) async {
    final data = await _readData();

    final note = data.firstWhere(
      (item) => item['fileName'] == fileName,
      orElse: () => <String, dynamic>{},
    );

    if (note.isEmpty) return 0;

    return utf8.encode(note['content'] as String).length;
  }

  // Отримання дати останньої зміни.
  Future<DateTime> getNoteLastModified(String fileName) async {
    final data = await _readData();

    final note = data.firstWhere(
      (item) => item['fileName'] == fileName,
      orElse: () => throw Exception('Нотатку не знайдено'),
    );

    return DateTime.parse(note['lastModified'] as String);
  }

  // Експорт нотатки у JSON.
  Future<String> exportNoteToJson(String fileName) async {
    try {
      final data = await _readData();

      final note = data.firstWhere(
        (item) => item['fileName'] == fileName,
        orElse: () => throw Exception('Нотатку не знайдено'),
      );

      return const JsonEncoder.withIndent('  ').convert(note);
    } catch (e) {
      throw Exception('Не вдалося експортувати нотатку: $e');
    }
  }

  // Пошук за назвою або вмістом.
  Future<List<Note>> searchNotes(String query) async {
    final notes = await getAllNotes();
    final normalizedQuery = query.toLowerCase().trim();

    if (normalizedQuery.isEmpty) return notes;

    return notes.where((note) {
      return note.title.toLowerCase().contains(normalizedQuery) ||
          note.content.toLowerCase().contains(normalizedQuery);
    }).toList();
  }

  // Фільтрація за датою.
  Future<List<Note>> filterNotesByDate(DateTime date) async {
    final notes = await getAllNotes();

    return notes.where((note) {
      return note.lastModified.year == date.year &&
          note.lastModified.month == date.month &&
          note.lastModified.day == date.day;
    }).toList();
  }
}
