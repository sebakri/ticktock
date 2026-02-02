import 'package:flutter/material.dart';
import '../../models/task.dart';

class DayTimeline extends StatelessWidget {
  final DateTime selectedDate;
  final List<Task> tasks;
  final bool isTracking;
  final DateTime? trackingStartTime;
  final String trackingTaskTitle;
  final List<Color> palette;

  const DayTimeline({
    super.key,
    required this.selectedDate,
    required this.tasks,
    required this.isTracking,
    this.trackingStartTime,
    required this.trackingTaskTitle,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 32,
          decoration: BoxDecoration(
            color: onSurface.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: onSurface.withOpacity(0.05)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildDayTimelineBars(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['00:00', '04:00', '08:00', '12:00', '16:00', '20:00', '23:59']
              .map((time) => Text(
                    time,
                    style: TextStyle(
                      color: onSurface.withOpacity(isDark ? 0.2 : 0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'monospace',
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildDayTimelineBars() {
    return LayoutBuilder(builder: (context, constraints) {
      double totalWidth = constraints.maxWidth;
      double totalMinutes = 24 * 60;
      DateTime startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 0, 0);

      List<Widget> bars = [];
      
      for (var task in tasks) {
        for (var block in task.blocks) {
          if (block.startTime.year != selectedDate.year || 
              block.startTime.month != selectedDate.month || 
              block.startTime.day != selectedDate.day) {
            continue;
          }

          double startMin = block.startTime.difference(startOfDay).inMinutes.toDouble();
          double durationMin = block.duration.inMinutes.toDouble();

          if (startMin + durationMin < 0 || startMin > totalMinutes) continue;

          double left = (startMin / totalMinutes) * totalWidth;
          double width = (durationMin / totalMinutes) * totalWidth;

          bars.add(Positioned(
            left: left,
            width: width.clamp(1.0, totalWidth),
            top: 0,
            bottom: 0,
            child: Container(color: task.color),
          ));
        }
      }

      if (isTracking && trackingStartTime != null) {
        final now = DateTime.now();
        if (now.year == selectedDate.year && now.month == selectedDate.month && now.day == selectedDate.day) {
          double startMin = trackingStartTime!.difference(startOfDay).inMinutes.toDouble();
          double durationMin = now.difference(trackingStartTime!).inMinutes.toDouble();
          
          double left = (startMin / totalMinutes) * totalWidth;
          double width = ((durationMin / totalMinutes) * totalWidth).clamp(2.0, totalWidth);

          final existingTask = tasks.where((t) => t.title == trackingTaskTitle).firstOrNull;
          final color = existingTask?.color ?? palette[tasks.length % palette.length];

          bars.add(
            Positioned(
              left: left,
              width: width,
              top: 0,
              bottom: 0,
              child: Container(color: color),
            ),
          );
        }
      }

      return Stack(children: bars);
    });
  }
}
