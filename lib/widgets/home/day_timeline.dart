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

    final now = DateTime.now();
    DateTime timelineStart = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 0, 0);
    DateTime timelineEnd = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);

    // Find the earliest start time on the selected day
    DateTime? firstActivityTime;
    for (var task in tasks) {
      for (var block in task.blocks) {
        if (block.startTime.year == selectedDate.year &&
            block.startTime.month == selectedDate.month &&
            block.startTime.day == selectedDate.day) {
          if (firstActivityTime == null || block.startTime.isBefore(firstActivityTime)) {
            firstActivityTime = block.startTime;
          }
        }
      }
    }

    if (isTracking && trackingStartTime != null &&
        trackingStartTime!.year == selectedDate.year &&
        trackingStartTime!.month == selectedDate.month &&
        trackingStartTime!.day == selectedDate.day) {
      if (firstActivityTime == null || trackingStartTime!.isBefore(firstActivityTime)) {
        firstActivityTime = trackingStartTime!;
      }
    }

    if (firstActivityTime != null) {
      timelineStart = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, firstActivityTime.hour, firstActivityTime.minute);
      if (timelineStart.isBefore(DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 0, 0))) {
        timelineStart = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 0, 0);
      }
    }

    // Find the latest end time on the selected day
    DateTime? lastActivityTime;
    for (var task in tasks) {
      for (var block in task.blocks) {
        if (block.endTime.year == selectedDate.year &&
            block.endTime.month == selectedDate.month &&
            block.endTime.day == selectedDate.day) {
          if (lastActivityTime == null || block.endTime.isAfter(lastActivityTime)) {
            lastActivityTime = block.endTime;
          }
        }
      }
    }

    if (isTracking && trackingStartTime != null &&
        trackingStartTime!.year == selectedDate.year &&
        trackingStartTime!.month == selectedDate.month &&
        trackingStartTime!.day == selectedDate.day) {
      if (lastActivityTime == null || now.isAfter(lastActivityTime)) {
        lastActivityTime = now;
      }
    }

    if (lastActivityTime != null) {
      timelineEnd = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, lastActivityTime.hour, lastActivityTime.minute);
      if (timelineEnd.isAfter(DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59))) {
        timelineEnd = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);
      }
    }

    final totalTimelineSeconds = timelineEnd.difference(timelineStart).inSeconds.toDouble();
    if (totalTimelineSeconds <= 0) return const SizedBox.shrink();

    // Generate labels
    List<DateTime> labels = [];
    labels.add(timelineStart);

    final int intervalMinutes = 30;
    DateTime currentIntervalTime = DateTime(
      timelineStart.year,
      timelineStart.month,
      timelineStart.day,
      timelineStart.hour,
      (timelineStart.minute ~/ intervalMinutes) * intervalMinutes,
    );
    if (currentIntervalTime.isBefore(timelineStart)) {
      currentIntervalTime = currentIntervalTime.add(Duration(minutes: intervalMinutes));
    }

    while (currentIntervalTime.isBefore(timelineEnd)) {
      if (!labels.any((label) => label.isAtSameMomentAs(currentIntervalTime))) {
          labels.add(currentIntervalTime);
      }
      currentIntervalTime = currentIntervalTime.add(Duration(minutes: intervalMinutes));
    }

    if (!labels.any((label) => label.isAtSameMomentAs(timelineEnd))) {
      labels.add(timelineEnd);
    }

    labels.sort((a, b) => a.compareTo(b));

    List<DateTime> finalLabels = [];
    if (labels.isNotEmpty) {
      finalLabels.add(labels.first);
      for (int i = 1; i < labels.length - 1; i++) {
        // Minimum 15-minute separation to prevent overlap
        if (labels[i].difference(finalLabels.last).inMinutes >= 15 &&
            labels.last.difference(labels[i]).inMinutes >= 15) {
          finalLabels.add(labels[i]);
        }
      }
      if (labels.length > 1) {
        finalLabels.add(labels.last);
      }
    }

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
            child: _buildDayTimelineBars(timelineStart, timelineEnd, totalTimelineSeconds, now, finalLabels, onSurface),
          ),
        ),
        const SizedBox(height: 8),
        _buildTimeLabels(onSurface, isDark, timelineStart, timelineEnd, totalTimelineSeconds, finalLabels),
      ],
    );
  }

  Widget _buildTimeLabels(Color onSurface, bool isDark, DateTime timelineStart, DateTime timelineEnd, double totalTimelineSeconds, List<DateTime> finalLabels) {
    return LayoutBuilder(builder: (context, constraints) {
      final double width = constraints.maxWidth;
      
      return SizedBox(
        height: 16,
        child: Stack(
          children: finalLabels.asMap().entries.map((entry) {
            final index = entry.key;
            final time = entry.value;
            final seconds = time.difference(timelineStart).inSeconds.toDouble();
            final percent = seconds / totalTimelineSeconds;
            
            const double labelWidth = 50;
            double left = percent * width - (labelWidth / 2);
            
            if (index == 0) {
              left = 0;
            } else if (index == finalLabels.length - 1) {
              left = width - labelWidth;
            } else {
              if (left < 10) left = 10;
              if (left + labelWidth > width - 10) left = width - labelWidth - 10;
            }

            return Positioned(
              left: left,
              width: labelWidth,
              child: Text(
                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                textAlign: index == 0 ? TextAlign.left : index == finalLabels.length - 1 ? TextAlign.right : TextAlign.center,
                style: TextStyle(
                  color: onSurface.withOpacity(isDark ? 0.2 : 0.4),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'monospace',
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _buildDayTimelineBars(DateTime timelineStart, DateTime timelineEnd, double totalTimelineSeconds, DateTime now, List<DateTime> finalLabels, Color onSurface) {
    return LayoutBuilder(builder: (context, constraints) {
      double totalWidth = constraints.maxWidth;
      List<Widget> bars = [];
      
      // 1. Grid Lines (Ticks)
      for (var labelTime in finalLabels) {
        double seconds = labelTime.difference(timelineStart).inSeconds.toDouble();
        double left = (seconds / totalTimelineSeconds) * totalWidth;
        bars.add(
          Positioned(
            left: left,
            top: 0,
            bottom: 0,
            width: 1,
            child: Container(color: onSurface.withOpacity(0.08)),
          ),
        );
      }

      // 2. First Task Corner Indicator
      Color? firstTaskColor;
      DateTime? earliestBlockTime;
      for (var task in tasks) {
        for (var block in task.blocks) {
          if (block.startTime.year == selectedDate.year && 
              block.startTime.month == selectedDate.month && 
              block.startTime.day == selectedDate.day) {
            if (earliestBlockTime == null || block.startTime.isBefore(earliestBlockTime)) {
              earliestBlockTime = block.startTime;
              firstTaskColor = task.color;
            }
          }
        }
      }

      if (isTracking && trackingStartTime != null &&
          trackingStartTime!.year == selectedDate.year &&
          trackingStartTime!.month == selectedDate.month &&
          trackingStartTime!.day == selectedDate.day) {
        if (earliestBlockTime == null || trackingStartTime!.isBefore(earliestBlockTime)) {
           final existingTask = tasks.where((t) => t.title == trackingTaskTitle).firstOrNull;
           if (existingTask != null) {
              firstTaskColor = existingTask.color;
           } else if (tasks.isNotEmpty) {
              firstTaskColor = palette[tasks.length % palette.length];
           }
        }
      }

      if (firstTaskColor != null) {
        bars.add(
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 4,
            child: Container(color: firstTaskColor),
          ),
        );
      }
      
      // 3. Task Bars
      for (var task in tasks) {
        for (var block in task.blocks) {
          if (block.startTime.year != selectedDate.year || 
              block.startTime.month != selectedDate.month || 
              block.startTime.day != selectedDate.day) {
            continue;
          }

          double startSec = block.startTime.difference(timelineStart).inSeconds.toDouble();
          double durationSec = block.duration.inSeconds.toDouble();

          if (startSec < 0) {
            durationSec += startSec;
            startSec = 0;
          }
          if (startSec + durationSec > totalTimelineSeconds) {
            durationSec = totalTimelineSeconds - startSec;
          }
          if (durationSec <= 0) continue;

          double left = (startSec / totalTimelineSeconds) * totalWidth;
          double width = (durationSec / totalTimelineSeconds) * totalWidth;

          bars.add(Positioned(
            left: left,
            width: width.clamp(1.0, totalWidth),
            top: 0,
            bottom: 0,
            child: Container(color: task.color),
          ));
        }
      }

      // 4. Tracking Bar
      if (isTracking && trackingStartTime != null) {
        if (now.year == selectedDate.year && now.month == selectedDate.month && now.day == selectedDate.day) {
          double startSec = trackingStartTime!.difference(timelineStart).inSeconds.toDouble();
          double currentSec = now.difference(timelineStart).inSeconds.toDouble();

          double durationSec = currentSec - startSec;
          
          if (startSec < 0) {
            durationSec += startSec;
            startSec = 0;
          }
          if (durationSec <= 0) return Stack(children: bars);

          double left = (startSec / totalTimelineSeconds) * totalWidth;
          double width = (durationSec / totalTimelineSeconds) * totalWidth;

          final existingTask = tasks.where((t) => t.title == trackingTaskTitle).firstOrNull;
          final color = existingTask?.color ?? palette[tasks.length % palette.length];

          bars.add(
            Positioned(
              left: left,
              width: width.clamp(2.0, totalWidth),
              top: 0,
              bottom: 0,
              child: Container(color: color),
            ),
          );
        }
      }

      // 5. Current Time Indicator (Red Line)
      if (isTracking && trackingStartTime != null &&
          trackingStartTime!.year == selectedDate.year &&
          trackingStartTime!.month == selectedDate.month &&
          trackingStartTime!.day == selectedDate.day) {
        double currentSec = now.difference(timelineStart).inSeconds.toDouble();
        if (currentSec >= 0 && currentSec <= totalTimelineSeconds) {
          double left = (currentSec / totalTimelineSeconds) * totalWidth;
          bars.add(
            Positioned(
              left: left,
              top: 0,
              bottom: 0,
              width: 2,
              child: Container(color: Colors.red),
            ),
          );
        }
      }

      return Stack(children: bars);
    });
  }
}