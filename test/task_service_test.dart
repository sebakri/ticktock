import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:ticktock/models/task.dart';
import 'package:ticktock/models/time_block.dart';
import 'package:ticktock/services/task_service.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('TaskService Tests', () {
    final taskService = TaskService.instance;

    setUp(() async {
      final db = await taskService.database;
      await db.delete('tasks');
      await db.delete('time_blocks');
      await db.delete('tracking_state');
      await db.delete('window_state');
    });

    test('Create and Get Task', () async {
      final task = Task(title: 'Test Task', color: Colors.blue);
      final id = await taskService.createTask(task);
      expect(id, isNotNull);

      final tasks = await taskService.getTasks();
      expect(tasks.length, 1);
      expect(tasks.first.title, 'Test Task');
      expect(tasks.first.id, id);
    });

    test('Update and Delete Task', () async {
      final task = Task(title: 'Original', color: Colors.red);
      final id = await taskService.createTask(task);
      task.id = id;
      task.title = 'Updated';
      
      await taskService.updateTask(task);
      var tasks = await taskService.getTasks();
      expect(tasks.first.title, 'Updated');

      await taskService.deleteTask(id);
      tasks = await taskService.getTasks();
      expect(tasks.isEmpty, true);
    });

    test('Create and Get Task with Tags', () async {
      final task = Task(
        title: 'Tagged Task',
        color: Colors.blue,
        tags: ['work', 'urgent'],
      );
      final id = await taskService.createTask(task);
      expect(id, isNotNull);

      final tasks = await taskService.getTasks();
      expect(tasks.length, 1);
      expect(tasks.first.tags, containsAll(['work', 'urgent']));
    });

    test('Update Task Tags', () async {
      final task = Task(title: 'T', color: Colors.blue, tags: ['a']);
      final id = await taskService.createTask(task);
      task.id = id;
      task.tags.clear();
      task.tags.add('b');

      await taskService.updateTask(task);
      final tasks = await taskService.getTasks();
      expect(tasks.first.tags, equals(['b']));
    });

    test('Create and Get TimeBlock', () async {
      final task = Task(title: 'Task for Block', color: Colors.green);
      final taskId = await taskService.createTask(task);

      final now = DateTime.now();
      final block = TimeBlock(
        taskId: taskId,
        name: 'Work Session',
        startTime: now,
        endTime: now.add(const Duration(hours: 1)),
      );

      final blockId = await taskService.createTimeBlock(block);
      expect(blockId, isNotNull);

      final tasks = await taskService.getTasks();
      expect(tasks.first.blocks.length, 1);
      expect(tasks.first.blocks.first.name, 'Work Session');
      
      final dates = await taskService.getSessionDates();
      expect(dates.length, 1);
      expect(dates.first.day, now.day);
    });

    test('Tracking State Operations', () async {
      final startTime = DateTime(2026, 2, 4, 12, 0);
      await taskService.saveTrackingState('Ongoing Task', startTime);

      var state = await taskService.getTrackingState();
      expect(state?['title'], 'Ongoing Task');
      expect(state?['start_time'], startTime.toIso8601String());

      await taskService.clearTrackingState();
      state = await taskService.getTrackingState();
      expect(state, isNull);
    });

    test('Window State Operations', () async {
      await taskService.saveWindowSize(1024, 768);
      
      final size = await taskService.getWindowSize();
      expect(size?.width, 1024);
      expect(size?.height, 768);
    });

    test('Update and Delete TimeBlock', () async {
      final taskId = await taskService.createTask(Task(title: 'T', color: Colors.blue));
      final block = TimeBlock(
        taskId: taskId,
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(minutes: 10)),
      );
      final blockId = await taskService.createTimeBlock(block);
      block.id = blockId;
      block.name = 'Renamed Block';

      await taskService.updateTimeBlock(block);
      final tasks = await taskService.getTasks();
      expect(tasks.first.blocks.first.name, 'Renamed Block');

      await taskService.deleteTimeBlock(blockId);
      final tasksAfterDelete = await taskService.getTasks();
      expect(tasksAfterDelete.first.blocks.isEmpty, true);
    });
  });
}