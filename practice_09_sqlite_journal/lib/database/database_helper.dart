import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/journal_entry.dart';
import '../models/tag.dart';

class DatabaseHelper {
  // Singleton pattern
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  // Database initialization
  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'journal.db');

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
    );
  }

  // Create database tables and indexes
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE journal_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        mood TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        word_count INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        color TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE entry_tags (
        entry_id INTEGER NOT NULL,
        tag_id INTEGER NOT NULL,
        PRIMARY KEY (entry_id, tag_id),
        FOREIGN KEY (entry_id)
          REFERENCES journal_entries(id)
          ON DELETE CASCADE,
        FOREIGN KEY (tag_id)
          REFERENCES tags(id)
          ON DELETE CASCADE
      )
    ''');

    // Indexes for faster searches
    await db.execute('''
      CREATE INDEX idx_entries_created_at
      ON journal_entries(created_at)
    ''');

    await db.execute('''
      CREATE INDEX idx_entries_mood
      ON journal_entries(mood)
    ''');

    await db.execute('''
      CREATE INDEX idx_tags_name
      ON tags(name)
    ''');

    await db.execute('''
      CREATE INDEX idx_entry_tags_tag_id
      ON entry_tags(tag_id)
    ''');
  }

  // ==============================
  // JOURNAL ENTRIES CRUD
  // ==============================

  // Insert entry with tags using transaction
  Future<int> insertEntry(JournalEntry entry) async {
    final db = await database;

    return await db.transaction((txn) async {
      final entryId = await txn.insert('journal_entries', entry.toMap());

      for (final tag in entry.tags) {
        if (tag.id == null) {
          throw ArgumentError('Tag must have an ID before assigning it.');
        }

        await txn.insert('entry_tags', {'entry_id': entryId, 'tag_id': tag.id});
      }

      return entryId;
    });
  }

  // Load entries with tags using JOIN
  Future<List<JournalEntry>> getEntries({
    String? searchQuery,
    String? mood,
    int? tagId,
    bool? favoritesOnly,
  }) async {
    final db = await database;

    final conditions = <String>[];
    final arguments = <dynamic>[];

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      conditions.add('(e.title LIKE ? OR e.content LIKE ?)');

      final search = '%${searchQuery.trim()}%';
      arguments.addAll([search, search]);
    }

    if (mood != null && mood.isNotEmpty) {
      conditions.add('e.mood = ?');
      arguments.add(mood);
    }

    if (tagId != null) {
      conditions.add('t.id = ?');
      arguments.add(tagId);
    }

    if (favoritesOnly == true) {
      conditions.add('e.is_favorite = 1');
    }

    final whereClause = conditions.isEmpty
        ? ''
        : 'WHERE ${conditions.join(' AND ')}';

    final rows = await db.rawQuery('''
      SELECT
        e.id,
        e.title,
        e.content,
        e.mood,
        e.created_at,
        e.updated_at,
        e.is_favorite,
        e.word_count,
        t.id AS tag_id,
        t.name AS tag_name,
        t.color AS tag_color,
        t.created_at AS tag_created_at
      FROM journal_entries e
      LEFT JOIN entry_tags et ON e.id = et.entry_id
      LEFT JOIN tags t ON et.tag_id = t.id
      $whereClause
      ORDER BY e.created_at DESC
    ''', arguments);

    final entries = <int, JournalEntry>{};

    for (final row in rows) {
      final entryId = row['id'] as int;

      final entry = entries.putIfAbsent(
        entryId,
        () => JournalEntry.fromMap(row),
      );

      if (row['tag_id'] != null) {
        final tag = Tag(
          id: row['tag_id'] as int,
          name: row['tag_name'] as String,
          color: row['tag_color'] as String,
          createdAt: DateTime.parse(row['tag_created_at'] as String),
        );

        if (!entry.tags.any((item) => item.id == tag.id)) {
          entry.tags.add(tag);
        }
      }
    }

    return entries.values.toList();
  }

  // Get a single entry
  Future<JournalEntry?> getEntryById(int id) async {
    final entries = await getEntries();

    for (final entry in entries) {
      if (entry.id == id) return entry;
    }

    return null;
  }

  // Update entry and its tags using transaction
  Future<int> updateEntry(JournalEntry entry) async {
    if (entry.id == null) {
      throw ArgumentError('Entry ID cannot be null.');
    }

    final db = await database;

    return await db.transaction((txn) async {
      final result = await txn.update(
        'journal_entries',
        {...entry.toMap(), 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [entry.id],
      );

      await txn.delete(
        'entry_tags',
        where: 'entry_id = ?',
        whereArgs: [entry.id],
      );

      for (final tag in entry.tags) {
        if (tag.id == null) continue;

        await txn.insert('entry_tags', {
          'entry_id': entry.id,
          'tag_id': tag.id,
        });
      }

      return result;
    });
  }

  // Delete entry
  Future<int> deleteEntry(int id) async {
    final db = await database;

    return await db.delete('journal_entries', where: 'id = ?', whereArgs: [id]);
  }

  // ==============================
  // TAGS CRUD
  // ==============================

  // Insert tag
  Future<int> insertTag(Tag tag) async {
    final db = await database;

    return await db.insert(
      'tags',
      tag.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // Get all tags with usage count
  Future<List<Tag>> getTags() async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT
        t.id,
        t.name,
        t.color,
        t.created_at,
        COUNT(et.entry_id) AS usage_count
      FROM tags t
      LEFT JOIN entry_tags et ON t.id = et.tag_id
      GROUP BY t.id
      ORDER BY t.name ASC
    ''');

    return result.map((row) => Tag.fromMap(row)).toList();
  }

  // Update tag
  Future<int> updateTag(Tag tag) async {
    if (tag.id == null) {
      throw ArgumentError('Tag ID cannot be null.');
    }

    final db = await database;

    return await db.update(
      'tags',
      tag.toMap(),
      where: 'id = ?',
      whereArgs: [tag.id],
    );
  }

  // Delete tag
  Future<int> deleteTag(int id) async {
    final db = await database;

    return await db.delete('tags', where: 'id = ?', whereArgs: [id]);
  }

  // ==============================
  // STATISTICS
  // ==============================

  // Total number of entries
  Future<int> getTotalEntries() async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT COUNT(*) AS total
      FROM journal_entries
    ''');

    return (result.first['total'] as int?) ?? 0;
  }

  // Mood breakdown
  Future<Map<String, int>> getMoodStatistics() async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT mood, COUNT(*) AS total
      FROM journal_entries
      GROUP BY mood
      ORDER BY total DESC
    ''');

    return {
      for (final row in result) row['mood'] as String: row['total'] as int,
    };
  }

  // Entries per month
  Future<Map<String, int>> getMonthlyStatistics() async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT
        strftime('%Y-%m', created_at) AS month,
        COUNT(*) AS total
      FROM journal_entries
      GROUP BY month
      ORDER BY month ASC
    ''');

    return {
      for (final row in result) row['month'] as String: row['total'] as int,
    };
  }

  // Most frequently used tags
  Future<List<Tag>> getMostUsedTags({int limit = 5}) async {
    final db = await database;

    final result = await db.rawQuery(
      '''
      SELECT
        t.id,
        t.name,
        t.color,
        t.created_at,
        COUNT(et.entry_id) AS usage_count
      FROM tags t
      LEFT JOIN entry_tags et ON t.id = et.tag_id
      GROUP BY t.id
      ORDER BY usage_count DESC
      LIMIT ?
    ''',
      [limit],
    );

    return result.map((row) => Tag.fromMap(row)).toList();
  }

  // Writing streak in consecutive days
  Future<int> getWritingStreak() async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT DISTINCT date(created_at) AS entry_date
      FROM journal_entries
      ORDER BY entry_date DESC
    ''');

    if (result.isEmpty) return 0;

    final dates = result
        .map((row) => DateTime.parse(row['entry_date'] as String))
        .toList();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final yesterday = today.subtract(const Duration(days: 1));

    if (dates.first != today && dates.first != yesterday) {
      return 0;
    }

    var streak = 0;
    var expectedDate = dates.first;

    for (final date in dates) {
      if (date != expectedDate) break;

      streak++;
      expectedDate = expectedDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  // Close database
  Future<void> closeDatabase() async {
    final db = await database;

    await db.close();
    _database = null;
  }
}
