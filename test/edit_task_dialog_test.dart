import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticktock/models/task.dart';
import 'package:ticktock/widgets/edit_task_dialog.dart';

void main() {
  testWidgets('EditTaskDialog layout test at app width', (WidgetTester tester) async {
    // Set physical size to match the actual running application (633x1410)
    tester.view.physicalSize = const Size(633, 1410);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final task = Task(
      id: 1,
      title: 'Test Task',
      description: 'Test Description',
      color: Colors.blue,
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: EditTaskDialog(
          task: task,
          palette: const [Colors.blue, Colors.red],
          onSave: (t, d, c) {},
          onDelete: () {},
          onStart: () {},
        ),
      ),
    ));

    // Check for overflow errors. 
    // In Flutter tests, RenderFlex overflows throw exceptions that fail the test.
    expect(tester.takeException(), isNull);
  });
}
