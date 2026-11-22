
import 'package:flutter_test/flutter_test.dart';
import 'package:practice_10_file_storage/main.dart';

void main() {
  testWidgets('Notes application starts correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const NotesApp());

    expect(find.text('Мої нотатки'), findsOneWidget);
    expect(find.text('Нова нотатка'), findsOneWidget);
  });
}
