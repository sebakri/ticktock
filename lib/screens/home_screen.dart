import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:window_manager/window_manager.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import '../models/task.dart';
import '../models/time_block.dart';
import '../widgets/edit_task_dialog.dart';
import '../widgets/add_task_dialog.dart';
import '../widgets/edit_session_dialog.dart';
import '../widgets/home/daily_log_header.dart';
import '../widgets/home/day_timeline.dart';
import '../widgets/home/task_item.dart';
import '../widgets/shortcut_badge.dart';
import '../services/database_service.dart';

class AddTaskIntent extends Intent {
  const AddTaskIntent();
}

class FocusSearchIntent extends Intent {
  const FocusSearchIntent();
}

class ToggleTrackingIntent extends Intent {
  const ToggleTrackingIntent();
}

class ClearSearchIntent extends Intent {
  const ClearSearchIntent();
}

class ShowHelpIntent extends Intent {
  const ShowHelpIntent();
}

class JumpToDateIntent extends Intent {
  const JumpToDateIntent();
}

class GoToTodayIntent extends Intent {
  const GoToTodayIntent();
}

class ActivateTaskIntent extends Intent {
  final int index;
  const ActivateTaskIntent(this.index);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WindowListener {
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final FocusNode _mainFocusNode = FocusNode();
  bool _isTracking = false;
  DateTime? _trackingStartTime;
  Timer? _ticker;
  DateTime _selectedDate = DateTime.now();
  List<Task> _tasks = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final Set<int> _expandedActivityIds = {};
  final Set<int> _expandedLibraryIds = {};

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
    _registerGlobalHotkeys();
  }

  Future<void> _registerGlobalHotkeys() async {
    // Option + Space: Toggle Visibility
    HotKey toggleVisibleHotKey = HotKey(
      key: LogicalKeyboardKey.space,
      modifiers: [HotKeyModifier.alt],
      scope: HotKeyScope.system,
    );
    await hotKeyManager.register(
      toggleVisibleHotKey,
      keyDownHandler: (hotKey) async {
        bool isVisible = await windowManager.isVisible();
        if (isVisible) {
          await windowManager.hide();
        } else {
          await windowManager.show();
          await windowManager.focus();
        }
      },
    );

    // Option + S: Toggle Tracking
    HotKey toggleTrackingHotKey = HotKey(
      key: LogicalKeyboardKey.keyS,
      modifiers: [HotKeyModifier.alt],
      scope: HotKeyScope.system,
    );
    await hotKeyManager.register(
      toggleTrackingHotKey,
      keyDownHandler: (hotKey) {
        _handleGlobalToggleTracking();
      },
    );
  }

  void _handleGlobalToggleTracking() {
    if (_isTracking) {
      _stopTracking();
    } else if (_tasks.isNotEmpty) {
      // Start the first task as a default global action
      _startTracking(_tasks.first.title);
    }
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
    hotKeyManager.unregisterAll();
    _ticker?.cancel();
    _taskController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _mainFocusNode.dispose();
    super.dispose();
  }

  @override
  void onWindowClose() async {
    await windowManager.hide();
  }

  Future _refreshTasks() async {
    final tasks = await DatabaseService.instance.getTasks();
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): () =>
              Navigator.pop(context),
        },
        child: Dialog(
          backgroundColor: const Color(0xFF1E293B),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Keyboard Shortcuts',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Close (Esc)',
                    ),
                  ],
                ),
                const Divider(color: Colors.white10),
                const SizedBox(height: 16),
                _buildShortcutRow('⌥ + Space', 'Toggle Hide/Show App (Global)'),
                _buildShortcutRow('⌥ + S', 'Toggle Tracking (Global)'),
                const SizedBox(height: 12),
                _buildShortcutRow('⌘ + N', 'New Task'),
                _buildShortcutRow('⌘ + F', 'Search Tasks'),
                _buildShortcutRow('⌘ + S', 'Toggle Tracking'),
                _buildShortcutRow('⌘ + T', 'Go to Today'),
                _buildShortcutRow('⌘ + D', 'Jump to Date'),
                _buildShortcutRow('⌘ + 1-9', 'Open task in library'),
                _buildShortcutRow('Esc', 'Clear Search / Unfocus'),
                _buildShortcutRow('?', 'Show this help'),
                const Divider(color: Colors.white10),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Inside Task Modal',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
                _buildShortcutRow('⌘ + S', 'Start Tracking'),
                _buildShortcutRow('⌘ + ⌫', 'Delete Task'),
                _buildShortcutRow('⌘ + ↵', 'Save Changes'),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShortcutRow(String keys, String action) {
    final keyParts = keys.split(' + ');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < keyParts.length; i++) ...[
                ShortcutBadge(label: keyParts[i], fontSize: 13),
                if (i < keyParts.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text('+',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 12)),
                  ),
              ],
            ],
          ),
          Text(
            action,
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ],
      ),
    );
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

  void _goToToday() {
    setState(() {
      final now = DateTime.now();
      _selectedDate = DateTime(
        now.year,
        now.month,
        now.day,
      );
    });
  }

  Future<void> _jumpToDate() async {
    final dates = await DatabaseService.instance.getSessionDates();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    // Ensure initial date and today are selectable
    dates.add(today);
    dates.add(selected);

    if (!mounted) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      selectableDayPredicate: (date) {
        final normalized = DateTime(date.year, date.month, date.day);
        return dates.contains(normalized);
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _onStartTracking(String title) async {
    if (_isTracking && _taskController.text.trim() == title) {
      await _stopTracking();
    } else {
      await _startTracking(title);
    }
  }

  Future<void> _startTracking(String title) async {
    if (_isTracking) {
      await _stopTracking();
    }

    // Ensure the task exists
    final existingTaskIndex = _tasks.indexWhere((t) => t.title == title);
    if (existingTaskIndex == -1) {
      final newTask = Task(title: title, color: _getNextColor());
      await DatabaseService.instance.createTask(newTask);
      await _refreshTasks();
    }

    final startTime = DateTime.now();
    await DatabaseService.instance.saveTrackingState(title, startTime);

    _taskController.text = title;
    setState(() {
      _isTracking = true;
      _trackingStartTime = startTime;
      final now = DateTime.now();
      if (_selectedDate.year != now.year ||
          _selectedDate.month != now.month ||
          _selectedDate.day != now.day) {
        _selectedDate = DateTime(now.year, now.month, now.day);
      }
      _ticker?.cancel();
      _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {});
      });
    });
    _refreshTasks();
  }

  Future<void> _stopTracking() async {
    final title = _taskController.text.trim();
    if (title.isEmpty || !_isTracking) return;

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
    }

    await DatabaseService.instance.clearTrackingState();

    setState(() {
      _isTracking = false;
      _trackingStartTime = null;
      _taskController.clear();
      _ticker?.cancel();
      _ticker = null;
    });
    _refreshTasks();
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
        onDelete: () {
          _deleteTask(task);
          Navigator.pop(context);
        },
        onStart: () {
          _onStartTracking(task.title);
          Navigator.pop(context);
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
    final filteredTasks = _tasks.where((task) {
      if (_searchQuery.isEmpty) return true;
      final title = task.title.toLowerCase();
      final desc = task.description.toLowerCase();
      if (title.contains(_searchQuery) || desc.contains(_searchQuery)) {
        return true;
      }
      int charIndex = 0;
      for (int i = 0; i < title.length && charIndex < _searchQuery.length; i++) {
        if (title[i] == _searchQuery[charIndex]) charIndex++;
      }
      return charIndex == _searchQuery.length;
    }).toList();

    final todayTasks = filteredTasks.where((task) {
      final hasToday = task.blocks.any((b) =>
          b.startTime.year == _selectedDate.year &&
          b.startTime.month == _selectedDate.month &&
          b.startTime.day == _selectedDate.day);
      final isTrackingThisTask =
          _isTracking && _taskController.text.trim() == task.title;
      final isTodaySelected = DateTime.now().year == _selectedDate.year &&
          DateTime.now().month == _selectedDate.month &&
          DateTime.now().day == _selectedDate.day;
      return hasToday || (isTrackingThisTask && isTodaySelected);
    }).toList();

    final libraryTasks = filteredTasks;

    return Shortcuts(
      shortcuts: {
        const SingleActivator(LogicalKeyboardKey.keyN, meta: true):
            const AddTaskIntent(),
        const SingleActivator(LogicalKeyboardKey.keyF, meta: true):
            const FocusSearchIntent(),
        const SingleActivator(LogicalKeyboardKey.keyS, meta: true):
            const ToggleTrackingIntent(),
        const SingleActivator(LogicalKeyboardKey.escape):
            const ClearSearchIntent(),
        const SingleActivator(LogicalKeyboardKey.slash, shift: true):
            const ShowHelpIntent(),
        const SingleActivator(LogicalKeyboardKey.keyT, meta: true):
            const GoToTodayIntent(),
        const SingleActivator(LogicalKeyboardKey.keyD, meta: true):
            const JumpToDateIntent(),
        // Cmd + 1-9
        const SingleActivator(LogicalKeyboardKey.digit1, meta: true):
            const ActivateTaskIntent(0),
        const SingleActivator(LogicalKeyboardKey.digit2, meta: true):
            const ActivateTaskIntent(1),
        const SingleActivator(LogicalKeyboardKey.digit3, meta: true):
            const ActivateTaskIntent(2),
        const SingleActivator(LogicalKeyboardKey.digit4, meta: true):
            const ActivateTaskIntent(3),
        const SingleActivator(LogicalKeyboardKey.digit5, meta: true):
            const ActivateTaskIntent(4),
        const SingleActivator(LogicalKeyboardKey.digit6, meta: true):
            const ActivateTaskIntent(5),
        const SingleActivator(LogicalKeyboardKey.digit7, meta: true):
            const ActivateTaskIntent(6),
        const SingleActivator(LogicalKeyboardKey.digit8, meta: true):
            const ActivateTaskIntent(7),
        const SingleActivator(LogicalKeyboardKey.digit9, meta: true):
            const ActivateTaskIntent(8),
      },
      child: Actions(
        actions: {
          AddTaskIntent: CallbackAction<AddTaskIntent>(
            onInvoke: (intent) => _addNewTask(),
          ),
          FocusSearchIntent: CallbackAction<FocusSearchIntent>(
            onInvoke: (intent) => _searchFocusNode.requestFocus(),
          ),
          ShowHelpIntent: CallbackAction<ShowHelpIntent>(
            onInvoke: (intent) => _showHelpDialog(),
          ),
          GoToTodayIntent: CallbackAction<GoToTodayIntent>(
            onInvoke: (intent) {
              _goToToday();
              return null;
            },
          ),
          JumpToDateIntent: CallbackAction<JumpToDateIntent>(
            onInvoke: (intent) {
              _jumpToDate();
              return null;
            },
          ),
          ActivateTaskIntent: CallbackAction<ActivateTaskIntent>(
            onInvoke: (intent) {
              if (intent.index < libraryTasks.length) {
                _editTask(libraryTasks[intent.index]);
              }
              return null;
            },
          ),
          ToggleTrackingIntent: CallbackAction<ToggleTrackingIntent>(
            onInvoke: (intent) {
              try {
                if (_isTracking) {
                  _stopTracking();
                } else if (_tasks.isNotEmpty) {
                  _startTracking(_tasks.first.title);
                }
              } catch (e) {
                debugPrint('Error toggling tracking via shortcut: $e');
              }
              return null;
            },
          ),
          ClearSearchIntent: CallbackAction<ClearSearchIntent>(
            onInvoke: (intent) {
              _searchController.clear();
              _mainFocusNode.requestFocus();
              return null;
            },
          ),
        },
        child: Focus(
          focusNode: _mainFocusNode,
          autofocus: true,
          child: Scaffold(
            backgroundColor: const Color(0xFF0F172A),
            body: Column(
              children: [
                DragToMoveArea(
                  child: Container(
                    height: 60,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            'TickTock',
                            style: GoogleFonts.fascinate(
                              fontSize: 36,
                              color: const Color(0xFF818CF8),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: _showHelpDialog,
                            icon: const Icon(Icons.help_outline,
                                color: Colors.white30, size: 20),
                            tooltip: 'Shortcuts (?)',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                                          Expanded(
                                            child: _isLoading
                                                ? const Center(child: CircularProgressIndicator())
                                                : Padding(
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
                                                                                                      _selectedDate =
                                                                                                          _selectedDate.subtract(
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
                                                                                                  onToday: _goToToday,
                                                                                                  onJumpToDate: _jumpToDate,
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
                                                        if (todayTasks.isNotEmpty) ...[
                                                          SliverToBoxAdapter(
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(bottom: 12),
                                                              child: Text(
                                                                'ACTIVITY',
                                                                style: TextStyle(
                                                                    color: Colors.grey[500],
                                                                    fontSize: 12,
                                                                    fontWeight: FontWeight.bold,
                                                                    letterSpacing: 1.2),
                                                              ),
                                                            ),
                                                          ),
                                                          SliverList(
                                                            delegate: SliverChildBuilderDelegate((
                                                              context,
                                                              index,
                                                            ) {
                                                              final task = todayTasks[index];
                                                              final isTrackingThisTask = _isTracking &&
                                                                  _taskController.text.trim() ==
                                                                      task.title;
                                                              final activeDuration =
                                                                  isTrackingThisTask &&
                                                                          _trackingStartTime != null
                                                                      ? DateTime.now().difference(
                                                                          _trackingStartTime!)
                                                                      : Duration.zero;
                          
                                                              return Padding(
                                                                padding:
                                                                    const EdgeInsets.only(bottom: 12),
                                                                child: TaskItem(
                                                                  task: task,
                                                                  isTracking: isTrackingThisTask,
                                                                  activeDuration: activeDuration,
                                                                  customDuration:
                                                                      task.durationOn(_selectedDate),
                                                                  durationLabel: 'On this day',
                                                                  isExpanded:
                                                                      _expandedActivityIds.contains(task.id),
                                                                  onToggleExpand: () => setState(
                                                                    () {
                                                                      if (task.id != null) {
                                                                        if (_expandedActivityIds
                                                                            .contains(task.id)) {
                                                                          _expandedActivityIds
                                                                              .remove(task.id);
                                                                        } else {
                                                                          _expandedActivityIds.add(task.id!);
                                                                        }
                                                                      }
                                                                    },
                                                                  ),
                                                                  onStartTracking: () =>
                                                                      _onStartTracking(task.title),
                                                                  onEdit: () => _editTask(task),
                                                                  onEditBlock: (block) =>
                                                                      _editTimeBlock(task, block),
                                                                  onDeleteBlock: (blockIndex) =>
                                                                      _deleteTimeBlock(
                                                                          task, blockIndex),
                                                                ),
                                                              );
                                                            }, childCount: todayTasks.length),
                                                          ),
                                                          const SliverToBoxAdapter(
                                                              child: SizedBox(height: 12)),
                                                        ],
                                                        if (libraryTasks.isNotEmpty) ...[
                                                          SliverToBoxAdapter(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets.only(bottom: 12),
                                                              child: Text(
                                                                'LIBRARY',
                                                                style: TextStyle(
                                                                    color: Colors.grey[500],
                                                                    fontSize: 12,
                                                                    fontWeight: FontWeight.bold,
                                                                    letterSpacing: 1.2),
                                                              ),
                                                            ),
                                                          ),
                                                          SliverList(
                                                            delegate: SliverChildBuilderDelegate((
                                                              context,
                                                              index,
                                                            ) {
                                                              final task = libraryTasks[index];
                                                              final isTrackingThisTask = _isTracking &&
                                                                  _taskController.text.trim() ==
                                                                      task.title;
                                                              final activeDuration =
                                                                  isTrackingThisTask &&
                                                                          _trackingStartTime != null
                                                                      ? DateTime.now().difference(
                                                                          _trackingStartTime!)
                                                                      : Duration.zero;
                          
                                                              return Padding(
                                                                padding:
                                                                    const EdgeInsets.only(bottom: 12),
                                                                child: TaskItem(
                                                                  task: task,
                                                                  isTracking: isTrackingThisTask,
                                                                  activeDuration: activeDuration,
                                                                  durationLabel: 'Lifetime total',
                                                                  isExpanded:
                                                                      _expandedLibraryIds.contains(task.id),
                                                                  shortcutLabel: index < 9 ? '⌘${index + 1}' : null,
                                                                  onToggleExpand: () => setState(
                                                                    () {
                                                                      if (task.id != null) {
                                                                        if (_expandedLibraryIds
                                                                            .contains(task.id)) {
                                                                          _expandedLibraryIds
                                                                              .remove(task.id);
                                                                        } else {
                                                                          _expandedLibraryIds.add(task.id!);
                                                                        }
                                                                      }
                                                                    },
                                                                  ),
                                                                  onStartTracking: () =>
                                                                      _onStartTracking(task.title),
                                                                  onEdit: () => _editTask(task),
                                                                  onEditBlock: (block) =>
                                                                      _editTimeBlock(task, block),
                                                                  onDeleteBlock: (blockIndex) =>
                                                                      _deleteTimeBlock(
                                                                          task, blockIndex),
                                                                ),
                                                              );
                                                            }, childCount: libraryTasks.length),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
  Widget _buildTaskListHeader() {
    final totalDuration = _tasks.fold(
      Duration.zero,
      (prev, task) => prev + task.durationOn(_selectedDate),
    );
    final activeDuration = _isTracking &&
            _trackingStartTime != null &&
            DateTime.now().year == _selectedDate.year &&
            DateTime.now().month == _selectedDate.month &&
            DateTime.now().day == _selectedDate.day
        ? DateTime.now().difference(_trackingStartTime!)
        : Duration.zero;
    final total = totalDuration + activeDuration;

    final totalTimeStr = '${total.inHours}h ${total.inMinutes % 60}m today';

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
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _addNewTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 18),
                    SizedBox(width: 8),
                    Text('New Task',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    SizedBox(width: 12),
                    ShortcutBadge(label: '⌘N', isLight: true),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    style: const TextStyle(fontSize: 14),
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: 'Search tasks...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                      prefixIcon: Icon(Icons.search,
                          size: 20, color: Colors.white.withOpacity(0.3)),
                      border: InputBorder.none,
                      isDense: true,
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear,
                                  size: 18, color: Colors.white70),
                              onPressed: () => _searchController.clear(),
                            )
                          : const Padding(
                              padding: EdgeInsets.only(right: 12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ShortcutBadge(label: '⌘F', isLight: true),
                                ],
                              ),
                            ),
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
