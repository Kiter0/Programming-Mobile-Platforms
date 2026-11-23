import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:practice_10_data_validation/database/database_helper.dart';
import 'package:practice_10_data_validation/repositories/user_repository.dart';
import 'package:practice_10_data_validation/screens/home_screen.dart';

void main() {
  testWidgets('Home screen displays user form', (tester) async {
    final repository = UserRepository(
      databaseHelper: DatabaseHelper.instance,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(repository: repository),
      ),
    );

    expect(find.text('Додати користувача'), findsOneWidget);
    expect(find.text('Збережені користувачі'), findsOneWidget);
  });
}
