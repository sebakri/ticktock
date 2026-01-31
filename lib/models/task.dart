import 'package:flutter/material.dart';
import 'time_block.dart';

class Task {
  String title;
  String description;
  Color color;
  final List<TimeBlock> blocks;
  bool isExpanded;

  Task({
    required this.title,
    this.description = '',
    required this.color,
    List<TimeBlock>? blocks,
    this.isExpanded = false,
  }) : blocks = blocks ?? [];

  Duration get totalDuration => blocks.fold(Duration.zero, (sum, block) => sum + block.duration);

  DateTime get firstStartTime => blocks.isEmpty ? DateTime.now() : blocks.map((b) => b.startTime).reduce((a, b) => a.isBefore(b) ? a : b);
  DateTime get lastEndTime => blocks.isEmpty ? DateTime.now() : blocks.map((b) => b.endTime).reduce((a, b) => a.isAfter(b) ? a : b);
}
