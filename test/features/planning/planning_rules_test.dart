import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/features/planning/data/planning_rules.dart';
import 'package:maleva/features/planning/models/plan_header.dart';
import 'package:maleva/features/planning/models/plan_line.dart';

void main() {
  group('parsePlanningNo (planningNumber.test.ts)', () {
    test('reads a typed plan number', () {
      expect(PlanningRules.parsePlanningNo('782'), 782);
      expect(PlanningRules.parsePlanningNo(' 782 '), 782);
      expect(PlanningRules.parsePlanningNo('784'), 784);
    });

    test('reads the display form a new plan shows', () {
      expect(PlanningRules.parsePlanningNo('PL000000782'), 782);
    });

    test('gives nothing for an empty, zero or unusable value', () {
      expect(PlanningRules.parsePlanningNo(''), isNull);
      expect(PlanningRules.parsePlanningNo(null), isNull);
      expect(PlanningRules.parsePlanningNo('PL'), isNull);
      expect(PlanningRules.parsePlanningNo('0'), isNull);
      expect(PlanningRules.parsePlanningNo('99999999999'), isNull);
    });
  });

  group('moveRow (planningRowOrder.test.ts)', () {
    List<String> twenty() => List.generate(20, (i) => 'JOB-${i + 1}');

    test('puts row 18 in position 5 and shifts rows 5-17 down by one', () {
      final next = PlanningRules.moveRow(twenty(), 17, 4);
      expect(next[4], 'JOB-18');
      expect(next[5], 'JOB-5');
      expect(next[17], 'JOB-17');
      expect(next[18], 'JOB-19');
      expect(next, hasLength(20));
    });

    test('moves a row down', () {
      final next = PlanningRules.moveRow(twenty(), 1, 6);
      expect(next.sublist(0, 8), ['JOB-1', 'JOB-3', 'JOB-4', 'JOB-5', 'JOB-6', 'JOB-7', 'JOB-2', 'JOB-8']);
    });

    test('keeps the row objects themselves unchanged', () {
      final rows = List.generate(20, (i) => PlanLine(jobNo: 'JOB-${i + 1}'));
      final next = PlanningRules.moveRow(rows, 17, 4);
      expect(identical(next[4], rows[17]), isTrue);
      expect(rows[17].jobNo, 'JOB-18');
    });

    test('returns the same list when nothing moves or an index is out of range', () {
      final rows = twenty();
      expect(identical(PlanningRules.moveRow(rows, 3, 3), rows), isTrue);
      expect(identical(PlanningRules.moveRow(rows, -1, 3), rows), isTrue);
      expect(identical(PlanningRules.moveRow(rows, 3, 20), rows), isTrue);
    });
  });

  group('sortRows (sortPlanningRows)', () {
    test('drops a last row without a job number, then SORT ascending with 0 / empty last', () {
      final rows = [
        PlanLine(jobNo: 'A', sortByD: '3'),
        PlanLine(jobNo: 'B', sortByD: ''),
        PlanLine(jobNo: 'C', sortByD: '1'),
        PlanLine(jobNo: 'D', sortByD: '0'),
        PlanLine(jobNo: 'E', sortByD: '2'),
        PlanLine(jobNo: ' ', sortByD: '1'),
      ];
      expect(PlanningRules.sortRows(rows).map((r) => r.jobNo), ['C', 'E', 'A', 'B', 'D']);
    });

    test('keeps a single row even without a job number', () {
      expect(PlanningRules.sortRows([PlanLine(jobNo: '')]), hasLength(1));
    });
  });

  group('search (helpers.ts)', () {
    const base =
        PlanHeader(planningDate: '2026-10-05', pickupFromDate: '2026-10-05', pickupToDate: '2026-10-06', employee: '12', searchText: ' PKG,WPK ');

    test('builds the live page payload: employeeid as a number, search trimmed', () {
      expect(PlanningRules.searchPayload(6, base), {
        'comid': 6,
        'search': 'PKG,WPK',
        'employeeid': 12,
        'fromdate': '2026-10-05',
        'todate': '2026-10-06',
      });
      expect(PlanningRules.searchPayload(6, const PlanHeader(planningDate: '2026-10-05'))['employeeid'], 0);
    });

    test('asks for the plan date first, then for any criteria', () {
      expect(PlanningRules.searchRefusal(const PlanHeader()), 'Please select a Planning Date');
      expect(PlanningRules.searchRefusal(const PlanHeader(planningDate: '2026-10-05')), 'Please enter at least one search criteria');
      expect(
          PlanningRules.searchRefusal(const PlanHeader(planningDate: '2026-10-05', searchText: '  ')), 'Please enter at least one search criteria');
      expect(PlanningRules.searchRefusal(const PlanHeader(planningDate: '2026-10-05', employee: '3')), isNull);
      expect(PlanningRules.searchRefusal(const PlanHeader(planningDate: '2026-10-05', pickupToDate: '2026-10-05')), isNull);
    });

    test('PORT Add joins the search text with a comma', () {
      expect(PlanningRules.appendPort(const PlanHeader(port: 'PKG')), 'PKG');
      expect(PlanningRules.appendPort(const PlanHeader(port: 'PKG', searchText: 'WPK')), 'WPK,PKG');
      expect(PlanningRules.appendPort(const PlanHeader(searchText: 'WPK')), isNull);
    });
  });

  group('mergeSearch (K2, usePlanningListPage.ts:189-231)', () {
    test('a new plan takes the rows found', () {
      final found = [PlanLine(saleOrderMasterRefId: 1)];
      final m = PlanningRules.mergeSearch(savedPlan: false, current: [PlanLine(saleOrderMasterRefId: 9)], found: found);
      expect(m.rows, same(found));
    });

    test('a saved plan refreshes its jobs and keeps truck, driver, remarks, sort and tick', () {
      final current = [
        PlanLine(
            saleOrderMasterRefId: 1,
            truckName: 'WA 1',
            truckRefid: 5,
            driverName: 'ALI',
            driverRefid: 7,
            remarks: '1ST TRIP',
            sortByD: '2',
            print: true,
            status: 'Pending',
            sPickupDate: 'old'),
      ];
      final found = [
        PlanLine(
            saleOrderMasterRefId: 1,
            truckName: 'OTHER',
            truckRefid: 9,
            driverName: 'X',
            remarks: 'NEW',
            status: 'Delivered',
            sPickupDate: '2026-10-05 08:00:00',
            picName: 'SITI'),
        PlanLine(saleOrderMasterRefId: 2, truckName: 'WB 2', truckRefid: 3, remarks: 'R', driverName: 'KEEP'),
      ];
      final m = PlanningRules.mergeSearch(savedPlan: true, current: current, found: found);
      final kept = m.rows.first;
      expect(kept.uid, current.first.uid);
      expect([kept.truckName, kept.truckRefid, kept.driverName, kept.driverRefid, kept.remarks, kept.sortByD, kept.print],
          ['WA 1', 5, 'ALI', 7, '1ST TRIP', '2', true]);
      expect([kept.status, kept.sPickupDate, kept.picName], ['Delivered', '2026-10-05 08:00:00', 'SITI']);
      final added = m.rows[1];
      expect([added.truckName, added.truckRefid, added.remarks, added.driverName], ['', 0, '', 'KEEP']);
      expect([m.added, m.refreshed], [1, 1]);
    });
  });

  group('RTI badges (usePlanningListPage.ts:760-792)', () {
    test('puts each job newest RTI on its rows and clears a gone one', () {
      final rows = [PlanLine(saleOrderMasterRefId: 1), PlanLine(saleOrderMasterRefId: 2, rtiNo: 'OLD', rtiMasterRefId: 4)];
      final next = PlanningRules.applyRtiStatuses(rows, [
        {'saleOrderMasterRefId': 1, 'rtiMasterRefId': 55, 'rtiNo': 'RTI000000055'},
      ]);
      expect([next[0].rtiNo, next[0].rtiMasterRefId], ['RTI000000055', 55]);
      expect([next[1].rtiNo, next[1].rtiMasterRefId], ['', 0]);
    });

    test('answers the same list when nothing changed', () {
      final rows = [PlanLine(saleOrderMasterRefId: 1, rtiNo: 'R', rtiMasterRefId: 3)];
      expect(
          identical(
              PlanningRules.applyRtiStatuses(rows, [
                {'saleOrderMasterRefId': 1, 'rtiMasterRefId': 3, 'rtiNo': 'R'}
              ]),
              rows),
          isTrue);
    });

    test('the job key is sorted, distinct and skips rows with no job', () {
      expect(
          PlanningRules.jobKey([PlanLine(saleOrderMasterRefId: 5), PlanLine(saleOrderMasterRefId: 2), PlanLine(saleOrderMasterRefId: 5), PlanLine()]),
          '2,5');
    });
  });

  group('clone (usePlanningOperations.ts:251-285)', () {
    test('refusals', () {
      expect(PlanningRules.cloneRefusal(null), 'Please select a row to duplicate');
      expect(PlanningRules.cloneRefusal(PlanLine()), 'Cannot duplicate: Row does not have a valid sale order');
      expect(PlanningRules.cloneRefusal(PlanLine(saleOrderMasterRefId: 3)), isNull);
    });

    test('the copy is a new row with the truck cleared and everything else kept', () {
      final row = PlanLine(saleOrderMasterRefId: 3, truckName: 'WA', truckRefid: 4, driverName: 'ALI', driverRefid: 2, remarks: 'R');
      final copy = PlanningRules.cloneOf(row);
      expect(copy.uid, isNot(row.uid));
      expect(
          [copy.truckName, copy.truckRefid, copy.driverName, copy.driverRefid, copy.remarks, copy.saleOrderMasterRefId], ['', 0, 'ALI', 2, 'R', 3]);
    });
  });

  test('Excel: 18 quoted columns with day-first dates', () {
    final csv = PlanningRules.csv([PlanLine(jobNo: 'J"1', sPickupDate: '2026-09-17 12:01:00', status: 'Pending')]);
    final lines = csv.split('\n');
    expect(lines.first, 'S.NO,SORT,REMARKS,TRUCK,DRIVER,P.DATE,D.DATE,ORIGIN,DEST,PKG / WT,CUSTOMER,VESSEL,JOB NO,PIC,L ETA,O ETA,STATUS,RTI');
    expect(lines[1], '"1","0","","","","17/09/2026 12:01","","","","","","","J""1","","","","Pending",""');
    expect(PlanningRules.csvFileName(DateTime.utc(2026, 10, 5, 9)), 'Planning_Export_2026-10-05.csv');
  });

  test('stops split on {@}', () {
    expect(PlanningRules.stops('WESTPORT{@} NORTHPORT {@}'), ['WESTPORT', 'NORTHPORT']);
  });
}
