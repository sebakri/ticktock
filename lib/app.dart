import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

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
    return MaterialApp(
      title: 'TickTock',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.light().textTheme,
        ),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF4F46E5),
          surface: Color(0xFFFFFFFF),
          onSurface: Color(0xFF0F172A),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4F46E5),
          surface: Color(0xFF0F172A),
          onSurface: Colors.white,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
