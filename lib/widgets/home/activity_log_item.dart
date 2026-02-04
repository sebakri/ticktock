import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/task.dart';
import '../../models/time_block.dart';
import '../shortcut_badge.dart';

class ActivityLogItem extends StatefulWidget {
  final Task task;
  final DateTime selectedDate;
  final bool isTracking;
  final Duration activeDuration;
  final Duration dailyDuration;
  final bool isExpanded;
  final String? shortcutLabel;
  final VoidCallback onToggleExpand;
  final VoidCallback onStartTracking;
  final Function(TimeBlock) onEditBlock;
  final Function(TimeBlock) onDeleteBlock;
  final Function(TimeBlock)? onAcceptTimeBlock;
  final bool isFirst;
  final bool isLast;

  const ActivityLogItem({
    super.key,
    required this.task,
    required this.selectedDate,
    this.isTracking = false,
    this.activeDuration = Duration.zero,
    required this.dailyDuration,
    this.isExpanded = false,
    this.shortcutLabel,
    required this.onToggleExpand,
    required this.onStartTracking,
    required this.onEditBlock,
    required this.onDeleteBlock,
    this.onAcceptTimeBlock,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  State<ActivityLogItem> createState() => _ActivityLogItemState();
}

class _ActivityLogItemState extends State<ActivityLogItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = widget.dailyDuration + widget.activeDuration;
    final durationStr =
        '${total.inHours}h ${(total.inMinutes % 60).toString().padLeft(2, '0')}m';
    final timeFormat = DateFormat('hh:mm a');

    final dayBlocks = widget.task.blocks.where((b) {
      final s = b.startTime;
      final d = widget.selectedDate;
      return s.year == d.year && s.month == d.month && s.day == d.day;
    }).toList();

    // Sort blocks by start time for consistent display
    dayBlocks.sort((a, b) => a.startTime.compareTo(b.startTime));

    // Use the first block's start time for this day as the primary timestamp
    final startTime = dayBlocks.isNotEmpty
        ? timeFormat.format(dayBlocks.first.startTime)
        : widget.isTracking
            ? timeFormat.format(DateTime.now().subtract(widget.activeDuration))
            : '--:--';

    final onSurface = theme.colorScheme.onSurface;
    final isDark = theme.brightness == Brightness.dark;
    final secondaryOpacity = isDark ? 0.3 : 0.5;

    return DragTarget<TimeBlock>(
      onWillAccept: (data) => data?.taskId != widget.task.id,
      onAccept: (data) {
        if (widget.onAcceptTimeBlock != null) {
          widget.onAcceptTimeBlock!(data);
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isDraggingOver = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isDraggingOver
                ? widget.task.color.withOpacity(0.1)
                : widget.isTracking
                    ? widget.task.color.withOpacity(0.03)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDraggingOver 
                  ? widget.task.color.withOpacity(0.2) 
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: widget.onToggleExpand,
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
                          if (!widget.isLast || widget.isExpanded)
                            Positioned(
                              top: 30,
                              bottom: 0,
                              child: Container(
                                  width: 1, color: onSurface.withOpacity(0.05)),
                            ),
                          if (!widget.isFirst)
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
                              color: widget.task.color,
                              shape: BoxShape.circle,
                              boxShadow: widget.isTracking || isDraggingOver
                                  ? [
                                      BoxShadow(
                                        color: widget.task.color.withOpacity(0.4),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      )
                                    ]
                                  : null,
                            ),
                            child: isDraggingOver
                                ? Icon(Icons.add,
                                    size: 8, color: Colors.white)
                                : null,
                          ),
                        ],
                      ),
                    ),
                    // 3. Shortcut Badge
                    SizedBox(
                      width: 48,
                      child: widget.shortcutLabel != null
                          ? Center(
                              child: ShortcutBadge(
                                  label: widget.shortcutLabel!, isLight: true))
                          : null,
                    ),
                    const SizedBox(width: 8),
                    // 4. Task Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.task.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: widget.isTracking
                                  ? onSurface
                                  : onSurface.withOpacity(0.8),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.task.description.isNotEmpty)
                            Text(
                              widget.task.description,
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: widget.isTracking
                            ? widget.task.color.withOpacity(0.1)
                            : onSurface.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        durationStr,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: widget.isTracking
                              ? widget.task.color
                              : onSurface.withOpacity(0.5),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 5. Quick Play/Stop
                    IconButton(
                      icon: Icon(
                        widget.isTracking
                            ? Icons.stop_rounded
                            : Icons.play_arrow_rounded,
                        size: 22,
                        color: widget.isTracking
                            ? Colors.redAccent
                            : onSurface.withOpacity(0.2),
                      ),
                      onPressed: widget.onStartTracking,
                    ),
                  ],
                ),
              ),
              // Expanded sessions
              if (widget.isExpanded)
                Padding(
                  padding:
                      const EdgeInsets.only(left: 70), // Align with timeline
                  child: Column(
                    children: [
                      ...dayBlocks.map((block) =>
                          _buildSessionRow(block, theme,
                              onSurface, secondaryOpacity)),
                      if (widget.isTracking)
                        _buildActiveSessionRow(theme, onSurface, secondaryOpacity),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActiveSessionRow(ThemeData theme, Color onSurface, double secondaryOpacity) {
    final timeFormat = DateFormat('hh:mm a');
    final startTime = DateTime.now().subtract(widget.activeDuration);
    final durationStr = '${widget.activeDuration.inMinutes}m';

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
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: widget.task.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.task.color.withOpacity(0.4),
                        blurRadius: 4,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              '${timeFormat.format(startTime)} - Now',
              style: TextStyle(
                  color: onSurface.withOpacity(secondaryOpacity + 0.2), 
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            durationStr,
            style: TextStyle(
                color: widget.task.color,
                fontSize: 12,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 80), // Space where edit/delete icons would be
        ],
      ),
    );
  }

  Widget _buildSessionRow(TimeBlock block, ThemeData theme,
      Color onSurface, double secondaryOpacity) {
    final timeFormat = DateFormat('hh:mm a');
    final duration = block.duration;
    final durationStr = '${duration.inMinutes}m';

    return Draggable<TimeBlock>(
      data: block,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: 300,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: widget.task.color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: widget.task.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${timeFormat.format(block.startTime)} - ${timeFormat.format(block.endTime)}',
                  style: TextStyle(color: onSurface, fontSize: 13),
                ),
              ),
              Text(
                durationStr,
                style: TextStyle(
                  color: widget.task.color,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildSessionContent(block, theme, onSurface,
            secondaryOpacity, timeFormat, durationStr),
      ),
      child: _buildSessionContent(block, theme, onSurface,
          secondaryOpacity, timeFormat, durationStr),
    );
  }

  Widget _buildSessionContent(
      TimeBlock block,
      ThemeData theme,
      Color onSurface,
      double secondaryOpacity,
      DateFormat timeFormat,
      String durationStr) {
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
                    color: widget.task.color.withOpacity(0.5),
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
            onPressed: () => widget.onEditBlock(block),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline,
                size: 14, color: onSurface.withOpacity(secondaryOpacity)),
            onPressed: () => widget.onDeleteBlock(block),
          ),
        ],
      ),
    );
  }
}
