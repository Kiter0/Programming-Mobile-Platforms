import 'package:flutter/material.dart';
import 'package:practice_11_social_app/core/error/app_exception.dart';
import 'package:practice_11_social_app/features/posts/data/repositories/posts_repository.dart';
import 'package:practice_11_social_app/features/posts/domain/entities/comment_entity.dart';
import 'package:practice_11_social_app/features/posts/domain/entities/post_entity.dart';

/// State management для стрічки постів, пагінації, пошуку, лайків та коментарів
class PostsProvider extends ChangeNotifier {
  final PostsRepository _repository;

  PostsProvider(this._repository);

  final List<PostEntity> _posts = [];
  List<PostEntity> _searchResults = [];
  List<PostEntity> _myPosts = [];
  final Map<int, List<CommentEntity>> _commentsByPost = {};

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isSearching = false;
  bool _isLoadingComments = false;
  bool _isOffline = false;
  bool _hasMore = true;
  int _total = 0;
  String? _error;

  static const int _pageSize = 10;

  List<PostEntity> get posts => List.unmodifiable(_posts);
  List<PostEntity> get searchResults => List.unmodifiable(_searchResults);
  List<PostEntity> get myPosts => List.unmodifiable(_myPosts);
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isSearching => _isSearching;
  bool get isLoadingComments => _isLoadingComments;
  bool get isOffline => _isOffline;
  bool get hasMore => _hasMore;
  String? get error => _error;

  List<CommentEntity> commentsFor(int postId) =>
      List.unmodifiable(_commentsByPost[postId] ?? []);

  /// Первинне завантаження або pull-to-refresh стрічки
  Future<void> fetchInitialPosts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.getPosts(limit: _pageSize, skip: 0);
      _posts
        ..clear()
        ..addAll(result.posts);
      _total = result.total;
      _isOffline = result.isFromCache;
      _hasMore = !result.isFromCache && _posts.length < _total;
    } on AppException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Підвантаження наступної сторінки постів (пагінація)
  Future<void> loadMorePosts() async {
    if (_isLoadingMore || !_hasMore || _isOffline) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _repository.getPosts(
        limit: _pageSize,
        skip: _posts.length,
      );
      _posts.addAll(result.posts);
      _total = result.total;
      _hasMore = _posts.length < _total;
    } catch (_) {
      // Тихо ігноруємо помилку довантаження при скролі
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Перемикання лайка на пості (оновлює пост у всіх списках)
  void toggleLike(int postId) {
    void updateList(List<PostEntity> list) {
      final idx = list.indexWhere((p) => p.id == postId);
      if (idx != -1) {
        final current = list[idx];
        final nextLiked = !current.isLikedByMe;
        list[idx] = current.copyWith(
          isLikedByMe: nextLiked,
          likes: current.likes + (nextLiked ? 1 : -1),
        );
      }
    }

    updateList(_posts);
    updateList(_searchResults);
    updateList(_myPosts);
    notifyListeners();
  }

  /// Пошук постів
  Future<void> searchPosts(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isSearching = true;
    _error = null;
    notifyListeners();

    try {
      _searchResults = await _repository.searchPosts(trimmed);
    } on AppException catch (e) {
      _error = e.message;
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  /// Завантаження власних постів поточного користувача
  Future<void> fetchMyPosts(int userId) async {
    try {
      _myPosts = await _repository.getUserPosts(userId);
      notifyListeners();
    } catch (_) {}
  }

  /// Створення нового поста та додавання у верх стрічки
  Future<bool> createPost({
    required String title,
    required String body,
    required List<String> tags,
    required int userId,
  }) async {
    try {
      final newPost = await _repository.createPost(
        title: title,
        body: body,
        tags: tags,
        userId: userId,
      );
      _posts.insert(0, newPost);
      _myPosts.insert(0, newPost);
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  /// Завантаження коментарів до поста
  Future<void> fetchComments(int postId) async {
    _isLoadingComments = true;
    notifyListeners();

    try {
      final items = await _repository.getComments(postId);
      _commentsByPost[postId] = items;
    } catch (_) {
    } finally {
      _isLoadingComments = false;
      notifyListeners();
    }
  }

  /// Додавання нового коментаря до поста
  Future<bool> addComment({
    required int postId,
    required String body,
    required int userId,
    required String authorName,
  }) async {
    try {
      final created = await _repository.addComment(
        postId: postId,
        body: body,
        userId: userId,
        authorName: authorName,
      );
      final currentList = _commentsByPost[postId] ?? [];
      _commentsByPost[postId] = [...currentList, created];
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }
}