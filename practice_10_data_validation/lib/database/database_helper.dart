import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

    DatabaseHelper._internal();

    @visibleForTesting
    DatabaseHelper.forTesting();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'users.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL,
            phone TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return db.insert('users', user);
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return db.query('users', orderBy: 'id DESC');
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
