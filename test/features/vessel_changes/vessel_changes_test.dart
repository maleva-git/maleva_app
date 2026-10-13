import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/vessel_changes/vessel_changes_api.dart';
import 'package:maleva/core/vessel_changes/vessel_changes_models.dart';
import 'package:maleva/features/vessel_changes/vessel_changes_cubit.dart';
import 'package:maleva/features/vessel_changes/vessel_changes_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../core/vessel_changes/vessel_changes_api_test.dart' show jobJson;
import '../../core/vessel_master/vessel_master_api_test.dart' show callJson;

class _Api extends Mock implements VesselChangesApi {}

VesselChanges changes(List<Map<String, dynamic>> jobs,
        {Map<String, dynamic>? call, String? lastChangedAt = '2026-10-12T09:15'}) =>
    VesselChanges.fromJava({
      'lastGoodReadAt': '2026-10-12T09:15',
      'groups': [
        {'call': call ?? callJson, 'lastChangedAt': lastChangedAt, 'changes': const [], 'jobs': jobs}
      ],
    });

Map<String, dynamic> offJob(int id) => {
      ...jobJson(id: id, leg: 'OFF'),
      'currentEta': '2026-10-10T06:30',
      'ptpEta': '2026-10-11T02:00',
      'ptpEtd': '2026-10-12T17:00',
    };

BulkUpdateResult allOk(List<int> ids) => BulkUpdateResult(
    requested: ids.length,
    updated: ids.length,
    results: [for (final id in ids) BulkJobResult(saleOrderId: id, jobNo: 'MY00$id', ok: true)]);

/// The Vessel changes screen (vessel-master-and-ptp-schedule, tasks 3.1, 3.2 and 4.11).
void main() {
  late _Api api;

  setUp(() {
    api = _Api();
    when(() => api.applyTimes(
            leg: any(named: 'leg'),
            saleOrderIds: any(named: 'saleOrderIds'),
            eta: any(named: 'eta'),
            etd: any(named: 'etd')))
        .thenAnswer((i) async => allOk(i.namedArguments[#saleOrderIds] as List<int>));
  });

  Future<VesselChangesCubit> loaded(VesselChanges first, {VesselChanges? after}) async {
    var calls = 0;
    when(() => api.list(scope: any(named: 'scope'))).thenAnswer((_) async => calls++ == 0 ? first : (after ?? first));
    final cubit = VesselChangesCubit(api);
    await cubit.load();
    return cubit;
  }

  group('cubit: update (3.1, 4.11)', () {
    test('"Update all": three off legs, one request with oeta and oetd only, then reload and they are gone', () async {
      final cubit = await loaded(changes([offJob(1), offJob(2), offJob(3)]), after: changes(const []));

      await cubit.update(cubit.state.data!.groups.single);

      verify(() => api.applyTimes(
          leg: 'OFF', saleOrderIds: [1, 2, 3], eta: '2026-10-11T02:00', etd: '2026-10-12T17:00')).called(1);
      verify(() => api.list(scope: 'me')).called(2);
      expect(cubit.state.data!.isEmpty, isTrue);
      expect(cubit.state.done, "3 jobs updated to PTP's times");
      expect(cubit.state.doneSeq, 1);
      expect(cubit.state.notes, isEmpty, reason: 'the notes card shows only when jobs were refused or left out');
    });

    test('"Use PTP\'s times" on one job sends only that job', () async {
      final cubit = await loaded(changes([offJob(1), offJob(2), offJob(3)]), after: changes([offJob(1), offJob(3)]));
      final g = cubit.state.data!.groups.single;

      await cubit.updateJob(g, g.jobs[1]);

      verify(() => api.applyTimes(leg: 'OFF', saleOrderIds: [2], eta: '2026-10-11T02:00', etd: '2026-10-12T17:00'))
          .called(1);
      verifyNever(() => api.applyTimes(
          leg: any(named: 'leg'), saleOrderIds: [1, 2, 3], eta: any(named: 'eta'), etd: any(named: 'etd')));
      expect(cubit.state.done, "MY002 updated to PTP's times");
      expect(cubit.state.data!.groups.single.jobs.map((j) => j.saleOrderId), [1, 3]);
    });

    test('one leg type and PTP time pair per request', () async {
      final other = {...offJob(4), 'ptpEtd': '2026-10-13T08:00'};
      final cubit = await loaded(changes([offJob(1), jobJson(id: 2), other]));

      await cubit.update(cubit.state.data!.groups.single);

      verify(() => api.applyTimes(leg: 'OFF', saleOrderIds: [1], eta: '2026-10-11T02:00', etd: '2026-10-12T17:00'))
          .called(1);
      verify(() => api.applyTimes(leg: 'LOADING', saleOrderIds: [2], eta: '2026-10-15T08:00', etd: '2026-10-16T17:00'))
          .called(1);
      verify(() => api.applyTimes(leg: 'OFF', saleOrderIds: [4], eta: '2026-10-11T02:00', etd: '2026-10-13T08:00'))
          .called(1);
    });

    test('a refused job is named and stays listed', () async {
      when(() => api.applyTimes(
              leg: any(named: 'leg'), saleOrderIds: any(named: 'saleOrderIds'), eta: any(named: 'eta'), etd: any(named: 'etd')))
          .thenAnswer((_) async => const BulkUpdateResult(requested: 2, updated: 1, skipped: 1, results: [
                BulkJobResult(saleOrderId: 1, jobNo: 'MY001', ok: true),
                BulkJobResult(saleOrderId: 2, jobNo: 'MY002', ok: false, message: 'Job is closed'),
              ]));
      final cubit = await loaded(changes([offJob(1), offJob(2)]), after: changes([offJob(2)]));

      await cubit.update(cubit.state.data!.groups.single);

      expect(cubit.state.notes, ['MY002: not updated - Job is closed']);
      expect(cubit.state.done, "MY001 updated to PTP's times");
      expect(cubit.state.data!.groups.single.jobs.single.saleOrderId, 2);
      expect(cubit.state.refused.values.single, 'Job is closed');
    });

    test('a failed list shows the error, not an empty list; retry loads again', () async {
      var calls = 0;
      when(() => api.list(scope: any(named: 'scope'))).thenAnswer((_) async {
        if (calls++ == 0) throw const ApiFailure('Server error occurred. (500)');
        return changes([offJob(1)]);
      });
      final cubit = VesselChangesCubit(api);

      await cubit.load();
      expect(cubit.state.error, 'Server error occurred. (500)');
      expect(cubit.state.data, isNull);

      await cubit.load();
      expect(cubit.state.error, isNull);
      expect(cubit.state.data!.groups.single.jobs, hasLength(1));
    });

    test('dismiss calls the API and removes the job', () async {
      when(() => api.dismiss(saleOrderId: 1, leg: 'OFF', ptpVesselCallId: 412)).thenAnswer((_) async => true);
      final cubit = await loaded(changes([offJob(1), offJob(2)]));
      final g = cubit.state.data!.groups.single;

      await cubit.dismiss(g, g.jobs.first);

      verify(() => api.dismiss(saleOrderId: 1, leg: 'OFF', ptpVesselCallId: 412)).called(1);
      expect(cubit.state.data!.groups.single.jobs.map((j) => j.saleOrderId), [2]);
    });

    test('My team loads the team scope', () async {
      final cubit = await loaded(changes([offJob(1)]));
      await cubit.load(scope: 'team');
      verify(() => api.list(scope: 'team')).called(1);
      expect(cubit.state.scope, 'team');
    });
  });

  group('cubit: boarding month (3.2)', () {
    test('a loading leg gets only its ETA and ETD: pickup and delivery are not moved', () async {
      final cubit = await loaded(changes([jobJson(id: 51234)]), after: changes(const []));

      await cubit.update(cubit.state.data!.groups.single);

      verify(() => api.list(scope: 'me')).called(2);
      verify(() => api.applyTimes(
          leg: 'LOADING', saleOrderIds: [51234], eta: '2026-10-15T08:00', etd: '2026-10-16T17:00')).called(1);
      verifyNoMoreInteractions(api);
      expect(cubit.state.notes, isEmpty);
      expect(cubit.state.done, "MY0051234 updated to PTP's times");
    });

    test('an unconfirmed boarding month row is held; the others update; confirming lets it through', () async {
      final flagged = jobJson(id: 2, boardingFrom: '2026-10', boardingTo: '2026-11');
      final cubit = await loaded(changes([jobJson(id: 1), flagged]), after: changes([flagged]));

      await cubit.update(cubit.state.data!.groups.single);

      verify(() => api.applyTimes(leg: 'LOADING', saleOrderIds: [1], eta: any(named: 'eta'), etd: any(named: 'etd')))
          .called(1);
      expect(cubit.state.notes,
          contains('MY002 waits for confirmation: boarding pay moves from Oct 2026 to Nov 2026'));

      final g = cubit.state.data!.groups.single;
      await cubit.updateJob(g, g.jobs.single);
      verifyNever(() => api.applyTimes(leg: 'LOADING', saleOrderIds: [2], eta: any(named: 'eta'), etd: any(named: 'etd')));
      expect(cubit.state.notes, ['MY002 waits for confirmation: boarding pay moves from Oct 2026 to Nov 2026']);

      cubit.confirmBoarding(g, g.jobs.single);
      await cubit.updateJob(g, g.jobs.single);

      verify(() => api.applyTimes(leg: 'LOADING', saleOrderIds: [2], eta: any(named: 'eta'), etd: any(named: 'etd')))
          .called(1);
    });
  });

  group('cubit: Read PTP now (3.4)', () {
    test('reads PTP, says how many calls, then reloads the list', () async {
      final cubit = await loaded(changes([offJob(1)]));
      when(() => api.readPtpNow()).thenAnswer((_) async => const PtpReadResult(ok: true, rows: 224, changes: 3));

      await cubit.readPtpNow();

      expect(cubit.state.notes, ['PTP read: 224 vessel calls, 3 changes']);
      expect(cubit.state.busy, isFalse);
      verify(() => api.list(scope: any(named: 'scope'))).called(2);
    });

    test('a read from the last few minutes is shown as the latest schedule', () async {
      final cubit = await loaded(changes([offJob(1)]));
      when(() => api.readPtpNow())
          .thenAnswer((_) async => const PtpReadResult(ok: true, rows: 224, startedAt: '2026-10-13T11:20', recent: true));

      await cubit.readPtpNow();

      expect(cubit.state.notes, ['PTP was read at 13 Oct 11:20; this is the latest schedule']);
    });

    test('a failure is said, and the list still reloads', () async {
      final cubit = await loaded(changes([offJob(1)]));
      when(() => api.readPtpNow()).thenThrow(Exception('PTP down'));

      await cubit.readPtpNow();

      expect(cubit.state.notes.single, startsWith('Could not read PTP now'));
      verify(() => api.list(scope: any(named: 'scope'))).called(2);
    });
  });

  group('screen', () {
    Future<void> pump(WidgetTester tester, {bool tall = true}) async {
      if (tall) {
        tester.view.physicalSize = const Size(800, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
      }
      await tester.pumpWidget(MaterialApp(home: VesselChangesPage(api: api)));
      await tester.pumpAndSettle();
    }

    void answer(VesselChanges first, {VesselChanges? after}) {
      var calls = 0;
      when(() => api.list(scope: any(named: 'scope'))).thenAnswer((_) async => calls++ == 0 ? first : (after ?? first));
    }

    Finder inRow(String key, String text) => find.descendant(of: find.byKey(ValueKey(key)), matching: find.text(text));

    BoxDecoration rowLook(WidgetTester tester, String key) => tester
        .widget<Container>(find.descendant(of: find.byKey(ValueKey(key)), matching: find.byType(Container)).first)
        .decoration! as BoxDecoration;

    testWidgets('every employee has "Read PTP now" in the top bar', (tester) async {
      when(() => api.list(scope: any(named: 'scope'))).thenAnswer((_) async => changes([offJob(1)]));
      when(() => api.readPtpNow()).thenAnswer((_) async => const PtpReadResult(ok: true, rows: 224, changes: 0));
      await pump(tester);

      await tester.tap(find.byKey(const Key('read_ptp_now')));
      await tester.pumpAndSettle();

      verify(() => api.readPtpNow()).called(1);
      expect(find.text('PTP read: 224 vessel calls, 0 changes'), findsOneWidget);
    });

    testWidgets('card header: vessel and voyage, what PTP says with est., when it changed; never "PTP changed -"',
        (tester) async {
      answer(changes([for (var i = 1; i <= 5; i++) offJob(i)]));
      await pump(tester);

      expect(find.text('MAERSK RIO NEGRO 641S'), findsOneWidget);
      expect(find.text('PTP: arrives 10 Oct 06:30 (est.) · departs 11 Oct 17:00 · changed 12 Oct 09:15'), findsOneWidget);
      expect(find.text('Update all 5 jobs to PTP'), findsOneWidget);
      expect(find.text("Use PTP's times"), findsNWidgets(5));
      expect(find.text('Keep mine (dismiss)'), findsNWidgets(5));
      expect(find.text('My jobs'), findsOneWidget);
      expect(find.text('My team'), findsOneWidget);
      expect(find.text('Also move pickup and delivery'), findsNothing);
    });

    testWidgets('no change time and no departure: "departs —", no "changed", no "PTP changed -"', (tester) async {
      answer(changes([offJob(1)], call: {...callJson, 'departAt': null, 'departEstimated': true}, lastChangedAt: null));
      await pump(tester);

      expect(find.text('PTP: arrives 10 Oct 06:30 (est.) · departs —'), findsOneWidget);
      expect(find.textContaining('PTP changed'), findsNothing);
      expect(find.text('Update this job to PTP'), findsOneWidget);
    });

    testWidgets('comparison: a time that differs is highlighted with PTP semibold and how far it moves', (tester) async {
      answer(changes([offJob(1)]));
      await pump(tester);

      expect(find.text('In Maleva'), findsOneWidget);
      expect(find.text('PTP now'), findsOneWidget);
      // ETA: 10 Oct 06:30 -> 11 Oct 02:00 est. (19 h 30 min, rounded)
      expect(inRow('eta_1_OFF', '10 Oct 06:30'), findsOneWidget);
      expect(inRow('eta_1_OFF', '11 Oct 02:00 est.'), findsOneWidget);
      expect(inRow('eta_1_OFF', '+20 h later'), findsOneWidget);
      expect(tester.widget<Text>(inRow('eta_1_OFF', '11 Oct 02:00 est.')).style!.fontWeight, FontWeight.w600);
      expect(rowLook(tester, 'eta_1_OFF').color, isNotNull);
      // ETD: 14 Oct 17:00 -> 12 Oct 17:00 (PTP's departure is not estimated)
      expect(inRow('etd_1_OFF', '14 Oct 17:00'), findsOneWidget);
      expect(inRow('etd_1_OFF', '12 Oct 17:00'), findsOneWidget);
      expect(inRow('etd_1_OFF', '−2 d earlier'), findsOneWidget);
    });

    testWidgets('comparison: a matching time is muted "✓ same"; not set reads "to fill"; no PTP time is "—"',
        (tester) async {
      answer(changes([
        {...offJob(1), 'currentEta': '2026-10-11T02:00', 'etaDiffers': false, 'ptpEtd': null, 'etdDiffers': false},
        {...offJob(2), 'currentEta': null},
      ]));
      await pump(tester);

      expect(inRow('eta_1_OFF', '11 Oct 02:00'), findsOneWidget);
      expect(inRow('eta_1_OFF', '✓ same'), findsOneWidget);
      expect(inRow('eta_1_OFF', '11 Oct 02:00 est.'), findsNothing, reason: 'a matching time is not shown as a change');
      expect(rowLook(tester, 'eta_1_OFF').color, isNull);
      expect(inRow('etd_1_OFF', '—'), findsOneWidget);
      expect(rowLook(tester, 'etd_1_OFF').color, isNull);

      expect(inRow('eta_2_OFF', 'not set'), findsOneWidget);
      expect(tester.widget<Text>(inRow('eta_2_OFF', 'not set')).style!.fontStyle, FontStyle.italic);
      expect(inRow('eta_2_OFF', '11 Oct 02:00 est.'), findsOneWidget);
      expect(inRow('eta_2_OFF', 'to fill'), findsOneWidget);
      expect(rowLook(tester, 'eta_2_OFF').color, isNotNull);
    });

    testWidgets('no SCN line per job (only the vessel\'s SCN chip), no checkboxes', (tester) async {
      answer(changes([offJob(1), jobJson(id: 2)]));
      await pump(tester);

      expect(find.textContaining('→'), findsNothing);
      expect(find.textContaining('PTP 269EK6'), findsNothing);
      expect(find.text('SCN 269EK6'), findsOneWidget);
      expect(find.byType(Checkbox), findsNothing);
      expect(find.textContaining('Update these jobs'), findsNothing);
    });

    testWidgets('job lines: number and leg, then customer and employee', (tester) async {
      answer(changes([offJob(1), jobJson(id: 2)]));
      await pump(tester);

      expect(find.text('MY001 · Off'), findsOneWidget);
      expect(find.text('MY002 · Loading'), findsOneWidget);
      expect(find.text('ABC MARINE · SHALINI'), findsNWidgets(2));
    });

    testWidgets('"Use PTP\'s times" updates only that job and says so', (tester) async {
      answer(changes([offJob(1), offJob(2)]), after: changes([offJob(1)]));
      await pump(tester);

      await tester.tap(find.byKey(const ValueKey('use_ptp_412|2|OFF')));
      await tester.pumpAndSettle();

      verify(() => api.applyTimes(leg: 'OFF', saleOrderIds: [2], eta: '2026-10-11T02:00', etd: '2026-10-12T17:00'))
          .called(1);
      verifyNever(() => api.applyTimes(
          leg: any(named: 'leg'), saleOrderIds: [1, 2], eta: any(named: 'eta'), etd: any(named: 'etd')));
      expect(find.text("MY002 updated to PTP's times"), findsOneWidget);
      expect(find.text('MY002 · Off'), findsNothing);
      expect(find.text('Update this job to PTP'), findsOneWidget);
    });

    testWidgets('the card button is enabled without selecting and updates all jobs', (tester) async {
      answer(changes([offJob(1), offJob(2)]), after: changes(const []));
      await pump(tester);

      final button = find.byKey(const ValueKey('update_412'));
      expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
      await tester.tap(button);
      await tester.pumpAndSettle();

      verify(() => api.applyTimes(leg: 'OFF', saleOrderIds: [1, 2], eta: '2026-10-11T02:00', etd: '2026-10-12T17:00'))
          .called(1);
      expect(find.text("2 jobs updated to PTP's times"), findsOneWidget);
      expect(find.text('No vessel changes'), findsOneWidget);
    });

    testWidgets('"Keep mine (dismiss)" dismisses that job', (tester) async {
      answer(changes([offJob(1), offJob(2)]));
      when(() => api.dismiss(saleOrderId: 1, leg: 'OFF', ptpVesselCallId: 412)).thenAnswer((_) async => true);
      await pump(tester);

      await tester.tap(find.byKey(const ValueKey('dismiss_412|1|OFF')));
      await tester.pumpAndSettle();

      verify(() => api.dismiss(saleOrderId: 1, leg: 'OFF', ptpVesselCallId: 412)).called(1);
      expect(find.text('MY001 · Off'), findsNothing);
      expect(find.text('MY002 · Off'), findsOneWidget);
    });

    testWidgets('rows show no pickup or delivery line; a flagged one keeps the boarding month note and confirm',
        (tester) async {
      answer(changes([
        jobJson(id: 1),
        jobJson(id: 3, boardingFrom: '2026-10', boardingTo: '2026-11'),
      ]));
      await pump(tester);

      expect(find.textContaining('Pickup'), findsNothing);
      expect(find.textContaining('Delivery'), findsNothing);
      expect(find.text('Boarding pay moves from Oct 2026 to Nov 2026'), findsOneWidget);
      expect(find.byKey(const ValueKey('confirm_412|3|LOADING')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('use_ptp_412|3|LOADING')));
      await tester.pumpAndSettle();
      verifyNever(() =>
          api.applyTimes(leg: any(named: 'leg'), saleOrderIds: [3], eta: any(named: 'eta'), etd: any(named: 'etd')));
      expect(find.text('MY003 waits for confirmation: boarding pay moves from Oct 2026 to Nov 2026'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('confirm_412|3|LOADING')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('use_ptp_412|3|LOADING')));
      await tester.pumpAndSettle();
      verify(() =>
              api.applyTimes(leg: 'LOADING', saleOrderIds: [3], eta: any(named: 'eta'), etd: any(named: 'etd')))
          .called(1);
    });

    testWidgets('updating reloads; the error state has a retry', (tester) async {
      var calls = 0;
      when(() => api.list(scope: any(named: 'scope'))).thenAnswer((_) async {
        calls++;
        if (calls == 2) throw const ApiFailure('Server error occurred. (500)');
        return calls == 1 ? changes([offJob(1)]) : changes(const []);
      });
      await pump(tester);

      await tester.tap(find.text('Update this job to PTP'));
      await tester.pumpAndSettle();

      expect(find.text('Server error occurred. (500)'), findsOneWidget);
      expect(find.text("MY001 updated to PTP's times"), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.text('No vessel changes'), findsOneWidget);
      expect(find.text('PTP last read 12 Oct 09:15'), findsOneWidget);
    });

    testWidgets('the SCN is copied, not sent', (tester) async {
      final copied = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') copied.add((call.arguments as Map)['text'] as String);
        return null;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
      when(() => api.list(scope: any(named: 'scope'))).thenAnswer((_) async => changes([offJob(1)]));
      await pump(tester);

      await tester.tap(find.byKey(const Key('copy_scn')));
      await tester.pump();

      expect(copied, ['269EK6']);
      expect(find.text('SCN 269EK6 copied'), findsOneWidget);
      expect(find.text('SCN 269EK6'), findsOneWidget);
      final semantics = tester.ensureSemantics();
      await tester.pump();
      expect(find.bySemanticsLabel('Copy SCN 269EK6'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('a 360-wide phone with long names has no overflow', (tester) async {
      const longVessel = 'MAERSK EXTRAORDINARILY LONG CONTAINER VESSEL NAME';
      const longCustomer = 'PAC DISTRICENTRE INTERNATIONAL LOGISTICS AND WAREHOUSING PTE LTD';
      const longEmployee = 'LEKHA MAHESWARI A/P SUBRAMANIAM';
      answer(changes([
        for (var i = 1; i <= 3; i++)
          {
            ...offJob(2605800 + i),
            'jobNo': 'MY00${2605800 + i}',
            'customerName': longCustomer,
            'employeeName': longEmployee,
            if (i == 2) 'currentEta': null,
            if (i == 3) ...{'boardingMonthFrom': '2026-10', 'boardingMonthTo': '2026-11'},
          }
      ], call: {...callJson, 'vesselName': longVessel, 'voyage': '636N', 'scn': '269SM2', 'departEstimated': true}));
      tester.view.physicalSize = const Size(1080, 4800);
      tester.view.devicePixelRatio = 3.0; // 360 wide, like the owner's phone
      addTearDown(tester.view.reset);
      await pump(tester, tall: false);

      expect(tester.takeException(), isNull, reason: 'no RenderFlex overflow');
      expect(find.text('$longVessel 636N'), findsOneWidget);
      expect(find.text('Update all 3 jobs to PTP'), findsOneWidget);
      expect(find.text('$longCustomer · $longEmployee'), findsNWidgets(3));
    });
  });

  test('opens on My team when given the team scope (a leader\'s "Not handled" notice, task 4.4)', () async {
    when(() => api.list(scope: any(named: 'scope'))).thenAnswer((_) async => changes(const []));
    final cubit = VesselChangesCubit(api, scope: 'team');
    expect(cubit.state.scope, 'team');

    await cubit.load();

    verify(() => api.list(scope: 'team')).called(1);
  });
}
