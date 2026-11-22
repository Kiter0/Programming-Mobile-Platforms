import 'package:flutter_test/flutter_test.dart';
import 'package:practice_09_sqlite_journal/main.dart';

void main() {
  testWidgets('Journal app starts successfully', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const JournalApp());

    expect(find.text('My Journal'), findsOneWidget);
    expect(find.text('Your personal space'), findsOneWidget);
  });
}