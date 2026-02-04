import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ticktock/app.dart';
import 'package:ticktock/models/task.dart';
import 'package:ticktock/models/time_block.dart';
import 'package:ticktock/services/task_service.dart';

class MockTaskService extends Mock implements TaskService {}

void main() {
  late MockTaskService mockTaskService;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    const MethodChannel('window_manager').setMockMethodCallHandler((MethodCall methodCall) async {
      return null;
    });
    const MethodChannel('hotkey_manager').setMockMethodCallHandler((MethodCall methodCall) async {
      return null;
    });
    
    registerFallbackValue(Task(title: '', color: Colors.black));
    registerFallbackValue(TimeBlock(startTime: DateTime.now(), endTime: DateTime.now()));
  });

  setUp(() {
    mockTaskService = MockTaskService();
    TaskService.instance = mockTaskService;

    when(() => mockTaskService.getTasks()).thenAnswer((_) async => []);
    when(() => mockTaskService.getTrackingState()).thenAnswer((_) async => null);
    when(() => mockTaskService.getSessionDates()).thenAnswer((_) async => <DateTime>{});
  });

  testWidgets('HomeScreen basic coverage test', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1200));
    
    // Provide some tasks to ensure the Library section is rendered and contains interactive elements
    final tasks = [
      Task(id: 1, title: 'Alpha', color: Colors.blue),
      Task(id: 2, title: 'Beta', color: Colors.red),
    ];
    when(() => mockTaskService.getTasks()).thenAnswer((_) async => tasks);

    await tester.pumpWidget(const TickTockApp());
    await tester.pumpAndSettle();

    expect(find.text('TickTock'), findsOneWidget);
    expect(find.text('Alpha'), findsWidgets);
    expect(find.text('Beta'), findsWidgets);
  });
}
