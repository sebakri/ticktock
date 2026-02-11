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
import '../widgets/home/activity_log_item.dart';
import '../widgets/home/task_tile.dart';
import '../widgets/shortcut_badge.dart';
import '../services/task_service.dart';
import '../services/tray_service.dart';
import '../app.dart';
import '../intents.dart';
import '../globals.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with WindowListener {
  final TextEditingController taskController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  final FocusNode mainFocusNode = FocusNode();
  bool _isTracking = false;
  bool _isWindowFocused = true;
  DateTime? _trackingStartTime;
  Timer? _ticker;
  DateTime _selectedDate = DateTime.now();
  List<Task> _tasks = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final Set<String> _selectedTags = {};
  final Set<int> _expandedActivityIds = {};
  final Map<int, Color> _taskColors = {};

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
    _loadFilterState();
    searchController.addListener(() {
      setState(() {
        _searchQuery = searchController.text.trim().toLowerCase();
      });
    });
    _registerGlobalHotkeys();
  }

  Future<void> _loadFilterState() async {
    final tags = await TaskService.instance.getSelectedTags();
    setState(() {
      _selectedTags.clear();
      _selectedTags.addAll(tags);
    });
  }

  Future<void> _registerGlobalHotkeys() async {
    try {
      // Clear any existing hotkeys to prevent duplicates or conflicts
      await hotKeyManager.unregisterAll();

      // Option + Space: Toggle Visibility
      HotKey toggleVisibleHotKey = HotKey(
        key: LogicalKeyboardKey.space,
        modifiers: [HotKeyModifier.alt],
        scope: HotKeyScope.system,
      );
      await hotKeyManager.register(
        toggleVisibleHotKey,
        keyDownHandler: (hotKey) async {
          bool isFocused = await windowManager.isFocused();
          if (isFocused) {
            await windowManager.hide();
          } else {
            await windowManager.show();
            await windowManager.focus();
          }
        },
      );
    } catch (e) {
      debugPrint('Error registering global hotkeys: $e');
    }
  }

  Future<void> _loadTrackingState() async {
    final state = await TaskService.instance.getTrackingState();
    if (state != null) {
      setState(() {
        taskController.text = state['title'];
        _trackingStartTime = DateTime.parse(state['start_time']);
        _isTracking = true;
        _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {});
        });
        TrayService.instance.updateTrayText(state['title']);
      });
      _refreshTasks();
    }
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    hotKeyManager.unregisterAll();
    _ticker?.cancel();
    taskController.dispose();
    searchController.dispose();
    searchFocusNode.dispose();
    mainFocusNode.dispose();
    super.dispose();
  }

  @override
  void onWindowClose() async {
    await windowManager.hide();
  }

  @override
  void onWindowFocus() {
    setState(() {
      _isWindowFocused = true;
    });
    windowFocusNotifier.value = true;
    final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
    if (isCurrentRoute && !searchFocusNode.hasFocus) {
      mainFocusNode.requestFocus();
    }
  }

  @override
  void onWindowBlur() {
    setState(() {
      _isWindowFocused = false;
    });
    windowFocusNotifier.value = false;
  }

  @override
  void onWindowResized() async {
    final size = await windowManager.getSize();
    await TaskService.instance.saveWindowSize(size.width, size.height);
  }

  Future _refreshTasks() async {
    final tasks = await TaskService.instance.getTasks();
    setState(() {
      _tasks = tasks;
      _isLoading = false;

      // Update dynamic colors based on all tasks
      _taskColors.clear();
      for (int i = 0; i < _tasks.length; i++) {
        if (_tasks[i].id != null) {
          _taskColors[_tasks[i].id!] = _palette[i % _palette.length];
        }
      }
    });
  }

  void showHelpDialog() {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    showDialog(
      context: context,
      builder: (context) => CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): () =>
              Navigator.pop(context),
        },
        child: Dialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
                    Text(
                      'Keyboard Shortcuts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: onSurface,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: onSurface.withOpacity(0.3),
                      ),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Close (Esc)',
                    ),
                  ],
                ),
                Divider(color: onSurface.withOpacity(0.05)),
                const SizedBox(height: 16),
                _buildShortcutRow('⌥ + Space', 'Toggle Hide/Show App (Global)'),
                const SizedBox(height: 12),
                _buildShortcutRow('⌘ + N', 'New Task'),
                _buildShortcutRow('⌘ + F', 'Search Tasks'),
                _buildShortcutRow('⌘ + S', 'Toggle Tracking'),
                _buildShortcutRow('⌘ + T', 'Go to Today'),
                _buildShortcutRow('⌘ + D', 'Jump to Date'),
                _buildShortcutRow('⌘ + 1-9', 'Start tracking activity task'),
                _buildShortcutRow('⌘ + A-Z', 'Open task in library'),
                _buildShortcutRow('Esc', 'Clear Search / Unfocus'),
                _buildShortcutRow('?', 'Show this help'),
                Divider(color: onSurface.withOpacity(0.05)),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Inside Task Modal',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: onSurface.withOpacity(0.6),
                    ),
                  ),
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
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
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
                    child: Text(
                      '+',
                      style: TextStyle(
                        color: onSurface.withOpacity(0.3),
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ],
          ),
          Text(
            action,
            style: TextStyle(color: onSurface.withOpacity(0.5), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, {Widget? trailing}) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 16, color: onSurface.withOpacity(0.3)),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: onSurface.withOpacity(0.4),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [onSurface.withOpacity(0.1), Colors.transparent],
                ),
              ),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 16), trailing],
        ],
      ),
    );
  }

  void addNewTask() {
    final existingTitles = _tasks.map((t) => t.title.toLowerCase()).toList();

    showDialog(
      context: context,
      builder: (context) => AddTaskDialog(
        existingTitles: existingTitles,
        onSave: (title, description, tags) async {
          final newTask = Task(
            title: title,
            description: description,
            tags: tags,
          );
          await TaskService.instance.createTask(newTask);
          _refreshTasks();
        },
      ),
    );
  }

  void goToToday() {
    setState(() {
      final now = DateTime.now();
      _selectedDate = DateTime(now.year, now.month, now.day);
    });
  }

  Future<void> jumpToDate() async {
    final dates = await TaskService.instance.getSessionDates();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

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

  Future<void> editActiveSession() async {
    if (!_isTracking || _trackingStartTime == null) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_trackingStartTime!),
    );

    if (pickedTime == null) return;

    final newStartTime = DateTime(
      _trackingStartTime!.year,
      _trackingStartTime!.month,
      _trackingStartTime!.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (newStartTime != _trackingStartTime) {
      await TaskService.instance
          .saveTrackingState(taskController.text, newStartTime);
      setState(() {
        _trackingStartTime = newStartTime;
      });
    }
  }

  void onStartTracking(String title) async {
    if (_isTracking && taskController.text.trim() == title) {
      await _stopTracking();
    } else {
      await _startTracking(title);
    }
  }

  void handleToggleTracking() async {
    if (_isTracking) {
      await _stopTracking();
    } else {
      // 1. Try to get the last active task from DB
      final lastActiveTitle = await TaskService.instance
          .getLastActiveTaskTitle();
      if (lastActiveTitle != null) {
        await _startTracking(lastActiveTitle);
      } else if (_tasks.isNotEmpty) {
        // 2. Fallback to first task in list
        await _startTracking(_tasks.first.title);
      }
    }
  }

  Future<void> _startTracking(String title) async {
    if (_isTracking) {
      await _stopTracking();
    }

    // Ensure the task exists
    final existingTaskIndex = _tasks.indexWhere((t) => t.title == title);
    if (existingTaskIndex == -1) {
      final newTask = Task(title: title);
      await TaskService.instance.createTask(newTask);
      await _refreshTasks();
    }

    final startTime = DateTime.now();
    await TaskService.instance.saveTrackingState(title, startTime);
    await TrayService.instance.updateTrayText(title);

    taskController.text = title;
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
    final title = taskController.text.trim();
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
      await TaskService.instance.createTimeBlock(block);
    }

    await TaskService.instance.clearTrackingState();
    await TrayService.instance.updateTrayText();

    setState(() {
      _isTracking = false;
      _trackingStartTime = null;
      taskController.clear();
      _ticker?.cancel();
      _ticker = null;
    });
    _refreshTasks();
  }

  void editTask(Task task) {
    showDialog(
      context: context,
      builder: (context) => EditTaskDialog(
        task: task,
        onSave: (title, description, tags) async {
          task.title = title;
          task.description = description;
          task.tags.clear();
          task.tags.addAll(tags);
          await TaskService.instance.updateTask(task);
          _refreshTasks();
        },
        onDelete: () {
          deleteTask(task);
          Navigator.pop(context);
        },
        onStart: () {
          onStartTracking(task.title);
          Navigator.pop(context);
        },
      ),
    );
  }

  void editTimeBlock(Task task, TimeBlock block) {
    showDialog(
      context: context,
      builder: (context) => EditSessionDialog(
        block: block,
        onSave: (newName, newStart, newEnd) async {
          block.name = newName;
          final updatedBlock = TimeBlock(
            id: block.id,
            taskId: block.taskId,
            name: newName,
            startTime: newStart,
            endTime: newEnd,
          );
          await TaskService.instance.updateTimeBlock(updatedBlock);
          _refreshTasks();
        },
      ),
    );
  }

  void deleteTimeBlock(Task task, TimeBlock block) async {
    if (block.id != null) {
      await TaskService.instance.deleteTimeBlock(block.id!);
      if (task.blocks.length == 1) {
        await TaskService.instance.deleteTask(task.id!);
      }
      _refreshTasks();
    }
  }

  void deleteTask(Task task) async {
    if (task.id != null) {
      await TaskService.instance.deleteTask(task.id!);
      _refreshTasks();
    }
  }

  void moveTimeBlockToTask(TimeBlock block, Task targetTask) async {
    if (block.taskId == targetTask.id) return;

    block.taskId = targetTask.id;
    await TaskService.instance.updateTimeBlock(block);

    _refreshTasks();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Moved session to ${targetTask.title}'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          width: 300,
        ),
      );
    }
  }

  void clearSearch() {
    searchController.clear();
    mainFocusNode.requestFocus();
  }

  void trackActivityTask(int index) {
    final today = _getTodayTasks(_getFilteredTasks());
    if (index < today.length) {
      onStartTracking(today[index].title);
    }
  }

  void editLibraryTask(String char) {
    final libraryTasks = _getFilteredTasks();
    final index = libraryKeys.indexWhere((k) => k.keyLabel == char);
    if (index != -1 && index < libraryTasks.length) {
      editTask(libraryTasks[index]);
    }
  }

  List<Task> _getFilteredTasks() {
    return _tasks.where((task) {
      if (_selectedTags.isNotEmpty) {
        if (!_selectedTags.every((tag) => task.tags.contains(tag))) {
          return false;
        }
      }
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
  }

  List<Task> _getTodayTasks(List<Task> filtered) {
    return filtered.where((task) {
      final hasToday = task.blocks.any(
        (b) =>
            b.startTime.year == _selectedDate.year &&
            b.startTime.month == _selectedDate.month &&
            b.startTime.day == _selectedDate.day,
      );
      final isTrackingThisTask =
          _isTracking && taskController.text.trim() == task.title;
      final isTodaySelected =
          DateTime.now().year == _selectedDate.year &&
          DateTime.now().month == _selectedDate.month &&
          DateTime.now().day == _selectedDate.day;
      return hasToday || (isTrackingThisTask && isTodaySelected);
    }).toList();
  }

  static const libraryKeys = [
    LogicalKeyboardKey.keyA,
    LogicalKeyboardKey.keyB,
    LogicalKeyboardKey.keyC,
    LogicalKeyboardKey.keyE,
    LogicalKeyboardKey.keyG,
    LogicalKeyboardKey.keyH,
    LogicalKeyboardKey.keyI,
    LogicalKeyboardKey.keyJ,
    LogicalKeyboardKey.keyK,
    LogicalKeyboardKey.keyL,
    LogicalKeyboardKey.keyM,
    LogicalKeyboardKey.keyO,
    LogicalKeyboardKey.keyP,
    LogicalKeyboardKey.keyQ,
    LogicalKeyboardKey.keyR,
    LogicalKeyboardKey.keyU,
    LogicalKeyboardKey.keyV,
    LogicalKeyboardKey.keyW,
    LogicalKeyboardKey.keyX,
    LogicalKeyboardKey.keyY,
    LogicalKeyboardKey.keyZ,
  ];

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _getFilteredTasks();
    final todayTasks = _getTodayTasks(filteredTasks);
    final libraryTasks = filteredTasks;

    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        // Local dynamic shortcuts for library tasks
        for (int i = 0; i < libraryTasks.length && i < libraryKeys.length; i++)
          SingleActivator(libraryKeys[i], meta: true): EditLibraryTaskIntent(
            libraryKeys[i].keyLabel,
          ),
      },
      child: FocusScope(
        autofocus: true,
        child: Focus(
          focusNode: mainFocusNode,
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Builder(
                                builder: (context) {
                                  final themeProvider = ThemeProvider.of(
                                    context,
                                  );
                                  final mode = themeProvider.themeMode;

                                  IconData iconData;
                                  if (mode == ThemeMode.system) {
                                    iconData = Icons.brightness_auto_rounded;
                                  } else if (mode == ThemeMode.dark) {
                                    iconData = Icons.dark_mode_rounded;
                                  } else {
                                    iconData = Icons.light_mode_rounded;
                                  }

                                  return IconButton(
                                    onPressed: themeProvider.toggleTheme,
                                    icon: Icon(
                                      iconData,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.3),
                                      size: 20,
                                    ),
                                    tooltip:
                                        'Theme: ${mode.name.toUpperCase()}',
                                  );
                                },
                              ),
                              IconButton(
                                onPressed: showHelpDialog,
                                icon: Icon(
                                  Icons.help_outline,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.3),
                                  size: 20,
                                ),
                                tooltip: 'Shortcuts (?)',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : GestureDetector(
                          onTap: () {
                            if (!searchFocusNode.hasFocus) {
                              mainFocusNode.requestFocus();
                            }
                          },
                          behavior: HitTestBehavior.translucent,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            child: CustomScrollView(
                              slivers: [
                                SliverToBoxAdapter(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildSectionHeader(
                                        'ACTIVITY',
                                        Icons.history_rounded,
                                        trailing: _buildTodayTotalBadge(),
                                      ),
                                      DailyLogHeader(
                                        selectedDate: _selectedDate,
                                        onPrevDay: () {
                                          setState(() {
                                            _selectedDate = _selectedDate
                                                .subtract(
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
                                        onToday: goToToday,
                                        onJumpToDate: jumpToDate,
                                      ),
                                      const SizedBox(height: 24),
                                      DayTimeline(
                                        selectedDate: _selectedDate,
                                        tasks: todayTasks,
                                        isTracking: _isTracking,
                                        trackingStartTime: _trackingStartTime,
                                        trackingTaskTitle: taskController.text
                                            .trim(),
                                        taskColors: _taskColors,
                                      ),
                                      const SizedBox(height: 16),
                                      _buildTagFilterBar(),
                                      const SizedBox(height: 16),
                                    ],
                                  ),
                                ),
                                if (todayTasks.isNotEmpty) ...[
                                  SliverList(
                                    delegate: SliverChildBuilderDelegate((
                                      context,
                                      index,
                                    ) {
                                      final task = todayTasks[index];
                                      final taskColor = _taskColors[task.id] ?? Colors.grey;
                                      final isTrackingThisTask =
                                          _isTracking &&
                                          taskController.text.trim() ==
                                              task.title;
                                      final activeDuration =
                                          isTrackingThisTask &&
                                              _trackingStartTime != null
                                          ? DateTime.now().difference(
                                              _trackingStartTime!,
                                            )
                                          : Duration.zero;

                                      final shortcutLabel = index < 9
                                          ? '⌘${index + 1}'
                                          : null;

                                      return ActivityLogItem(
                                        task: task,
                                        selectedDate: _selectedDate,
                                        isTracking: isTrackingThisTask,
                                        activeDuration: activeDuration,
                                        dailyDuration: task.durationOn(
                                          _selectedDate,
                                        ),
                                        color: taskColor,
                                        isExpanded: _expandedActivityIds.contains(
                                          task.id,
                                        ),
                                        shortcutLabel: shortcutLabel,
                                        isFirst: index == 0,
                                        isLast: index == todayTasks.length - 1,
                                        onToggleExpand: () => setState(() {
                                          if (task.id != null) {
                                            if (_expandedActivityIds.contains(
                                              task.id,
                                            )) {
                                              _expandedActivityIds.remove(
                                                task.id,
                                              );
                                            } else {
                                              _expandedActivityIds.add(task.id!);
                                            }
                                          }
                                        }),
                                                                              onStartTracking: () =>
                                                                                  onStartTracking(task.title),
                                                                              onEditActiveSession: editActiveSession,
                                                                              onEditBlock: (block) =>
                                                                                  editTimeBlock(task, block),                                        onDeleteBlock: (block) =>
                                            deleteTimeBlock(task, block),
                                        onAcceptTimeBlock: (block) =>
                                            moveTimeBlockToTask(block, task),
                                        onTagTap: (tag) => setState(() {
                                          if (_selectedTags.contains(tag)) {
                                            _selectedTags.remove(tag);
                                          } else {
                                            _selectedTags.add(tag);
                                          }
                                          TaskService.instance.saveSelectedTags(_selectedTags);
                                        }),
                                      );
                                    }, childCount: todayTasks.length),
                                  ),
                                ],
                                if (libraryTasks.isNotEmpty) ...[
                                   SliverToBoxAdapter(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildSectionHeader(
                                          'LIBRARY',
                                          Icons.layers_rounded,
                                        ),
                                        _buildSearchHeader(),
                                        const SizedBox(height: 16),
                                      ],
                                    ),
                                  ),
                                  SliverGrid(
                                    gridDelegate:
                                        const SliverGridDelegateWithMaxCrossAxisExtent(
                                          maxCrossAxisExtent: 280,
                                          mainAxisSpacing: 12,
                                          crossAxisSpacing: 12,
                                          childAspectRatio: 1.8,
                                        ),
                                    delegate: SliverChildBuilderDelegate((
                                      context,
                                      index,
                                    ) {
                                      final task = libraryTasks[index];
                                      final taskColor = _taskColors[task.id] ?? Colors.grey;
                                      final isTrackingThisTask =
                                          _isTracking &&
                                          taskController.text.trim() ==
                                              task.title;

                                      final shortcutLabel =
                                          index < libraryKeys.length
                                          ? '⌘${libraryKeys[index].keyLabel}'
                                          : null;

                                      return TaskTile(
                                        task: task,
                                        isTracking: isTrackingThisTask,
                                        shortcutLabel: shortcutLabel,
                                        color: taskColor,
                                        onTap: () => editTask(task),
                                        onAcceptTimeBlock: (block) =>
                                            moveTimeBlockToTask(block, task),
                                        onTagTap: (tag) => setState(() {
                                          if (_selectedTags.contains(tag)) {
                                            _selectedTags.remove(tag);
                                          } else {
                                            _selectedTags.add(tag);
                                          }
                                          TaskService.instance.saveSelectedTags(_selectedTags);
                                        }),
                                      );
                                    }, childCount: libraryTasks.length),
                                  ),
                                ],
                              ],
                            ),
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

  Widget _buildTagFilterBar() {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    final allTags = _tasks.expand((t) => t.tags).toSet().toList()..sort();

    if (allTags.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 32,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildTagChip(
            'All',
            _selectedTags.isEmpty,
            () => setState(() {
              _selectedTags.clear();
              TaskService.instance.saveSelectedTags(_selectedTags);
            }),
            onSurface,
          ),
          const SizedBox(width: 8),
          ...allTags.map(
            (tag) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildTagChip(
                '#$tag',
                _selectedTags.contains(tag),
                () => setState(() {
                  if (_selectedTags.contains(tag)) {
                    _selectedTags.remove(tag);
                  } else {
                    _selectedTags.add(tag);
                  }
                  TaskService.instance.saveSelectedTags(_selectedTags);
                }),
                onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
    Color onSurface,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4F46E5)
              : onSurface.withOpacity(0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : onSurface.withOpacity(0.05),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : onSurface.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildTodayTotalBadge() {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    final totalDuration = _tasks.fold(
      Duration.zero,
      (prev, task) => prev + task.durationOn(_selectedDate),
    );
    final activeDuration =
        _isTracking &&
            _trackingStartTime != null &&
            DateTime.now().year == _selectedDate.year &&
            DateTime.now().month == _selectedDate.month &&
            DateTime.now().day == _selectedDate.day
        ? DateTime.now().difference(_trackingStartTime!)
        : Duration.zero;
    final total = totalDuration + activeDuration;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: onSurface.withOpacity(0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: onSurface.withOpacity(0.05)),
      ),
      child: Text(
        '${total.inHours}h ${total.inMinutes % 60}m total',
        style: TextStyle(
          color: onSurface.withOpacity(0.4),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Row(
      children: [
        ElevatedButton(
          onPressed: addNewTask,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F46E5).withOpacity(0.1),
            foregroundColor: const Color(0xFF4F46E5),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: const Color(0xFF4F46E5).withOpacity(0.2)),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add, size: 18),
              const SizedBox(width: 8),
              const Text(
                'New Task',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              const ShortcutBadge(label: '⌘N', isLight: true),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: onSurface.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: searchController,
              focusNode: searchFocusNode,
              style: TextStyle(fontSize: 14, color: onSurface),
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                hintStyle: TextStyle(color: onSurface.withOpacity(0.3)),
                prefixIcon: Icon(
                  Icons.search,
                  size: 20,
                  color: onSurface.withOpacity(0.3),
                ),
                border: InputBorder.none,
                isDense: true,
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          size: 18,
                          color: onSurface.withOpacity(0.7),
                        ),
                        onPressed: () => searchController.clear(),
                      )
                    : const Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ShortcutBadge(label: '⌘F', isLight: true)
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
