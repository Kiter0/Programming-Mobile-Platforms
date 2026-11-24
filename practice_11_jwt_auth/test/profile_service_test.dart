import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import 'package:practice_11_jwt_auth/models/user.dart';
import 'package:practice_11_jwt_auth/services/profile_service.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late ProfileService profileService;

  setUp(() {
    dio = Dio(
      BaseOptions(baseUrl: 'https://reqres.in/api'),
    );

    dioAdapter = DioAdapter(dio: dio);
    dio.httpClientAdapter = dioAdapter;

    profileService = ProfileService(dio: dio);
  });

  group('ProfileService', () {
    test('отримує профіль користувача', () async {
      dioAdapter.onGet(
        '/users/2',
        (server) => server.reply(
          200,
          {
            'data': {
              'id': 2,
              'email': 'janet.weaver@reqres.in',
              'first_name': 'Janet',
              'last_name': 'Weaver',
              'avatar': 'https://example.com/avatar.jpg',
            },
          },
        ),
      );

      final user = await profileService.getProfile(2);

      expect(user.id, 2);
      expect(user.email, 'janet.weaver@reqres.in');
      expect(user.firstName, 'Janet');
      expect(user.lastName, 'Weaver');
    });

    test('повідомляє про некоректну відповідь сервера', () async {
      dioAdapter.onGet(
        '/users/2',
        (server) => server.reply(
          200,
          {'data': null},
        ),
      );

      expect(
        () => profileService.getProfile(2),
        throwsA(isA<Exception>()),
      );
    });

    test('оновлює дані профілю', () async {
      dioAdapter.onPut(
        '/users/2',
        (server) => server.reply(
          200,
          {
            'email': 'updated@example.com',
            'first_name': 'Updated',
            'last_name': 'User',
          },
        ),
        data: {
          'email': 'old@example.com',
          'first_name': 'Old',
          'last_name': 'User',
        },
      );

      const user = User(
        id: 2,
        email: 'old@example.com',
        firstName: 'Old',
        lastName: 'User',
      );

      final result = await profileService.updateProfile(
        userId: 2,
        user: user,
      );

      expect(result.email, 'updated@example.com');
      expect(result.firstName, 'Updated');
      expect(result.lastName, 'User');
    });

    test('відправляє запит на зміну пароля', () async {
      dioAdapter.onPut(
        '/users/2',
        (server) => server.reply(
          200,
          {'password': 'newpassword123'},
        ),
        data: {
          'password': 'newpassword123',
        },
      );

      await expectLater(
        profileService.changePassword(
          userId: 2,
          newPassword: 'newpassword123',
        ),
        completes,
      );
    });
  });
}
