class CommentEntity {
  final int id;
  final String body;
  final int postId;
  final String authorName;

  const CommentEntity({
    required this.id,
    required this.body,
    required this.postId,
    required this.authorName,
  });
}