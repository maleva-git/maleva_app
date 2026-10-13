import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/employee_notifications/employee_notifications_models.dart';
import 'package:maleva/features/notifications/notification_bell.dart';
import 'package:maleva/features/notifications/notification_look.dart';
import 'package:maleva/features/notifications/notification_routes.dart';
import 'package:maleva/features/notifications/notification_summary_cubit.dart';
import 'package:mocktail/mocktail.dart';

import '../../core/employee_notifications/employee_notifications_api_test.dart' show noticeJson;
import '../../core/vessel_changes/vessel_changes_api_test.dart' show alertJson;
import 'notifications_cubit_test.dart' show NoticesApi, VesselsApi, alertsOf, answerInbox, inboxOf;

/// The dashboard bell and ship (vessel-master-and-ptp-schedule, tasks 4.4, 4.5 and 4.10). The ship's badge
/// is calm (no animation), so the page settles.
void main() {
  late NoticesApi notices;
  late VesselsApi vessels;
  late StreamController<void> signals;
  NotificationSummaryCubit? summary;
  late List<String> opened;

  setUp(() {
    notices = NoticesApi();
    vessels = VesselsApi();
    signals = StreamController<void>.broadcast();
    summary = null;
    opened = [];
  });

  tearDown(() async {
    await summary?.close();
    await signals.close();
  });

  Future<void> show(WidgetTester tester, Widget child) async {
    // made inside the test so the signal's delivery runs in the test's fake time
    final cubit = summary = NotificationSummaryCubit(notices, vessels, signals: signals.stream);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            appBar: AppBar(actions: [
              NotificationBellButton(cubit: cubit, onOpen: (_, r) => opened.add(r)),
            ]),
            body: child)));
    await tester.pump();
    await tester.pump();
  }

  group('bell and ship', () {
    testWidgets('the bell counts only the other notices and opens the Other tab; the ship counts open alerts',
        (tester) async {
      answerInbox(notices, NoticeGroup.other, () => inboxOf([noticeJson(id: 9, kind: 'LEAVE_APPROVED')], unread: 3));
      answerInbox(notices, NoticeGroup.vessel, () => inboxOf([noticeJson()], unread: 4));
      when(() => vessels.alerts()).thenAnswer((_) async => alertsOf([alertJson(id: 7), alertJson(id: 9, mine: false)]));

      await show(tester, const SizedBox());

      expect(find.descendant(of: find.byKey(const Key('bell_unread_badge')), matching: find.text('3')), findsOneWidget);
      // the ship: a solid red badge with the open alerts (not the unread vessel notices)
      expect(find.byKey(const Key('vessel_notice_button')), findsOneWidget);
      expect(
          find.descendant(of: find.byKey(const Key('vessel_alert_badge')), matching: find.text('2')), findsOneWidget);
      expect(find.byKey(const Key('vessel_unread_badge')), findsNothing);
      // the vessel numbers never reach the bell
      expect(find.descendant(of: find.byKey(const Key('notification_bell')), matching: find.text('2')), findsNothing);
      expect(find.descendant(of: find.byKey(const Key('notification_bell')), matching: find.text('4')), findsNothing);
      verifyNever(() => notices.mine());

      await tester.tap(find.byKey(const Key('notification_bell')));
      await tester.tap(find.byKey(const Key('vessel_notice_button')));
      expect(opened, [notificationsOtherPath, notificationsVesselPath]);
    });

    testWidgets('no open alerts: the ship shows the unread vessel notices in amber', (tester) async {
      answerInbox(notices, NoticeGroup.other, () => inboxOf(const []));
      answerInbox(notices, NoticeGroup.vessel, () => inboxOf([noticeJson()], unread: 2));
      when(() => vessels.alerts()).thenAnswer((_) async => const []);

      await show(tester, const SizedBox());

      expect(find.byKey(const Key('bell_unread_badge')), findsNothing);
      expect(find.byKey(const Key('vessel_alert_badge')), findsNothing);
      final amber = find.byKey(const Key('vessel_unread_badge'));
      expect(find.descendant(of: amber, matching: find.text('2')), findsOneWidget);
      final box = tester.widget<Container>(find.descendant(of: amber, matching: find.byType(Container)).first);
      expect(box.decoration, isA<BoxDecoration>().having((d) => d.color, 'color', NoticeColors.reminder));
    });

    testWidgets('open alerts: a solid red badge, no pulsing, no glow; the page settles', (tester) async {
      answerInbox(notices, NoticeGroup.other, () => inboxOf(const []));
      answerInbox(notices, NoticeGroup.vessel, () => inboxOf([noticeJson()], unread: 5));
      when(() => vessels.alerts()).thenAnswer((_) async => alertsOf([alertJson(id: 7)]));

      await show(tester, const SizedBox());
      // nothing keeps animating: settling ends
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);

      final ship = find.byKey(const Key('vessel_notice_button'));
      expect(find.descendant(of: ship, matching: find.byType(ScaleTransition)), findsNothing);
      expect(find.descendant(of: ship, matching: find.byType(FadeTransition)), findsNothing);
      final red = find.byKey(const Key('vessel_alert_badge'));
      expect(find.descendant(of: red, matching: find.text('1')), findsOneWidget);
      final box = tester.widget<Container>(find.descendant(of: red, matching: find.byType(Container)).first).decoration
          as BoxDecoration;
      expect(box.color, NoticeColors.alert);
      expect(box.boxShadow, isNull);
      // the amber badge only when no alert is open
      expect(find.byKey(const Key('vessel_unread_badge')), findsNothing);
    });

    testWidgets('nothing waiting: a plain bell and no ship; 120 unread shows 99+', (tester) async {
      var unread = 0;
      answerInbox(notices, NoticeGroup.other, () => inboxOf(const [], unread: unread));
      answerInbox(notices, NoticeGroup.vessel, () => inboxOf(const []));
      when(() => vessels.alerts()).thenAnswer((_) async => const []);

      await show(tester, const SizedBox());
      expect(find.byKey(const Key('bell_unread_badge')), findsNothing);
      expect(find.byKey(const Key('vessel_notice_button')), findsNothing);
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);

      // a push arrives
      unread = 120;
      signals.add(null);
      await tester.pump();
      await tester.pump();
      expect(find.text('99+'), findsOneWidget);
    });
  });
}
