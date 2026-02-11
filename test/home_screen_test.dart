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
    
    registerFallbackValue(Task(title: ''));
    registerFallbackValue(TimeBlock(startTime: DateTime.now(), endTime: DateTime.now()));
  });

  setUp(() {
    mockTaskService = MockTaskService();
    TaskService.instance = mockTaskService;

    when(() => mockTaskService.getTasks()).thenAnswer((_) async => []);
    when(() => mockTaskService.getTrackingState()).thenAnswer((_) async => null);
    when(() => mockTaskService.getSessionDates()).thenAnswer((_) async => <DateTime>{});
    when(() => mockTaskService.getWindowSize()).thenAnswer((_) async => null);
  });

  testWidgets('HomeScreen basic coverage test', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1200));
    
    // Provide some tasks to ensure the Library section is rendered and contains interactive elements
    final tasks = [
      Task(id: 1, title: 'Alpha'),
      Task(id: 2, title: 'Beta'),
    ];
    when(() => mockTaskService.getTasks()).thenAnswer((_) async => tasks);

    await tester.pumpWidget(const TickTockApp());
    await tester.pumpAndSettle();

    expect(find.text('TickTock'), findsOneWidget);
    expect(find.text('Alpha'), findsWidgets);
    expect(find.text('Beta'), findsWidgets);
  });

  testWidgets('HomeScreen tag filtering logic', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1200));
    
    final tasks = [
      Task(id: 1, title: 'WorkTask', tags: ['work']),
      Task(id: 2, title: 'HomeTask', tags: ['home']),
    ];
    when(() => mockTaskService.getTasks()).thenAnswer((_) async => tasks);

    await tester.pumpWidget(const TickTockApp());
    await tester.pumpAndSettle();

    // Verify both tasks are visible
    expect(find.text('WorkTask'), findsWidgets);
    expect(find.text('HomeTask'), findsWidgets);

    // Find and tap the #work tag chip in the filter bar
    final workChip = find.text('#work');
    expect(workChip, findsWidgets); // One in filter bar, one in TaskTile
    await tester.tap(workChip.first); // Tap the one in filter bar
    await tester.pumpAndSettle();

    // Verify only WorkTask is visible
    expect(find.text('WorkTask'), findsWidgets);
    expect(find.text('HomeTask'), findsNothing);

    // Tap #work again to clear filter
    await tester.tap(workChip.first);
    await tester.pumpAndSettle();

    // Verify both are visible again
    expect(find.text('WorkTask'), findsWidgets);
    expect(find.text('HomeTask'), findsWidgets);
  });

  testWidgets('HomeScreen toggle tracking shortcut logic', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1200));
    
    final tasks = [
      Task(id: 1, title: 'LastTask'),
    ];
    when(() => mockTaskService.getTasks()).thenAnswer((_) async => tasks);
    when(() => mockTaskService.getLastActiveTaskTitle()).thenAnswer((_) async => 'LastTask');
    when(() => mockTaskService.saveTrackingState(any(), any())).thenAnswer((_) async => {});

    await tester.pumpWidget(const TickTockApp());
    await tester.pumpAndSettle();

    // Trigger Cmd+S
    await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);
    await tester.pumpAndSettle();

    // Verify tracking started for 'LastTask'
    verify(() => mockTaskService.saveTrackingState('LastTask', any())).called(1);
  });
}
