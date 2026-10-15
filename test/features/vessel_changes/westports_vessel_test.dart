import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/employee_notifications/employee_notifications_models.dart';
import 'package:maleva/core/firebase/local_notification_service.dart';
import 'package:maleva/core/vessel_changes/vessel_change_look.dart';
import 'package:maleva/core/vessel_changes/vessel_changes_api.dart';
import 'package:maleva/core/vessel_changes/vessel_changes_models.dart';
import 'package:maleva/core/vessel_master/vessel_master_models.dart';
import 'package:maleva/features/mail_monitor/mine/push_route.dart';
import 'package:maleva/features/notifications/notification_look.dart';
import 'package:maleva/features/notifications/notification_routes.dart';
import 'package:maleva/features/notifications/notifications_page.dart';
import 'package:maleva/features/vessel_changes/push_route.dart';
import 'package:maleva/features/vessel_changes/vessel_changes_cubit.dart';
import 'package:maleva/features/vessel_changes/vessel_changes_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../core/employee_notifications/employee_notifications_api_test.dart' show noticeJson;
import '../../core/vessel_changes/vessel_changes_api_test.dart' show alertJson, jobJson, linkAlertJson;
import '../../core/vessel_master/vessel_master_api_test.dart' show callJson;
import '../notifications/notifications_cubit_test.dart' show NoticesApi, VesselsApi, alertsOf, answerInbox, inboxOf;

class _Api extends Mock implements VesselChangesApi {}

/// A Westports call as the backend answers it (westports-vessel-schedule api-contract.md).
const Map<String, dynamic> westportsCallJson = {
  'id': 9031,
  'port': 'WESTPORTS',
  'vesselName': 'EVER LIFTING',
  'vesselCode': 'EMCR',
  'lineId': 'EMC',
  'voyage': '066W',
  'scn': '269XG8',
  'arriveAt': '2026-10-16T23:00',
  'arriveEstimated': true,
  'departAt': '2026-10-21T08:56',
  'departEstimated': true,
  'dryCutoff': '2026-10-16T15:00',
  'reeferCutoff': null,
  'cfsCutoff': null,
  'hazardCutoff': null,
  'listed': true,
  'lastSeenAt': '2026-10-15T13:16',
  'portLabel': 'Westports',
  'voyageOut': '066W',
  'status': 'Not Arrived',
  'omitted': false,
  'yardOpening': '2026-10-12T23:00',
  'berth': 'B19',
  'actualArriveAt': null,
  'actualDepartAt': null,
};

final Map<String, dynamic> omittedCallJson = {
  ...westportsCallJson,
  'voyage': '066WOMIT',
  'status': 'Omitted',
  'omitted': true,
};

Map<String, dynamic> westportsJob(int id) => {...jobJson(id: id), 'port': 'WESTPORT-B18', 'terminal': 'B18'};

Map<String, dynamic> omittedAlertJson({int id = 31}) => {
      ...alertJson(id: id),
      'ptpVesselCallId': 9031,
      'vesselName': 'EVER LIFTING',
      'voyage': '066W',
      'arriveAt': '2026-10-16T23:00',
      'kind': 'OMITTED',
      'port': 'WESTPORTS',
      'portLabel': 'Westports',
      'terminal': 'B18',
    };

VesselChanges westportsChanges(Map<String, dynamic> call, List<Map<String, dynamic>> jobs,
        {List<Map<String, dynamic>> changes = const []}) =>
    VesselChanges.fromJava({
      'lastGoodReadAt': '2026-10-15T09:15',
      'lastReadAtByPort': {'PTP': '2026-10-15T09:15', 'WESTPORTS': '2026-10-15T13:16'},
      'groups': [
        {'call': call, 'lastChangedAt': null, 'changes': changes, 'jobs': jobs}
      ],
    });

/// Westports vessel schedule in the app (backend change westports-vessel-schedule): the new fields, the
/// OMITTED alert, STATUS changes and the two new vessel notice kinds.
void main() {
  group('models', () {
    test('a Westports call reads the new fields; its label is "Westports"', () {
      final call = PtpCall.fromJava(omittedCallJson);
      expect(call.isWestports, isTrue);
      expect(call.sourceLabel, 'Westports');
      expect(call.voyageOut, '066W');
      expect(call.status, 'Omitted');
      expect(call.omitted, isTrue);
      expect(call.yardOpening, '2026-10-12T23:00');
      expect(call.berth, 'B19');
      expect(call.actualArriveAt, isNull);
    });

    test('an older PTP answer without the fields still parses as PTP', () {
      final call = PtpCall.fromJava(callJson);
      expect(call.sourceLabel, 'PTP');
      expect(call.omitted, isFalse);
      expect(call.status, isNull);
      expect(PtpCall.fromJava({...callJson, 'port': null}).sourceLabel, 'PTP');

      final old = VesselChanges.fromJava({
        'lastGoodReadAt': '2026-10-12T09:15',
        'groups': [
          {'call': callJson, 'changes': const [], 'jobs': [jobJson()]}
        ],
      });
      expect(old.lastReadAtByPort, isEmpty);
      expect(old.lastReadAt(VesselSource.ptp), '2026-10-12T09:15');
      expect(old.lastReadAt(VesselSource.westports), isNull);
      expect(old.groups.single.jobs.single.terminal, isNull);
      expect(old.groups.single.jobs.single.port, isNull);
    });

    test('jobs read port and terminal; the answer reads lastReadAtByPort; a STATUS change is known', () {
      final data = westportsChanges(omittedCallJson, [westportsJob(1)], changes: [
        {'field': 'STATUS', 'oldValue': 'Not Arrived', 'newValue': 'Omitted', 'seenAt': '2026-10-15T13:16'}
      ]);
      expect(data.lastReadAt(VesselSource.westports), '2026-10-15T13:16');
      final job = data.groups.single.jobs.single;
      expect(job.port, 'WESTPORT-B18');
      expect(job.terminal, 'B18');
      expect(data.groups.single.changes.single.isStatus, isTrue);
    });

    test('an OMITTED alert reads port, label and terminal and cannot be closed; older alerts still parse', () {
      final omitted = VesselAlert.fromJava(omittedAlertJson());
      expect(omitted.isOmitted, isTrue);
      expect(omitted.canClose, isFalse);
      expect(omitted.sourceLabel, 'Westports');
      expect(omitted.terminal, 'B18');

      final bare = VesselAlert.fromJava({...omittedAlertJson(), 'port': null, 'portLabel': null});
      expect(bare.sourceLabel, 'Westports', reason: 'only Westports omits calls');

      final link = VesselAlert.fromJava(linkAlertJson());
      expect(link.canClose, isTrue);
      expect(link.sourceLabel, 'PTP');
      final eta = VesselAlert.fromJava(alertJson());
      expect(eta.port, isNull);
      expect(eta.terminal, isNull);
      expect(eta.sourceLabel, 'PTP');
    });
  });

  group('texts', () {
    test('a Westports card says "Westports:", its status and berth; an omitted one leaves the status out', () {
      final g = westportsChanges(westportsCallJson, const []).groups.single;
      expect(vesselCallSubline(g), 'Westports: arrives 16 Oct 23:00 (est.) · departs 21 Oct 08:56 (est.) · '
          'status Not Arrived · berth B19');
      final o = westportsChanges(omittedCallJson, const []).groups.single;
      expect(vesselCallSubline(o), 'Westports: arrives 16 Oct 23:00 (est.) · departs 21 Oct 08:56 (est.) · berth B19');
      expect(omittedCallText(o.call), 'Omitted at Westports');
      expect(sourceNowLabel(o.call), 'Westports now');
    });

    test('the STATUS change line, buttons and snackbar in the source\'s words', () {
      final g = westportsChanges(omittedCallJson, const [], changes: [
        {'field': 'ARRIVE', 'oldValue': '2026-10-15T23:00', 'newValue': '2026-10-16T23:00'},
        {'field': 'STATUS', 'oldValue': 'Not Arrived', 'newValue': 'Omitted'},
      ]).groups.single;
      expect(statusChangeText(g), 'Status: Not Arrived → Omitted');
      expect(statusChangeText(westportsChanges(westportsCallJson, const []).groups.single), isNull);
      expect(updateAllLabel(2, label: 'Westports'), 'Update all 2 jobs to Westports');
      expect(updateAllLabel(1), 'Update this job to PTP');
      expect(useTimesLabel(label: 'Westports'), "Use Westports' times");
      expect(useTimesLabel(), "Use PTP's times");
      final job = VesselChangeJob.fromJava(westportsJob(1));
      expect(updatedText([job], label: 'Westports'), "MY001 updated to Westports' times");
      expect(vesselJobLine(job), 'MY001 · Loading · B18');
      expect(vesselJobLine(VesselChangeJob.fromJava(jobJson(id: 2, leg: 'OFF'))), 'MY002 · Off');
    });

    test('alert lines: Westports ETA with the terminal; OMITTED says "Omitted at Westports"', () {
      final eta = VesselAlert.fromJava({...alertJson(), 'port': 'WESTPORTS', 'portLabel': 'Westports', 'terminal': 'B18'});
      expect(alertDetailParts(eta), ['Westports ETA 15 Oct 08:00 (est.)', '2 jobs not updated', 'Terminal B18']);
      expect(alertDetailParts(VesselAlert.fromJava(alertJson())).where((p) => p.isNotEmpty),
          ['PTP ETA 15 Oct 08:00 (est.)', '2 jobs not updated']);
      expect(alertDetailParts(VesselAlert.fromJava(omittedAlertJson())),
          ['Omitted at Westports', 'ETA 16 Oct 23:00 (est.)', '2 jobs to rearrange', 'Terminal B18']);
      expect(linkAlertTitle(VesselAlert.fromJava({...linkAlertJson(), 'portLabel': 'Westports'})),
          'Pick Westports voyage · job MY002605357');
      expect(linkAlertTitle(VesselAlert.fromJava(linkAlertJson())), 'Pick PTP voyage · job MY002605357');
    });
  });

  group('notice kinds and pushes', () {
    test('VESSEL_OMITTED opens Vessel changes; WESTPORTS_UPLOAD_DUE the Vessel tab (the upload is on the web)', () {
      const omitted = {'type': 'VESSEL_OMITTED', 'link': '/vessel-changes'};
      expect(vesselChangesRouteForPush(omitted), vesselChangesPath);
      expect(routeForPush(omitted), vesselChangesPath);
      expect(routeForPush({'type': 'VESSEL_OMITTED'}), vesselChangesPath);
      expect(routeForPayload(localPayloadForPush(omitted)), vesselChangesPath);
      expect(routeForPayload('VESSEL_OMITTED'), vesselChangesPath);
      // one job without employee: the job
      expect(routeForPush({'type': 'VESSEL_OMITTED', 'link': '/sale-order/edit/51234'}), saleOrderEditRoute(51234));

      const due = {'type': 'WESTPORTS_UPLOAD_DUE', 'link': '/westports-schedule'};
      expect(vesselChangesRouteForPush(due), notificationsVesselPath);
      expect(routeForPush(due), notificationsVesselPath);
      expect(routeForPayload(localPayloadForPush(due)), notificationsVesselPath);
      expect(routeForPayload('WESTPORTS_UPLOAD_DUE'), notificationsVesselPath);
    });

    test('both new kinds use the vibrate-only vessel channel', () {
      for (final type in ['VESSEL_OMITTED', 'WESTPORTS_UPLOAD_DUE']) {
        expect(isVesselPushType(type), isTrue, reason: type);
        expect(LocalNotificationService.usesVesselChannel({'type': type}), isTrue, reason: type);
      }
    });

    test('a tapped notice opens by kind; the upload reminder looks like the PTP stale notice', () {
      final omitted = EmployeeNotification.fromJava(
          noticeJson(id: 41, kind: 'VESSEL_OMITTED', linkPath: '/vessel-changes', refType: 'PTP_CALL', refId: 9031));
      final due = EmployeeNotification.fromJava(noticeJson(
          id: 42, kind: 'WESTPORTS_UPLOAD_DUE', linkPath: '/westports-schedule', refType: 'WESTPORTS_UPLOAD', refId: null));
      expect(routeForNotice(omitted), vesselChangesPath);
      expect(routeForNotice(due), notificationsVesselPath);
      expect(toneOf(omitted), NoticeTone.vessel);
      expect(toneOf(due), NoticeTone.ptpStale);
      expect(NoticeGroup.of(due), NoticeGroup.vessel);
    });
  });

  group('Vessel changes screen', () {
    late _Api api;

    setUp(() => api = _Api());

    Future<void> pump(WidgetTester tester, VesselChanges data) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      when(() => api.list(scope: any(named: 'scope'))).thenAnswer((_) async => data);
      await tester.pumpWidget(MaterialApp(home: VesselChangesPage(api: api)));
      await tester.pumpAndSettle();
    }

    testWidgets('a Westports card: label, terminal on the job, "Westports now", Westports buttons', (tester) async {
      await pump(tester, westportsChanges(westportsCallJson, [westportsJob(1), westportsJob(2)]));

      expect(find.textContaining('Westports: arrives 16 Oct 23:00'), findsOneWidget);
      expect(find.text('MY001 · Loading · B18'), findsOneWidget);
      expect(find.text('Westports now'), findsNWidgets(2));
      expect(find.text("Use Westports' times"), findsNWidgets(2));
      expect(find.text('Update all 2 jobs to Westports'), findsOneWidget);
      expect(find.byKey(const ValueKey('vessel_omitted_9031')), findsNothing);
    });

    testWidgets('an omitted call: "Omitted at Westports", the status change, "Open job" and "Dismiss" only',
        (tester) async {
      await pump(
          tester,
          westportsChanges(omittedCallJson, [westportsJob(1)], changes: [
            {'field': 'STATUS', 'oldValue': 'Not Arrived', 'newValue': 'Omitted'}
          ]));

      expect(find.byKey(const ValueKey('vessel_omitted_9031')), findsOneWidget);
      expect(find.text('Omitted at Westports'), findsOneWidget);
      expect(find.text('Status: Not Arrived → Omitted'), findsOneWidget);
      expect(find.text('Open job'), findsOneWidget);
      expect(find.text('Dismiss'), findsOneWidget);
      expect(find.text("Use Westports' times"), findsNothing);
      expect(find.byKey(const ValueKey('update_9031')), findsNothing);
    });

    test('the cubit never applies an omitted call\'s times', () async {
      final data = westportsChanges(omittedCallJson, [westportsJob(1)]);
      when(() => api.list(scope: any(named: 'scope'))).thenAnswer((_) async => data);
      final cubit = VesselChangesCubit(api);
      await cubit.load();

      await cubit.update(cubit.state.data!.groups.single);

      verifyNever(() => api.applyTimes(
          leg: any(named: 'leg'),
          saleOrderIds: any(named: 'saleOrderIds'),
          eta: any(named: 'eta'),
          etd: any(named: 'etd')));
    });

    testWidgets('nothing to do: the Westports last upload is shown under PTP\'s last read', (tester) async {
      await pump(tester, westportsChanges(westportsCallJson, const []));
      expect(find.byKey(const Key('westports_last_read')), findsOneWidget);
      expect(find.textContaining('Westports last uploaded'), findsOneWidget);
    });
  });

  group('notifications page', () {
    late NoticesApi notices;
    late VesselsApi vessels;
    late List<String> opened;

    setUp(() {
      notices = NoticesApi();
      vessels = VesselsApi();
      opened = [];
    });

    testWidgets('an OMITTED alert: "Omitted at Westports" with the terminal, no "Not this vessel"; it opens Vessel '
        'changes', (tester) async {
      tester.view.physicalSize = const Size(1080, 3600);
      tester.view.devicePixelRatio = 2.6;
      addTearDown(tester.view.reset);
      when(() => vessels.alerts()).thenAnswer((_) async => alertsOf([omittedAlertJson()]));
      answerInbox(notices, NoticeGroup.vessel, () => inboxOf(const []));
      answerInbox(notices, NoticeGroup.other, () => inboxOf(const []));
      await tester.pumpWidget(MaterialApp(
        home: NotificationsPage(
          notices: notices,
          vessels: vessels,
          now: () => DateTime(2026, 10, 15, 14, 0),
          onOpen: (_, route) => opened.add(route),
          initialTab: NoticeGroup.vessel,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('vessel_alert_31')), findsOneWidget);
      expect(find.byKey(const ValueKey('close_alert_31')), findsNothing);
      expect(find.text('Not this vessel'), findsNothing);
      expect(find.textContaining('Omitted at Westports'), findsOneWidget);
      expect(find.textContaining('Terminal B18'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('update_jobs_31')));
      await tester.pumpAndSettle();
      expect(opened, [vesselChangesPath]);
    });
  });
}
