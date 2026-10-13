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

VesselChanges changes(List<Map<String, dynamic>> jobs, {Map<String, dynamic>? call}) => VesselChanges.fromJava({
      'lastGoodReadAt': '2026-10-12T09:15',
      'groups': [
        {'call': call ?? callJson, 'lastChangedAt': '2026-10-12T09:15', 'changes': const [], 'jobs': jobs}
      ],
    });

Map<String, dynamic> offJob(int id) => {
      ...jobJson(id: id, leg: 'OFF', reason: 'NOT_THIS_LEG', suggestedPickup: null),
      'currentEta': '2026-10-10T06:30',
      'ptpEta': '2026-10-11T02:00',
      'ptpEtd': '2026-10-12T17:00',
    };

BulkUpdateResult allOk(List<int> ids) => BulkUpdateResult(
    requested: ids.length,
    updated: ids.length,
    results: [for (final id in ids) BulkJobResult(saleOrderId: id, jobNo: 'MY00$id', ok: true)]);

/// The Vessel changes screen (vessel-master-and-ptp-schedule, tasks 3.1 and 3.2).
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
    when(() => api.movePickupDelivery(
            ptpVesselCallId: any(named: 'ptpVesselCallId'), saleOrderIds: any(named: 'saleOrderIds')))
        .thenAnswer((i) async => [
              for (final id in i.namedArguments[#saleOrderIds] as List<int>)
                MoveResult(saleOrderId: id, jobNo: 'MY00$id', outcome: MoveOutcome.moved)
            ]);
  });

  Future<VesselChangesCubit> loaded(VesselChanges first, {VesselChanges? after}) async {
    var calls = 0;
    when(() => api.list(scope: any(named: 'scope'))).thenAnswer((_) async => calls++ == 0 ? first : (after ?? first));
    final cubit = VesselChangesCubit(api);
    await cubit.load();
    return cubit;
  }

  void selectAll(VesselChangesCubit c) => c.selectAll(c.state.data!.groups.single, true);

  group('cubit: update (3.1)', () {
    test('three off legs: one request with oeta and oetd only, then reload and they are gone', () async {
      final cubit = await loaded(changes([offJob(1), offJob(2), offJob(3)]), after: changes(const []));
      selectAll(cubit);

      await cubit.update(cubit.state.data!.groups.single);

      verify(() => api.applyTimes(
          leg: 'OFF', saleOrderIds: [1, 2, 3], eta: '2026-10-11T02:00', etd: '2026-10-12T17:00')).called(1);
      verifyNever(() => api.movePickupDelivery(
          ptpVesselCallId: any(named: 'ptpVesselCallId'), saleOrderIds: any(named: 'saleOrderIds')));
      verify(() => api.list(scope: 'me')).called(2);
      expect(cubit.state.data!.isEmpty, isTrue);
      expect(cubit.state.notes.first, 'Updated 3 jobs.');
    });

    test('one leg type and PTP time pair per request', () async {
      final other = {...offJob(4), 'ptpEtd': '2026-10-13T08:00'};
      final cubit = await loaded(changes([offJob(1), jobJson(id: 2), other]));
      selectAll(cubit);

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
      selectAll(cubit);

      await cubit.update(cubit.state.data!.groups.single);

      expect(cubit.state.notes, ['Updated 1 job.', 'MY002: not updated - Job is closed']);
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

  group('cubit: pickup and delivery, boarding month (3.2)', () {
    test('ETA moving to 15 Oct sends the move (14 Oct suggested) after the ETA update', () async {
      final cubit = await loaded(changes([jobJson(id: 51234)]));
      expect(cubit.state.data!.groups.single.jobs.single.suggestedPickupDate, '2026-10-14T09:00');
      selectAll(cubit);

      await cubit.update(cubit.state.data!.groups.single);

      verifyInOrder([
        () => api.applyTimes(leg: 'LOADING', saleOrderIds: [51234], eta: '2026-10-15T08:00', etd: '2026-10-16T17:00'),
        () => api.movePickupDelivery(ptpVesselCallId: 412, saleOrderIds: [51234]),
      ]);
    });

    test('a PLANNED job is updated but never in the move request, and says re-plan in Planning', () async {
      final cubit = await loaded(changes([jobJson(id: 1), jobJson(id: 2, reason: 'PLANNED', suggestedPickup: null)]));
      selectAll(cubit);

      await cubit.update(cubit.state.data!.groups.single);

      verify(() => api.applyTimes(leg: 'LOADING', saleOrderIds: [1, 2], eta: any(named: 'eta'), etd: any(named: 'etd')))
          .called(1);
      verify(() => api.movePickupDelivery(ptpVesselCallId: 412, saleOrderIds: [1])).called(1);
      expect(cubit.state.notes, contains('MY002: Planned for 12 Oct 09:00, re-plan in Planning'));
    });

    test('with the box off no move request is sent', () async {
      final cubit = await loaded(changes([jobJson(id: 1)]));
      cubit.setMovePickupDelivery(false);
      selectAll(cubit);

      await cubit.update(cubit.state.data!.groups.single);

      verify(() => api.applyTimes(leg: 'LOADING', saleOrderIds: [1], eta: any(named: 'eta'), etd: any(named: 'etd')))
          .called(1);
      verifyNever(() => api.movePickupDelivery(
          ptpVesselCallId: any(named: 'ptpVesselCallId'), saleOrderIds: any(named: 'saleOrderIds')));
    });

    test('a job whose ETA update was refused is not moved', () async {
      when(() => api.applyTimes(
              leg: any(named: 'leg'), saleOrderIds: any(named: 'saleOrderIds'), eta: any(named: 'eta'), etd: any(named: 'etd')))
          .thenAnswer((_) async => const BulkUpdateResult(requested: 2, updated: 1, skipped: 1, results: [
                BulkJobResult(saleOrderId: 1, jobNo: 'MY001', ok: true),
                BulkJobResult(saleOrderId: 2, jobNo: 'MY002', ok: false, message: 'Locked'),
              ]));
      final cubit = await loaded(changes([jobJson(id: 1), jobJson(id: 2)]));
      selectAll(cubit);

      await cubit.update(cubit.state.data!.groups.single);

      verify(() => api.movePickupDelivery(ptpVesselCallId: 412, saleOrderIds: [1])).called(1);
    });

    test('a move the server refuses is named with its reason', () async {
      when(() => api.movePickupDelivery(
              ptpVesselCallId: any(named: 'ptpVesselCallId'), saleOrderIds: any(named: 'saleOrderIds')))
          .thenAnswer((_) async => const [MoveResult(saleOrderId: 1, jobNo: 'MY001', outcome: MoveOutcome.collected)]);
      final cubit = await loaded(changes([jobJson(id: 1)]));
      selectAll(cubit);

      await cubit.update(cubit.state.data!.groups.single);

      expect(cubit.state.notes, contains('MY001: pickup and delivery not moved - Already collected'));
    });

    test('FAILED and an outcome the app does not know are named too', () async {
      when(() => api.movePickupDelivery(
              ptpVesselCallId: any(named: 'ptpVesselCallId'), saleOrderIds: any(named: 'saleOrderIds')))
          .thenAnswer((_) async => const [
                MoveResult(saleOrderId: 1, jobNo: 'MY001', outcome: MoveOutcome.failed),
                MoveResult(saleOrderId: 2, jobNo: 'MY002', outcome: 'SOMETHING_NEW'),
              ]);
      final cubit = await loaded(changes([jobJson(id: 1), jobJson(id: 2)]));
      selectAll(cubit);

      await cubit.update(cubit.state.data!.groups.single);

      expect(cubit.state.notes, containsAll([
        'MY001: pickup and delivery not moved - Failed, nothing changed',
        'MY002: pickup and delivery not moved - SOMETHING_NEW',
      ]));
    });

    test('an unconfirmed boarding month row is held; the others update; confirming lets it through', () async {
      final flagged = jobJson(id: 2, boardingFrom: '2026-10', boardingTo: '2026-11');
      final cubit = await loaded(changes([jobJson(id: 1), flagged]), after: changes([flagged]));
      selectAll(cubit);

      await cubit.update(cubit.state.data!.groups.single);

      verify(() => api.applyTimes(leg: 'LOADING', saleOrderIds: [1], eta: any(named: 'eta'), etd: any(named: 'etd')))
          .called(1);
      expect(cubit.state.notes,
          contains('MY002 waits for confirmation: boarding pay moves from Oct 2026 to Nov 2026'));
      expect(cubit.state.selected, hasLength(1), reason: 'the held row stays selected');

      final g = cubit.state.data!.groups.single;
      cubit.confirmBoarding(g, g.jobs.single);
      await cubit.update(g);

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
    Future<void> pump(WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: VesselChangesPage(api: api)));
      await tester.pumpAndSettle();
    }

    testWidgets('every employee has "Read PTP now" in the top bar', (tester) async {
      when(() => api.list(scope: any(named: 'scope'))).thenAnswer((_) async => changes([offJob(1)]));
      when(() => api.readPtpNow()).thenAnswer((_) async => const PtpReadResult(ok: true, rows: 224, changes: 0));
      await pump(tester);

      await tester.tap(find.byKey(const Key('read_ptp_now')));
      await tester.pumpAndSettle();

      verify(() => api.readPtpNow()).called(1);
      expect(find.text('PTP read: 224 vessel calls, 0 changes'), findsOneWidget);
    });

    testWidgets('one moved vessel: one group, five off legs, Maleva against PTP', (tester) async {
      when(() => api.list(scope: any(named: 'scope')))
          .thenAnswer((_) async => changes([for (var i = 1; i <= 5; i++) offJob(i)]));
      await pump(tester);

      expect(find.text('MAERSK RIO NEGRO 641S'), findsOneWidget);
      expect(find.text('ETA 10 Oct 06:30  →  PTP 11 Oct 02:00 est.'), findsNWidgets(5));
      expect(find.text('Dismiss'), findsNWidgets(5));
      expect(find.text('My jobs'), findsOneWidget);
      expect(find.text('My team'), findsOneWidget);
      final move = tester.widget<SwitchListTile>(find.byKey(const Key('move_pickup_delivery')));
      expect(move.value, isTrue, reason: '"Also move pickup and delivery" is on by default');
    });

    testWidgets('a loading row shows the suggested pickup; a planned one its reason; a flagged one asks', (tester) async {
      when(() => api.list(scope: any(named: 'scope'))).thenAnswer((_) async => changes([
            jobJson(id: 1),
            jobJson(id: 2, reason: 'PLANNED', suggestedPickup: null),
            jobJson(id: 3, boardingFrom: '2026-10', boardingTo: '2026-11'),
          ]));
      await pump(tester);

      expect(find.text('Pickup 12 Oct 09:00 → 14 Oct 09:00 · Delivery 12 Oct 15:00 → 14 Oct 15:00'), findsNWidgets(2));
      expect(find.text('Planned for 12 Oct 09:00, re-plan in Planning'), findsOneWidget);
      expect(find.text('Boarding pay moves from Oct 2026 to Nov 2026'), findsOneWidget);
      expect(find.byKey(const ValueKey('confirm_412|3|LOADING')), findsOneWidget);
    });

    testWidgets('selecting and updating reloads; the error state has a retry', (tester) async {
      var calls = 0;
      when(() => api.list(scope: any(named: 'scope'))).thenAnswer((_) async {
        calls++;
        if (calls == 2) throw const ApiFailure('Server error occurred. (500)');
        return calls == 1 ? changes([offJob(1)]) : changes(const []);
      });
      await pump(tester);

      await tester.tap(find.byType(Checkbox).last);
      await tester.pump();
      await tester.tap(find.text('Update these jobs (1)'));
      await tester.pumpAndSettle();

      expect(find.text('Server error occurred. (500)'), findsOneWidget);
      expect(find.text('Updated 1 job.'), findsOneWidget);
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
