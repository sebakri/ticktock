import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../models/time_block.dart';
import '../shortcut_badge.dart';

class TaskTile extends StatefulWidget {
  final Task task;
  final String? shortcutLabel;
  final VoidCallback onTap;
  final Function(String)? onTagTap;
  final bool isTracking;
  final Function(TimeBlock)? onAcceptTimeBlock;
  final Color color;

  const TaskTile({
    super.key,
    required this.task,
    this.shortcutLabel,
    required this.onTap,
    this.onTagTap,
    this.isTracking = false,
    this.onAcceptTimeBlock,
    required this.color,
  });

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final duration = widget.task.totalDuration;
    final durationStr =
        '${duration.inHours}h ${(duration.inMinutes % 60)}m total';

    final onSurface = theme.colorScheme.onSurface;
    final isDark = theme.brightness == Brightness.dark;

    return DragTarget<TimeBlock>(
      onWillAccept: (data) => data?.taskId != widget.task.id,
      onAccept: (data) {
        if (widget.onAcceptTimeBlock != null) {
          widget.onAcceptTimeBlock!(data);
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isDraggingOver = candidateData.isNotEmpty;

        return GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: isDraggingOver
                  ? widget.color.withOpacity(0.1)
                  : onSurface.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.isTracking || isDraggingOver
                    ? widget.color
                    : onSurface.withOpacity(0.05),
                width: widget.isTracking || isDraggingOver ? 1.5 : 1,
              ),
            ),
            child: Stack(
              children: [
                // Active task highlight
                if (widget.isTracking)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            widget.color.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                // Left color accent
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 4,
                  child: Container(color: widget.color),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.task.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: onSurface,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (widget.shortcutLabel != null) ...[
                            const SizedBox(width: 4),
                            ShortcutBadge(
                              label: widget.shortcutLabel!,
                              fontSize: 10,
                              isLight: true,
                            ),
                          ],
                        ],
                      ),
                      if (widget.task.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Flexible(
                          child: Text(
                            widget.task.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: onSurface.withOpacity(isDark ? 0.25 : 0.45),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      if (widget.task.tags.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Flexible(
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            clipBehavior: Clip.antiAlias,
                            children: widget.task.tags.map((tag) => GestureDetector(
                              onTap: widget.onTagTap != null ? () => widget.onTagTap!(tag) : null,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: widget.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '#$tag',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: widget.color.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            )).toList(),
                          ),
                        ),
                      ],
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            durationStr,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: onSurface.withOpacity(isDark ? 0.3 : 0.5),
                            ),
                          ),
                          if (widget.isTracking || isDraggingOver)
                            Icon(
                              isDraggingOver
                                  ? Icons.add_circle_outline_rounded
                                  : Icons.play_arrow_rounded,
                              color: widget.color,
                              size: 18,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
