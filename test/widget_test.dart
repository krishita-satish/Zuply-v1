import 'package:flutter_test/flutter_test.dart';
import 'package:zuply/main.dart';

void main() {
  testWidgets('ZuplyApp renders login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ZuplyApp());
    await tester.pumpAndSettle();

    // Verify the app renders successfully with the Zuply branding
    expect(find.text('Zuply'), findsOneWidget);
  });
}
