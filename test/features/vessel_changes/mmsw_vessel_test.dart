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
import 'package:maleva/features/vessel_changes/vessel_changes_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../core/employee_notifications/employee_notifications_api_test.dart' show noticeJson;
import '../../core/vessel_changes/vessel_changes_api_test.dart' show alertJson, jobJson, linkAlertJson;
import '../../core/vessel_master/vessel_master_api_test.dart' show callJson;
import '../notifications/notifications_cubit_test.dart' show NoticesApi, VesselsApi, alertsOf, answerInbox, inboxOf;
import 'westports_vessel_test.dart' show westportsCallJson;

class _Api extends Mock implements VesselChangesApi {}

/// An MMSW call as the backend answers it (mmsw-vessel-schedule api-contract.md).
const Map<String, dynamic> mmswCallJson = {
  'id': 9101,
  'port': 'MMSW',
  'vesselName': 'XIN XU ZHOU',
  'vesselCode': 'FCN895090',
  'lineId': 'BS0504',
  'voyage': null,
  'scn': '267DF4',
  'arriveAt': '2026-10-15T08:00',
  'arriveEstimated': true,
  'departAt': '2026-10-16T23:59',
  'departEstimated': true,
  'dryCutoff': null,
  'reeferCutoff': null,
  'cfsCutoff': null,
  'hazardCutoff': null,
  'listed': true,
  'lastSeenAt': '2026-10-15T10:20',
  'portLabel': 'MMSW',
  'voyageOut': null,
  'status': null,
  'omitted': false,
  'yardOpening': null,
  'berth': null,
  'actualArriveAt': null,
  'actualDepartAt': null,
  'terminal': 'Northport KCT',
  'callSign': 'BPKK',
  'lastPort': 'SGSIN-SINGAPORE',
  'shippingAgent': 'COSCO SHIPPING LINES (M) SDN BHD',
};

Map<String, dynamic> mmswJob(int id) => {...jobJson(id: id), 'port': 'NORTHPORT- B10', 'terminal': 'Northport KCT'};

Map<String, dynamic> mmswAlertJson({int id = 41}) => {
      ...alertJson(id: id),
      'ptpVesselCallId': 9101,
      'vesselName': 'XIN XU ZHOU',
      'voyage': null,
      'arriveAt': '2026-10-15T08:00',
      'port': 'MMSW',
      'portLabel': 'MMSW',
      'terminal': 'Northport KCT',
    };

VesselChanges mmswChanges(List<Map<String, dynamic>> jobs) => VesselChanges.fromJava({
      'lastGoodReadAt': '2026-10-15T09:15',
      'lastReadAtByPort': {'PTP': '2026-10-15T09:15', 'WESTPORTS': '2026-10-15T13:16', 'MMSW': '2026-10-15T10:20'},
      'groups': [
        {'call': mmswCallJson, 'lastChangedAt': null, 'changes': const [], 'jobs': jobs}
      ],
    });

/// MMSW, the third vessel schedule source (backend change mmsw-vessel-schedule): the new call fields, the
/// "MMSW · terminal" label, the SCN where a voyage would be, and the MMSW_SCHEDULE_STALE notice.
void main() {
  group('models', () {
    test('an MMSW call reads the new fields; no voyage, so its SCN stands in', () {
      final call = PtpCall.fromJava(mmswCallJson);
      expect(call.isMmsw, isTrue);
      expect(call.isWestports, isFalse);
      expect(call.sourceLabel, 'MMSW');
      expect(call.sourceText, 'MMSW · Northport KCT');
      expect(call.voyage, isNull);
      expect(call.voyageText, 'SCN 267DF4');
      expect(call.terminal, 'Northport KCT');
      expect(call.callSign, 'BPKK');
      expect(call.lastPort, 'SGSIN-SINGAPORE');
      expect(call.shippingAgent, 'COSCO SHIPPING LINES (M) SDN BHD');
    });

    test('the label comes from the port without portLabel; a terminal list is kept; no terminal: the label', () {
      expect(PtpCall.fromJava({...mmswCallJson, 'portLabel': null}).sourceLabel, 'MMSW');
      expect(PtpCall.fromJava({...mmswCallJson, 'terminal': 'Northport KCT, Southport BST'}).sourceText,
          'MMSW · Northport KCT, Southport BST');
      expect(PtpCall.fromJava({...mmswCallJson, 'terminal': null}).sourceText, 'MMSW');
      expect(PtpCall.fromJava({...mmswCallJson, 'scn': null}).voyageText, isNull);
      expect(VesselSource.labelOf('mmsw'), 'MMSW');
    });

    test('older PTP and Westports answers still parse; their voyage and label are unchanged', () {
      final ptp = PtpCall.fromJava(callJson);
      expect(ptp.terminal, isNull);
      expect(ptp.callSign, isNull);
      expect(ptp.lastPort, isNull);
      expect(ptp.shippingAgent, isNull);
      expect(ptp.voyageText, '641S');
      expect(ptp.sourceText, 'PTP');
      final westports = PtpCall.fromJava(westportsCallJson);
      expect(westports.sourceText, 'Westports');
      expect(westports.voyageText, '066W');
    });

    test('lastReadAtByPort has MMSW; MMSW job rows carry port and terminal', () {
      final data = mmswChanges([mmswJob(1)]);
      expect(data.lastReadAt(VesselSource.mmsw), '2026-10-15T10:20');
      expect(data.groups.single.jobs.single.terminal, 'Northport KCT');
      final old = VesselChanges.fromJava({'lastGoodReadAt': '2026-10-12T09:15', 'groups': const []});
      expect(old.lastReadAt(VesselSource.mmsw), isNull);
    });

    test('an MMSW alert reads port and terminal', () {
      final alert = VesselAlert.fromJava(mmswAlertJson());
      expect(alert.isMmsw, isTrue);
      expect(alert.sourceLabel, 'MMSW');
      expect(alert.sourceText, 'MMSW · Northport KCT');
      expect(alert.vesselText, 'XIN XU ZHOU');
      expect(VesselAlert.fromJava(alertJson()).sourceText, 'PTP');
    });
  });

  group('texts', () {
    test('an MMSW card starts with "MMSW · terminal"; buttons in MMSW\'s words', () {
      final g = mmswChanges(const []).groups.single;
      expect(vesselCallTitle(g.call), 'XIN XU ZHOU');
      expect(vesselCallSubline(g), 'MMSW · Northport KCT: arrives 15 Oct 08:00 (est.) · departs 16 Oct 23:59 (est.)');
      expect(sourceNowLabel(g.call), 'MMSW now');
      expect(updateAllLabel(2, label: g.call.sourceLabel), 'Update all 2 jobs to MMSW');
      expect(useTimesLabel(label: g.call.sourceLabel), "Use MMSW's times");
      expect(vesselJobLine(VesselChangeJob.fromJava(mmswJob(1))), 'MY001 · Loading · Northport KCT');
    });

    test('alert lines: "MMSW · terminal", the ETA and the jobs; Westports and PTP lines unchanged', () {
      expect(alertDetailParts(VesselAlert.fromJava(mmswAlertJson())),
          ['MMSW · Northport KCT', 'ETA 15 Oct 08:00 (est.)', '2 jobs not updated']);
      expect(alertDetailParts(VesselAlert.fromJava({...mmswAlertJson(), 'terminal': null})),
          ['MMSW', 'ETA 15 Oct 08:00 (est.)', '2 jobs not updated']);
      expect(alertTerminalText(VesselAlert.fromJava(mmswAlertJson())), 'MMSW · Northport KCT');
      final westports =
          VesselAlert.fromJava({...alertJson(), 'port': 'WESTPORTS', 'portLabel': 'Westports', 'terminal': 'B18'});
      expect(alertDetailParts(westports), ['Westports ETA 15 Oct 08:00 (est.)', '2 jobs not updated', 'Terminal B18']);
      final link = VesselAlert.fromJava({...linkAlertJson(), 'voyage': null, 'port': 'MMSW', 'portLabel': 'MMSW'});
      expect(linkAlertTitle(link), 'Pick MMSW voyage · job MY002605357');
    });
  });

  group('MMSW_SCHEDULE_STALE', () {
    final stale = EmployeeNotification.fromJava(noticeJson(
        id: 51,
        kind: 'MMSW_SCHEDULE_STALE',
        title: 'MMSW schedule not updating since 15 Oct 07:20',
        linkPath: '/vessel-changes',
        refType: 'MMSW_SCHEDULE',
        refId: null));

    test('is a vessel kind: Vessel tab, vibrate-only vessel channel', () {
      expect(NoticeKind.isVessel('MMSW_SCHEDULE_STALE'), isTrue);
      expect(NoticeGroup.of(stale), NoticeGroup.vessel);
      expect(isVesselPushType('MMSW_SCHEDULE_STALE'), isTrue);
      expect(LocalNotificationService.usesVesselChannel({'type': 'MMSW_SCHEDULE_STALE'}), isTrue);
    });

    test('looks like the PTP stale notice and opens Vessel changes', () {
      expect(toneOf(stale), NoticeTone.ptpStale);
      expect(isSystemNotice(stale), isTrue);
      expect(routeForNotice(stale), vesselChangesPath);

      const push = {'type': 'MMSW_SCHEDULE_STALE', 'link': '/vessel-changes'};
      expect(vesselChangesRouteForPush(push), vesselChangesPath);
      expect(routeForPush(push), vesselChangesPath);
      expect(routeForPush({'type': 'MMSW_SCHEDULE_STALE'}), vesselChangesPath);
      expect(routeForPayload(localPayloadForPush(push)), vesselChangesPath);
      expect(routeForPayload('MMSW_SCHEDULE_STALE'), vesselChangesPath);
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

    testWidgets('an MMSW card: SCN beside the name, "MMSW · terminal", MMSW buttons', (tester) async {
      await pump(tester, mmswChanges([mmswJob(1), mmswJob(2)]));

      expect(find.text('XIN XU ZHOU'), findsOneWidget);
      expect(find.text('SCN 267DF4'), findsOneWidget);
      expect(find.textContaining('MMSW · Northport KCT: arrives 15 Oct 08:00'), findsOneWidget);
      expect(find.text('MY001 · Loading · Northport KCT'), findsOneWidget);
      expect(find.text("Use MMSW's times"), findsNWidgets(2));
      expect(find.text('Update all 2 jobs to MMSW'), findsOneWidget);
    });

    testWidgets('nothing to do: MMSW\'s last read is shown', (tester) async {
      await pump(tester, mmswChanges(const []));
      expect(find.byKey(const Key('mmsw_last_read')), findsOneWidget);
      expect(find.textContaining('MMSW last read'), findsOneWidget);
    });
  });

  group('notifications page', () {
    late NoticesApi notices;
    late VesselsApi vessels;

    setUp(() {
      notices = NoticesApi();
      vessels = VesselsApi();
    });

    Future<void> pump(WidgetTester tester, List<Map<String, dynamic>> alerts) async {
      tester.view.physicalSize = const Size(1080, 3600);
      tester.view.devicePixelRatio = 2.6;
      addTearDown(tester.view.reset);
      when(() => vessels.alerts()).thenAnswer((_) async => alertsOf(alerts));
      answerInbox(notices, NoticeGroup.vessel, () => inboxOf(const []));
      answerInbox(notices, NoticeGroup.other, () => inboxOf(const []));
      await tester.pumpWidget(MaterialApp(
        home: NotificationsPage(
          notices: notices,
          vessels: vessels,
          now: () => DateTime(2026, 10, 15, 14, 0),
          onOpen: (_, __) {},
          initialTab: NoticeGroup.vessel,
        ),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('an MMSW ETA alert shows "MMSW · Northport KCT"', (tester) async {
      await pump(tester, [mmswAlertJson()]);
      expect(find.byKey(const ValueKey('vessel_alert_41')), findsOneWidget);
      expect(find.textContaining('MMSW · Northport KCT'), findsOneWidget);
    });

    testWidgets('an MMSW LINK alert with a suggested call shows its ETA, not "No MMSW voyage suggested"',
        (tester) async {
      await pump(tester, [
        {
          ...linkAlertJson(id: 42),
          'ptpVesselCallId': 9101,
          'voyage': null,
          'port': 'MMSW',
          'portLabel': 'MMSW',
          'terminal': 'Northport KCT',
        }
      ]);
      expect(find.textContaining('Pick MMSW voyage'), findsOneWidget);
      expect(find.textContaining('No MMSW voyage suggested'), findsNothing);
      expect(find.textContaining('15 Oct 08:00'), findsOneWidget);
      expect(find.textContaining('MMSW · Northport KCT'), findsOneWidget);
    });
  });
}
