import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/features/planning/bloc/create_all_rti_cubit.dart';
import 'package:maleva/features/planning/bloc/sale_order_update_cubit.dart';
import 'package:maleva/features/planning/data/sale_order_update.dart';
import 'package:maleva/features/planning/models/rti_batch.dart';
import 'package:mocktail/mocktail.dart';

import 'plan_test_support.dart';

void main() {
  setUpAll(() => registerFallbackValue(<String, dynamic>{}));

  late MockPlanningRepository repo;
  setUp(() => repo = stubbedRepo());

  RtiBatchPreview preview({int driver = 85}) => RtiBatchPreview(planningId: 752, planningNo: 'PL000000752', plannedJobs: 3, groups: [
        RtiBatchGroup(groupKey: 'a', truckRefId: 64, truckName: 'WA 1234', driverRefId: driver, driverName: 'ALI', driverSource: 'PLAN', jobs: const [
          RtiBatchJob(saleOrderMasterRefId: 101),
          RtiBatchJob(saleOrderMasterRefId: 102),
        ]),
        const RtiBatchGroup(groupKey: 'b', truckRefId: 13, driverRefId: 0, driverSource: 'NONE', jobs: [RtiBatchJob(saleOrderMasterRefId: 103)]),
      ]);

  group('Create All RTI (useCreateAllRti)', () {
    blocTest<CreateAllRtiCubit, CreateAllRtiState>('opens with the jobs that already have an RTI included; a group with a driver starts ticked',
        setUp: () => when(() => repo.batchPreview(752, includeExisting: true)).thenAnswer((_) async => preview()),
        build: () => CreateAllRtiCubit(repo: repo, planningId: 752),
        act: (c) => c.open(),
        verify: (c) {
          expect(c.state.stage, CreateAllStage.review);
          expect(c.state.includeExisting, isTrue);
          expect([c.state.choices['a']!.selected, c.state.choices['b']!.selected], [true, false]);
          expect([c.state.tally.trucks, c.state.tally.jobs, c.state.tally.needingDriver, c.state.tally.leftOut], [1, 2, 1, 1]);
        });

    blocTest<CreateAllRtiCubit, CreateAllRtiState>('a failed first read: the web fallback "Could not read the plan."',
        setUp: () => when(() => repo.batchPreview(752, includeExisting: true)).thenThrow(Exception()),
        build: () => CreateAllRtiCubit(repo: repo, planningId: 752),
        act: (c) => c.open(),
        verify: (c) => expect([c.state.stage, c.state.error], [CreateAllStage.failed, 'Could not read the plan.']));

    blocTest<CreateAllRtiCubit, CreateAllRtiState>('"Skip jobs that already have an RTI" reads the plan again; a failure puts the switch back',
        setUp: () {
          when(() => repo.batchPreview(752, includeExisting: true)).thenAnswer((_) async => preview());
          when(() => repo.batchPreview(752, includeExisting: false)).thenThrow(const ApiFailure('Plan is locked'));
        },
        build: () => CreateAllRtiCubit(repo: repo, planningId: 752),
        act: (c) async {
          await c.open();
          await c.setSkipExisting(true);
        },
        verify: (c) {
          verify(() => repo.batchPreview(752, includeExisting: false)).called(1);
          expect([c.state.includeExisting, c.state.stage, c.state.error], [true, CreateAllStage.review, 'Plan is locked']);
        });

    blocTest<CreateAllRtiCubit, CreateAllRtiState>('a picked driver clears the outside name; no driver unticks the group',
        setUp: () => when(() => repo.batchPreview(752, includeExisting: true)).thenAnswer((_) async => preview()),
        build: () => CreateAllRtiCubit(repo: repo, planningId: 752),
        act: (c) async {
          await c.open();
          c.pickDriver('b', 27, 'KUMAR');
          c.tick('b', true);
          c.pickDriver('a', 0, '');
        },
        verify: (c) {
          expect(c.state.choices['b'], const GroupChoice(selected: true, driverRefId: 27, driverName: 'KUMAR'));
          expect(c.state.choices['a']!.selected, isFalse);
        });

    blocTest<CreateAllRtiCubit, CreateAllRtiState>('nothing ticked: "Tick at least one truck to create."',
        setUp: () => when(() => repo.batchPreview(752, includeExisting: true)).thenAnswer((_) async => preview(driver: 0)),
        build: () => CreateAllRtiCubit(repo: repo, planningId: 752),
        act: (c) async {
          await c.open();
          await c.confirm(companyId: 6, employeeId: 15);
        },
        verify: (c) {
          expect(c.state.error, 'Tick at least one truck to create.');
          verifyNever(() => repo.batchCreate(any(), any()));
        });

    blocTest<CreateAllRtiCubit, CreateAllRtiState>('creates the ticked groups; duplicates allowed while existing jobs are included',
        setUp: () {
          when(() => repo.batchPreview(752, includeExisting: true)).thenAnswer((_) async => preview());
          when(() => repo.batchCreate(752, any())).thenAnswer(
              (_) async => const RtiBatchResult(jobsCreated: 2, created: [RtiBatchCreated(rtiId: 5, rtiNo: 'RTI5', truckRefId: 64, jobCount: 2)]));
        },
        build: () => CreateAllRtiCubit(repo: repo, planningId: 752),
        act: (c) async {
          await c.open();
          await c.confirm(companyId: 6, employeeId: 15);
        },
        verify: (c) {
          final sent = verify(() => repo.batchCreate(752, captureAny())).captured.single as Map<String, dynamic>;
          expect([sent['companyRefId'], sent['employeeRefId'], sent['allowDuplicates']], [6, 15, true]);
          expect((sent['groups'] as List).single['saleOrderMasterRefIds'], [101, 102]);
          expect([c.state.stage, c.state.resultMessage], [CreateAllStage.done, '1 RTI created for 2 jobs']);
        });

    blocTest<CreateAllRtiCubit, CreateAllRtiState>(
        'a failed create keeps the review and says why (fallback "Could not create the RTI for this plan.")',
        setUp: () {
          when(() => repo.batchPreview(752, includeExisting: true)).thenAnswer((_) async => preview());
          when(() => repo.batchCreate(752, any())).thenThrow(Exception());
        },
        build: () => CreateAllRtiCubit(repo: repo, planningId: 752),
        act: (c) async {
          await c.open();
          await c.confirm(companyId: 6, employeeId: 15);
        },
        verify: (c) => expect([c.state.stage, c.state.error], [CreateAllStage.review, 'Could not create the RTI for this plan.']));
  });

  group('Update sale order (UpdateSaleOrderModal)', () {
    const draft = SaleOrderDraft(
        saleOrderId: 21507, orderNo: 'TR1', origin: 'KLANG', pickups: [StopRow(key: 'pickup-1', dbId: 11, address: 'A')], loadedPickupIds: [11]);

    blocTest<SaleOrderUpdateCubit, SaleOrderUpdateState>('a failed load: the message for "Unable to load the selected sale order."',
        setUp: () => when(() => repo.saleOrderDraft(21507)).thenThrow(Exception()),
        build: () => SaleOrderUpdateCubit(repo: repo, saleOrderId: 21507),
        act: (c) => c.load(),
        verify: (c) => expect([c.state.stage, c.state.error], [UpdateStage.failed, 'Failed to load sale order details.']));

    blocTest<SaleOrderUpdateCubit, SaleOrderUpdateState>('no order: "Unable to prepare the sale order update form."',
        setUp: () => when(() => repo.saleOrderDraft(21507)).thenAnswer((_) async => null),
        build: () => SaleOrderUpdateCubit(repo: repo, saleOrderId: 21507),
        act: (c) => c.load(),
        verify: (c) => expect(c.state.error, 'Unable to prepare the sale order update form.'));

    blocTest<SaleOrderUpdateCubit, SaleOrderUpdateState>('saves the edited form for this job; the server message is shown',
        setUp: () {
          when(() => repo.saleOrderDraft(21507)).thenAnswer((_) async => draft);
          when(() => repo.updateSaleOrder(any())).thenAnswer((_) async => {'ok': true, 'saleOrderId': 21507, 'message': ''});
        },
        build: () => SaleOrderUpdateCubit(repo: repo, saleOrderId: 21507),
        act: (c) async {
          await c.load();
          c.edit((d) => d.copyWith(origin: 'PORT KLANG', originRefId: ''));
          c.removeStop('pickup-1', pickup: true);
          await c.save();
        },
        verify: (c) {
          final sent = verify(() => repo.updateSaleOrder(captureAny())).captured.single as Map<String, dynamic>;
          expect([
            sent['saleOrderId'],
            sent['companyId'],
            sent['employeeId'],
            sent['origin'],
            sent['removedPickupIds']
          ], [
            21507,
            6,
            15,
            'PORT KLANG',
            [11]
          ]);
          expect([c.state.stage, c.state.message], [UpdateStage.saved, 'Sale order updated successfully']);
        });

    blocTest<SaleOrderUpdateCubit, SaleOrderUpdateState>('a job that did not finish loading is refused; a failed save says "Update Failed"',
        setUp: () {
          when(() => repo.saleOrderDraft(21507)).thenAnswer((_) async => draft);
          when(() => repo.updateSaleOrder(any())).thenThrow(Exception());
        },
        build: () => SaleOrderUpdateCubit(repo: repo, saleOrderId: 21507),
        act: (c) async {
          expect(c.saveRefusal(), 'This job did not finish loading. Close and reopen it before saving.');
          await c.load();
          await c.save();
        },
        verify: (c) => expect([c.state.stage, c.state.message], [UpdateStage.ready, 'Update Failed']));

    test('a row without a sale order: "Sale order details are missing."', () {
      expect(SaleOrderUpdateCubit(repo: repo, saleOrderId: 0).saveRefusal(), 'Sale order details are missing.');
    });
  });
}
