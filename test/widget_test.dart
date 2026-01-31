import 'package:flutter_test/flutter_test.dart';
import 'package:ticktock/main.dart';

void main() {
  testWidgets('Smoke test: TickTock loads and shows title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TickTockApp());

    // Verify that the app title is present.
    expect(find.text('TickTock'), findsOneWidget);
  });
}