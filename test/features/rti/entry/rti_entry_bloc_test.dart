import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/features/rti/bloc/rti_entry_bloc.dart';
import 'package:maleva/features/rti/models/planning_transfer_item.dart';
import 'package:maleva/features/rti/models/rti_form.dart';
import 'package:mocktail/mocktail.dart';

import 'rti_mocks.dart';

const _today = RtiForm(rtiDate: '2026-10-05');

Map<String, dynamic> savedMaster({int id = 44}) => {
      'id': id, 'cnumberDisplay': 'RTI000000044', 'saleDate': '2026-10-02T00:00:00', 'driverRefId': 5, 'truckRefId': 72, 'amount': 120,
      'destination': 'PTP', 'routeActivities': [
        {'id': 3, 'sequenceNo': 1, 'activityType': 'SEAL,BREAK_SEAL', 'fullRoute': 'PTP'},
      ],
    };

final _lines = [
  {'id': 9, 'saleOrderMasterRefId': 20498, 'salary': 120, 'jobNo': 'TR1', 'customerName': 'ACME', 'originD': 'PKG', 'destinationD': 'KL', 'deliveryDateD': '2026-10-03T00:00:00'},
];

void main() {
  setUpAll(() => registerFallbackValue(<String, dynamic>{}));

  group('push prefill (PT2)', () {
    blocTest<RtiEntryBloc, RtiEntryState>(
      'truck and driver from the first item, an outside name in both outside fields, one row per item, the toast',
      build: () => RtiEntryBloc(repository: mockRepository().repo, initialForm: () => _today),
      act: (b) => b.add(const RtiEntryStarted(fromPlanning: [
        PlanningTransferItem(saleOrderMasterRefId: 1, jobNo: 'TR1', truckRefId: 72, driverName: 'Ahmad', isOutsideDriver: true),
        PlanningTransferItem(saleOrderMasterRefId: 2, jobNo: 'TR2', truckRefId: 99),
      ])),
      verify: (b) {
        final s = b.state;
        expect([s.form.truckRefId, s.form.driverRefId, s.form.outsideDriver, s.form.outsideTruck], ['72', '', 'Ahmad', 'Ahmad']);
        expect(s.grid.map((r) => r.saleOrderMasterRefId), [1, 2]);
        expect(s.form.rtiNo, 'RTI000000101');
        expect(s.stops, isEmpty);
      },
      expect: () => contains(isA<RtiEntryState>().having((s) => s.notice?.text, 'notice', 'Loaded 2 planning orders into RTI')),
    );

    blocTest<RtiEntryBloc, RtiEntryState>(
      'one item says "order"',
      build: () => RtiEntryBloc(repository: mockRepository().repo),
      act: (b) => b.add(const RtiEntryStarted(fromPlanning: [PlanningTransferItem(saleOrderMasterRefId: 1, driverRefId: 5)])),
      expect: () => contains(isA<RtiEntryState>().having((s) => s.notice?.text, 'notice', 'Loaded 1 planning order into RTI')),
    );
  });

  group('save', () {
    blocTest<RtiEntryBloc, RtiEntryState>(
      'shows every problem together and goes to Review',
      build: () => RtiEntryBloc(repository: mockRepository().repo, initialForm: () => _today),
      act: (b) => b.add(const RtiSaveRequested()),
      verify: (b) {
        expect(b.state.errors, ['Please select Driver Name', 'Please select Vehicle Number', 'Row 1: Job No is required']);
        expect(b.state.step, 4);
      },
    );

    blocTest<RtiEntryBloc, RtiEntryState>(
      'a driver login cannot save',
      build: () => RtiEntryBloc(repository: mockRepository(session: const FixedSession(employeeId: 0)).repo),
      act: (b) => b.add(const RtiSaveRequested()),
      verify: (b) => expect(b.state.notice!.text, 'Employee login is required before saving RTI.'),
    );

    test('a new RTI: POST once (double save ignored), then the saved RTI opens in edit', () async {
      final m = mockRepository();
      var posts = 0;
      when(() => m.api.save(any(), any(), routeActivities: any(named: 'routeActivities'))).thenAnswer((_) async {
        posts++;
        await Future<void>.delayed(const Duration(milliseconds: 20));
        return {'id': 44};
      });
      when(() => m.api.load(44)).thenAnswer((_) async => (master: savedMaster(), lines: _lines));
      when(() => m.lookup.saleOrder(any())).thenThrow(Exception('offline'));
      final b = RtiEntryBloc(repository: m.repo, initialForm: () => _today.copyWith(driverRefId: '5', truckRefId: '72'));
      b.add(const RtiJobCellEdited(0, 'JobNo', 'TR1'));
      await Future<void>.delayed(Duration.zero);
      b.emit(b.state.copyWith(grid: [b.state.grid.first.copyWith(saleOrderMasterRefId: 20498, salary: '120')]));
      b.add(const RtiSaveRequested());
      b.add(const RtiSaveRequested());
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(posts, 1);
      expect(b.state.form.editId, 44);
      expect(b.state.stops.single.jobType, 'SEAL_AND_BREAK');
      expect(b.state.notice!.text, 'RTI saved successfully');
      await b.close();
    });

    test('an edit is retried up to twice, then the server message shows', () async {
      final m = mockRepository();
      var puts = 0;
      when(() => m.api.save(any(), any(), routeActivities: any(named: 'routeActivities'))).thenAnswer((_) async {
        puts++;
        throw const ApiFailure('Truck is inactive');
      });
      final b = RtiEntryBloc(repository: m.repo, initialForm: () => _today.copyWith(driverRefId: '5', truckRefId: '72', editId: 44));
      b.emit(b.state.copyWith(grid: [b.state.grid.first.copyWith(jobNo: 'TR1', saleOrderMasterRefId: 1)]));
      b.add(const RtiSaveRequested());
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(puts, 3);
      expect(b.state.notice!.text, 'Truck is inactive');
      expect(b.state.busy, RtiBusy.none);
      await b.close();
    });
  });

  group('delete', () {
    blocTest<RtiEntryBloc, RtiEntryState>(
      'no saved RTI → "No RTI selected for delete."',
      build: () => RtiEntryBloc(repository: mockRepository().repo),
      act: (b) => b.add(const RtiDeleteRequested()),
      verify: (b) => expect(b.state.notice!.text, 'No RTI selected for delete.'),
    );

    test('deletes, says so and clears to a new RTI with the next number', () async {
      final m = mockRepository();
      when(() => m.api.delete(44)).thenAnswer((_) async {});
      final b = RtiEntryBloc(repository: m.repo, initialForm: () => _today);
      b.emit(b.state.copyWith(form: _today.copyWith(editId: 44, rtiNo: 'RTI000000044')));
      final notices = <String>[];
      final sub = b.stream.listen((s) => s.notice == null ? null : notices.add(s.notice!.text));
      b.add(const RtiDeleteRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      verify(() => m.api.delete(44)).called(1);
      expect(notices, contains('RTI deleted successfully'));
      expect([b.state.form.editId, b.state.form.rtiNo], [0, 'RTI000000101']);
      await sub.cancel();
      await b.close();
    });

    test('a refusal keeps the RTI: the fallback text when the server says nothing', () async {
      final m = mockRepository();
      when(() => m.api.delete(44)).thenThrow(const ApiFailure(''));
      final b = RtiEntryBloc(repository: m.repo, initialForm: () => _today.copyWith(editId: 44));
      b.add(const RtiDeleteRequested());
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(b.state.notice!.text, 'Failed to delete RTI.');
      expect(b.state.form.editId, 44);
      await b.close();
    });
  });
}
