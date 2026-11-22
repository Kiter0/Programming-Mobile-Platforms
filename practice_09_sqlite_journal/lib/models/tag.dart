class Tag {
  final int? id;
  final String name;
  final String color;
  final DateTime createdAt;
  final int usageCount;

  Tag({
    this.id,
    required this.name,
    required this.color,
    DateTime? createdAt,
    this.usageCount = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'color': color,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
      id: map['id'] as int?,
      name: map['name'] as String,
      color: map['color'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      usageCount: (map['usage_count'] as num?)?.toInt() ?? 0,
    );
  }
}
