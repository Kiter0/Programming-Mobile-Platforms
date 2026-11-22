import 'tag.dart';

class JournalEntry {
  final int? id;
  final String title;
  final String content;
  final String mood;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;
  final int wordCount;
  final List<Tag> tags;

  JournalEntry({
    this.id,
    required this.title,
    required this.content,
    required this.mood,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isFavorite = false,
    int? wordCount,
    List<Tag>? tags,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       wordCount = wordCount ?? countWords(content),
       tags = tags ?? [];

  static int countWords(String text) {
    final trimmed = text.trim();

    if (trimmed.isEmpty) return 0;

    return trimmed.split(RegExp(r'\s+')).length;
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'mood': mood,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_favorite': isFavorite ? 1 : 0,
      'word_count': countWords(content),
    };
  }

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String,
      mood: map['mood'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      isFavorite: (map['is_favorite'] as num).toInt() == 1,
      wordCount: (map['word_count'] as num).toInt(),
    );
  }

  JournalEntry copyWith({
    int? id,
    String? title,
    String? content,
    String? mood,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    int? wordCount,
    List<Tag>? tags,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      wordCount: wordCount ?? this.wordCount,
      tags: tags ?? this.tags,
    );
  }
}
