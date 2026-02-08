import 'package:flutter_test/flutter_test.dart';
import 'package:raah_app/app.dart';

void main() {
  testWidgets('Raah app smoke test', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const RaahApp());

    // Verify the app title shows on login screen
    expect(find.text('Raah'), findsOneWidget);
  });
}
