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
  List<MethodCall> hotkeyCalls = [];

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    const MethodChannel('window_manager').setMockMethodCallHandler((MethodCall methodCall) async {
      return null;
    });
  });

  setUp(() {
    mockTaskService = MockTaskService();
    TaskService.instance = mockTaskService;
    hotkeyCalls.clear();

    // Re-setup hotkey mock for each test to ensure it captures calls
    const MethodChannel('dev.leanflutter.plugins/hotkey_manager').setMockMethodCallHandler((MethodCall methodCall) async {
      hotkeyCalls.add(methodCall);
      return null;
    });

    when(() => mockTaskService.getTasks()).thenAnswer((_) async => []);
    when(() => mockTaskService.getTrackingState()).thenAnswer((_) async => null);
    when(() => mockTaskService.getSessionDates()).thenAnswer((_) async => <DateTime>{});
    when(() => mockTaskService.getWindowSize()).thenAnswer((_) async => null);
    when(() => mockTaskService.getSelectedTags()).thenAnswer((_) async => <String>{});
    when(() => mockTaskService.saveSelectedTags(any())).thenAnswer((_) async => {});
    when(() => mockTaskService.getSetting(any())).thenAnswer((_) async => null);
  });

  testWidgets('HomeScreen basic coverage test', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1200));
    
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

    expect(find.text('WorkTask'), findsWidgets);
    expect(find.text('HomeTask'), findsWidgets);

    final workChip = find.text('#work');
    await tester.tap(workChip.first);
    await tester.pumpAndSettle();

    expect(find.text('WorkTask'), findsWidgets);
    expect(find.text('HomeTask'), findsNothing);

    await tester.tap(workChip.first);
    await tester.pumpAndSettle();

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

    await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);
    await tester.pumpAndSettle();

    verify(() => mockTaskService.saveTrackingState('LastTask', any())).called(1);
  });

  testWidgets('HomeScreen registers global hotkey on init', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const TickTockApp());
      await tester.pumpAndSettle();
      
      // Allow async registration to complete
      await Future.delayed(const Duration(milliseconds: 500));
    });

    final methodsCalled = hotkeyCalls.map((c) => c.method).toList();
    expect(methodsCalled, contains('unregisterAll'));
    expect(methodsCalled, contains('register'));
    
    final regCall = hotkeyCalls.firstWhere((call) => call.method == 'register');
    final hotkeyMap = regCall.arguments as Map;
    
    expect(hotkeyMap.containsKey('keyCode'), isTrue);
    expect(hotkeyMap['keyCode'], isNotNull);
    final modifiers = hotkeyMap['modifiers'] as List?;
    expect(modifiers, contains('alt'));
  });
}
