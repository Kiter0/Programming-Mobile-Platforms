import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:practice_11_social_app/features/posts/presentation/providers/posts_provider.dart';
import 'package:practice_11_social_app/features/posts/presentation/screens/feed_tab.dart';
import 'package:practice_11_social_app/features/posts/presentation/screens/post_detail_screen.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PostsProvider>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: provider.searchPosts,
            decoration: InputDecoration(
              hintText: 'Пошук постів за ключовим словом (напр. love, history)...',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => provider.searchPosts(_searchController.text),
              ),
            ),
          ),
        ),
        Expanded(
          child: provider.isSearching
              ? const Center(child: CircularProgressIndicator())
              : provider.searchResults.isEmpty
                  ? const Center(
                      child: Text('Введіть запит для пошуку постів'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: provider.searchResults.length,
                      itemBuilder: (context, index) {
                        final post = provider.searchResults[index];
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
                    ),
        ),
      ],
    );
  }
}