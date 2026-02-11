import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticktock/models/task.dart';
import 'package:ticktock/models/time_block.dart';
import 'package:ticktock/widgets/home/activity_log_item.dart';

void main() {
  testWidgets('ActivityLogItem filters sessions by selected date', (WidgetTester tester) async {
    final today = DateTime(2026, 2, 4);
    
    final task = Task(
      id: 1,
      title: 'Test Task',
      blocks: [
        TimeBlock(
          id: 1,
          taskId: 1,
          name: 'Today Session',
          startTime: DateTime(2026, 2, 4, 10, 0),
          endTime: DateTime(2026, 2, 4, 11, 0),
        ),
        TimeBlock(
          id: 2,
          taskId: 1,
          name: 'Yesterday Session',
          startTime: DateTime(2026, 2, 3, 10, 0),
          endTime: DateTime(2026, 2, 3, 11, 0),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActivityLogItem(
            task: task,
            selectedDate: today,
            dailyDuration: const Duration(hours: 1),
            color: Colors.blue,
            isExpanded: true,
            onToggleExpand: () {},
            onStartTracking: () {},
            onEditBlock: (_) {},
            onDeleteBlock: (_) {},
          ),
        ),
      ),
    );

    // Should find the today session
    expect(find.text('10:00 - 11:00'), findsOneWidget);
    // Should NOT find the yesterday session
    expect(find.text('Yesterday Session'), findsNothing);
  });

  testWidgets('ActivityLogItem shows active session when tracking', (WidgetTester tester) async {
    final today = DateTime(2026, 2, 4);
    
    final task = Task(
      id: 1,
      title: 'Test Task',
      blocks: [],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActivityLogItem(
            task: task,
            selectedDate: today,
            isTracking: true,
            color: Colors.blue,
            activeDuration: const Duration(minutes: 30),
            dailyDuration: Duration.zero,
            isExpanded: true,
            onToggleExpand: () {},
            onStartTracking: () {},
            onEditBlock: (_) {},
            onDeleteBlock: (_) {},
          ),
        ),
      ),
    );

    expect(find.textContaining('Now'), findsOneWidget);
    expect(find.text('30m'), findsOneWidget);
  });
}
