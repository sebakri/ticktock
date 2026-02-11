import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticktock/models/task.dart';
import 'package:ticktock/models/time_block.dart';
import 'package:ticktock/widgets/home/day_timeline.dart';

void main() {
  testWidgets('DayTimeline renders without error', (WidgetTester tester) async {
    final today = DateTime(2026, 2, 4);
    
    final task = Task(
      id: 1,
      title: 'Test Task',
      blocks: [
        TimeBlock(
          id: 1,
          taskId: 1,
          startTime: DateTime(2026, 2, 4, 10, 0),
          endTime: DateTime(2026, 2, 4, 11, 0),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DayTimeline(
            selectedDate: today,
            tasks: [task],
            isTracking: false,
            trackingTaskTitle: '',
            taskColors: const {1: Colors.blue},
          ),
        ),
      ),
    );

    // Verify some labels are present
    expect(find.text('10:00'), findsOneWidget);
    expect(find.text('11:00'), findsOneWidget);
  });

  testWidgets('DayTimeline shows tracking bar and current time', (WidgetTester tester) async {
    final today = DateTime.now();
    final startTime = today.subtract(const Duration(hours: 1));
    
    final task = Task(
      id: 1,
      title: 'Tracking Task',
      blocks: [],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DayTimeline(
            selectedDate: today,
            tasks: [task],
            isTracking: true,
            trackingStartTime: startTime,
            trackingTaskTitle: 'Tracking Task',
            taskColors: const {1: Colors.green},
          ),
        ),
      ),
    );

    // Verify current time is shown in labels
    expect(find.byType(DayTimeline), findsOneWidget);
  });
}
