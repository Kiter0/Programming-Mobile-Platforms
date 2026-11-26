import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:practice_11_social_app/features/posts/domain/entities/post_entity.dart';
import 'package:practice_11_social_app/features/posts/presentation/providers/posts_provider.dart';
import 'package:practice_11_social_app/features/posts/presentation/screens/post_detail_screen.dart';
import 'package:practice_11_social_app/shared/widgets/offline_banner.dart';

class FeedTab extends StatefulWidget {
  const FeedTab({super.key});

  @override
  State<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends State<FeedTab> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PostsProvider>();
      if (provider.posts.isEmpty) {
        provider.fetchInitialPosts();
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<PostsProvider>().loadMorePosts();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PostsProvider>();

    return Column(
      children: [
        if (provider.isOffline)
          OfflineBanner(onRetry: provider.fetchInitialPosts),
        Expanded(
          child: RefreshIndicator(
            onRefresh: provider.fetchInitialPosts,
            child: _buildBody(provider),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(PostsProvider provider) {
    if (provider.isLoading && provider.posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.posts.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Center(
            child: Column(
              children: [
                Text(provider.error!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: provider.fetchInitialPosts,
                  child: const Text('Спробувати ще раз'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: provider.posts.length + (provider.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == provider.posts.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final post = provider.posts[index];
        return PostCard(
          post: post,
          onLike: () => provider.toggleLike(post.id),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PostDetailScreen(post: post),
              ),
            );
          },
        );
      },
    );
  }
}

/// Перевикористовувана картка поста для Стрічки, Пошуку та Профілю
class PostCard extends StatelessWidget {
  final PostEntity post;
  final VoidCallback onLike;
  final VoidCallback onTap;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                post.body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (post.tags.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: post.tags
                      .map(
                        (tag) => Chip(
                          label: Text('#$tag', style: const TextStyle(fontSize: 12)),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        ),
                      )
                      .toList(),
                ),
              ],
              const Divider(height: 20),
              Row(
                children: [
                  InkWell(
                    onTap: onLike,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            post.isLikedByMe
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 20,
                            color: post.isLikedByMe ? Colors.red : null,
                          ),
                          const SizedBox(width: 4),
                          Text('${post.likes}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.visibility_outlined, size: 18),
                  const SizedBox(width: 4),
                  Text('${post.views}'),
                  const Spacer(),
                  const Text(
                    'Коментарі →',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}