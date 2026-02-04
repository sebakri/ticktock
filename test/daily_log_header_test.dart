import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticktock/widgets/home/daily_log_header.dart';

void main() {
  testWidgets('DailyLogHeader renders and handles callbacks', (WidgetTester tester) async {
    final date = DateTime(2026, 2, 4);
    bool prevCalled = false;
    bool nextCalled = false;
    bool todayCalled = false;
    bool jumpCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DailyLogHeader(
            selectedDate: date,
            onPrevDay: () => prevCalled = true,
            onNextDay: () => nextCalled = true,
            onToday: () => todayCalled = true,
            onJumpToDate: () => jumpCalled = true,
          ),
        ),
      ),
    );

    expect(find.text('Wednesday'), findsOneWidget);
    expect(find.text('February 04, 2026'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    expect(prevCalled, true);

    await tester.tap(find.byIcon(Icons.chevron_right_rounded));
    expect(nextCalled, true);

    await tester.tap(find.text('Today'));
    expect(todayCalled, true);

    await tester.tap(find.text('Jump'));
    expect(jumpCalled, true);
  });
}
