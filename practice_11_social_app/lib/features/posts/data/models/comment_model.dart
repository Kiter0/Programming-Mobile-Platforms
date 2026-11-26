import 'package:practice_11_social_app/features/posts/domain/entities/comment_entity.dart';

class CommentModel extends CommentEntity {
  const CommentModel({
    required super.id,
    required super.body,
    required super.postId,
    required super.authorName,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    String author = 'Анонім';
    final userObj = json['user'];
    if (userObj is Map<String, dynamic>) {
      author = (userObj['fullName'] ?? userObj['username'] ?? 'Анонім')
          .toString();
    }

    return CommentModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      body: json['body']?.toString() ?? '',
      postId: (json['postId'] as num?)?.toInt() ?? 0,
      authorName: author,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'body': body,
        'postId': postId,
        'user': {'fullName': authorName},
      };
}