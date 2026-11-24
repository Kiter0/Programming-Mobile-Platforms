import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mocktail/mocktail.dart';

import 'package:practice_11_jwt_auth/core/token_storage.dart';
import 'package:practice_11_jwt_auth/services/auth_service.dart';

class MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late MockTokenStorage tokenStorage;
  late AuthService authService;

  setUp(() {
    dio = Dio(
      BaseOptions(baseUrl: 'https://reqres.in/api'),
    );

    dioAdapter = DioAdapter(dio: dio);
    dio.httpClientAdapter = dioAdapter;

    tokenStorage = MockTokenStorage();

    authService = AuthService(
      dio: dio,
      tokenStorage: tokenStorage,
    );
  });

  group('AuthService', () {
    test('виконує вхід та зберігає токени', () async {
      dioAdapter.onPost(
        '/login',
        (server) => server.reply(
          200,
          {'token': 'test_access_token'},
        ),
        data: {
          'email': 'eve.holt@reqres.in',
          'password': 'cityslicka',
        },
      );

      when(
        () => tokenStorage.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        ),
      ).thenAnswer((_) async {});

      await authService.login(
        email: 'eve.holt@reqres.in',
        password: 'cityslicka',
      );

      verify(
        () => tokenStorage.saveTokens(
          accessToken: 'test_access_token',
          refreshToken: 'test_access_token',
        ),
      ).called(1);
    });

    test('виконує реєстрацію та зберігає токени', () async {
      dioAdapter.onPost(
        '/register',
        (server) => server.reply(
          200,
          {'token': 'registered_token'},
        ),
        data: {
          'email': 'test@example.com',
          'password': 'password123',
        },
      );

      when(
        () => tokenStorage.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        ),
      ).thenAnswer((_) async {});

      await authService.register(
        email: 'test@example.com',
        password: 'password123',
      );

      verify(
        () => tokenStorage.saveTokens(
          accessToken: 'registered_token',
          refreshToken: 'registered_token',
        ),
      ).called(1);
    });

    test('повідомляє про відсутність токена під час входу', () async {
      dioAdapter.onPost(
        '/login',
        (server) => server.reply(
          200,
          {'message': 'Missing token'},
        ),
        data: {
          'email': 'eve.holt@reqres.in',
          'password': 'cityslicka',
        },
      );

      expect(
        () => authService.login(
          email: 'eve.holt@reqres.in',
          password: 'cityslicka',
        ),
        throwsA(isA<Exception>()),
      );

      verifyNever(
        () => tokenStorage.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        ),
      );
    });

    test('виконує вихід та очищує токени', () async {
      when(
        () => tokenStorage.clearTokens(),
      ).thenAnswer((_) async {});

      await authService.logout();

      verify(
        () => tokenStorage.clearTokens(),
      ).called(1);
    });

    test('повертає true, якщо користувач авторизований', () async {
      when(
        () => tokenStorage.hasTokens(),
      ).thenAnswer((_) async => true);

      final result = await authService.isAuthenticated();

      expect(result, isTrue);
    });

    test('повертає false, якщо користувач не авторизований', () async {
      when(
        () => tokenStorage.hasTokens(),
      ).thenAnswer((_) async => false);

      final result = await authService.isAuthenticated();

      expect(result, isFalse);
    });
  });
}
