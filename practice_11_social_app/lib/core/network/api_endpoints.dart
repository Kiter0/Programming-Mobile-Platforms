/// Конфігурація базового URL та ендпоінтів DummyJSON API
class ApiEndpoints {
  static const String baseUrl = 'https://dummyjson.com';

  // Авторизація
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String me = '/auth/me';

  // Пости
  static const String posts = '/posts';
  static const String searchPosts = '/posts/search';
  static const String addPost = '/posts/add';
  static String userPosts(int userId) => '/posts/user/$userId';
  static String postComments(int postId) => '/posts/$postId/comments';

  // Коментарі
  static const String addComment = '/comments/add';
}