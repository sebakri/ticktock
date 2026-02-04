import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticktock/models/time_block.dart';
import 'package:ticktock/widgets/edit_session_dialog.dart';

void main() {
  testWidgets('EditSessionDialog shows initial values and saves changes', (WidgetTester tester) async {
    // Set a very large surface size
    await tester.binding.setSurfaceSize(const Size(1200, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final startTime = DateTime(2026, 2, 4, 10, 0);
    final endTime = DateTime(2026, 2, 4, 11, 0);
    final block = TimeBlock(
      id: 1,
      taskId: 1,
      name: 'Original Name',
      startTime: startTime,
      endTime: endTime,
    );

    String? savedName;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: EditSessionDialog(
              block: block,
              onSave: (name, start, end) {
                savedName = name;
              },
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify initial values
    expect(find.text('Original Name'), findsOneWidget);

    // Change name
    await tester.enterText(find.byType(TextField), 'New Session Name');
    
    // Tap Save
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(savedName, 'New Session Name');
  });

  testWidgets('EditSessionDialog allows clicking date and time pickers', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final block = TimeBlock(
      startTime: DateTime(2026, 2, 4, 10, 0),
      endTime: DateTime(2026, 2, 4, 11, 0),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: EditSessionDialog(
              block: block,
              onSave: (_, __, ___) {},
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Open Date Picker
    await tester.tap(find.byIcon(Icons.calendar_today_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Open Start Time Picker
    await tester.tap(find.text('10:00 AM'));
    await tester.pumpAndSettle();
    expect(find.byType(TimePickerDialog), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
  });
}