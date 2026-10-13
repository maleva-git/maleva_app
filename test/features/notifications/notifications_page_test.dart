import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/employee_notifications/employee_notifications_models.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/features/notifications/notification_look.dart';
import 'package:maleva/features/notifications/notification_routes.dart';
import 'package:maleva/features/notifications/notifications_page.dart';
import 'package:maleva/features/vessel_changes/push_route.dart';
import 'package:mocktail/mocktail.dart';

import '../../core/employee_notifications/employee_notifications_api_test.dart' show noticeJson;
import '../../core/vessel_changes/vessel_changes_api_test.dart' show alertJson, linkAlertJson;
import 'notifications_cubit_test.dart' show NoticesApi, VesselsApi, alertsOf, answerInbox, inboxOf;

/// The notifications page in two separate tabs, Vessel and Other (vessel-master-and-ptp-schedule,
/// tasks 4.4 and 4.5).
void main() {
  late NoticesApi notices;
  late VesselsApi vessels;
  late List<String> opened;
  final now = DateTime(2026, 10, 13, 10, 0);

  setUp(() {
    notices = NoticesApi();
    vessels = VesselsApi();
    opened = [];
  });

  Map<String, dynamic> leave({int id = 9, bool read = false, String createdDate = '2026-10-13 08:00:00'}) => noticeJson(
      id: id,
      kind: 'LEAVE_APPROVED',
      title: 'Leave approved',
      linkPath: '/leave',
      read: read,
      createdDate: createdDate);

  Future<void> show(WidgetTester tester, {NoticeGroup? tab}) async {
    tester.view.physicalSize = const Size(1080, 3600);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: NotificationsPage(
        notices: notices,
        vessels: vessels,
        now: () => now,
        onOpen: (_, route) => opened.add(route),
        initialTab: tab,
      ),
    ));
    await tester.pumpAndSettle();
  }

  int tabIndex(WidgetTester tester) => tester.widget<TabBar>(find.byType(TabBar)).controller!.index;

  Future<void> openTab(WidgetTester tester, NoticeGroup g) async {
    await tester.tap(find.byKey(Key('tab_${g.wire}')));
    await tester.pumpAndSettle();
  }

  Finder badge(String key, String text) => find.descendant(of: find.byKey(Key(key)), matching: find.text(text));

  testWidgets('two tabs with their own counts: red open alerts on Vessel, red unread on Other', (tester) async {
    when(() => vessels.alerts()).thenAnswer((_) async => alertsOf([alertJson(id: 7), alertJson(id: 8, mine: false)]));
    answerInbox(notices, NoticeGroup.vessel, () => inboxOf([noticeJson()]));
    answerInbox(notices, NoticeGroup.other, () => inboxOf([leave(), leave(id: 10)]));

    await show(tester);

    expect(find.text('Vessel'), findsOneWidget);
    expect(find.text('Other'), findsOneWidget);
    expect(badge('tab_vessel_badge', '2'), findsOneWidget);
    expect(tester.widget<Container>(find.byKey(const Key('tab_vessel_badge'))).decoration,
        isA<BoxDecoration>().having((d) => d.color, 'color', NoticeColors.alert));
    expect(badge('tab_other_badge', '2'), findsOneWidget);
    // open alerts: the page opens on Vessel
    expect(tabIndex(tester), 0);
  });

  testWidgets('no open alerts: the Vessel badge is amber with the unread vessel notices', (tester) async {
    when(() => vessels.alerts()).thenAnswer((_) async => const []);
    answerInbox(
        notices, NoticeGroup.vessel, () => inboxOf([noticeJson(), noticeJson(id: 12), noticeJson(id: 13, read: true)]));
    answerInbox(notices, NoticeGroup.other, () => inboxOf(const []));

    await show(tester);

    expect(badge('tab_vessel_badge', '2'), findsOneWidget);
    expect(tester.widget<Container>(find.byKey(const Key('tab_vessel_badge'))).decoration,
        isA<BoxDecoration>().having((d) => d.color, 'color', NoticeColors.reminder));
    expect(find.byKey(const Key('tab_other_badge')), findsNothing);
    expect(tabIndex(tester), 0);
  });

  testWidgets('Vessel tab: alerts pinned on top, then only vessel notices; a team alert opens team scope',
      (tester) async {
    when(() => vessels.alerts()).thenAnswer((_) async => alertsOf(
        [alertJson(id: 8, mine: false, employeeName: 'SHALINI', reminders: 0), alertJson(id: 7, escalated: true)]));
    answerInbox(notices, NoticeGroup.vessel, () => inboxOf([noticeJson()]));
    answerInbox(notices, NoticeGroup.other, () => inboxOf([leave()]));

    await show(tester);

    expect(find.text('ACTION NEEDED'), findsOneWidget);
    expect(find.text('VESSEL NOTICES'), findsOneWidget);
    final mineCard = find.byKey(const ValueKey('vessel_alert_7'));
    final teamCard = find.byKey(const ValueKey('vessel_alert_8'));
    // own alert first, both above the vessel notices
    expect(tester.getTopLeft(mineCard).dy, lessThan(tester.getTopLeft(teamCard).dy));
    expect(
        tester.getTopLeft(teamCard).dy, lessThan(tester.getTopLeft(find.byKey(const Key('vessel_notices_header'))).dy));
    expect(tester.getTopLeft(find.byKey(const Key('vessel_notices_header'))).dy,
        lessThan(tester.getTopLeft(find.byKey(const ValueKey('notice_11'))).dy));
    // the other notice is not on this tab
    expect(find.byKey(const ValueKey('notice_9')), findsNothing);
    expect(find.descendant(of: mineCard, matching: find.text('MAERSK RIO NEGRO 641S')), findsOneWidget);
    expect(find.descendant(of: mineCard, matching: find.text('PTP ETA 15 Oct 08:00 est.')), findsOneWidget);
    expect(find.descendant(of: mineCard, matching: find.text('2 jobs not updated')), findsOneWidget);
    expect(find.descendant(of: mineCard, matching: find.text('since 09:29')), findsOneWidget);
    expect(find.descendant(of: mineCard, matching: find.text('Reminded 1×')), findsOneWidget);
    expect(find.descendant(of: mineCard, matching: find.text('Leader told')), findsOneWidget);
    expect(find.byKey(const ValueKey('team_chip_7')), findsNothing);
    expect(find.byKey(const ValueKey('team_chip_8')), findsOneWidget);
    expect(find.text('Team: SHALINI'), findsOneWidget);
    expect(find.byKey(const Key('no_vessel_alerts')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('update_jobs_7')));
    await tester.tap(find.byKey(const ValueKey('update_jobs_8')));
    expect(opened, [vesselChangesPath, vesselChangesTeamPath]);
  });

  testWidgets('Vessel tab without alerts: the green all-clear line; notices Today / Earlier, red and amber ships',
      (tester) async {
    when(() => vessels.alerts()).thenAnswer((_) async => const []);
    answerInbox(
        notices,
        NoticeGroup.vessel,
        () => inboxOf([
              noticeJson(id: 11, title: 'Not handled: MSC COLETTE III 641R', createdDate: '2026-10-13 09:40:00'),
              noticeJson(
                  id: 10,
                  title: 'Reminder: MSC COLETTE III 641R: ETA moved',
                  createdDate: '2026-10-13 07:00:00',
                  read: true),
              noticeJson(id: 12, createdDate: '2026-10-12 15:20:00', read: true),
            ]));
    answerInbox(notices, NoticeGroup.other, () => inboxOf(const []));

    await show(tester, tab: NoticeGroup.vessel);

    expect(find.byKey(const Key('no_vessel_alerts')), findsOneWidget);
    expect(find.text('No vessel alerts – all jobs match PTP'), findsOneWidget);
    final today = tester.getTopLeft(find.byKey(const Key('vessel_today_header'))).dy;
    final earlier = tester.getTopLeft(find.byKey(const Key('vessel_earlier_header'))).dy;
    expect(tester.getTopLeft(find.byKey(const ValueKey('notice_11'))).dy, inInclusiveRange(today, earlier));
    expect(tester.getTopLeft(find.byKey(const ValueKey('notice_10'))).dy, inInclusiveRange(today, earlier));
    expect(tester.getTopLeft(find.byKey(const ValueKey('notice_12'))).dy, greaterThan(earlier));

    // unread: bold and a dot; read: neither
    Text title(int id) => tester.widget<Text>(find.byKey(ValueKey('notice_title_$id')));
    expect(title(11).style!.fontWeight, FontWeight.w800);
    expect(title(10).style!.fontWeight, FontWeight.w500);
    expect(find.byKey(const ValueKey('unread_dot_11')), findsOneWidget);
    expect(find.byKey(const ValueKey('unread_dot_10')), findsNothing);

    // ships: red for "Not handled", amber for "Reminder", blue otherwise
    Icon icon(int id) => tester.widget<Icon>(find.byKey(ValueKey('notice_icon_$id')));
    for (final id in [11, 10, 12]) {
      expect(icon(id).icon, Icons.directions_boat_filled_rounded);
    }
    expect(icon(11).color, NoticeColors.alert);
    expect(icon(10).color, NoticeColors.reminder);
    expect(icon(12).color, NoticeColors.vessel);
    expect(find.text('20 min ago'), findsOneWidget);
    expect(find.text('Yesterday 15:20'), findsOneWidget);
  });

  testWidgets('Other tab: the other notices with their kind icons, never a vessel notice even if answered there',
      (tester) async {
    when(() => vessels.alerts()).thenAnswer((_) async => const []);
    answerInbox(notices, NoticeGroup.vessel, () => inboxOf(const []));
    answerInbox(
        notices,
        NoticeGroup.other,
        () => inboxOf([
              noticeJson(id: 11, title: 'MSC COLETTE III 641R: ETA moved'), // wrongly answered here
              noticeJson(
                  id: 9, kind: 'FORWARDING_APPROVED', title: 'Request approved', createdDate: '2026-10-12 15:20:00'),
              leave(id: 14),
            ]));

    await show(tester);

    // nothing waits on Vessel: the page opens on Other
    expect(tabIndex(tester), 1);
    expect(find.text('OTHER NOTICES'), findsOneWidget);
    expect(find.byKey(const ValueKey('notice_11')), findsNothing);
    expect(find.text('MSC COLETTE III 641R: ETA moved'), findsNothing);
    expect(find.byKey(const ValueKey('notice_9')), findsOneWidget);
    expect(find.byKey(const ValueKey('notice_14')), findsOneWidget);
    expect(find.byKey(const Key('action_needed_header')), findsNothing);
    expect(tester.widget<Icon>(find.byKey(const ValueKey('notice_icon_9'))).icon, Icons.description_outlined);
    expect(tester.widget<Icon>(find.byKey(const ValueKey('notice_icon_14'))).icon, Icons.notifications_none_rounded);
    final today = tester.getTopLeft(find.byKey(const Key('other_today_header'))).dy;
    expect(tester.getTopLeft(find.byKey(const ValueKey('notice_14'))).dy, greaterThan(today));
    expect(tester.getTopLeft(find.byKey(const ValueKey('notice_9'))).dy,
        greaterThan(tester.getTopLeft(find.byKey(const Key('other_earlier_header'))).dy));
    // the count leaves the vessel notice out
    expect(badge('tab_other_badge', '2'), findsOneWidget);
  });

  testWidgets('tapping a notice marks it read in its tab, then opens it by kind and link', (tester) async {
    final read = <int>{};
    when(() => vessels.alerts()).thenAnswer((_) async => const []);
    answerInbox(
        notices,
        NoticeGroup.vessel,
        () => inboxOf([
              noticeJson(
                  id: 11, title: 'Not handled: X', linkPath: '/vessel-changes?scope=team', read: read.contains(11)),
            ]));
    answerInbox(notices, NoticeGroup.other, () => inboxOf([leave(id: 12, read: read.contains(12))]));
    when(() => notices.markRead(any())).thenAnswer((i) async {
      final id = i.positionalArguments.first as int;
      read.add(id);
      return EmployeeNotification.fromJava(noticeJson(id: id, read: true));
    });

    await show(tester);
    await tester.tap(find.byKey(const ValueKey('notice_11')));
    await tester.pumpAndSettle();

    verify(() => notices.markRead(11)).called(1);
    expect(opened, [vesselChangesTeamPath]);
    expect(find.byKey(const ValueKey('unread_dot_11')), findsNothing);
    expect(find.byKey(const Key('tab_vessel_badge')), findsNothing);
    expect(badge('tab_other_badge', '1'), findsOneWidget);

    await openTab(tester, NoticeGroup.other);
    await tester.tap(find.byKey(const ValueKey('notice_12')));
    await tester.pumpAndSettle();
    verify(() => notices.markRead(12)).called(1);
    expect(opened, [vesselChangesTeamPath]); // nothing to open for this kind
    expect(find.byKey(const ValueKey('unread_dot_12')), findsNothing);
    expect(find.byKey(const Key('tab_other_badge')), findsNothing);
  });

  testWidgets('"Mark all vessel notices read" clears the Vessel tab only; the Other tab keeps its unread',
      (tester) async {
    var vesselRead = false;
    when(() => vessels.alerts()).thenAnswer((_) async => const []);
    answerInbox(notices, NoticeGroup.vessel,
        () => inboxOf([noticeJson(id: 11, read: vesselRead), noticeJson(id: 12, read: vesselRead)]));
    answerInbox(notices, NoticeGroup.other, () => inboxOf([leave()]));
    when(() => notices.markAllRead(group: NoticeGroup.vessel)).thenAnswer((_) async {
      vesselRead = true;
      return 2;
    });

    await show(tester);
    expect(find.byKey(const ValueKey('unread_dot_12')), findsOneWidget);
    expect(find.text('Mark all vessel notices read'), findsOneWidget);
    await tester.tap(find.byKey(const Key('mark_all_read_vessel')));
    await tester.pumpAndSettle();

    verify(() => notices.markAllRead(group: NoticeGroup.vessel)).called(1);
    verifyNever(() => notices.markAllRead(group: NoticeGroup.other));
    expect(find.byKey(const ValueKey('unread_dot_11')), findsNothing);
    expect(find.byKey(const ValueKey('unread_dot_12')), findsNothing);
    expect(find.byKey(const Key('tab_vessel_badge')), findsNothing);
    expect(badge('tab_other_badge', '1'), findsOneWidget);
    // nothing left to mark on Vessel
    expect(tester.widget<TextButton>(find.byKey(const Key('mark_all_read_vessel'))).onPressed, isNull);

    await openTab(tester, NoticeGroup.other);
    expect(find.byKey(const ValueKey('unread_dot_9')), findsOneWidget);
  });

  testWidgets('"Mark all read" on Other clears the Other tab only', (tester) async {
    var otherRead = false;
    when(() => vessels.alerts()).thenAnswer((_) async => const []);
    answerInbox(notices, NoticeGroup.vessel, () => inboxOf([noticeJson()]));
    answerInbox(notices, NoticeGroup.other, () => inboxOf([leave(read: otherRead), leave(id: 10, read: otherRead)]));
    when(() => notices.markAllRead(group: NoticeGroup.other)).thenAnswer((_) async {
      otherRead = true;
      return 2;
    });

    await show(tester, tab: NoticeGroup.other);
    await tester.tap(find.byKey(const Key('mark_all_read_other')));
    await tester.pumpAndSettle();

    verify(() => notices.markAllRead(group: NoticeGroup.other)).called(1);
    verifyNever(() => notices.markAllRead(group: NoticeGroup.vessel));
    expect(find.byKey(const ValueKey('unread_dot_9')), findsNothing);
    expect(find.byKey(const Key('tab_other_badge')), findsNothing);
    expect(badge('tab_vessel_badge', '1'), findsOneWidget);
  });

  testWidgets('each tab has its own empty state', (tester) async {
    when(() => vessels.alerts()).thenAnswer((_) async => const []);
    answerInbox(notices, NoticeGroup.vessel, () => inboxOf(const []));
    answerInbox(notices, NoticeGroup.other, () => inboxOf(const []));

    await show(tester, tab: NoticeGroup.vessel);
    expect(find.byKey(const Key('no_vessel_alerts')), findsOneWidget);
    expect(find.byKey(const Key('vessel_notices_empty')), findsOneWidget);
    expect(find.text('No vessel ETA notices yet.'), findsOneWidget);

    await openTab(tester, NoticeGroup.other);
    expect(find.byKey(const Key('other_notices_empty')), findsOneWidget);
    expect(find.text('No other notices yet.'), findsOneWidget);
  });

  testWidgets('a failing tab shows its own error with a retry; the other tab still shows', (tester) async {
    var calls = 0;
    when(() => vessels.alerts()).thenAnswer((_) async => const []);
    answerInbox(notices, NoticeGroup.vessel, () => inboxOf([noticeJson()]));
    when(() => notices.mine(group: NoticeGroup.other)).thenAnswer((_) async {
      if (calls++ == 0) throw const ApiFailure('No internet connection. Check your network.');
      return inboxOf([leave()]);
    });

    await show(tester, tab: NoticeGroup.vessel);
    expect(find.byKey(const ValueKey('notice_11')), findsOneWidget);
    expect(find.byKey(const Key('vessel_tab_error')), findsNothing);

    await openTab(tester, NoticeGroup.other);
    expect(find.byKey(const Key('other_tab_error')), findsOneWidget);
    expect(find.text('No internet connection. Check your network.'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('other_tab_error')), findsNothing);
    expect(find.byKey(const ValueKey('notice_9')), findsOneWidget);
  });

  testWidgets('the Vessel tab with nothing loaded shows its error; a failed alerts check is never "no alerts"',
      (tester) async {
    when(() => vessels.alerts()).thenThrow(const ApiFailure('Server error occurred. (500)'));
    when(() => notices.mine(group: NoticeGroup.vessel)).thenThrow(const ApiFailure('Server error occurred. (500)'));
    answerInbox(notices, NoticeGroup.other, () => inboxOf([leave()]));

    await show(tester);

    // the alerts could not be checked: the page opens on Vessel to say so
    expect(tabIndex(tester), 0);
    expect(find.byKey(const Key('vessel_tab_error')), findsOneWidget);
    expect(find.byKey(const Key('no_vessel_alerts')), findsNothing);
  });

  testWidgets('the tab asked for wins over the automatic choice', (tester) async {
    when(() => vessels.alerts()).thenAnswer((_) async => alertsOf([alertJson(id: 7)]));
    answerInbox(notices, NoticeGroup.vessel, () => inboxOf(const []));
    answerInbox(notices, NoticeGroup.other, () => inboxOf([leave()]));

    await show(tester, tab: NoticeGroup.other);

    expect(tabIndex(tester), 1);
    expect(find.byKey(const ValueKey('notice_9')), findsOneWidget);
    expect(find.byKey(const ValueKey('vessel_alert_7')), findsNothing);
  });

  testWidgets('asked for Vessel with nothing there still opens on Vessel', (tester) async {
    when(() => vessels.alerts()).thenAnswer((_) async => const []);
    answerInbox(notices, NoticeGroup.vessel, () => inboxOf(const []));
    answerInbox(notices, NoticeGroup.other, () => inboxOf([leave()]));

    await show(tester, tab: NoticeGroup.vessel);

    expect(tabIndex(tester), 0);
    expect(find.byKey(const Key('no_vessel_alerts')), findsOneWidget);
  });

  testWidgets('fits a narrow phone: both tab badges and the vessel "Mark all" wrap without overflow', (tester) async {
    when(() => vessels.alerts()).thenAnswer((_) async => alertsOf([for (var i = 1; i <= 120; i++) alertJson(id: i)]));
    answerInbox(notices, NoticeGroup.vessel, () => inboxOf([noticeJson()], unread: 150));
    answerInbox(notices, NoticeGroup.other, () => inboxOf([leave()], unread: 150));
    tester.view.physicalSize = const Size(320 * 3, 640 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      home: NotificationsPage(notices: notices, vessels: vessels, now: () => now, initialTab: NoticeGroup.vessel),
    ));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(badge('tab_vessel_badge', '99+'), findsOneWidget);
    expect(badge('tab_other_badge', '99+'), findsOneWidget);
  });

  test('the route\'s tab query: ?tab=vessel and ?tab=other, anything else picks automatically', () {
    NoticeGroup? tabOf(String route) => NoticeGroup.fromWire(Uri.parse(route).queryParameters['tab']);
    expect(tabOf(notificationsVesselPath), NoticeGroup.vessel);
    expect(tabOf(notificationsOtherPath), NoticeGroup.other);
    expect(tabOf(notificationsPath), isNull);
    expect(tabOf('$notificationsPath?tab=mail'), isNull);
  });

  testWidgets('a LINK alert card: job, typed vessel and PTP\'s voyage; "Open job" opens the sale order screen',
      (tester) async {
    when(() => vessels.alerts()).thenAnswer((_) async => alertsOf([linkAlertJson(), alertJson()]));
    answerInbox(notices, NoticeGroup.vessel, () => inboxOf(const []));
    answerInbox(notices, NoticeGroup.other, () => inboxOf(const []));

    await show(tester, tab: NoticeGroup.vessel);

    final card = find.byKey(const ValueKey('link_alert_21'));
    expect(card, findsOneWidget);
    expect(find.descendant(of: card, matching: find.text('Pick the PTP voyage: job MY002605357')), findsOneWidget);
    expect(find.descendant(of: card, matching: find.text('Maersk Rio Negro')), findsOneWidget);
    expect(find.descendant(of: card, matching: find.text('PTP: MAERSK RIO NEGRO 641S · arrives 15 Oct 08:00')),
        findsOneWidget);
    // the ETA alert keeps its own card; the LINK one has no "Update jobs"
    expect(find.byKey(const ValueKey('vessel_alert_7')), findsOneWidget);
    expect(find.byKey(const ValueKey('update_jobs_21')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('open_job_21')));
    expect(opened, [saleOrderEditRoute(51234)]);
  });

  testWidgets('"Not this vessel" closes the LINK alert and the card goes', (tester) async {
    // the server leaves a closed alert out of the next fetch (the page reloads on the bell's signal)
    var closed = false;
    when(() => vessels.alerts()).thenAnswer((_) async => closed ? const [] : alertsOf([linkAlertJson()]));
    when(() => vessels.closeAlert(21)).thenAnswer((_) async => closed = true);
    answerInbox(notices, NoticeGroup.vessel, () => inboxOf(const []));
    answerInbox(notices, NoticeGroup.other, () => inboxOf(const []));
    await show(tester, tab: NoticeGroup.vessel);

    await tester.tap(find.byKey(const ValueKey('close_alert_21')));
    await tester.pumpAndSettle();

    verify(() => vessels.closeAlert(21)).called(1);
    expect(find.byKey(const ValueKey('link_alert_21')), findsNothing);
    expect(find.byKey(const Key('no_vessel_alerts')), findsOneWidget);
  });

  testWidgets('"Not this vessel" refused: a snackbar with the server message, the card stays', (tester) async {
    when(() => vessels.alerts()).thenAnswer((_) async => alertsOf([linkAlertJson()]));
    when(() => vessels.closeAlert(21)).thenThrow(const ApiFailure('Not your alert', statusCode: 403));
    answerInbox(notices, NoticeGroup.vessel, () => inboxOf(const []));
    answerInbox(notices, NoticeGroup.other, () => inboxOf(const []));
    await show(tester, tab: NoticeGroup.vessel);

    await tester.tap(find.byKey(const ValueKey('close_alert_21')));
    await tester.pumpAndSettle();

    expect(find.text('Could not close the alert: Not your alert'), findsOneWidget);
    expect(find.byKey(const ValueKey('link_alert_21')), findsOneWidget);
  });

  testWidgets('a LINK alert without a job or a suggested voyage: no "Open job", "No PTP voyage suggested"',
      (tester) async {
    when(() => vessels.alerts())
        .thenAnswer((_) async => alertsOf([linkAlertJson(id: 22, suggested: false, saleOrderId: null)]));
    answerInbox(notices, NoticeGroup.vessel, () => inboxOf(const []));
    answerInbox(notices, NoticeGroup.other, () => inboxOf(const []));

    await show(tester, tab: NoticeGroup.vessel);

    expect(find.byKey(const ValueKey('open_job_22')), findsNothing);
    expect(find.byKey(const ValueKey('close_alert_22')), findsOneWidget);
    expect(find.text('No PTP voyage suggested'), findsOneWidget);
  });

  testWidgets('an ETA alert of jobs without employee: a "No employee" badge, "Update jobs" opens the job',
      (tester) async {
    when(() => vessels.alerts()).thenAnswer((_) async => alertsOf([
          alertJson(id: 9, unassigned: true, employeeName: 'No employee', saleOrderId: 51300, jobNo: 'MY002605400'),
          alertJson(id: 10, unassigned: true, employeeName: 'No employee'),
        ]));
    answerInbox(notices, NoticeGroup.vessel, () => inboxOf(const []));
    answerInbox(notices, NoticeGroup.other, () => inboxOf(const []));

    await show(tester, tab: NoticeGroup.vessel);

    expect(find.byKey(const ValueKey('no_employee_9')), findsOneWidget);
    expect(find.byKey(const ValueKey('no_employee_10')), findsOneWidget);
    expect(find.text('No employee'), findsNWidgets(2));
    await tester.tap(find.byKey(const ValueKey('update_jobs_9')));
    await tester.tap(find.byKey(const ValueKey('update_jobs_10')));
    // one job named: that job; several: Vessel changes
    expect(opened, [saleOrderEditRoute(51300), vesselChangesPath]);
  });

  testWidgets('LINK and PTP stale notices are listed on the Vessel tab only, with their own icons', (tester) async {
    when(() => vessels.alerts()).thenAnswer((_) async => const []);
    final link = noticeJson(
        id: 31,
        kind: 'VESSEL_LINK_NEEDED',
        title: 'Pick the PTP voyage: job MY002605357',
        linkPath: '/sale-order/edit/51234',
        refType: 'SALE_ORDER',
        refId: 51234);
    final stale = noticeJson(
        id: 32, kind: 'PTP_SCHEDULE_STALE', title: 'PTP schedule not updating since 13 Oct 10:05', linkPath: '/ptp-schedule');
    answerInbox(notices, NoticeGroup.vessel, () => inboxOf([link, stale]));
    // a server answering them in the other group: never shown there
    answerInbox(notices, NoticeGroup.other, () => inboxOf([link, stale, leave()]));
    when(() => notices.markRead(any())).thenAnswer((i) async => EmployeeNotification.fromJava(link));

    await show(tester, tab: NoticeGroup.vessel);

    expect(tester.widget<Icon>(find.byKey(const ValueKey('notice_icon_31'))).icon, Icons.link_rounded);
    expect(tester.widget<Icon>(find.byKey(const ValueKey('notice_icon_32'))).icon, Icons.sync_problem_rounded);
    await tester.tap(find.byKey(const ValueKey('notice_31')));
    await tester.tap(find.byKey(const ValueKey('notice_32')));
    await tester.pumpAndSettle();
    expect(opened, [saleOrderEditRoute(51234), vesselChangesPath]);

    await openTab(tester, NoticeGroup.other);
    expect(find.byKey(const ValueKey('notice_9')), findsOneWidget);
    expect(find.byKey(const ValueKey('notice_31')), findsNothing);
    expect(find.byKey(const ValueKey('notice_32')), findsNothing);
  });
}
