import 'package:practice_11_social_app/features/posts/domain/entities/post_entity.dart';

class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.title,
    required super.body,
    required super.tags,
    required super.likes,
    required super.dislikes,
    required super.views,
    required super.userId,
    super.isLikedByMe,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    // DummyJSON повертає reactions як Map {'likes': ..., 'dislikes': ...} або як int
    int likesCount = 0;
    int dislikesCount = 0;
    final reactions = json['reactions'];
    if (reactions is Map<String, dynamic>) {
      likesCount = (reactions['likes'] as num?)?.toInt() ?? 0;
      dislikesCount = (reactions['dislikes'] as num?)?.toInt() ?? 0;
    } else if (reactions is num) {
      likesCount = reactions.toInt();
    }

    return PostModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      likes: likesCount,
      dislikes: dislikesCount,
      views: (json['views'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'tags': tags,
        'reactions': {
          'likes': likes,
          'dislikes': dislikes,
        },
        'views': views,
        'userId': userId,
      };
}