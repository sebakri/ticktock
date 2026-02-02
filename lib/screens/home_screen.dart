import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:window_manager/window_manager.dart';
import '../models/task.dart';
import '../models/time_block.dart';
import '../widgets/edit_task_dialog.dart';
import '../widgets/add_task_dialog.dart';
import '../widgets/edit_session_dialog.dart';
import '../widgets/home/daily_log_header.dart';
import '../widgets/home/day_timeline.dart';
import '../widgets/home/task_item.dart';
import '../services/database_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WindowListener {
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool _isTracking = false;
  DateTime? _trackingStartTime;
  Timer? _ticker;
  DateTime _selectedDate = DateTime.now();
  List<Task> _tasks = [];
  bool _isLoading = true;
  String _searchQuery = '';

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

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _selectedDate = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    _refreshTasks();
    _loadTrackingState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  Future<void> _loadTrackingState() async {
    final state = await DatabaseService.instance.getTrackingState();
    if (state != null) {
      setState(() {
        _taskController.text = state['title'];
        _trackingStartTime = DateTime.parse(state['start_time']);
        _isTracking = true;
        _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {});
        });
      });
      _refreshTasks();
    }
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    _ticker?.cancel();
    _taskController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void onWindowClose() async {
    await windowManager.hide();
  }

  Future _refreshTasks() async {
    final tasks = await DatabaseService.instance.getTasks();
    
    // Sort tasks: if tracking, active task comes first.
    if (_isTracking) {
      final activeTitle = _taskController.text.trim();
      final activeIndex = tasks.indexWhere((t) => t.title == activeTitle);
      if (activeIndex != -1) {
        final activeTask = tasks.removeAt(activeIndex);
        tasks.insert(0, activeTask);
      }
    }
    
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  Color _getNextColor() {
    return _palette[_tasks.length % _palette.length];
  }

  void _addNewTask() {
    final usedColors = _tasks.map((t) => t.color).toSet();
    final availablePalette = _palette.where((color) => !usedColors.contains(color)).toList();
    final existingTitles = _tasks.map((t) => t.title.toLowerCase()).toList();

    showDialog(
      context: context,
      builder: (context) => AddTaskDialog(
        palette: availablePalette.isEmpty ? _palette : availablePalette,
        existingTitles: existingTitles,
        onSave: (title, description, color) async {
          final newTask = Task(
            title: title,
            description: description,
            color: color,
          );
          await DatabaseService.instance.createTask(newTask);
          _refreshTasks();
        },
      ),
    );
  }

  void _toggleTracking() async {
    final title = _taskController.text.trim();
    if (title.isEmpty) return;

    if (_isTracking) {
      final endTime = DateTime.now();
      final existingTaskIndex = _tasks.indexWhere((t) => t.title == title);

      if (existingTaskIndex != -1) {
        final task = _tasks[existingTaskIndex];
        final block = TimeBlock(
          taskId: task.id,
          startTime: _trackingStartTime!,
          endTime: endTime,
        );
        await DatabaseService.instance.createTimeBlock(block);
      } else {
        final newTask = Task(title: title, color: _getNextColor());
        final taskId = await DatabaseService.instance.createTask(newTask);
        final block = TimeBlock(
          taskId: taskId,
          startTime: _trackingStartTime!,
          endTime: endTime,
        );
        await DatabaseService.instance.createTimeBlock(block);
      }

      await DatabaseService.instance.clearTrackingState();

      setState(() {
        _isTracking = false;
        _trackingStartTime = null;
        _taskController.clear();
        _ticker?.cancel();
      });
      _refreshTasks();
    } else {
      final existingTaskIndex = _tasks.indexWhere((t) => t.title == title);
      if (existingTaskIndex == -1) {
        final newTask = Task(title: title, color: _getNextColor());
        await DatabaseService.instance.createTask(newTask);
        await _refreshTasks();
      }

      final startTime = DateTime.now();
      await DatabaseService.instance.saveTrackingState(title, startTime);

      setState(() {
        _isTracking = true;
        _trackingStartTime = startTime;
        final now = DateTime.now();
        if (_selectedDate.year != now.year ||
            _selectedDate.month != now.month ||
            _selectedDate.day != now.day) {
          _selectedDate = DateTime(now.year, now.month, now.day);
        }
        _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {});
        });
      });
      _refreshTasks();
    }
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
        onSave: (title, description, color) async {
          task.title = title;
          task.description = description;
          task.color = color;
          await DatabaseService.instance.updateTask(task);
          _refreshTasks();
        },
      ),
    );
  }

  void _editTimeBlock(Task task, TimeBlock block) {
    showDialog(
      context: context,
      builder: (context) => EditSessionDialog(
        block: block,
        onSave: (newName) async {
          block.name = newName;
          await DatabaseService.instance.updateTimeBlock(block);
          _refreshTasks();
        },
      ),
    );
  }

  void _deleteTimeBlock(Task task, int blockIndex) async {
    final block = task.blocks[blockIndex];
    if (block.id != null) {
      await DatabaseService.instance.deleteTimeBlock(block.id!);
      if (task.blocks.length == 1) {
        await DatabaseService.instance.deleteTask(task.id!);
      }
      _refreshTasks();
    }
  }

  void _deleteTask(Task task) async {
    if (task.id != null) {
      await DatabaseService.instance.deleteTask(task.id!);
      _refreshTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Column(
        children: [
          DragToMoveArea(
            child: Container(
              height: 60,
              width: double.infinity,
              alignment: Alignment.center,
              child: Text(
                'TickTock',
                style: GoogleFonts.fascinate(
                  fontSize: 36,
                  color: const Color(0xFF818CF8),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Builder(builder: (context) {
                      final filteredTasks = _tasks.where((task) {
                        if (_searchQuery.isEmpty) return true;
                        final title = task.title.toLowerCase();
                        final desc = task.description.toLowerCase();
                        if (title.contains(_searchQuery) ||
                            desc.contains(_searchQuery)) return true;
                        int charIndex = 0;
                        for (int i = 0;
                            i < title.length && charIndex < _searchQuery.length;
                            i++) {
                          if (title[i] == _searchQuery[charIndex]) charIndex++;
                        }
                        return charIndex == _searchQuery.length;
                      }).toList();

                      return CustomScrollView(
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
                                    final dates = await DatabaseService.instance
                                        .getSessionDates();
                                    final now = DateTime.now();
                                    final today =
                                        DateTime(now.year, now.month, now.day);
                                    final selected = DateTime(
                                        _selectedDate.year,
                                        _selectedDate.month,
                                        _selectedDate.day);

                                    // Ensure initial date and today are selectable
                                    dates.add(today);
                                    dates.add(selected);

                                    if (!mounted) return;

                                    final DateTime? picked =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: _selectedDate,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2101),
                                      selectableDayPredicate: (date) {
                                        final normalized = DateTime(
                                            date.year, date.month, date.day);
                                        return dates.contains(normalized);
                                      },
                                    );
                                    if (picked != null &&
                                        picked != _selectedDate) {
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
                                  trackingTaskTitle:
                                      _taskController.text.trim(),
                                  palette: _palette,
                                ),
                                const SizedBox(height: 24),
                                _buildTaskListHeader(),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final task = filteredTasks[index];
                              final isTrackingThisTask = _isTracking &&
                                  _taskController.text.trim() == task.title;
                              final activeDuration = isTrackingThisTask &&
                                      _trackingStartTime != null
                                  ? DateTime.now()
                                      .difference(_trackingStartTime!)
                                  : Duration.zero;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: TaskItem(
                                  task: task,
                                  isTracking: isTrackingThisTask,
                                  activeDuration: activeDuration,
                                  onToggleExpand: () => setState(
                                    () => task.isExpanded = !task.isExpanded,
                                  ),
                                  onStartTracking: () {
                                    _taskController.text = task.title;
                                    _toggleTracking();
                                  },
                                  onEdit: () => _editTask(task),
                                  onDelete: () => _deleteTask(task),
                                  onEditBlock: (block) =>
                                      _editTimeBlock(task, block),
                                  onDeleteBlock: (blockIndex) =>
                                      _deleteTimeBlock(task, blockIndex),
                                ),
                              );
                            }, childCount: filteredTasks.length),
                          ),
                        ],
                      );
                    }),
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
        Expanded(
          child: Row(
            children: [
              const Text(
                'Tasks',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _addNewTask,
                icon: const Icon(Icons.add_circle_outline, color: Color(0xFF818CF8)),
                tooltip: 'Add New Task',
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search tasks...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                      prefixIcon: Icon(Icons.search, size: 18, color: Colors.white.withOpacity(0.3)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      suffixIcon: _searchQuery.isNotEmpty 
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Text(totalTimeStr, style: TextStyle(color: Colors.grey[400])),
      ],
    );
  }
}
