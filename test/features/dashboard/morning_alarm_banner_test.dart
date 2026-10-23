import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:maleva/core/rti/rti_api.dart';
import 'package:maleva/features/dashboard/forwarding_agent_dashboard/view/morning_alarm_banner.dart';

class _MockRtiApi extends Mock implements RtiApi {}

/// rti-morning-briefing follow-up: the "Got it" card on RTI Activities.
void main() {
  late _MockRtiApi api;
  setUp(() => api = _MockRtiApi());

  Widget host() => MaterialApp(home: Scaffold(body: MorningAlarmBanner(api: api)));

  testWidgets('no alarm today: nothing shown', (tester) async {
    when(() => api.morningAlarmToday()).thenAnswer((_) async => {'sent': false, 'stopCount': 0});
    await tester.pumpWidget(host());
    await tester.pump();
    expect(find.text('Got it'), findsNothing);
  });

  testWidgets('alarm not answered: tapping Got it saves and shows the time', (tester) async {
    when(() => api.morningAlarmToday()).thenAnswer((_) async => {'sent': true, 'stopCount': 4, 'ackAt': null});
    when(() => api.morningAlarmGotIt())
        .thenAnswer((_) async => {'sent': true, 'stopCount': 4, 'ackAt': '2026-10-24T06:04:00'});
    await tester.pumpWidget(host());
    await tester.pump();
    expect(find.textContaining('Today: 4 stops'), findsOneWidget);

    await tester.tap(find.byKey(const Key('morning-alarm-got-it')));
    await tester.pump();
    await tester.pump();
    verify(() => api.morningAlarmGotIt()).called(1);
    expect(find.text("Today's trucks seen at 06:04"), findsOneWidget);
    expect(find.text('Got it'), findsNothing);
  });

  testWidgets('a failed read shows nothing', (tester) async {
    when(() => api.morningAlarmToday()).thenThrow(Exception('offline'));
    await tester.pumpWidget(host());
    await tester.pump();
    expect(find.byType(FilledButton), findsNothing);
  });
}
