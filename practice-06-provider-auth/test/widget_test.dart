// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.


import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:practice_06_provider_auth/main.dart';
import 'package:practice_06_provider_auth/models/auth_model.dart';
import 'package:practice_06_provider_auth/models/profile_model.dart';
import 'package:practice_06_provider_auth/services/fake_auth_api.dart';

void main() {
  testWidgets('Login screen is displayed initially', (tester) async {
    final api = FakeAuthApi();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthModel>(
            create: (_) => AuthModel(api),
          ),
          ChangeNotifierProvider<ProfileModel>(
            create: (_) => ProfileModel(api),
          ),
        ],
        child: const AuthApp(),
      ),
    );

    expect(find.text('Вхід у застосунок'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Пароль'), findsOneWidget);
    expect(find.text('Увійти'), findsOneWidget);
  });
}