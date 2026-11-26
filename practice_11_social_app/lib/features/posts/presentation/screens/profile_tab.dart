import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:practice_11_social_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:practice_11_social_app/features/posts/presentation/providers/posts_provider.dart';
import 'package:practice_11_social_app/features/posts/presentation/screens/feed_tab.dart';
import 'package:practice_11_social_app/features/posts/presentation/screens/post_detail_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<PostsProvider>().fetchMyPosts(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final postsProvider = context.watch<PostsProvider>();
    final user = auth.user;

    if (user == null) {
      return const Center(child: Text('Користувач не авторизований'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundImage:
                      user.image.isNotEmpty ? NetworkImage(user.image) : null,
                  child: user.image.isEmpty
                      ? const Icon(Icons.person, size: 36)
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  user.fullName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '@${user.username}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(user.email),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => auth.logout(),
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'Вийти з акаунта',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Мої пости (${postsProvider.myPosts.length})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        if (postsProvider.myPosts.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text('У вас ще немає постів')),
          )
        else
          ...postsProvider.myPosts.map(
            (post) => PostCard(
              post: post,
              onLike: () => postsProvider.toggleLike(post.id),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PostDetailScreen(post: post),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}