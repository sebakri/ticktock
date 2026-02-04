import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticktock/app.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('TickTockApp theme toggling works', (WidgetTester tester) async {
    await tester.pumpWidget(const TickTockApp());
    
    final TickTockAppState state = tester.state(find.byType(TickTockApp));
    
    expect(state.themeMode, ThemeMode.system);
    
    state.toggleTheme();
    expect(state.themeMode, ThemeMode.light);
    
    state.toggleTheme();
    expect(state.themeMode, ThemeMode.dark);
    
    state.toggleTheme();
    expect(state.themeMode, ThemeMode.system);
  });
}
