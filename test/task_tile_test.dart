import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticktock/models/task.dart';
import 'package:ticktock/models/time_block.dart';
import 'package:ticktock/widgets/home/task_tile.dart';

void main() {
  testWidgets('TaskTile renders task information correctly', (WidgetTester tester) async {
    final task = Task(
      id: 1,
      title: 'Test Task',
      description: 'Test Description',
      color: Colors.blue,
      blocks: [
        TimeBlock(
          startTime: DateTime(2026, 2, 4, 10, 0),
          endTime: DateTime(2026, 2, 4, 11, 30),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            height: 150,
            child: TaskTile(
              task: task,
              shortcutLabel: '⌘A',
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Test Task'), findsOneWidget);
    expect(find.text('Test Description'), findsOneWidget);
    expect(find.text('1h 30m total'), findsOneWidget);
    expect(find.text('⌘A'), findsOneWidget);
  });

  testWidgets('TaskTile shows tracking indicator', (WidgetTester tester) async {
    final task = Task(title: 'Tracking Task', color: Colors.green);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            height: 150,
            child: TaskTile(
              task: task,
              isTracking: true,
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
  });

  testWidgets('TaskTile accepts TimeBlock via DragTarget', (WidgetTester tester) async {
    final targetTask = Task(id: 1, title: 'Target Task', color: Colors.blue);
    final droppedBlock = TimeBlock(
      id: 10,
      taskId: 2,
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(minutes: 30)),
    );

    TimeBlock? acceptedBlock;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Draggable<TimeBlock>(
                data: droppedBlock,
                feedback: const Text('Dragging...'),
                child: const SizedBox(
                  width: 100,
                  height: 50,
                  child: Text('Drag Me'),
                ),
              ),
              SizedBox(
                width: 300,
                height: 150,
                child: TaskTile(
                  task: targetTask,
                  onTap: () {},
                  onAcceptTimeBlock: (block) {
                    acceptedBlock = block;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Simulate drag and drop
    final dragLocation = tester.getCenter(find.text('Drag Me'));
    final dropLocation = tester.getCenter(find.byType(TaskTile));

    final TestGesture gesture = await tester.startGesture(dragLocation);
    await tester.pump();
    await gesture.moveTo(dropLocation);
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(acceptedBlock, equals(droppedBlock));
  });
}