class PostEntity {
  final int id;
  final String title;
  final String body;
  final List<String> tags;
  final int likes;
  final int dislikes;
  final int views;
  final int userId;
  final bool isLikedByMe;

  const PostEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.tags,
    required this.likes,
    required this.dislikes,
    required this.views,
    required this.userId,
    this.isLikedByMe = false,
  });

  PostEntity copyWith({
    int? likes,
    bool? isLikedByMe,
  }) {
    return PostEntity(
      id: id,
      title: title,
      body: body,
      tags: tags,
      likes: likes ?? this.likes,
      dislikes: dislikes,
      views: views,
      userId: userId,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
    );
  }
}