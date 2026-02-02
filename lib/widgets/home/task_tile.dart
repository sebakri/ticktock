import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../shortcut_badge.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final String? shortcutLabel;
  final VoidCallback onTap;
  final bool isTracking;

  const TaskTile({
    super.key,
    required this.task,
    this.shortcutLabel,
    required this.onTap,
    this.isTracking = false,
  });

  @override
  Widget build(BuildContext context) {
    final duration = task.totalDuration;
    final durationStr =
        '${duration.inHours}h ${(duration.inMinutes % 60)}m total';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isTracking ? task.color : Colors.white.withOpacity(0.05),
            width: isTracking ? 1.5 : 1,
          ),
        ),
        child: Stack(
          children: [
            // Active task highlight
            if (isTracking)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        task.color.withOpacity(0.1),
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
              child: Container(color: task.color),
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
                          task.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (shortcutLabel != null) ...[
                        const SizedBox(width: 4),
                        ShortcutBadge(
                          label: shortcutLabel!,
                          fontSize: 10,
                          isLight: true,
                        ),
                      ],
                    ],
                  ),
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
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      if (isTracking)
                        Icon(
                          Icons.play_arrow_rounded,
                          color: task.color,
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
  }
}
