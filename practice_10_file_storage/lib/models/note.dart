
class Note {
  final String fileName;
  final String title;
  final String content;
  final DateTime lastModified;

  const Note({
    required this.fileName,
    required this.title,
    required this.content,
    required this.lastModified,
  });

  Note copyWith({
    String? fileName,
    String? title,
    String? content,
    DateTime? lastModified,
  }) {
    return Note(
      fileName: fileName ?? this.fileName,
      title: title ?? this.title,
      content: content ?? this.content,
      lastModified: lastModified ?? this.lastModified,
    );
  }
}
