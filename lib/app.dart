import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'intents.dart';
import 'globals.dart';

class ThemeProvider extends InheritedWidget {
  final ThemeMode themeMode;
  final VoidCallback toggleTheme;

  const ThemeProvider({
    super.key,
    required this.themeMode,
    required this.toggleTheme,
    required super.child,
  });

  static ThemeProvider of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<ThemeProvider>();
    assert(result != null, 'No ThemeProvider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(ThemeProvider oldWidget) {
    return themeMode != oldWidget.themeMode;
  }
}

class TickTockApp extends StatefulWidget {
  const TickTockApp({super.key});

  @override
  State<TickTockApp> createState() => TickTockAppState();

  static TickTockAppState of(BuildContext context) =>
      context.findAncestorStateOfType<TickTockAppState>()!;
}

class TickTockAppState extends State<TickTockApp> {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.system) {
        _themeMode = ThemeMode.light;
      } else if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.system;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      themeMode: _themeMode,
      toggleTheme: toggleTheme,
      child: Shortcuts(
        shortcuts: <ShortcutActivator, Intent>{
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
          // Digit shortcuts
          const SingleActivator(LogicalKeyboardKey.digit1, meta: true):
              const TrackActivityTaskIntent(0),
          const SingleActivator(LogicalKeyboardKey.digit2, meta: true):
              const TrackActivityTaskIntent(1),
          const SingleActivator(LogicalKeyboardKey.digit3, meta: true):
              const TrackActivityTaskIntent(2),
          const SingleActivator(LogicalKeyboardKey.digit4, meta: true):
              const TrackActivityTaskIntent(3),
          const SingleActivator(LogicalKeyboardKey.digit5, meta: true):
              const TrackActivityTaskIntent(4),
          const SingleActivator(LogicalKeyboardKey.digit6, meta: true):
              const TrackActivityTaskIntent(5),
          const SingleActivator(LogicalKeyboardKey.digit7, meta: true):
              const TrackActivityTaskIntent(6),
          const SingleActivator(LogicalKeyboardKey.digit8, meta: true):
              const TrackActivityTaskIntent(7),
          const SingleActivator(LogicalKeyboardKey.digit9, meta: true):
              const TrackActivityTaskIntent(8),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            AddTaskIntent: CallbackAction<AddTaskIntent>(
                onInvoke: (intent) => homeKey.currentState?.addNewTask()),
            FocusSearchIntent: CallbackAction<FocusSearchIntent>(
                onInvoke: (intent) =>
                    homeKey.currentState?.searchFocusNode.requestFocus()),
            ShowHelpIntent: CallbackAction<ShowHelpIntent>(
                onInvoke: (intent) => homeKey.currentState?.showHelpDialog()),
            GoToTodayIntent: CallbackAction<GoToTodayIntent>(
                onInvoke: (intent) => homeKey.currentState?.goToToday()),
            JumpToDateIntent: CallbackAction<JumpToDateIntent>(
                onInvoke: (intent) => homeKey.currentState?.jumpToDate()),
            TrackActivityTaskIntent: CallbackAction<TrackActivityTaskIntent>(
              onInvoke: (intent) =>
                  homeKey.currentState?.trackActivityTask(intent.index),
            ),
            EditLibraryTaskIntent: CallbackAction<EditLibraryTaskIntent>(
              onInvoke: (intent) =>
                  homeKey.currentState?.editLibraryTask(intent.char),
            ),
            ToggleTrackingIntent: CallbackAction<ToggleTrackingIntent>(
                onInvoke: (intent) =>
                    homeKey.currentState?.handleToggleTracking()),
            ClearSearchIntent: CallbackAction<ClearSearchIntent>(
              onInvoke: (intent) => homeKey.currentState?.clearSearch(),
            ),
          },
          child: MaterialApp(
            title: 'TickTock',
            debugShowCheckedModeBanner: false,
            themeMode: _themeMode,
            theme: ThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor: const Color(0xFFF8FAFC),
              textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF4F46E5),
                surface: Color(0xFFFFFFFF),
                onSurface: Color(0xFF0F172A),
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF0F172A),
              textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF4F46E5),
                surface: Color(0xFF0F172A),
                onSurface: Colors.white,
              ),
            ),
            home: HomeScreen(key: homeKey),
          ),
        ),
      ),
    );
  }
}
