import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/rti/rti_job_lookup_api.dart';
import 'package:maleva/features/rti/bloc/rti_entry_bloc.dart';
import 'package:maleva/features/rti/data/rti_grid_rules.dart';
import 'package:maleva/features/rti/models/rti_form.dart';
import 'package:maleva/features/rti/models/rti_job_row.dart';
import 'package:mocktail/mocktail.dart';

import 'rti_mocks.dart';

// Q-JOBLOOKUP: R/api/rtiApi.ts:452-531, R/services/rtiService.ts:503-563, R/hooks/useRTIOperations.ts:295-339.
void main() {
  test("the search body is React's 19-key sale-order filter", () {
    final body = RtiJobLookupApi.searchBody(6, 'TR0026');
    expect(body.length, 19);
    expect(body['Comid'], 6);
    expect(body['Search'], 'TR0026');
    expect(body.keys, containsAll(['JId', 'Employeeid', 'DashboardStatus', 'statusList', 'completestatusnotshow', 'Offvesselname', 'ETAType', 'Invoicecheck']));
  });

  group('lookupJob', () {
    test('keeps exact matches only (any case, BillNoDisplay | CNumberDisplay | JobNo) and reads each sale order', () async {
      final m = mockRepository();
      when(() => m.lookup.searchSaleMasters('tr0026')).thenAnswer((_) async => [
            {'Id': 11, 'BillNoDisplay': 'TR0026', 'CustomerName': 'ACME', 'BillDate': '2026-10-01'},
            {'Id': 12, 'BillNoDisplay': 'TR00261'},
            {'Id': 13, 'CNumberDisplay': 'TR0026'},
          ]);
      when(() => m.lookup.saleOrder(11)).thenAnswer((_) async => {
            'saleOrderMaster': {'id': 11, 'cNumberDisplay': 'TR0026', 'customerName': 'ACME SDN', 'origin': 'PKG', 'destination': 'KL', 'pickupDate': '2026-10-02T08:00:00'},
          });
      when(() => m.lookup.saleOrder(13)).thenThrow(Exception('down'));
      final rows = await m.repo.lookupJob('tr0026');
      expect(rows!.map((r) => [r.saleOrderMasterRefId, r.jobNo, r.customerName]), [
        [11, 'TR0026', 'ACME SDN'],
        [13, 'TR0026', ''],
      ]);
      expect(rows.first.originD, 'PKG');
      expect(rows.first.salary, '0');
    });

    test('no exact match → null ("Job not found.")', () async {
      final m = mockRepository();
      when(() => m.lookup.searchSaleMasters(any())).thenAnswer((_) async => [{'Id': 1, 'BillNoDisplay': 'OTHER'}]);
      expect(await m.repo.lookupJob('TR0026'), isNull);
    });
  });

  group('replace rules', () {
    const looked = RtiJobRow(jobNo: 'TR9', customerName: 'C', saleOrderMasterRefId: 9);
    test('an already-loaded row is skipped', () {
      expect(RtiGridRules.alreadyLoaded([looked], 0, 'TR9'), isTrue);
      expect(RtiGridRules.alreadyLoaded([const RtiJobRow(jobNo: 'TR9')], 0, 'TR9'), isFalse);
    });

    test('blank rows and older rows of the job go; the first match takes the row; extra matches go below', () {
      final grid = [
        const RtiJobRow(jobNo: 'TR1', customerName: 'A', saleOrderMasterRefId: 1),
        const RtiJobRow(),
        const RtiJobRow(jobNo: 'TR5', customerName: 'old', saleOrderMasterRefId: 5),
        const RtiJobRow(jobNo: 'TR5'),
        const RtiJobRow(jobNo: 'TR2', customerName: 'B', saleOrderMasterRefId: 2),
      ];
      final next = RtiGridRules.applyLookup(grid, 3, 'TR5', const [
        RtiJobRow(jobNo: 'TR5', customerName: 'new', saleOrderMasterRefId: 50),
        RtiJobRow(jobNo: 'TR5', customerName: 'new2', saleOrderMasterRefId: 51),
      ]);
      expect(next.map((r) => '${r.jobNo}/${r.saleOrderMasterRefId}'), ['TR1/1', 'TR5/50', 'TR5/51', 'TR2/2']);
      expect(next[1].editMode, 1);
    });

    test('the same job may be looked up again into another row (repeats allowed)', () {
      final next = RtiGridRules.applyLookup([looked, const RtiJobRow(jobNo: 'TR8')], 1, 'TR8', const [RtiJobRow(jobNo: 'TR8', saleOrderMasterRefId: 8)]);
      expect(next.length, 2);
    });
  });

  group('bloc', () {
    blocTest<RtiEntryBloc, RtiEntryState>(
      'not found warns "Job not found." and keeps the typed job number',
      build: () {
        final m = mockRepository();
        when(() => m.lookup.searchSaleMasters(any())).thenAnswer((_) async => []);
        return RtiEntryBloc(repository: m.repo, initialForm: () => const RtiForm(rtiDate: '2026-10-02'));
      },
      act: (b) => b.add(const RtiJobLookupRequested(-1, 'TR404')),
      verify: (b) {
        expect(b.state.grid.single.jobNo, 'TR404');
        expect(b.state.notice!.text, 'Job not found.');
        expect(b.state.busy, RtiBusy.none);
      },
    );

    blocTest<RtiEntryBloc, RtiEntryState>(
      'the phone box fills the first blank row; looking the job up again replaces its older row',
      build: () {
        final m = mockRepository();
        when(() => m.lookup.searchSaleMasters(any())).thenAnswer((i) async => [{'Id': 7, 'BillNoDisplay': i.positionalArguments.first}]);
        when(() => m.lookup.saleOrder(7)).thenAnswer((_) async => {'saleOrderMaster': {'id': 7, 'cNumberDisplay': 'TR7', 'customerName': 'Z'}});
        return RtiEntryBloc(repository: m.repo, initialForm: () => const RtiForm(rtiDate: '2026-10-02'));
      },
      act: (b) async {
        b.add(const RtiJobLookupRequested(-1, 'TR7'));
        await Future<void>.delayed(const Duration(milliseconds: 10));
        b.add(const RtiJobCellEdited(0, 'Salary', '120'));
        b.add(const RtiJobLookupRequested(-1, 'TR7'));
        await Future<void>.delayed(const Duration(milliseconds: 10));
      },
      verify: (b) {
        expect(b.state.grid.map((r) => r.saleOrderMasterRefId), [7]);
        expect(b.state.grid.single.salary, '0');
      },
    );
  });
}
