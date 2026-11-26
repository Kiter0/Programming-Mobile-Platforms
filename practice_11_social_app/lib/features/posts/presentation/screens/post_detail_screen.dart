import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:practice_11_social_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:practice_11_social_app/features/posts/domain/entities/post_entity.dart';
import 'package:practice_11_social_app/features/posts/presentation/providers/posts_provider.dart';

/// Екран деталей поста з реакціями, тегами, списком коментарів і додаванням нового
class PostDetailScreen extends StatefulWidget {
  final PostEntity post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentController = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostsProvider>().fetchComments(widget.post.id);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    setState(() => _isSending = true);
    final success = await context.read<PostsProvider>().addComment(
          postId: widget.post.id,
          body: text,
          userId: user.id,
          authorName: user.fullName,
        );
    setState(() => _isSending = false);

    if (success && mounted) {
      _commentController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Коментар додано')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PostsProvider>();
    // Отримуємо актуальний стан поста (щоб оновлювався лічильник лайків)
    final currentPost = provider.posts.firstWhere(
      (p) => p.id == widget.post.id,
      orElse: () => widget.post,
    );
    final comments = provider.commentsFor(widget.post.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Деталі поста')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  currentPost.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  currentPost.body,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: currentPost.tags
                      .map((t) => Chip(label: Text('#$t')))
                      .toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ActionChip(
                      avatar: Icon(
                        currentPost.isLikedByMe
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: currentPost.isLikedByMe ? Colors.red : null,
                        size: 18,
                      ),
                      label: Text('Лайки: ${currentPost.likes}'),
                      onPressed: () => provider.toggleLike(currentPost.id),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      avatar: const Icon(Icons.thumb_down_outlined, size: 18),
                      label: Text('Дизлайки: ${currentPost.dislikes}'),
                    ),
                  ],
                ),
                const Divider(height: 32),
                Text(
                  'Коментарі (${comments.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                if (provider.isLoadingComments && comments.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else if (comments.isEmpty)
                  const Text('Коментарів поки немає. Будьте першим!')
                else
                  ...comments.map(
                    (c) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person, size: 20),
                        ),
                        title: Text(
                          c.authorName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(c.body),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Написати коментар...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _isSending ? null : _sendComment,
                    icon: _isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}