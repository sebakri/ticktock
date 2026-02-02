import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/task.dart';
import '../../models/time_block.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final bool isTracking;
  final Duration activeDuration;
  final Duration? customDuration;
  final String? durationLabel;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final VoidCallback onStartTracking;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(TimeBlock) onEditBlock;
  final Function(int) onDeleteBlock;

  const TaskItem({
    super.key,
    required this.task,
    this.isTracking = false,
    this.activeDuration = Duration.zero,
    this.customDuration,
    this.durationLabel,
    this.isExpanded = false,
    required this.onToggleExpand,
    required this.onStartTracking,
    required this.onEdit,
    required this.onDelete,
    required this.onEditBlock,
    required this.onDeleteBlock,
  });

  @override
  Widget build(BuildContext context) {
    final baseDuration = customDuration ?? task.totalDuration;
    final duration = baseDuration + activeDuration;
    final durationStr =
        '${duration.inHours}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onToggleExpand,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isExpanded ? Colors.white.withOpacity(0.02) : Colors.transparent,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(right: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${task.blocks.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: task.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (task.description.isNotEmpty)
                          Text(
                            task.description,
                            style: TextStyle(color: Colors.grey[400], fontSize: 13),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    durationLabel ?? 'Total today',
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    durationStr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isTracking ? task.color : Colors.white,
                    ),
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    icon: Icon(isTracking ? Icons.stop : Icons.play_arrow,
                        size: 20, color: isTracking ? Colors.redAccent : null),
                    onPressed: onStartTracking,
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            ...task.blocks.asMap().entries.map((entry) => _buildTimeBlockItem(task, entry.value, entry.key)),
        ],
      ),
    );
  }

  Widget _buildTimeBlockItem(Task task, TimeBlock block, int blockIndex) {
    final timeFormat = DateFormat('hh:mm a');
    final durationStr = '${block.duration.inHours}:${(block.duration.inMinutes % 60).toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.only(left: 64, right: 16, top: 8, bottom: 8),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: task.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              block.name,
              style: TextStyle(color: Colors.grey[300], fontSize: 14),
            ),
          ),
          Text(
            '${timeFormat.format(block.startTime)} - ${timeFormat.format(block.endTime)}',
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
          const SizedBox(width: 24),
          Text(
            durationStr,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.edit, size: 16, color: Colors.white60),
            onPressed: () => onEditBlock(block),
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 16, color: Colors.white60),
            onPressed: () => onDeleteBlock(blockIndex),
          ),
        ],
      ),
    );
  }
}
