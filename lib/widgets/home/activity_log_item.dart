import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/task.dart';
import '../../models/time_block.dart';
import '../shortcut_badge.dart';

class ActivityLogItem extends StatelessWidget {
  final Task task;
  final bool isTracking;
  final Duration activeDuration;
  final Duration dailyDuration;
  final bool isExpanded;
  final String? shortcutLabel;
  final VoidCallback onToggleExpand;
  final VoidCallback onStartTracking;
  final Function(TimeBlock) onEditBlock;
  final Function(int) onDeleteBlock;
  final bool isFirst;
  final bool isLast;

  const ActivityLogItem({
    super.key,
    required this.task,
    this.isTracking = false,
    this.activeDuration = Duration.zero,
    required this.dailyDuration,
    this.isExpanded = false,
    this.shortcutLabel,
    required this.onToggleExpand,
    required this.onStartTracking,
    required this.onEditBlock,
    required this.onDeleteBlock,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = dailyDuration + activeDuration;
    final durationStr =
        '${total.inHours}h ${(total.inMinutes % 60).toString().padLeft(2, '0')}m';
    final timeFormat = DateFormat('hh:mm a');

    // Use the first block's start time as the primary timestamp
    final startTime = task.blocks.isNotEmpty
        ? timeFormat.format(task.blocks.first.startTime)
        : isTracking
            ? timeFormat.format(DateTime.now().subtract(activeDuration))
            : '--:--';

    final onSurface = theme.colorScheme.onSurface;
    final isDark = theme.brightness == Brightness.dark;
    final secondaryOpacity = isDark ? 0.3 : 0.5;

    return Column(
      children: [
        GestureDetector(
          onTap: onToggleExpand,
          behavior: HitTestBehavior.opaque,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Timestamp
              SizedBox(
                width: 70,
                child: Text(
                  startTime,
                  style: TextStyle(
                    color: onSurface.withOpacity(secondaryOpacity),
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              // 2. Timeline Line & Node
              SizedBox(
                width: 40,
                height: 60,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (!isLast || isExpanded)
                      Positioned(
                        top: 30,
                        bottom: 0,
                        child: Container(
                            width: 1, color: onSurface.withOpacity(0.05)),
                      ),
                    if (!isFirst)
                      Positioned(
                        top: 0,
                        bottom: 30,
                        child: Container(
                            width: 1, color: onSurface.withOpacity(0.05)),
                      ),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: task.color,
                        shape: BoxShape.circle,
                        boxShadow: isTracking
                            ? [
                                BoxShadow(
                                  color: task.color.withOpacity(0.4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                )
                              ]
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              // 3. Shortcut Badge
              SizedBox(
                width: 48,
                child: shortcutLabel != null
                    ? Center(
                        child: ShortcutBadge(
                            label: shortcutLabel!, isLight: true))
                    : null,
              ),
              const SizedBox(width: 8),
              // 4. Task Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color:
                            isTracking ? onSurface : onSurface.withOpacity(0.8),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (task.description.isNotEmpty)
                      Text(
                        task.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: onSurface.withOpacity(secondaryOpacity),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              // 5. Duration Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isTracking
                      ? task.color.withOpacity(0.1)
                      : onSurface.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  durationStr,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isTracking ? task.color : onSurface.withOpacity(0.5),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 5. Quick Play/Stop
              IconButton(
                icon: Icon(
                  isTracking ? Icons.stop_rounded : Icons.play_arrow_rounded,
                  size: 22,
                  color:
                      isTracking ? Colors.redAccent : onSurface.withOpacity(0.2),
                ),
                onPressed: onStartTracking,
              ),
            ],
          ),
        ),
        // Expanded sessions
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 70), // Align with timeline
            child: Column(
              children: [
                ...task.blocks.asMap().entries.map((entry) =>
                    _buildSessionRow(entry.value, entry.key, onSurface, secondaryOpacity)),
                const SizedBox(height: 16),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSessionRow(
      TimeBlock block, int index, Color onSurface, double secondaryOpacity) {
    final timeFormat = DateFormat('hh:mm a');
    final duration = block.duration;
    final durationStr = '${duration.inMinutes}m';

    return Container(
      height: 40,
      child: Row(
        children: [
          // Sub-node
          SizedBox(
            width: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(width: 1, color: onSurface.withOpacity(0.05)),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: task.color.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              '${timeFormat.format(block.startTime)} - ${timeFormat.format(block.endTime)}',
              style: TextStyle(
                  color: onSurface.withOpacity(secondaryOpacity), fontSize: 12),
            ),
          ),
          Text(
            durationStr,
            style: TextStyle(
                color: onSurface.withOpacity(secondaryOpacity + 0.1),
                fontSize: 12,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.edit_outlined,
                size: 14, color: onSurface.withOpacity(secondaryOpacity)),
            onPressed: () => onEditBlock(block),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline,
                size: 14, color: onSurface.withOpacity(secondaryOpacity)),
            onPressed: () => onDeleteBlock(index),
          ),
        ],
      ),
    );
  }
}
