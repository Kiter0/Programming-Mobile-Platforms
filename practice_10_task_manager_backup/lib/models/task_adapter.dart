import 'package:hive/hive.dart';

import 'task.dart';

// Hive-адаптер для збереження та читання задач.
class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 3;

  @override
  Task read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{};

    for (var i = 0; i < fieldCount; i++) {
      final fieldId = reader.readByte();
      fields[fieldId] = reader.read();
    }

    return Task(
      title: fields[0] as String,
      description: fields[1] as String,
      dueDate: fields[2] as DateTime,
      priority: fields[3] as String,
      isCompleted: fields[4] as bool,
      subtasks: (fields[5] as List).cast<String>(),
      createdAt: fields[6] as DateTime? ?? DateTime.now(),
      completedAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.dueDate)
      ..writeByte(3)
      ..write(obj.priority)
      ..writeByte(4)
      ..write(obj.isCompleted)
      ..writeByte(5)
      ..write(obj.subtasks)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.completedAt);
  }
}
