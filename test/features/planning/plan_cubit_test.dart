import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/features/planning/bloc/plan_cubit.dart';
import 'package:maleva/features/planning/bloc/plan_state.dart';
import 'package:maleva/features/planning/models/fleet_options.dart';
import 'package:maleva/features/planning/models/plan_header.dart';
import 'package:maleva/features/planning/models/plan_line.dart';
import 'package:maleva/features/rti/data/rti_from_planning.dart';
import 'package:mocktail/mocktail.dart';

import 'plan_test_support.dart' hide line;

void main() {
  setUpAll(() => registerFallbackValue(<String, dynamic>{}));

  late MockPlanningRepository repo;
  late FakeRtiFromPlanning rti;
  final clock = DateTime(2026, 10, 5, 9);
  const header = PlanHeader(planningNo: 'PL000000783', planningDate: '2026-10-05', pickupFromDate: '2026-10-05', pickupToDate: '2026-10-05');
  const all = {'VIEW', 'CREATE', 'EDIT', 'DELETE'};

  setUp(() {
    repo = stubbedRepo();
    rti = FakeRtiFromPlanning();
  });

  PlanCubit build() => PlanCubit(repo: repo, rtiFromPlanning: rti, clock: () => clock);
  PlanState seeded({List<PlanLine> rows = const [], int editId = 0, Set<String> actions = all, int? selected}) => PlanState(
      phase: PlanPhase.ready,
      actions: actions,
      editId: editId,
      header: header,
      rows: rows,
      selectedUid: selected,
      trucks: const [TruckOption(id: 64, name: 'WA 1234'), TruckOption(id: 13, name: 'WB 8020')],
      drivers: const [DriverOption(id: 85, name: 'ALI-0123'), DriverOption(id: 36, name: 'OUTSIDE DRIVER')]);
  String? lastNotice(PlanCubit c) => c.state.notice?.message;

  group('start', () {
    blocTest<PlanCubit, PlanState>('a new plan: actions, pickers, then the next number',
        build: build,
        act: (c) => c.start(),
        verify: (c) {
          expect(c.state.phase, PlanPhase.ready);
          expect(c.state.actions, all);
          expect(c.state.trucks, hasLength(2));
          expect(c.state.header.planningNo, 'PL000000783');
          expect(
              [c.state.header.planningDate, c.state.header.pickupFromDate, c.state.header.pickupToDate], ['2026-10-05', '2026-10-05', '2026-10-05']);
        });

    blocTest<PlanCubit, PlanState>('a failed Screen Access read leaves VIEW only (the web default)',
        setUp: () => when(() => repo.access()).thenThrow(const ApiFailure('x')),
        build: build,
        act: (c) => c.start(),
        verify: (c) => expect([c.state.access.canView, c.state.access.canWrite], [true, false]));

    blocTest<PlanCubit, PlanState>('employees failing: the error screen and the web toast',
        setUp: () => when(() => repo.employees()).thenThrow(const ApiFailure('down')),
        build: build,
        act: (c) => c.start(),
        verify: (c) {
          expect(c.state.phase, PlanPhase.employeesFailed);
          expect(lastNotice(c), 'Failed to load employees. Please refresh.');
        });
  });

  group('search', () {
    blocTest<PlanCubit, PlanState>('refuses without criteria and calls nothing',
        build: build,
        seed: () => seeded().copyWith(header: const PlanHeader(planningDate: '2026-10-05')),
        act: (c) => c.search(),
        verify: (c) {
          expect(c.state.searchError, 'Please enter at least one search criteria');
          expect(lastNotice(c), 'Please enter at least one search criteria');
          verifyNever(() => repo.search(any()));
        });

    blocTest<PlanCubit, PlanState>('refuses without a plan date first',
        build: build,
        seed: () => seeded().copyWith(header: const PlanHeader(searchText: 'PKG')),
        act: (c) => c.search(),
        verify: (c) => expect(c.state.searchError, 'Please select a Planning Date'));

    blocTest<PlanCubit, PlanState>('a new plan: the web payload, the rows replaced, the web message',
        setUp: () => when(() => repo.search(any())).thenAnswer((_) async => [line(1), line(2)]),
        build: build,
        seed: () => seeded(rows: [line(9)]).copyWith(header: header.copyWith(searchText: ' PKG ', employee: '12')),
        act: (c) => c.search(),
        verify: (c) {
          verify(() => repo.search({'comid': 6, 'search': 'PKG', 'employeeid': 12, 'fromdate': '2026-10-05', 'todate': '2026-10-05'})).called(1);
          expect(c.state.rows.map((r) => r.saleOrderMasterRefId), [1, 2]);
          expect(lastNotice(c), 'Planning data loaded successfully');
          expect(c.state.searching, isFalse);
        });

    blocTest<PlanCubit, PlanState>('a saved plan merges (K2): kept rows keep truck, driver, remarks, sort and tick',
        setUp: () =>
            when(() => repo.search(any())).thenAnswer((_) async => [line(1, truck: 'NEW', truckId: 13), line(3, truck: 'WB 8020', truckId: 13)]),
        build: build,
        seed: () =>
            seeded(editId: 752, rows: [line(1, truck: 'WA 1234', truckId: 64, driver: 'ALI-0123', driverId: 85, tick: true, sort: '2'), line(2)]),
        act: (c) => c.search(),
        verify: (c) {
          final rows = c.state.rows;
          expect(rows.map((r) => r.saleOrderMasterRefId), [1, 2, 3]);
          expect([rows[0].truckName, rows[0].driverName, rows[0].print, rows[0].sortByD], ['WA 1234', 'ALI-0123', true, '2']);
          expect([rows[2].truckName, rows[2].truckRefid], ['', 0]);
          expect(lastNotice(c), 'Planning data loaded successfully (1 added · 1 refreshed)');
        });

    blocTest<PlanCubit, PlanState>('a failure shows the server message and clears the grid, as the web does',
        setUp: () => when(() => repo.search(any())).thenThrow(const ApiFailure('Bad search')),
        build: build,
        seed: () => seeded(rows: [line(1)]).copyWith(header: header.copyWith(searchText: 'PKG')),
        act: (c) => c.search(),
        verify: (c) {
          expect(c.state.rows, isEmpty);
          expect(c.state.notice!.kind, NoticeKind.error);
          expect(lastNotice(c), 'Bad search');
        });
  });

  group('load', () {
    blocTest<PlanCubit, PlanState>('"Planning data not found" when the answer holds no plan',
        setUp: () => when(() => repo.load(id: any(named: 'id'), planningNo: any(named: 'planningNo'))).thenAnswer((_) async => null),
        build: build,
        seed: seeded,
        act: (c) => c.loadPlan(id: 5),
        verify: (c) => expect(lastNotice(c), 'Planning data not found'));

    blocTest<PlanCubit, PlanState>('PLAN NO: the digits of PL000000782; an empty box does nothing',
        setUp: () => when(() => repo.load(id: any(named: 'id'), planningNo: any(named: 'planningNo')))
            .thenAnswer((_) async => LoadedPlan(editId: 752, header: const {'planningNo': '782'}, lines: [line(1)])),
        build: build,
        seed: seeded,
        act: (c) async {
          await c.openPlanNumber('');
          await c.openPlanNumber('PL000000782');
        },
        verify: (c) {
          verify(() => repo.load(id: null, planningNo: 782)).called(1);
          expect([c.state.editId, c.state.header.planningNo], [752, '782']);
          expect(c.state.access.mode.name, 'edit');
        });

    blocTest<PlanCubit, PlanState>('reading the same plan again keeps the rows with unsaved edits (PV8)',
        setUp: () => when(() => repo.load(id: any(named: 'id'), planningNo: any(named: 'planningNo')))
            .thenAnswer((_) async => LoadedPlan(editId: 752, header: const {}, lines: [line(1, remarks: 'server'), line(2, remarks: 'server')])),
        build: build,
        seed: () => seeded(editId: 752, rows: [line(1), line(2)]),
        act: (c) async {
          c.editRemarks(c.state.rows.first.uid, 'mine');
          await c.loadPlan(id: 752);
        },
        verify: (c) => expect(c.state.rows.map((r) => r.remarks), ['mine', 'server']));
  });

  group('save', () {
    blocTest<PlanCubit, PlanState>('no valid row: the web refusal, nothing sent',
        build: build,
        seed: () => seeded(rows: [line(0)]),
        act: (c) => c.save(),
        verify: (c) {
          expect(lastNotice(c), 'Please add at least one valid row in the table before saving');
          verifyNever(() => repo.save(any()));
        });

    blocTest<PlanCubit, PlanState>('a view-only role is told why',
        build: build,
        seed: () => seeded(rows: [line(1)], actions: const {'VIEW'}),
        act: (c) => c.save(),
        verify: (c) => expect(lastNotice(c), 'View only: your role cannot create a plan.'));

    blocTest<PlanCubit, PlanState>('a new plan: the exact payload, one success message, then the plan is read in place',
        setUp: () {
          when(() => repo.save(any())).thenAnswer((_) async => {'ok': true, 'message': '', 'id': 900});
          when(() => repo.load(id: any(named: 'id'), planningNo: any(named: 'planningNo')))
              .thenAnswer((_) async => LoadedPlan(editId: 900, header: const {'planningNo': '783'}, lines: [line(1)]));
        },
        build: build,
        seed: () => seeded(rows: [line(1, truck: 'WA 1234', truckId: 64, driver: 'ALI-0123', driverId: 85)]),
        act: (c) async {
          final first = c.save();
          final second = await c.save(); // a second tap while saving is ignored
          expect(second, isFalse);
          await first;
        },
        verify: (c) {
          final sent = verify(() => repo.save(captureAny())).captured.single as Map<String, dynamic>;
          expect(sent['id'], 0);
          expect(sent['cNumberDisplay'], 'PL000000783');
          expect(sent['cNumber'], 783);
          expect(sent['saleDate'], '2026/10/05');
          expect((sent['saleDetails'] as List).single['truckRefid'], 64);
          verify(() => repo.load(id: 900, planningNo: null)).called(1);
          expect(c.state.editId, 900);
          expect(c.state.hasChanges, isFalse);
        },
        expect: () => contains(isA<PlanState>().having((s) => s.notice?.message, 'notice', 'Planning saved successfully')));

    blocTest<PlanCubit, PlanState>('a saved plan says "updated"; the server message wins when there is one',
        setUp: () {
          when(() => repo.save(any())).thenAnswer((_) async => {'ok': true, 'id': 752});
          when(() => repo.load(id: any(named: 'id'), planningNo: any(named: 'planningNo')))
              .thenAnswer((_) async => LoadedPlan(editId: 752, header: const {}, lines: [line(1)]));
        },
        build: build,
        seed: () => seeded(editId: 752, rows: [line(1)]),
        act: (c) => c.save(),
        expect: () => contains(isA<PlanState>().having((s) => s.notice?.message, 'notice', 'Planning updated successfully')));

    blocTest<PlanCubit, PlanState>('a refusal shows the server message',
        setUp: () => when(() => repo.save(any())).thenThrow(const ApiFailure('Error saving planning')),
        build: build,
        seed: () => seeded(rows: [line(1)]),
        act: (c) => c.save(),
        verify: (c) {
          expect(lastNotice(c), 'Error saving planning');
          expect(c.state.saving, isFalse);
        });
  });

  group('delete', () {
    blocTest<PlanCubit, PlanState>('nothing to delete on a new plan',
        build: build, seed: seeded, act: (c) => c.canDelete(), verify: (c) => expect(lastNotice(c), 'No planning selected to delete'));

    blocTest<PlanCubit, PlanState>('delete is its own permission',
        build: build,
        seed: () => seeded(editId: 752, actions: const {'VIEW', 'EDIT'}),
        act: (c) => c.delete(),
        verify: (c) {
          expect(lastNotice(c), 'Your role cannot delete a plan.');
          verifyNever(() => repo.delete(any()));
        });

    blocTest<PlanCubit, PlanState>('after the confirm: deleted, then a new plan',
        setUp: () => when(() => repo.delete(752)).thenAnswer((_) async {}),
        build: build,
        seed: () => seeded(editId: 752, rows: [line(1)]),
        act: (c) => c.delete(),
        verify: (c) {
          expect([c.state.editId, c.state.rows.length, c.state.header.planningNo], [0, 0, 'PL000000783']);
          expect(c.state.notice?.message, 'Planning deleted successfully');
        });
  });

  group('rows', () {
    blocTest<PlanCubit, PlanState>('Sort: SORT ascending, 0 / empty last',
        build: build,
        seed: () => seeded(rows: [line(1, sort: ''), line(2, sort: '2'), line(3, sort: '1')]),
        act: (c) => c.sort(),
        verify: (c) => expect(c.state.rows.map((r) => r.saleOrderMasterRefId), [3, 2, 1]));

    blocTest<PlanCubit, PlanState>('Clone: the selected row is copied to the end without its truck',
        build: build,
        seed: () {
          final rows = [line(1, truck: 'WA 1234', truckId: 64, driver: 'ALI-0123', driverId: 85)];
          return seeded(rows: rows, selected: rows.first.uid);
        },
        act: (c) => c.clone(),
        verify: (c) {
          final copy = c.state.rows.last;
          expect(c.state.rows, hasLength(2));
          expect([copy.truckName, copy.truckRefid, copy.driverName, copy.saleOrderMasterRefId], ['', 0, 'ALI-0123', 1]);
          expect(lastNotice(c), 'Row duplicated successfully');
        });

    blocTest<PlanCubit, PlanState>('Clone refusals',
        build: build,
        seed: () => seeded(rows: [line(1)]),
        act: (c) => c.clone(),
        verify: (c) => expect(lastNotice(c), 'Please select a row to duplicate'));

    blocTest<PlanCubit, PlanState>('Remove and reorder',
        build: build,
        seed: () => seeded(rows: [line(1), line(2), line(3)]),
        act: (c) {
          c.reorder(2, 0);
          c.remove(c.state.rows[1].uid);
        },
        verify: (c) {
          expect(c.state.rows.map((r) => r.saleOrderMasterRefId), [3, 2]);
          expect(lastNotice(c), 'Row removed');
          expect(c.state.hasChanges, isTrue);
        });

    blocTest<PlanCubit, PlanState>('picking a truck changes only TRUCK, and only on the chosen rows',
        build: build,
        seed: () => seeded(rows: [line(1, driver: 'ALI-0123', driverId: 85), line(2, driver: 'OTHER', driverId: 9), line(3)]),
        act: (c) => c.assignTruck({c.state.rows[0].uid, c.state.rows[1].uid}, const TruckOption(id: 13, name: 'WB 8020')),
        verify: (c) {
          final r = c.state.rows;
          expect([r[0].truckName, r[0].truckRefid, r[0].driverName, r[0].driverRefid], ['WB 8020', 13, 'ALI-0123', 85]);
          expect([r[1].truckName, r[1].driverName, r[1].driverRefid], ['WB 8020', 'OTHER', 9]);
          expect([r[2].truckName, r[2].truckRefid], ['', 0]);
          expect(c.state.changeCount, 2);
        });

    blocTest<PlanCubit, PlanState>('picking a driver changes only DRIVER; an outside driver keeps the typed name',
        build: build,
        seed: () => seeded(rows: [line(1, truck: 'WA 1234', truckId: 64), line(2, truck: 'OUTSIDE DRIVER', truckId: 22)]),
        act: (c) {
          c.assignDriver({c.state.rows[0].uid}, const DriverOption(id: 85, name: 'ALI-0123'));
          c.assignDriver({c.state.rows[1].uid}, const DriverOption(id: 36, name: 'OUTSIDE DRIVER'), outsideName: 'RAJU');
        },
        verify: (c) {
          final r = c.state.rows;
          expect([r[0].driverName, r[0].driverRefid, r[0].truckName, r[0].truckRefid], ['ALI-0123', 85, 'WA 1234', 64]);
          expect([r[1].driverName, r[1].driverRefid, r[1].truckName], ['RAJU', 36, 'OUTSIDE DRIVER']);
        });

    blocTest<PlanCubit, PlanState>('a typed driver has no id; the X clears every name',
        build: build,
        seed: () => seeded(rows: [line(1, truck: 'WA 1234', truckId: 64, driver: 'ALI-0123', driverId: 85)]),
        act: (c) {
          final uid = c.state.rows.first.uid;
          c.typeDriver({uid}, 'RAJU');
          expect([c.state.rows.first.driverName, c.state.rows.first.driverNameD, c.state.rows.first.driverRefid], ['RAJU', 'RAJU', 0]);
          c.clearTruck({uid});
        },
        verify: (c) => expect([c.state.rows.first.truckName, c.state.rows.first.truckRefid, c.state.rows.first.driverName], ['', 0, 'RAJU']));

    blocTest<PlanCubit, PlanState>('a view-only role cannot tick, assign or sort',
        build: build,
        seed: () => seeded(rows: [line(1)], actions: const {'VIEW'}),
        act: (c) {
          c.toggleTick(c.state.rows.first.uid);
          c.assignTruck({c.state.rows.first.uid}, const TruckOption(id: 13, name: 'WB 8020'));
          c.sort();
        },
        verify: (c) {
          expect([c.state.rows.first.print, c.state.rows.first.truckName], [false, '']);
          expect(lastNotice(c), 'View only: your role cannot create a plan.');
        });

    blocTest<PlanCubit, PlanState>('Update: the refusals before its window',
        build: build,
        seed: () => seeded(rows: [line(0)]),
        act: (c) {
          expect(c.updateRefusal(), 'Please select a row first');
          expect(c.updateRefusal(c.state.rows.first.uid), 'Selected row does not have a sale order to update');
        });
  });

  group('RTI', () {
    blocTest<PlanCubit, PlanState>('Create RTI with nothing ticked: the first refusal (K7), nothing created',
        build: build,
        seed: () => seeded(rows: [line(1)]),
        act: (c) => c.createRti(),
        verify: (c) {
          expect(lastNotice(c), 'Tick the jobs for this RTI first, or use Create All RTI');
          expect(rti.calls, isEmpty);
        });

    blocTest<PlanCubit, PlanState>('Create RTI: one RTI from the ticked rows; they get its number and lose the tick',
        build: build,
        seed: () => seeded(rows: [line(1, tick: true, truck: 'WA 1234', truckId: 64), line(2, tick: true), line(3)]),
        act: (c) => c.createRti(),
        verify: (c) {
          expect(rti.calls.single.map((i) => i.saleOrderMasterRefId), [1, 2]);
          expect(c.state.rows.map((r) => r.rtiNo), ['RTI000000077', 'RTI000000077', '']);
          expect(c.state.rows.map((r) => r.print), [false, false, false]);
          expect(c.state.rtiStage, RtiCreateStage.done);
          expect(lastNotice(c), 'RTI RTI000000077 created with 2 jobs');
        });

    blocTest<PlanCubit, PlanState>('Create RTI refused: the service message, the rows unchanged',
        setUp: () => rti = FakeRtiFromPlanning(error: const RtiCreateRefused('Selected rows have different trucks')),
        build: build,
        seed: () => seeded(rows: [line(1, tick: true)]),
        act: (c) => c.createRti(),
        verify: (c) {
          expect([c.state.rtiStage, c.state.rtiMessage], [RtiCreateStage.refused, 'Selected rows have different trucks']);
          expect(c.state.rows.first.print, isTrue);
        });

    blocTest<PlanCubit, PlanState>('Push RTI and Create All refusals',
        build: build,
        seed: () => seeded(rows: [line(1)]),
        act: (c) {
          expect(c.pushItems(), isNull);
          expect(c.state.notice?.message, 'Please select orders to push to RTI');
          expect(c.createAllPlanId(), isNull);
          expect(c.state.notice?.message, 'Save the plan first, then create its RTI.');
        });

    blocTest<PlanCubit, PlanState>('the RTI badges come from rti-status for the jobs on the plan',
        setUp: () => when(() => repo.rtiStatus(any())).thenAnswer((_) async => [
              {'saleOrderMasterRefId': 2, 'rtiMasterRefId': 40, 'rtiNo': 'RTI40'}
            ]),
        build: build,
        seed: () => seeded(rows: [line(1), line(2)]),
        act: (c) async {
          await c.syncRtiStatuses();
          expect(c.state.rows.map((r) => r.rtiNo), ['', 'RTI40']);
          expect(c.rtiOf(c.state.rows[1]), 40);
          expect(c.rtiOf(c.state.rows[0]), isNull);
          expect(c.state.notice?.message, 'No RTI created for this job yet');
        },
        verify: (c) => verify(() => repo.rtiStatus([1, 2])).called(1));
  });
}

PlanLine line(int so,
        {String truck = '', int truckId = 0, String driver = '', int driverId = 0, bool tick = false, String sort = '', String remarks = ''}) =>
    PlanLine(
      saleOrderMasterRefId: so,
      jobNo: 'TR$so',
      truckName: truck,
      truckRefid: truckId,
      driverName: driver,
      driverRefid: driverId,
      print: tick,
      sortByD: sort,
      remarks: remarks,
      status: 'Pending',
    );
