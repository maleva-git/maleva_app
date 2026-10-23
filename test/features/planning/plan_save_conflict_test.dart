import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/planning/planning_api.dart' show PlanSaveConflict;
import 'package:maleva/features/planning/bloc/plan_cubit.dart';
import 'package:maleva/features/planning/bloc/plan_state.dart';
import 'package:maleva/features/planning/data/planning_save_payload.dart';
import 'package:maleva/features/planning/models/plan_header.dart';
import 'package:mocktail/mocktail.dart';

import 'plan_test_support.dart';

/// Two planners on one plan: a save on an old screen is not silently lost (change plan-save-keeps-changes).
void main() {
  setUpAll(() => registerFallbackValue(<String, dynamic>{}));

  late MockPlanningRepository repo;
  late FakeRtiFromPlanning rti;
  const header = PlanHeader(
      planningNo: 'PL000000752', planningDate: '2026-10-21', pickupFromDate: '2026-10-21', pickupToDate: '2026-10-21', saveVersion: 5);
  const conflict = PlanSaveConflict(changedBy: 'ANNA', changedAt: '21/10/2026 10:05', message: 'Plan changed by ANNA at 21/10/2026 10:05');

  setUp(() {
    repo = stubbedRepo();
    rti = FakeRtiFromPlanning();
  });

  PlanCubit build() => PlanCubit(repo: repo, rtiFromPlanning: rti, clock: () => DateTime(2026, 10, 21, 10, 10));
  PlanState seeded() => PlanState(
      phase: PlanPhase.ready, actions: const {'VIEW', 'CREATE', 'EDIT', 'DELETE'}, editId: 752, header: header, rows: [line(1), line(2)]);

  test('the save sends the version it opened, rows top to bottom, and overwrite only when chosen', () {
    Map<String, dynamic> body({bool overwrite = false, int editId = 752}) => PlanningSavePayload.build(
        companyId: 6, editId: editId, header: header, rows: [line(2), line(1)], userId: 15, employeeId: 15, overwrite: overwrite);
    expect(body()['saveVersion'], 5);
    expect(body().containsKey('overwrite'), isFalse);
    expect(body(overwrite: true)['overwrite'], isTrue);
    expect([for (final d in body()['saleDetails'] as List) d['saleOrderMasterRefId']], [2, 1]);
    expect(body(editId: 0).containsKey('saveVersion'), isFalse);
  });

  test('the edit answer gives the version', () {
    expect(LoadedPlan.fromJava({'Id': 752, 'SaveVersion': 5, 'SaleDetails': []})!.saveVersion, 5);
    expect(LoadedPlan.fromJava({'Id': 752, 'SaleDetails': []})!.saveVersion, isNull);
  });

  blocTest<PlanCubit, PlanState>('a conflict asks; nothing is reloaded or said yet',
      setUp: () => when(() => repo.save(any())).thenThrow(conflict),
      build: build,
      seed: seeded,
      act: (c) => c.save(),
      verify: (c) {
        expect(c.state.conflict?.conflict.who, 'ANNA');
        expect(c.state.saving, isFalse);
        verifyNever(() => repo.load(id: any(named: 'id'), planningNo: any(named: 'planningNo')));
      });

  blocTest<PlanCubit, PlanState>('Reload reads the plan again and says whose changes came in',
      setUp: () {
        when(() => repo.save(any())).thenThrow(conflict);
        when(() => repo.load(id: any(named: 'id'), planningNo: any(named: 'planningNo')))
            .thenAnswer((_) async => LoadedPlan(editId: 752, header: const {}, lines: [line(1), line(2)], saveVersion: 6));
      },
      build: build,
      seed: seeded,
      act: (c) async {
        await c.save();
        await c.resolveConflict(overwrite: false);
      },
      verify: (c) {
        verify(() => repo.load(id: 752, planningNo: null)).called(1);
        expect(c.state.header.saveVersion, 6);
        expect(c.state.notice?.message, startsWith("ANNA's changes are loaded"));
      });

  blocTest<PlanCubit, PlanState>('Save over it sends overwrite',
      setUp: () {
        var calls = 0;
        when(() => repo.save(any())).thenAnswer((_) async {
          if (calls++ == 0) throw conflict;
          return {'ok': true, 'id': 752, 'saveVersion': 7};
        });
        when(() => repo.load(id: any(named: 'id'), planningNo: any(named: 'planningNo')))
            .thenAnswer((_) async => LoadedPlan(editId: 752, header: const {}, lines: [line(1)], saveVersion: 7));
      },
      build: build,
      seed: seeded,
      act: (c) async {
        await c.save();
        await c.resolveConflict(overwrite: true);
      },
      verify: (c) {
        final sent = verify(() => repo.save(captureAny())).captured.cast<Map<String, dynamic>>();
        expect(sent.first.containsKey('overwrite'), isFalse);
        expect(sent.last['overwrite'], isTrue);
        expect(c.state.notice?.message, 'Planning updated successfully');
      });
}
