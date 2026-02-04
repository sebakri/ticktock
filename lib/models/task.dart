import 'package:flutter/material.dart';
import 'time_block.dart';

class Task {
  int? id;
  String title;
  String description;
  Color color;
  final List<TimeBlock> blocks;
  final List<String> tags;

  Task({
    this.id,
    required this.title,
    this.description = '',
    required this.color,
    List<TimeBlock>? blocks,
    List<String>? tags,
  })  : blocks = blocks ?? [],
        tags = tags ?? [];

  Duration get totalDuration =>
      blocks.fold(Duration.zero, (sum, block) => sum + block.duration);

  Duration durationOn(DateTime date) {
    return blocks
        .where((b) =>
            b.startTime.year == date.year &&
            b.startTime.month == date.month &&
            b.startTime.day == date.day)
        .fold(Duration.zero, (sum, block) => sum + block.duration);
  }

  DateTime get firstStartTime => blocks.isEmpty
      ? DateTime.now()
      : blocks.map((b) => b.startTime).reduce((a, b) => a.isBefore(b) ? a : b);
  DateTime get lastEndTime => blocks.isEmpty
      ? DateTime.now()
      : blocks.map((b) => b.endTime).reduce((a, b) => a.isAfter(b) ? a : b);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'color': color.value,
      'tags': tags.join(','),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map, List<TimeBlock> blocks) {
    final tagsStr = map['tags'] as String? ?? '';
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      color: Color(map['color']),
      blocks: blocks,
      tags: tagsStr.isEmpty ? [] : tagsStr.split(','),
    );
  }
}
