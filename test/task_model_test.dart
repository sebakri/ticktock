import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticktock/models/task.dart';
import 'package:ticktock/models/time_block.dart';

void main() {
  group('Task Model', () {
    test('totalDuration handles empty blocks', () {
      final task = Task(title: 'T', color: Colors.blue);
      expect(task.totalDuration, Duration.zero);
    });

    test('durationOn handles date filtering', () {
      final today = DateTime(2026, 2, 4);
      final yesterday = DateTime(2026, 2, 3);
      
      final task = Task(
        title: 'T',
        color: Colors.blue,
        blocks: [
          TimeBlock(startTime: today, endTime: today.add(const Duration(hours: 1))),
          TimeBlock(startTime: yesterday, endTime: yesterday.add(const Duration(hours: 2))),
        ],
      );

      expect(task.durationOn(today), const Duration(hours: 1));
      expect(task.durationOn(yesterday), const Duration(hours: 2));
    });

    test('firstStartTime and lastEndTime', () {
      final t1 = DateTime(2026, 2, 4, 10, 0);
      final t2 = DateTime(2026, 2, 4, 12, 0);
      
      final task = Task(
        title: 'T',
        color: Colors.blue,
        blocks: [
          TimeBlock(startTime: t1, endTime: t1.add(const Duration(hours: 1))),
          TimeBlock(startTime: t2, endTime: t2.add(const Duration(hours: 1))),
        ],
      );

      expect(task.firstStartTime, t1);
      expect(task.lastEndTime, t2.add(const Duration(hours: 1)));
    });

    test('toMap and fromMap', () {
      final task = Task(id: 1, title: 'Test', description: 'Desc', color: Colors.red);
      final map = task.toMap();
      
      expect(map['id'], 1);
      expect(map['title'], 'Test');
      expect(map['description'], 'Desc');
      expect(map['color'], Colors.red.value);

      final fromMap = Task.fromMap(map, []);
      expect(fromMap.id, 1);
      expect(fromMap.title, 'Test');
      expect(fromMap.color.value, Colors.red.value);
    });
  });
}
