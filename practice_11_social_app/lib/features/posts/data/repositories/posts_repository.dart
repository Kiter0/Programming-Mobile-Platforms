import 'package:dio/dio.dart';
import 'package:practice_11_social_app/core/error/app_exception.dart';
import 'package:practice_11_social_app/core/network/api_endpoints.dart';
import 'package:practice_11_social_app/core/storage/cache_service.dart';
import 'package:practice_11_social_app/features/posts/data/models/comment_model.dart';
import 'package:practice_11_social_app/features/posts/data/models/post_model.dart';

/// Результат завантаження постів із позначкою, чи взято дані з офлайн-кешу
class PostsFetchResult {
  final List<PostModel> posts;
  final int total;
  final bool isFromCache;

  PostsFetchResult({
    required this.posts,
    required this.total,
    required this.isFromCache,
  });
}

/// Offline-aware репозиторій постів і коментарів
class PostsRepository {
  final Dio _dio;
  final CacheService _cacheService;

  PostsRepository({
    required Dio dio,
    required CacheService cacheService,
  })  : _dio = dio,
        _cacheService = cacheService;

  /// Отримання стрічки постів з пагінацією та кешуванням першої сторінки
  Future<PostsFetchResult> getPosts({int limit = 10, int skip = 0}) async {
    const cacheKey = 'feed_posts_first_page';

    if (await _cacheService.isOnline()) {
      try {
        final response = await _dio.get(
          ApiEndpoints.posts,
          queryParameters: {'limit': limit, 'skip': skip},
        );
        final data = response.data as Map<String, dynamic>;
        if (skip == 0) {
          await _cacheService.cache(cacheKey, data);
        }
        return _parsePostsResponse(data, isFromCache: false);
      } on DioException catch (e) {
        if (skip == 0) {
          final cached = await _cacheService.getCached(cacheKey);
          if (cached != null) {
            return _parsePostsResponse(
              cached as Map<String, dynamic>,
              isFromCache: true,
            );
          }
        }
        throw AppException.fromDioException(e);
      }
    } else {
      final cached = await _cacheService.getCached(cacheKey);
      if (cached != null) {
        return _parsePostsResponse(
          cached as Map<String, dynamic>,
          isFromCache: true,
        );
      }
      throw AppException('Немає з\'єднання та кешованих даних');
    }
  }

  /// Пошук постів за запитом GET /posts/search?q=...
  Future<List<PostModel>> searchPosts(String query) async {
    if (!await _cacheService.isOnline()) {
      throw AppException('Пошук недоступний в offline-режимі');
    }
    try {
      final response = await _dio.get(
        ApiEndpoints.searchPosts,
        queryParameters: {'q': query},
      );
      final data = response.data as Map<String, dynamic>;
      return _parsePostsResponse(data, isFromCache: false).posts;
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  /// Пости конкретного користувача GET /posts/user/{userId}
  Future<List<PostModel>> getUserPosts(int userId) async {
    final cacheKey = 'user_posts_$userId';

    if (await _cacheService.isOnline()) {
      try {
        final response = await _dio.get(ApiEndpoints.userPosts(userId));
        final data = response.data as Map<String, dynamic>;
        await _cacheService.cache(cacheKey, data);
        return _parsePostsResponse(data, isFromCache: false).posts;
      } on DioException catch (e) {
        final cached = await _cacheService.getCached(cacheKey);
        if (cached != null) {
          return _parsePostsResponse(
            cached as Map<String, dynamic>,
            isFromCache: true,
          ).posts;
        }
        throw AppException.fromDioException(e);
      }
    } else {
      final cached = await _cacheService.getCached(cacheKey);
      if (cached != null) {
        return _parsePostsResponse(
          cached as Map<String, dynamic>,
          isFromCache: true,
        ).posts;
      }
      return [];
    }
  }

  /// Створення нового поста POST /posts/add
  Future<PostModel> createPost({
    required String title,
    required String body,
    required List<String> tags,
    required int userId,
  }) async {
    if (!await _cacheService.isOnline()) {
      throw AppException('Створення поста потребує інтернет-з\'єднання');
    }
    try {
      final response = await _dio.post(
        ApiEndpoints.addPost,
        data: {
          'title': title,
          'body': body,
          'tags': tags,
          'userId': userId,
        },
      );
      final json = response.data as Map<String, dynamic>;
      return PostModel(
        id: (json['id'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
        title: json['title']?.toString() ?? title,
        body: json['body']?.toString() ?? body,
        tags: tags,
        likes: 0,
        dislikes: 0,
        views: 1,
        userId: userId,
      );
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  /// Отримання коментарів до поста GET /posts/{id}/comments
  Future<List<CommentModel>> getComments(int postId) async {
    final cacheKey = 'post_comments_$postId';

    if (await _cacheService.isOnline()) {
      try {
        final response = await _dio.get(ApiEndpoints.postComments(postId));
        final data = response.data as Map<String, dynamic>;
        await _cacheService.cache(cacheKey, data);
        return _parseComments(data);
      } on DioException catch (e) {
        final cached = await _cacheService.getCached(cacheKey);
        if (cached != null) return _parseComments(cached as Map<String, dynamic>);
        throw AppException.fromDioException(e);
      }
    } else {
      final cached = await _cacheService.getCached(cacheKey);
      if (cached != null) return _parseComments(cached as Map<String, dynamic>);
      return [];
    }
  }

  /// Додавання коментаря POST /comments/add
  Future<CommentModel> addComment({
    required int postId,
    required String body,
    required int userId,
    required String authorName,
  }) async {
    if (!await _cacheService.isOnline()) {
      throw AppException('Додавання коментаря потребує інтернет-з\'єднання');
    }
    try {
      final response = await _dio.post(
        ApiEndpoints.addComment,
        data: {
          'body': body,
          'postId': postId,
          'userId': userId,
        },
      );
      final json = response.data as Map<String, dynamic>;
      return CommentModel(
        id: (json['id'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
        body: json['body']?.toString() ?? body,
        postId: postId,
        authorName: authorName,
      );
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  PostsFetchResult _parsePostsResponse(
    Map<String, dynamic> data, {
    required bool isFromCache,
  }) {
    final list = (data['posts'] as List<dynamic>? ?? [])
        .map((item) => PostModel.fromJson(item as Map<String, dynamic>))
        .toList();
    final total = (data['total'] as num?)?.toInt() ?? list.length;
    return PostsFetchResult(
      posts: list,
      total: total,
      isFromCache: isFromCache,
    );
  }

  List<CommentModel> _parseComments(Map<String, dynamic> data) {
    return (data['comments'] as List<dynamic>? ?? [])
        .map((item) => CommentModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}