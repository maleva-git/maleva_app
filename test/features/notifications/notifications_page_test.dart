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

    // quiet headings in normal case, a small grey count
    expect(find.text('Action needed'), findsOneWidget);
    expect(find.text('ACTION NEEDED'), findsNothing);
    expect(find.text('Vessel notices'), findsOneWidget);
    expect(
        find.descendant(of: find.byKey(const Key('action_needed_header')), matching: find.text('2')), findsOneWidget);
    final mineRow = find.byKey(const ValueKey('vessel_alert_7'));
    final teamRow = find.byKey(const ValueKey('vessel_alert_8'));
    // own alert first, both above the vessel notices
    expect(tester.getTopLeft(mineRow).dy, lessThan(tester.getTopLeft(teamRow).dy));
    expect(
        tester.getTopLeft(teamRow).dy, lessThan(tester.getTopLeft(find.byKey(const Key('vessel_notices_header'))).dy));
    expect(tester.getTopLeft(find.byKey(const Key('vessel_notices_header'))).dy,
        lessThan(tester.getTopLeft(find.byKey(const ValueKey('notice_11'))).dy));
    // the other notice is not on this tab
    expect(find.byKey(const ValueKey('notice_9')), findsNothing);
    // line 1: vessel and voyage, the sent time; line 2: plain details, the team member's name last
    expect(find.descendant(of: mineRow, matching: find.text('MAERSK RIO NEGRO 641S')), findsOneWidget);
    expect(find.descendant(of: mineRow, matching: find.text('09:29')), findsOneWidget);
    expect(find.descendant(of: mineRow, matching: find.text('PTP ETA 15 Oct 08:00 (est.) · 2 jobs not updated')),
        findsOneWidget);
    expect(
        find.descendant(of: teamRow, matching: find.text('PTP ETA 15 Oct 08:00 (est.) · 2 jobs not updated · SHALINI')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('team_chip_7')), findsNothing);
    expect(find.descendant(of: find.byKey(const ValueKey('team_chip_8')), matching: find.textContaining('SHALINI')),
        findsOneWidget);
    expect(find.byKey(const Key('no_vessel_alerts')), findsNothing);
    // calm: no filled buttons, no reminders / leader chips
    expect(find.byType(FilledButton), findsNothing);
    expect(find.text('Update jobs'), findsNothing);
    expect(find.textContaining('Reminded'), findsNothing);

    // the whole row opens the jobs
    await tester.tap(find.byKey(const ValueKey('update_jobs_7')));
    await tester.tap(find.byKey(const ValueKey('update_jobs_8')));
    expect(opened, [vesselChangesPath, vesselChangesTeamPath]);
  });

  testWidgets('alert rows: the only colour is a thin left border, red mine, amber team, blue LINK', (tester) async {
    when(() => vessels.alerts()).thenAnswer((_) async =>
        alertsOf([alertJson(id: 7), linkAlertJson(id: 21), alertJson(id: 8, mine: false, employeeName: 'RAJ')]));
    answerInbox(notices, NoticeGroup.vessel, () => inboxOf(const []));
    answerInbox(notices, NoticeGroup.other, () => inboxOf(const []));

    await show(tester, tab: NoticeGroup.vessel);

    BorderSide left(String key) {
      final box = tester.widget<DecoratedBox>(
          find.descendant(of: find.byKey(ValueKey(key)), matching: find.byType(DecoratedBox)).first);
      final decoration = box.decoration as BoxDecoration;
      expect(decoration.color, isNull, reason: 'no tinted card');
      expect(decoration.boxShadow, isNull, reason: 'no shadow');
      return (decoration.border! as Border).left;
    }

    expect(left('vessel_alert_7').color, NoticeColors.alert);
    expect(left('vessel_alert_8').color, NoticeColors.reminder);
    expect(left('link_alert_21').color, NoticeColors.vessel);
    expect(left('vessel_alert_7').width, inInclusiveRange(3, 4));
    // no 44 px icon box on a row
    expect(
        find.descendant(of: find.byKey(const ValueKey('vessel_alert_7')), matching: find.byType(Icon)), findsNothing);
  });

  testWidgets('an alert sent on another day shows its date; a team alert with an empty name shows no name',
      (tester) async {
    when(() => vessels.alerts()).thenAnswer((_) async => alertsOf([
          {...alertJson(id: 5, mine: false, employeeName: '  ', jobs: 1), 'sentAt': '2026-10-12T15:42'},
          {...alertJson(id: 6), 'arriveAt': null, 'arriveEstimated': false},
        ]));
    answerInbox(notices, NoticeGroup.vessel, () => inboxOf(const []));
    answerInbox(notices, NoticeGroup.other, () => inboxOf(const []));

    await show(tester, tab: NoticeGroup.vessel);

    expect(find.text('12 Oct 15:42'), findsOneWidget);
    expect(find.byKey(const ValueKey('team_chip_5')), findsNothing);
    expect(find.text('PTP ETA 15 Oct 08:00 (est.) · 1 job not updated'), findsOneWidget);
    expect(find.text('PTP ETA not given · 2 jobs not updated'), findsOneWidget);
  });

  testWidgets('more than 5 alerts: the first 5, then "Show all N" and "Show fewer"', (tester) async {
    when(() => vessels.alerts()).thenAnswer((_) async => alertsOf([for (var i = 1; i <= 7; i++) alertJson(id: i)]));
    answerInbox(notices, NoticeGroup.vessel, () => inboxOf(const []));
    answerInbox(notices, NoticeGroup.other, () => inboxOf(const []));

    await show(tester, tab: NoticeGroup.vessel);

    for (var i = 1; i <= 5; i++) {
      expect(find.byKey(ValueKey('vessel_alert_$i')), findsOneWidget);
    }
    expect(find.byKey(const ValueKey('vessel_alert_6')), findsNothing);
    expect(find.byKey(const ValueKey('vessel_alert_7')), findsNothing);
    expect(find.text('Show all 7'), findsOneWidget);

    await tester.tap(find.byKey(const Key('show_all_alerts')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('vessel_alert_7')), findsOneWidget);
    expect(find.text('Show fewer'), findsOneWidget);

    await tester.tap(find.byKey(const Key('show_all_alerts')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('vessel_alert_7')), findsNothing);
  });

  testWidgets('5 alerts or fewer: no "Show all"', (tester) async {
    when(() => vessels.alerts()).thenAnswer((_) async => alertsOf([for (var i = 1; i <= 5; i++) alertJson(id: i)]));
    answerInbox(notices, NoticeGroup.vessel, () => inboxOf(const []));
    answerInbox(notices, NoticeGroup.other, () => inboxOf(const []));

    await show(tester, tab: NoticeGroup.vessel);

    expect(find.byKey(const ValueKey('vessel_alert_5')), findsOneWidget);
    expect(find.byKey(const Key('show_all_alerts')), findsNothing);
  });

  testWidgets('Vessel tab without alerts: a muted all-clear line; the unread notices only, quiet rows', (tester) async {
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
              noticeJson(
                  id: 12,
                  kind: 'PTP_SCHEDULE_STALE',
                  title: 'PTP schedule not updating since 12 Oct 15:00',
                  createdDate: '2026-10-12 15:20:00'),
              noticeJson(id: 13, kind: 'PHONE_PUSH_DOWN', title: 'Phone alerts are not working', body: null),
            ]));
    answerInbox(notices, NoticeGroup.other, () => inboxOf(const []));

    await show(tester, tab: NoticeGroup.vessel);

    expect(find.byKey(const Key('no_vessel_alerts')), findsOneWidget);
    expect(find.text('No vessel alerts – all your jobs match PTP.'), findsOneWidget);
    // no Today / Earlier groups on the Vessel tab; the read notice waits behind "Show all"
    expect(find.byKey(const Key('vessel_today_header')), findsNothing);
    expect(find.byKey(const ValueKey('notice_11')), findsOneWidget);
    expect(find.byKey(const ValueKey('notice_10')), findsNothing);
    expect(find.text('3 unread'), findsOneWidget);

    // unread: medium title and a small blue dot; one line of body
    Text title(int id) => tester.widget<Text>(find.byKey(ValueKey('notice_title_$id')));
    expect(title(11).style!.fontWeight, FontWeight.w500);
    expect(find.byKey(const ValueKey('unread_dot_11')), findsOneWidget);
    expect(tester.widget<Text>(find.byKey(const ValueKey('notice_body_11'))).maxLines, 1);
    expect(find.byKey(const ValueKey('notice_body_13')), findsNothing);

    // small grey ships; red only for PTP schedule stale and phone alerts down; never red for "Not handled"
    Icon icon(int id) => tester.widget<Icon>(find.byKey(ValueKey('notice_icon_$id')));
    final grey = icon(11).color;
    expect(grey, isNot(NoticeColors.alert));
    expect(icon(11).size, lessThanOrEqualTo(16));
    expect(icon(12).color, NoticeColors.alert);
    expect(icon(13).color, NoticeColors.alert);
    expect(title(11).style!.color, isNot(NoticeColors.alert));
    expect(find.text('20 min ago'), findsOneWidget);
    expect(find.text('Yesterday 15:20'), findsOneWidget);

    await tester.tap(find.byKey(const Key('vessel_notices_toggle')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('notice_10')), findsOneWidget);
    // read: normal weight, no dot, the same grey ship
    expect(title(10).style!.fontWeight, FontWeight.w400);
    expect(find.byKey(const ValueKey('unread_dot_10')), findsNothing);
    expect(icon(10).color, grey);
    expect(find.text('Show unread only'), findsOneWidget);
  });

  testWidgets('vessel notices: at most 5 unread, "Show all" / "Show unread only", "Nothing unread."', (tester) async {
    var allRead = false;
    when(() => vessels.alerts()).thenAnswer((_) async => const []);
    answerInbox(
        notices,
        NoticeGroup.vessel,
        () => inboxOf([
              for (var i = 1; i <= 7; i++)
                noticeJson(id: 100 + i, title: 'Vessel $i: ETA moved', read: allRead || i == 7),
            ]));
    answerInbox(notices, NoticeGroup.other, () => inboxOf(const []));
    when(() => notices.markAllRead(group: NoticeGroup.vessel)).thenAnswer((_) async {
      allRead = true;
      return 6;
    });

    await show(tester, tab: NoticeGroup.vessel);

    for (var i = 1; i <= 5; i++) {
      expect(find.byKey(ValueKey('notice_${100 + i}')), findsOneWidget);
    }
    expect(find.byKey(const ValueKey('notice_106')), findsNothing); // the 6th unread
    expect(find.byKey(const ValueKey('notice_107')), findsNothing); // read
    expect(find.text('Show all'), findsOneWidget);

    await tester.tap(find.byKey(const Key('vessel_notices_toggle')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('notice_106')), findsOneWidget);
    expect(find.byKey(const ValueKey('notice_107')), findsOneWidget);
    await tester.tap(find.byKey(const Key('vessel_notices_toggle')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('notice_107')), findsNothing);

    await tester.tap(find.byKey(const Key('mark_all_read_vessel')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('vessel_nothing_unread')), findsOneWidget);
    expect(find.text('Nothing unread.'), findsOneWidget);
    expect(find.text('nothing unread'), findsOneWidget);
    expect(find.byKey(const ValueKey('notice_101')), findsNothing);
    expect(find.text('Show all'), findsOneWidget);
  });

  testWidgets('a "Not handled" notice is hidden while its team alert row shows; the counts stay the server\'s',
      (tester) async {
    when(() => vessels.alerts()).thenAnswer((_) async => alertsOf([alertJson(id: 8, mine: false)]));
    answerInbox(
        notices,
        NoticeGroup.vessel,
        () => inboxOf([
              noticeJson(id: 11, title: 'Not handled: MAERSK RIO NEGRO 641S'),
              noticeJson(id: 12, title: 'Still not handled: Maersk Rio Negro 641S'),
              noticeJson(id: 13, title: 'Not handled: MSC COLETTE III 641R'),
              noticeJson(id: 14, title: 'MAERSK RIO NEGRO 641S: ETA moved'),
            ]));
    answerInbox(notices, NoticeGroup.other, () => inboxOf(const []));

    await show(tester, tab: NoticeGroup.vessel);

    expect(find.byKey(const ValueKey('vessel_alert_8')), findsOneWidget);
    expect(find.byKey(const ValueKey('notice_11')), findsNothing);
    expect(find.byKey(const ValueKey('notice_12')), findsNothing);
    expect(find.byKey(const ValueKey('notice_13')), findsOneWidget); // another vessel
    expect(find.byKey(const ValueKey('notice_14')), findsOneWidget); // not an escalation
    expect(find.text('4 unread'), findsOneWidget);
    expect(badge('tab_vessel_badge', '1'), findsOneWidget);
  });

  testWidgets('my own alert does not hide a "Not handled" notice', (tester) async {
    when(() => vessels.alerts()).thenAnswer((_) async => alertsOf([alertJson(id: 7)]));
    answerInbox(
        notices, NoticeGroup.vessel, () => inboxOf([noticeJson(id: 11, title: 'Not handled: MAERSK RIO NEGRO 641S')]));
    answerInbox(notices, NoticeGroup.other, () => inboxOf(const []));

    await show(tester, tab: NoticeGroup.vessel);

    expect(find.byKey(const ValueKey('notice_11')), findsOneWidget);
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
    expect(find.byTooltip('Mark all vessel notices read'), findsOneWidget);
    await tester.tap(find.byKey(const Key('mark_all_read_vessel')));
    await tester.pumpAndSettle();

    verify(() => notices.markAllRead(group: NoticeGroup.vessel)).called(1);
    verifyNever(() => notices.markAllRead(group: NoticeGroup.other));
    expect(find.byKey(const ValueKey('unread_dot_11')), findsNothing);
    expect(find.byKey(const ValueKey('unread_dot_12')), findsNothing);
    expect(find.byKey(const Key('tab_vessel_badge')), findsNothing);
    expect(badge('tab_other_badge', '1'), findsOneWidget);
    // nothing left to mark on Vessel
    expect(find.byKey(const Key('mark_all_read_vessel')), findsNothing);

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
    expect(find.text('No vessel notices yet.'), findsOneWidget);
    expect(find.byKey(const Key('vessel_nothing_unread')), findsNothing);

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

  testWidgets('a LINK alert row: job, typed vessel and PTP\'s voyage; "Open job" opens the sale order screen',
      (tester) async {
    when(() => vessels.alerts()).thenAnswer((_) async => alertsOf([linkAlertJson(), alertJson()]));
    answerInbox(notices, NoticeGroup.vessel, () => inboxOf(const []));
    answerInbox(notices, NoticeGroup.other, () => inboxOf(const []));

    await show(tester, tab: NoticeGroup.vessel);

    final row = find.byKey(const ValueKey('link_alert_21'));
    expect(row, findsOneWidget);
    expect(find.descendant(of: row, matching: find.text('Pick PTP voyage · job MY002605357')), findsOneWidget);
    expect(find.descendant(of: row, matching: find.text('09:29')), findsOneWidget);
    expect(find.descendant(of: row, matching: find.text('Maersk Rio Negro → MAERSK RIO NEGRO 641S, ETA 15 Oct 08:00')),
        findsOneWidget);
    // small text actions, no filled button
    expect(find.descendant(of: row, matching: find.byType(TextButton)), findsNWidgets(2));
    expect(find.byType(FilledButton), findsNothing);
    expect(find.byType(OutlinedButton), findsNothing);
    // the ETA alert keeps its own row; the LINK one is not a tap target itself
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
    expect(find.text('Maersk Rio Negro · No PTP voyage suggested'), findsOneWidget);
  });

  testWidgets('an ETA alert of jobs without employee: a neutral "No employee" label, the row opens the job',
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
    // the name "No employee" is never repeated as a team name
    expect(find.byKey(const ValueKey('team_chip_9')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('update_jobs_9')));
    await tester.tap(find.byKey(const ValueKey('update_jobs_10')));
    // one job named: that job; several: Vessel changes
    expect(opened, [saleOrderEditRoute(51300), vesselChangesPath]);
  });

  testWidgets('LINK and PTP stale notices are listed on the Vessel tab only, PTP stale with a red ship',
      (tester) async {
    when(() => vessels.alerts()).thenAnswer((_) async => const []);
    final link = noticeJson(
        id: 31,
        kind: 'VESSEL_LINK_NEEDED',
        title: 'Pick the PTP voyage: job MY002605357',
        linkPath: '/sale-order/edit/51234',
        refType: 'SALE_ORDER',
        refId: 51234);
    final stale = noticeJson(
        id: 32,
        kind: 'PTP_SCHEDULE_STALE',
        title: 'PTP schedule not updating since 13 Oct 10:05',
        linkPath: '/ptp-schedule');
    answerInbox(notices, NoticeGroup.vessel, () => inboxOf([link, stale]));
    // a server answering them in the other group: never shown there
    answerInbox(notices, NoticeGroup.other, () => inboxOf([link, stale, leave()]));
    when(() => notices.markRead(any())).thenAnswer((i) async => EmployeeNotification.fromJava(link));

    await show(tester, tab: NoticeGroup.vessel);

    expect(tester.widget<Icon>(find.byKey(const ValueKey('notice_icon_31'))).color, isNot(NoticeColors.alert));
    expect(tester.widget<Icon>(find.byKey(const ValueKey('notice_icon_32'))).color, NoticeColors.alert);
    await tester.tap(find.byKey(const ValueKey('notice_31')));
    await tester.tap(find.byKey(const ValueKey('notice_32')));
    await tester.pumpAndSettle();
    expect(opened, [saleOrderEditRoute(51234), vesselChangesPath]);

    await openTab(tester, NoticeGroup.other);
    expect(find.byKey(const ValueKey('notice_9')), findsOneWidget);
    expect(find.byKey(const ValueKey('notice_31')), findsNothing);
    expect(find.byKey(const ValueKey('notice_32')), findsNothing);
  });

  testWidgets('a long team name on a narrow phone fits: no overflow, the title stays readable (owner screenshot)',
      (tester) async {
    const longName = 'HELEN MINOLTA ELIZABETH FERNANDEZ ANTHONYSAMY';
    when(() => vessels.alerts()).thenAnswer((_) async => alertsOf([
          alertJson(id: 8, mine: false, employeeName: longName, reminders: 7),
          {...linkAlertJson(id: 21, mine: false), 'employeeName': longName},
        ]));
    answerInbox(notices, NoticeGroup.vessel, () => inboxOf([]));
    answerInbox(notices, NoticeGroup.other, () => inboxOf([]));
    tester.view.physicalSize = const Size(1080, 3600);
    tester.view.devicePixelRatio = 3.0; // 360 wide, like the owner's phone
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: NotificationsPage(notices: notices, vessels: vessels, now: () => now, onOpen: (_, r) => opened.add(r)),
    ));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull, reason: 'no RenderFlex overflow');
    // the title gets the row's width: one line (the test font draws every letter as a wide block), not
    // one letter per line as on the owner's phone
    final title = tester.getSize(find.text('MAERSK RIO NEGRO 641S'));
    expect(title.width, greaterThan(150));
    expect(title.height, lessThan(30));
    // the name ends line 2, cut with "…" after two lines when too long
    expect(find.byKey(const ValueKey('team_chip_8')), findsOneWidget);
    expect(find.byKey(const ValueKey('team_chip_21')), findsOneWidget);
    final details = find.text('PTP ETA 15 Oct 08:00 (est.) · 2 jobs not updated · $longName');
    expect(details, findsOneWidget);
    expect(tester.widget<Text>(details).maxLines, 2);
    expect(tester.widget<Text>(details).overflow, TextOverflow.ellipsis);
    expect(find.text('Maersk Rio Negro → MAERSK RIO NEGRO 641S, ETA 15 Oct 08:00 · $longName'), findsOneWidget);
    // both rows lie inside the 360 px screen
    for (final key in ['vessel_alert_8', 'link_alert_21']) {
      expect(tester.getRect(find.byKey(ValueKey(key))).right, lessThanOrEqualTo(360));
    }
  });

  testWidgets('a narrow phone with a long vessel name, "No employee" and long notices: no overflow', (tester) async {
    when(() => vessels.alerts()).thenAnswer((_) async => alertsOf([
          {
            ...alertJson(id: 9, unassigned: true, employeeName: 'No employee', saleOrderId: 51300),
            'vesselName': 'MAERSK VERY LONG VESSEL NAME FOR A NARROW PHONE SCREEN',
            'sentAt': '2026-10-12T15:42',
          },
          {...linkAlertJson(id: 22, suggested: false), 'jobNo': 'MY002605978-LONG-JOB-NUMBER-REFERENCE'},
        ]));
    answerInbox(
        notices,
        NoticeGroup.vessel,
        () => inboxOf([
              noticeJson(
                  id: 11,
                  title: 'MAERSK VERY LONG VESSEL NAME FOR A NARROW PHONE SCREEN 641S: ETA moved again',
                  body: 'ETA moved from 17 Oct 05:00 to 17 Oct 11:00. 12 of your jobs are affected; please update.'),
            ], unread: 150));
    answerInbox(notices, NoticeGroup.other, () => inboxOf([]));
    tester.view.physicalSize = const Size(1080, 3600);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: NotificationsPage(notices: notices, vessels: vessels, now: () => now, initialTab: NoticeGroup.vessel),
    ));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull, reason: 'no RenderFlex overflow');
    expect(find.byKey(const ValueKey('no_employee_9')), findsOneWidget);
    expect(find.text('12 Oct 15:42'), findsOneWidget);
    expect(find.text('150 unread'), findsOneWidget);
  });
}
