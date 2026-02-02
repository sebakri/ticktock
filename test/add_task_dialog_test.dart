import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticktock/widgets/add_task_dialog.dart';

void main() {
  testWidgets('AddTaskDialog validation and color filtering', (WidgetTester tester) async {
    String? savedTitle;
    String? savedDesc;
    Color? savedColor;

    final palette = [Colors.red, Colors.blue, Colors.green];
    final existingTitles = ['existing task'];

    await tester.pumpWidget(MaterialApp(
      home: AddTaskDialog(
        palette: palette,
        existingTitles: existingTitles,
        onSave: (t, d, c) {
          savedTitle = t;
          savedDesc = d;
          savedColor = c;
        },
      ),
    ));

    // Initially, "Add Task" button should be disabled (name is empty)
    final addButton = find.text('Add Task');
    final elevatedButton = tester.widget<ElevatedButton>(find.ancestor(
      of: addButton,
      matching: find.byType(ElevatedButton),
    ));
    expect(elevatedButton.onPressed, isNull);

    // Type an existing title
    await tester.enterText(find.byType(TextField).first, 'Existing Task');
    await tester.pump();

    // Verify error message and button still disabled
    expect(find.text('A task with this name already exists'), findsOneWidget);
    expect(tester.widget<ElevatedButton>(find.ancestor(
      of: addButton,
      matching: find.byType(ElevatedButton),
    )).onPressed, isNull);

    // Type a new title
    await tester.enterText(find.byType(TextField).first, 'New Task');
    await tester.pump();

    // Verify error message is gone and button is enabled
    expect(find.text('A task with this name already exists'), findsNothing);
    expect(tester.widget<ElevatedButton>(find.ancestor(
      of: addButton,
      matching: find.byType(ElevatedButton),
    )).onPressed, isNotNull);

    // Save and verify callback
    await tester.tap(addButton);
    await tester.pump();

    expect(savedTitle, 'New Task');
    expect(savedColor, Colors.red); // First color in palette
  });
}
