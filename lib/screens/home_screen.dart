import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:window_manager/window_manager.dart';
import '../models/task.dart';
import '../models/time_block.dart';
import '../widgets/edit_task_dialog.dart';
import '../widgets/edit_session_dialog.dart';
import '../widgets/home/daily_log_header.dart';
import '../widgets/home/day_timeline.dart';
import '../widgets/home/quick_input.dart';
import '../widgets/home/task_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _taskController = TextEditingController();
  bool _isTracking = false;
  DateTime? _trackingStartTime;
  Timer? _ticker;
  DateTime _selectedDate = DateTime(2023, 10, 24);

  final List<Task> _tasks = [
    Task(
      title: 'UI Design for Dashboard',
      description: 'Wireframing new layout concepts',
      color: const Color(0xFF6366F1),
      isExpanded: true,
      blocks: [
        TimeBlock(
          name: 'Morning Session',
          startTime: DateTime(2023, 10, 24, 9, 0),
          endTime: DateTime(2023, 10, 24, 10, 30),
        ),
        TimeBlock(
          name: 'Afternoon Iteration',
          startTime: DateTime(2023, 10, 24, 14, 0),
          endTime: DateTime(2023, 10, 24, 15, 30),
        ),
      ],
    ),
    Task(
      title: 'Reading & Research',
      description: 'Design systems best practices',
      color: const Color(0xFF06B6D4),
      blocks: [
        TimeBlock(
          startTime: DateTime(2023, 10, 24, 13, 0),
          endTime: DateTime(2023, 10, 24, 14, 0),
        ),
      ],
    ),
    Task(
      title: 'Personal Project Coding',
      description: 'Implementing core logic',
      color: const Color(0xFFF59E0B),
      blocks: [
        TimeBlock(
          startTime: DateTime(2023, 10, 24, 14, 30),
          endTime: DateTime(2023, 10, 24, 17, 0),
        ),
      ],
    ),
  ];

  static const List<Color> _palette = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF06B6D4), // Cyan
    Color(0xFFF59E0B), // Amber
    Color(0xFF10B981), // Emerald
    Color(0xFFEC4899), // Pink
    Color(0xFF8B5CF6), // Violet
    Color(0xFFF43F5E), // Rose
    Color(0xFF0EA5E9), // Sky
    Color(0xFFF97316), // Orange
    Color(0xFF14B8A6), // Teal
    Color(0xFF84CC16), // Lime
    Color(0xFFD946EF), // Fuchsia
    Color(0xFFEF4444), // Red
  ];

  Color _getNextColor() {
    return _palette[_tasks.length % _palette.length];
  }

  void _toggleTracking() {
    final title = _taskController.text.trim();
    if (title.isEmpty) return;

    setState(() {
      if (_isTracking) {
        final existingTaskIndex = _tasks.indexWhere((t) => t.title == title);
        final endTime = DateTime.now();

        if (existingTaskIndex != -1) {
          _tasks[existingTaskIndex].blocks.add(
            TimeBlock(startTime: _trackingStartTime!, endTime: endTime),
          );
        } else {
          _tasks.insert(
            0,
            Task(
              title: title,
              color: _getNextColor(),
              blocks: [
                TimeBlock(startTime: _trackingStartTime!, endTime: endTime),
              ],
            ),
          );
        }
        _isTracking = false;
        _trackingStartTime = null;
        _taskController.clear();
        _ticker?.cancel();
      } else {
        _isTracking = true;
        _trackingStartTime = DateTime.now();
        final now = DateTime.now();
        if (_selectedDate.year != now.year ||
            _selectedDate.month != now.month ||
            _selectedDate.day != now.day) {
          _selectedDate = DateTime(now.year, now.month, now.day);
        }
        _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {});
        });
      }
    });
  }

  void _editTask(Task task) {
    final usedColors = _tasks
        .where((t) => t != task)
        .map((t) => t.color)
        .toSet();

    final availablePalette = _palette
        .where((color) => !usedColors.contains(color) || color == task.color)
        .toList();

    showDialog(
      context: context,
      builder: (context) => EditTaskDialog(
        task: task,
        palette: availablePalette,
        onSave: (title, description, color) {
          setState(() {
            task.title = title;
            task.description = description;
            task.color = color;
          });
        },
      ),
    );
  }

  void _editTimeBlock(Task task, TimeBlock block) {
    showDialog(
      context: context,
      builder: (context) => EditSessionDialog(
        block: block,
        onSave: (newName) {
          setState(() {
            block.name = newName;
          });
        },
      ),
    );
  }

  void _deleteTimeBlock(Task task, int blockIndex) {
    setState(() {
      task.blocks.removeAt(blockIndex);
      if (task.blocks.isEmpty) {
        _tasks.remove(task);
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          DragToMoveArea(
            child: Container(
              height: 32,
              width: double.infinity,
              alignment: Alignment.center,
              child: Text(
                'TickTock',
                style: GoogleFonts.zain(
                  fontSize: 22,
                  color: const Color(0xFF818CF8),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        DailyLogHeader(
                          selectedDate: _selectedDate,
                          onPrevDay: () {
                            setState(() {
                              _selectedDate = _selectedDate.subtract(
                                const Duration(days: 1),
                              );
                            });
                          },
                          onNextDay: () {
                            setState(() {
                              _selectedDate = _selectedDate.add(
                                const Duration(days: 1),
                              );
                            });
                          },
                          onToday: () {
                            setState(() {
                              final now = DateTime.now();
                              _selectedDate = DateTime(
                                now.year,
                                now.month,
                                now.day,
                              );
                            });
                          },
                          onJumpToDate: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2101),
                            );
                            if (picked != null && picked != _selectedDate) {
                              setState(() {
                                _selectedDate = picked;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 24),
                        DayTimeline(
                          selectedDate: _selectedDate,
                          tasks: _tasks,
                          isTracking: _isTracking,
                          trackingStartTime: _trackingStartTime,
                          trackingTaskTitle: _taskController.text.trim(),
                          palette: _palette,
                        ),
                        const SizedBox(height: 24),
                        QuickInput(
                          controller: _taskController,
                          isTracking: _isTracking,
                          onToggleTracking: _toggleTracking,
                        ),
                        const SizedBox(height: 24),
                        _buildTaskListHeader(),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final task = _tasks[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TaskItem(
                          task: task,
                          onToggleExpand: () => setState(
                            () => task.isExpanded = !task.isExpanded,
                          ),
                          onStartTracking: () {
                            _taskController.text = task.title;
                            _toggleTracking();
                          },
                          onEdit: () => _editTask(task),
                          onDelete: () =>
                              setState(() => _tasks.removeAt(index)),
                          onEditBlock: (block) => _editTimeBlock(task, block),
                          onDeleteBlock: (blockIndex) =>
                              _deleteTimeBlock(task, blockIndex),
                        ),
                      );
                    }, childCount: _tasks.length),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskListHeader() {
    final totalDuration = _tasks.fold(
      Duration.zero,
      (prev, task) => prev + task.totalDuration,
    );
    final totalTimeStr =
        '${totalDuration.inHours}h ${totalDuration.inMinutes % 60}m total';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Tasks',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(totalTimeStr, style: TextStyle(color: Colors.grey[400])),
      ],
    );
  }
}
