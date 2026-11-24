import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/user.dart';

class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  static const Duration timeoutDuration = Duration(seconds: 10);

  final http.Client _client;

  ApiService({http.Client? client})
      : _client = client ?? http.Client();

  Future<List<User>> getUsers() async {
    final response = await _sendRequest(
      () => _client.get(Uri.parse('$baseUrl/users')),
    );

    final data = _decodeJson(response);

    if (data is! List) {
      throw ApiException('Некоректний формат списку користувачів.');
    }

    return data.map((item) {
      if (item is! Map<String, dynamic>) {
        throw ApiException('Некоректні дані користувача.');
      }
      return User.fromJson(item);
    }).toList();
  }

  Future<User> getUserById(int id) async {
    final response = await _sendRequest(
      () => _client.get(Uri.parse('$baseUrl/users/$id')),
    );

    final data = _decodeJson(response);

    if (data is! Map<String, dynamic>) {
      throw ApiException('Некоректний формат даних користувача.');
    }

    return User.fromJson(data);
  }

  Future<User> createUser(User user) async {
    final response = await _sendRequest(
      () => _client.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(user.toJson()),
      ),
    );

    final data = _decodeJson(response);

    if (data is! Map<String, dynamic>) {
      throw ApiException('Некоректна відповідь сервера.');
    }

    return User.fromJson(data);
  }

  Future<User> updateUser(int id, User user) async {
    final response = await _sendRequest(
      () => _client.put(
        Uri.parse('$baseUrl/users/$id'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(user.toJson()),
      ),
    );

    final data = _decodeJson(response);

    if (data is! Map<String, dynamic>) {
      throw ApiException('Некоректна відповідь сервера.');
    }

    return User.fromJson(data);
  }

  Future<void> deleteUser(int id) async {
    await _sendRequest(
      () => _client.delete(Uri.parse('$baseUrl/users/$id')),
    );
  }

  Future<http.Response> _sendRequest(
    Future<http.Response> Function() request,
  ) async {
    try {
      final response = await request().timeout(timeoutDuration);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        switch (response.statusCode) {
          case 404:
            throw ApiException('Ресурс не знайдено (404).');
          case 500:
            throw ApiException('Помилка сервера (500).');
          default:
            throw ApiException(
              'Помилка HTTP: ${response.statusCode}.',
            );
        }
      }

      return response;
    } on TimeoutException {
      throw ApiException('Час очікування відповіді перевищено (10 секунд).');
    } on http.ClientException {
      throw ApiException(
        'Не вдалося підключитися до сервера. Перевірте інтернет-з’єднання.',
      );
    }
  }

  dynamic _decodeJson(http.Response response) {
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw ApiException('Сервер повернув некоректний JSON.');
    }
  }

  void dispose() {
    _client.close();
  }
}
