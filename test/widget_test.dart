import 'package:flutter_test/flutter_test.dart';
import 'package:ticktock/app.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    // Initialize sqflite for ffi
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('Smoke test: TickTock loads and shows title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TickTockApp());

    // Verify that the app title is present.
    expect(find.text('TickTock'), findsOneWidget);
  });
}
