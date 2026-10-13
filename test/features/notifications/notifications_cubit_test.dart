import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/employee_notifications/employee_notifications_api.dart';
import 'package:maleva/core/employee_notifications/employee_notifications_models.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/vessel_changes/vessel_changes_api.dart';
import 'package:maleva/core/vessel_changes/vessel_changes_models.dart';
import 'package:maleva/features/forwarding_requests/view/forwarding_requests_page.dart';
import 'package:maleva/features/notifications/notification_routes.dart';
import 'package:maleva/features/notifications/notification_signals.dart';
import 'package:maleva/features/notifications/notification_summary_cubit.dart';
import 'package:maleva/features/notifications/notifications_cubit.dart';
import 'package:maleva/features/vessel_changes/push_route.dart';
import 'package:mocktail/mocktail.dart';

import '../../core/employee_notifications/employee_notifications_api_test.dart' show noticeJson;
import '../../core/vessel_changes/vessel_changes_api_test.dart' show alertJson, linkAlertJson;

class NoticesApi extends Mock implements EmployeeNotificationsApi {}

class VesselsApi extends Mock implements VesselChangesApi {}

NotificationInbox inboxOf(List<Map<String, dynamic>> items, {int? unread}) => NotificationInbox(
    unreadCount: unread ?? items.where((i) => i['read'] != true).length,
    items: items.map(EmployeeNotification.fromJava).toList());

/// Answers `mine(group: group)` with [inbox] on every call.
void answerInbox(NoticesApi notices, NoticeGroup group, NotificationInbox Function() inbox) =>
    when(() => notices.mine(group: group)).thenAnswer((_) async => inbox());

List<VesselAlert> alertsOf(List<Map<String, dynamic>> rows) => rows.map(VesselAlert.fromJava).toList();

/// The notifications page's cubit and the bell's summary (vessel-master-and-ptp-schedule, tasks 4.4, 4.5).
void main() {
  late NoticesApi notices;
  late VesselsApi vessels;
  late StreamController<void> signals;

  setUp(() {
    notices = NoticesApi();
    vessels = VesselsApi();
    signals = StreamController<void>.broadcast();
  });

  tearDown(() => signals.close());

  NotificationsCubit cubit() => NotificationsCubit(notices, vessels, signals: signals.stream);

  group('NotificationsCubit', () {
    test('loads the vessel notices, the other notices and the alerts at once; own alerts pinned first', () async {
      final gate = Completer<NotificationInbox>();
      when(() => notices.mine(group: NoticeGroup.vessel)).thenAnswer((_) => gate.future);
      answerInbox(notices, NoticeGroup.other, () => inboxOf([noticeJson(id: 9, kind: 'FORWARDING_APPROVED')]));
      when(() => vessels.alerts()).thenAnswer((_) async => alertsOf(
          [alertJson(id: 8, mine: false, employeeName: 'RAJ'), alertJson(id: 7), alertJson(id: 9, mine: false)]));
      final c = cubit();

      final loading = c.load();
      // all three requests are out before any answers
      verify(() => notices.mine(group: NoticeGroup.vessel)).called(1);
      verify(() => notices.mine(group: NoticeGroup.other)).called(1);
      verify(() => vessels.alerts()).called(1);
      verifyNever(() => notices.mine());
      gate.complete(inboxOf([noticeJson(), noticeJson(id: 12, read: true)]));
      await loading;

      expect(c.state.loading, isFalse);
      expect([for (final a in c.state.alerts!) a.id], [7, 8, 9]);
      expect(c.state.vesselCount, 3);
      expect(c.state.vesselUnread, 1);
      expect(c.state.vesselInbox!.items.map((n) => n.id), [11, 12]);
      expect(c.state.otherUnread, 1);
      expect(c.state.otherInbox!.items.single.id, 9);
      await c.close();
    });

    test('a vessel notice answered in the other inbox is kept out of it', () async {
      answerInbox(notices, NoticeGroup.vessel, () => inboxOf(const []));
      answerInbox(notices, NoticeGroup.other,
          () => inboxOf([noticeJson(id: 11), noticeJson(id: 9, kind: 'LEAVE_APPROVED')], unread: 2));
      when(() => vessels.alerts()).thenAnswer((_) async => const []);
      final c = cubit();

      await c.load();

      expect(c.state.otherInbox!.items.single.id, 9);
      expect(c.state.otherUnread, 1);
      await c.close();
    });

    test('a failed alerts check is shown as an error, not as "no alerts"; the notices still show', () async {
      answerInbox(notices, NoticeGroup.vessel, () => inboxOf([noticeJson()]));
      answerInbox(notices, NoticeGroup.other, () => inboxOf(const []));
      when(() => vessels.alerts()).thenThrow(const ApiFailure('Server error occurred. (500)'));
      final c = cubit();

      await c.load();

      expect(c.state.alerts, isNull);
      expect(c.state.alertsError, contains('500'));
      expect(c.state.vesselInbox!.items, hasLength(1));
      expect(c.state.vesselFailed, isFalse);
      expect(c.state.otherFailed, isFalse);
      await c.close();
    });

    test('each tab keeps its own failure: other failing does not touch the vessel tab, and back', () async {
      answerInbox(notices, NoticeGroup.vessel, () => inboxOf([noticeJson()]));
      when(() => notices.mine(group: NoticeGroup.other))
          .thenThrow(const ApiFailure('No internet connection. Check your network.'));
      when(() => vessels.alerts()).thenAnswer((_) async => const []);
      final c = cubit();

      await c.load();

      expect(c.state.otherFailed, isTrue);
      expect(c.state.otherError, contains('No internet'));
      expect(c.state.vesselFailed, isFalse);
      expect(c.state.vesselError, isNull);
      expect(c.state.vesselInbox!.items, hasLength(1));
      await c.close();

      when(() => notices.mine(group: NoticeGroup.vessel)).thenThrow(const ApiFailure('Server error occurred. (500)'));
      when(() => vessels.alerts()).thenThrow(const ApiFailure('Server error occurred. (500)'));
      answerInbox(notices, NoticeGroup.other, () => inboxOf([noticeJson(id: 9, kind: 'LEAVE_APPROVED')]));
      final d = cubit();

      await d.load();

      expect(d.state.vesselFailed, isTrue);
      expect(d.state.otherFailed, isFalse);
      expect(d.state.otherInbox!.items.single.id, 9);
      await d.close();
    });

    test('markRead marks the notice in the inbox that holds it and lowers that count only', () async {
      answerInbox(notices, NoticeGroup.vessel,
          () => inboxOf([noticeJson(), noticeJson(id: 12, title: 'Reminder: X')], unread: 2));
      answerInbox(notices, NoticeGroup.other, () => inboxOf([noticeJson(id: 9, kind: 'LEAVE_APPROVED')]));
      when(() => vessels.alerts()).thenAnswer((_) async => const []);
      when(() => notices.markRead(any())).thenAnswer(
          (i) async => EmployeeNotification.fromJava(noticeJson(id: i.positionalArguments.first as int, read: true)));
      final c = cubit();
      await c.load();

      await c.markRead(c.state.vesselInbox!.items.first);
      verify(() => notices.markRead(11)).called(1);
      expect(c.state.vesselInbox!.items.first.read, isTrue);
      expect(c.state.vesselInbox!.items.last.read, isFalse);
      expect(c.state.vesselUnread, 1);
      expect(c.state.otherUnread, 1);

      await c.markRead(c.state.otherInbox!.items.single);
      verify(() => notices.markRead(9)).called(1);
      expect(c.state.otherInbox!.items.single.read, isTrue);
      expect(c.state.otherUnread, 0);
      expect(c.state.vesselUnread, 1);
      await c.close();
    });

    test('a refused markRead puts the notice back unread', () async {
      answerInbox(notices, NoticeGroup.vessel, () => inboxOf(const []));
      answerInbox(notices, NoticeGroup.other, () => inboxOf([noticeJson(id: 9, kind: 'LEAVE_APPROVED')]));
      when(() => vessels.alerts()).thenAnswer((_) async => const []);
      when(() => notices.markRead(9)).thenThrow(const ApiFailure('Notification not found'));
      final c = cubit();
      await c.load();

      await c.markRead(c.state.otherInbox!.items.first);

      expect(c.state.otherInbox!.items.first.read, isFalse);
      expect(c.state.otherUnread, 1);
      await c.close();
    });

    test('markAllRead(vessel) marks only the vessel notices; the other tab is untouched', () async {
      answerInbox(notices, NoticeGroup.vessel, () => inboxOf([noticeJson(), noticeJson(id: 12)]));
      answerInbox(notices, NoticeGroup.other, () => inboxOf([noticeJson(id: 9, kind: 'LEAVE_APPROVED')]));
      when(() => vessels.alerts()).thenAnswer((_) async => const []);
      when(() => notices.markAllRead(group: NoticeGroup.vessel)).thenAnswer((_) async => 2);
      final c = cubit();
      await c.load();

      await c.markAllRead(NoticeGroup.vessel);

      verify(() => notices.markAllRead(group: NoticeGroup.vessel)).called(1);
      verifyNever(() => notices.markAllRead(group: NoticeGroup.other));
      verifyNever(() => notices.markAllRead());
      expect(c.state.vesselInbox!.items.every((i) => i.read), isTrue);
      expect(c.state.vesselUnread, 0);
      expect(c.state.otherInbox!.items.single.read, isFalse);
      expect(c.state.otherUnread, 1);
      expect(c.state.busy, isEmpty);
      await c.close();
    });

    test('markAllRead(other) marks only the other notices', () async {
      answerInbox(notices, NoticeGroup.vessel, () => inboxOf([noticeJson()]));
      answerInbox(notices, NoticeGroup.other, () => inboxOf([noticeJson(id: 9, kind: 'LEAVE_APPROVED')]));
      when(() => vessels.alerts()).thenAnswer((_) async => const []);
      when(() => notices.markAllRead(group: NoticeGroup.other)).thenAnswer((_) async => 1);
      final c = cubit();
      await c.load();

      await c.markAllRead(NoticeGroup.other);

      verify(() => notices.markAllRead(group: NoticeGroup.other)).called(1);
      verifyNever(() => notices.markAllRead(group: NoticeGroup.vessel));
      expect(c.state.otherUnread, 0);
      expect(c.state.vesselUnread, 1);
      expect(c.state.vesselInbox!.items.single.read, isFalse);
      await c.close();
    });

    test('a refused markAllRead puts that tab back and says why there; nothing to mark sends nothing', () async {
      answerInbox(notices, NoticeGroup.vessel, () => inboxOf(const []));
      answerInbox(notices, NoticeGroup.other, () => inboxOf([noticeJson(id: 9, kind: 'LEAVE_APPROVED')]));
      when(() => vessels.alerts()).thenAnswer((_) async => const []);
      when(() => notices.markAllRead(group: NoticeGroup.other))
          .thenThrow(const ApiFailure('Server error occurred. (500)'));
      final c = cubit();
      await c.load();

      await c.markAllRead(NoticeGroup.other);
      expect(c.state.otherInbox!.items.single.read, isFalse);
      expect(c.state.otherUnread, 1);
      expect(c.state.otherError, contains('500'));
      expect(c.state.vesselError, isNull);
      expect(c.state.busy, isEmpty);

      await c.markAllRead(NoticeGroup.vessel);
      verifyNever(() => notices.markAllRead(group: NoticeGroup.vessel));
      await c.close();
    });

    test('a push (signal) reloads the page, and a handled alert is gone', () async {
      var calls = 0;
      answerInbox(notices, NoticeGroup.vessel, () => inboxOf(const []));
      answerInbox(notices, NoticeGroup.other, () => inboxOf(const []));
      when(() => vessels.alerts()).thenAnswer((_) async => calls++ == 0 ? alertsOf([alertJson()]) : const []);
      final c = cubit();
      await c.load();
      expect(c.state.alerts, hasLength(1));

      signals.add(null);
      await pumpEventQueue();

      expect(c.state.alerts, isEmpty);
      await c.close();
    });
  });

  group('NotificationSummaryCubit (bell, ship and banner)', () {
    test('reads the other and vessel unread counts apart and the alerts; keeps them when a reload fails; clears',
        () async {
      var calls = 0;
      when(() => notices.mine(group: NoticeGroup.other)).thenAnswer((_) async {
        if (calls++ > 0) throw const ApiFailure('offline');
        return inboxOf([noticeJson(id: 9, kind: 'LEAVE_APPROVED')], unread: 3);
      });
      answerInbox(notices, NoticeGroup.vessel, () => inboxOf([noticeJson()], unread: 2));
      when(() => vessels.alerts()).thenAnswer((_) async => alertsOf([alertJson(id: 8, mine: false), alertJson(id: 7)]));
      final s = NotificationSummaryCubit(notices, vessels, signals: signals.stream);

      await s.load();
      expect(s.state.otherUnread, 3);
      expect(s.state.vesselUnread, 2);
      expect([for (final a in s.state.alerts) a.id], [7, 8]);
      expect(s.state.mineAlerts.single.id, 7);
      expect(s.state.teamAlerts.single.id, 8);
      verifyNever(() => notices.mine());

      await s.load();
      expect(s.state.otherUnread, 3);

      s.clear();
      expect(s.state.otherUnread, 0);
      expect(s.state.vesselUnread, 0);
      expect(s.state.alerts, isEmpty);
      await s.close();
    });

    test('calls made together share one request each', () async {
      answerInbox(notices, NoticeGroup.vessel, () => inboxOf(const []));
      answerInbox(notices, NoticeGroup.other, () => inboxOf(const []));
      when(() => vessels.alerts()).thenAnswer((_) async => const []);
      final s = NotificationSummaryCubit(notices, vessels, signals: signals.stream);

      await Future.wait([s.load(), s.load()]);

      verify(() => notices.mine(group: NoticeGroup.vessel)).called(1);
      verify(() => notices.mine(group: NoticeGroup.other)).called(1);
      verify(() => vessels.alerts()).called(1);
      await s.close();
    });

    test('the app-wide signal reaches a summary listening to it', () async {
      answerInbox(notices, NoticeGroup.vessel, () => inboxOf(const []));
      answerInbox(notices, NoticeGroup.other, () => inboxOf([noticeJson(id: 9, kind: 'LEAVE_APPROVED')], unread: 5));
      when(() => vessels.alerts()).thenAnswer((_) async => const []);
      final s = NotificationSummaryCubit(notices, vessels);

      NotificationSignals.changed();
      await pumpEventQueue();

      expect(s.state.otherUnread, 5);
      await s.close();
    });
  });

  group('NotificationsCubit.closeAlert ("Not this vessel")', () {
    setUp(() {
      answerInbox(notices, NoticeGroup.vessel, () => inboxOf(const []));
      answerInbox(notices, NoticeGroup.other, () => inboxOf(const []));
    });

    test('closes the LINK alert: the card goes at once and the bell is told to reload', () async {
      when(() => vessels.alerts()).thenAnswer((_) async => alertsOf([linkAlertJson(), alertJson()]));
      when(() => vessels.closeAlert(21)).thenAnswer((_) async => true);
      final told = <void>[];
      final sub = NotificationSignals.refresh.listen(told.add);
      final c = cubit();
      await c.load();

      final error = await c.closeAlert(c.state.alerts!.first);
      await pumpEventQueue();

      expect(error, isNull);
      verify(() => vessels.closeAlert(21)).called(1);
      expect(c.state.alerts!.map((a) => a.id), [7]);
      expect(told, hasLength(1));
      await sub.cancel();
      await c.close();
    });

    test('a refusal keeps the alert and answers the server message', () async {
      when(() => vessels.alerts()).thenAnswer((_) async => alertsOf([linkAlertJson()]));
      when(() => vessels.closeAlert(21)).thenThrow(const ApiFailure('Not your alert', statusCode: 403));
      final c = cubit();
      await c.load();

      final error = await c.closeAlert(c.state.alerts!.single);

      expect(error, 'Not your alert');
      expect(c.state.alerts!.single.id, 21);
      await c.close();
    });
  });

  group('routeForNotice and toneOf', () {
    EmployeeNotification n(Map<String, dynamic> m) => EmployeeNotification.fromJava(m);

    test('vessel notices open Vessel changes, team scope for "Not handled"', () {
      expect(routeForNotice(n(noticeJson())), vesselChangesPath);
      final notHandled =
          n(noticeJson(title: 'Not handled: MSC COLETTE III 641R', linkPath: '/vessel-changes?scope=team'));
      expect(routeForNotice(notHandled), vesselChangesTeamPath);
      expect(toneOf(notHandled), NoticeTone.notHandled);
      expect(toneOf(n(noticeJson(title: 'Reminder: MSC COLETTE III 641R: ETA moved'))), NoticeTone.reminder);
      expect(toneOf(n(noticeJson())), NoticeTone.vessel);
    });

    test('VESSEL_LINK_NEEDED opens the job, PTP_SCHEDULE_STALE opens Vessel changes, both vessel-toned', () {
      final link = n(noticeJson(
          kind: 'VESSEL_LINK_NEEDED',
          title: 'Pick the PTP voyage: job MY002605357',
          linkPath: '/sale-order/edit/51234',
          refType: 'SALE_ORDER',
          refId: 51234));
      expect(routeForNotice(link), saleOrderEditRoute(51234));
      expect(toneOf(link), NoticeTone.linkNeeded);
      // no link: the SALE_ORDER ref still names the job
      final refOnly =
          n(noticeJson(kind: 'VESSEL_LINK_NEEDED', linkPath: null, refType: 'SALE_ORDER', refId: 51240));
      expect(routeForNotice(refOnly), saleOrderEditRoute(51240));
      // neither: the Vessel tab
      expect(routeForNotice(n(noticeJson(kind: 'VESSEL_LINK_NEEDED', linkPath: null, refType: null, refId: null))),
          notificationsVesselPath);
      final stale = n(noticeJson(
          kind: 'PTP_SCHEDULE_STALE',
          title: 'PTP schedule not updating since 13 Oct 10:05',
          linkPath: '/ptp-schedule',
          refType: 'PTP_SCHEDULE',
          refId: null));
      expect(routeForNotice(stale), vesselChangesPath);
      expect(toneOf(stale), NoticeTone.ptpStale);
      // a reminder of a LINK alert reads as a reminder
      expect(toneOf(n(noticeJson(kind: 'VESSEL_LINK_NEEDED', title: 'Reminder: Pick the PTP voyage: job MY1'))),
          NoticeTone.reminder);
    });

    test('a VESSEL_ETA_CHANGED for a job without employee opens that job; a PTP_CALL ref is not a job', () {
      final unassigned = n(noticeJson(
          title: 'MSC COLETTE III 641R: ETA moved – job without employee', linkPath: '/sale-order/edit/51300'));
      expect(routeForNotice(unassigned), saleOrderEditRoute(51300));
      final differs = n(noticeJson(title: 'MSC COLETTE III 641R: job ETA differs from PTP'));
      expect(routeForNotice(differs), vesselChangesPath);
      expect(toneOf(differs), NoticeTone.vessel);
    });

    test('forwarding notices open their forwarding list; others open nothing', () {
      final fw = n(noticeJson(kind: 'FORWARDING_REQUESTED', linkPath: '/forwarding-requests/5'));
      expect(routeForNotice(fw), forwardingRequestsPath);
      expect(routeForNotice(n(noticeJson(kind: 'FORWARDING_APPROVED', linkPath: null))), myForwardingRequestsPath);
      expect(toneOf(fw), NoticeTone.forwarding);
      final other = n(noticeJson(kind: 'LEAVE_APPROVED', linkPath: '/leave'));
      expect(routeForNotice(other), isNull);
      expect(toneOf(other), NoticeTone.other);
    });
  });
}
