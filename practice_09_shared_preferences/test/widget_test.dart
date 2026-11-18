import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practice_09_shared_preferences/main.dart';
import 'package:practice_09_shared_preferences/models/user_settings.dart';
import 'package:practice_09_shared_preferences/services/preferences_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Settings app displays all main sections', (tester) async {
    SharedPreferences.setMockInitialValues({});

    final preferences = await PreferencesManager.getInstance();

    await tester.pumpWidget(
      SettingsApp(
        preferences: preferences,
        initialSettings: UserSettings.defaults,
      ),
    );

    await tester.pump();

    expect(find.text('Профіль користувача'), findsOneWidget);
    expect(find.text('Зовнішній вигляд'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Сповіщення'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Сповіщення'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Улюблені категорії'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Улюблені категорії'), findsOneWidget);
  });
}
