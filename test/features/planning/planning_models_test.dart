import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/features/planning/data/planning_transfer.dart';
import 'package:maleva/features/planning/models/fleet_options.dart';
import 'package:maleva/features/planning/models/plan_header.dart';
import 'package:maleva/features/planning/models/plan_line.dart';
import 'package:maleva/features/planning/models/planning_access.dart';

void main() {
  group('planningModeFor / resolvePlanningAccess (planningAccess.test.ts)', () {
    test('is edit for a saved plan id and new otherwise', () {
      expect(planningModeFor(42), PlanningMode.edit);
      expect(planningModeFor(0), PlanningMode.newPlan);
      expect(planningModeFor(null), PlanningMode.newPlan);
    });

    test('full access writes in both modes and may delete', () {
      const all = ['VIEW', 'CREATE', 'EDIT', 'DELETE'];
      final n = PlanningAccess.resolve(all, PlanningMode.newPlan);
      expect([n.canView, n.canWrite, n.canDelete, n.deniedReason, n.deleteDeniedReason], [true, true, true, '', '']);
      expect(PlanningAccess.resolve(all, PlanningMode.edit).canWrite, isTrue);
    });

    test('create without edit: a new plan is writable, a saved one is not', () {
      const rules = ['VIEW', 'CREATE'];
      expect(PlanningAccess.resolve(rules, PlanningMode.newPlan).canWrite, isTrue);
      final saved = PlanningAccess.resolve(rules, PlanningMode.edit);
      expect(saved.canWrite, isFalse);
      expect(saved.deniedReason, 'View only: your role can open this plan but not change it.');
    });

    test('edit without create: a saved plan is writable, a new one is not', () {
      const rules = ['VIEW', 'EDIT'];
      expect(PlanningAccess.resolve(rules, PlanningMode.edit).canWrite, isTrue);
      final fresh = PlanningAccess.resolve(rules, PlanningMode.newPlan);
      expect(fresh.canWrite, isFalse);
      expect(fresh.deniedReason, 'View only: your role cannot create a plan.');
    });

    test('delete is its own permission', () {
      final a = PlanningAccess.resolve(['VIEW', 'EDIT'], PlanningMode.edit);
      expect([a.canDelete, a.deleteDeniedReason], [false, 'Your role cannot delete a plan.']);
      final b = PlanningAccess.resolve(['VIEW', 'DELETE'], PlanningMode.edit);
      expect([b.canDelete, b.canWrite], [true, false]);
    });

    test('read-only and no access; actions without VIEW count for nothing', () {
      final ro = PlanningAccess.resolve(['VIEW'], PlanningMode.edit);
      expect([ro.canView, ro.canWrite, ro.canDelete], [true, false, false]);
      expect(PlanningAccess.resolve([], PlanningMode.newPlan).canView, isFalse);
      expect(PlanningAccess.resolve(null, PlanningMode.newPlan).canView, isFalse);
      expect(PlanningAccess.resolve(['EDIT'], PlanningMode.edit).canWrite, isFalse);
    });

    test('the loading default views but writes nothing', () {
      final a = PlanningAccess.readOnly;
      expect([a.canView, a.canWrite, a.canDelete], [true, false, false]);
    });

    test('the mode badge and the view-only notice (planningAccessUi.test.tsx)', () {
      expect(PlanningAccess.resolve(['VIEW'], PlanningMode.edit).badge('782'), 'Read-only');
      expect(PlanningAccess.resolve(['VIEW', 'EDIT'], PlanningMode.edit).badge(''), 'Editing');
      expect(PlanningAccess.resolve(['VIEW', 'EDIT'], PlanningMode.edit).badge('782'), 'Editing Plan #782');
      expect(PlanningAccess.resolve(['VIEW', 'CREATE'], PlanningMode.newPlan).badge('PL000000783'), 'New plan');
      expect(viewOnlyBannerText(),
          'View only. You can open, search and export plans. The Super Admin decides who may create and change plans (Utils → Screen Access).');
      expect(viewOnlyBannerText(roleName: 'Clerk'), startsWith('View only. Your role (Clerk) can open'));
    });
  });

  group('PlanLine.fromSearch (mapPlanningSearchItem)', () {
    test('reads the Java search row', () {
      final r = PlanLine.fromSearch({
        'Id': 21507,
        'SaleOrderMasterRefId': 0,
        'TruckRefid': 0,
        'TruckName': 'IGNORED',
        'DriverName': 'ALI',
        'SPickupDate': '2026-09-17T12:01:00',
        'PickupDate': '2026-09-01',
        'JobStatus': null,
        'SortBy': 4,
        'pkg': '4/114.96',
        'EmployeeName': 'SITI',
        'TruckNameD': '',
        'RTINo': 'RTI1',
      });
      expect(r.saleOrderMasterRefId, 21507);
      expect(r.truckName, '');
      expect(r.status, 'Pending');
      expect(r.sPickupDate, '2026-09-17 12:01:00');
      expect([r.sortByD, r.originalSortByD], ['', '4']);
      expect([r.packageType, r.picName, r.rtiNo, r.driverNameD], ['4/114.96', 'SITI', 'RTI1', 'ALI']);
      expect(r.print, isFalse);
    });

    test('a truck with an id keeps its name', () {
      expect(PlanLine.fromSearch({'TruckRefid': 5, 'TruckName': 'WA 1'}).truckName, 'WA 1');
    });
  });

  group('LoadedPlan.fromJava (mapPlanningEditResponse)', () {
    test('reads the edit answer: CNumber first, dates for the form, the rows', () {
      final p = LoadedPlan.fromJava({
        'Id': 752,
        'CNumber': 782,
        'CNumberDisplay': 'PL000000782',
        'SaleDate': '2026-10-05T00:00:00',
        'FDate': '05/10/2026',
        'TDate': '2026/10/06',
        'Remarks': 'notes',
        'Search': 'PKG',
        'EmployeeRefId': 12,
        'SaleDetails': [
          {'Id': 1, 'SaleOrderMasterRefId': 101, 'TruckRefid': 0, 'TruckName': 'X', 'JobStatus': null, 'SortBy': 0, 'DriverName': 'ALI'},
          {
            'Id': 2,
            'SaleOrderMasterRefId': 102,
            'TruckRefid': 64,
            'TruckNameD': 'WA 7151',
            'TruckName': 'WA',
            'PickupsList': [
              {'id': 1}
            ]
          },
        ],
      })!;
      expect(p.editId, 752);
      expect(p.header['planningNo'], '782');
      expect([p.header['planningDate'], p.header['pickupFromDate'], p.header['pickupToDate']], ['2026-10-05', '2026-10-05', '2026-10-06']);
      expect([p.header['remarks'], p.header['searchText']], ['notes', 'PKG']);
      expect(p.lines, hasLength(2));
      expect([p.lines[0].truckName, p.lines[0].status, p.lines[0].originalSortByD], ['', '', '0']);
      expect([p.lines[1].truckName, p.lines[1].truckNameD, p.lines[1].pickupsList!.length], ['WA 7151', 'WA 7151', 1]);
    });

    test('no plan in the answer', () => expect(LoadedPlan.fromJava(null), isNull));
  });

  group('transfer items (mapPlanningRowToTransferItem + savePlanningRTITransfer)', () {
    test('maps a row like the web, D fields first for the dates', () {
      final item = PlanningTransfer.item(PlanLine(
        saleOrderMasterRefId: 101,
        jobNo: 'TR1',
        truckName: '',
        truckNameD: 'WA D',
        driverName: 'ALI',
        pickupDateD: '',
        pickupDate: '2026-10-05 08:00',
        sPickupDate: 'S',
        origin: '',
        originD: 'NORTH',
        pickuptimelist: 't',
        pickupQuantitylist: 'q',
        deliveryQuantitylist: 'dq',
        delivertimelist: 'dt',
      ))!;
      expect([item.saleOrderMasterRefId, item.truckName, item.driverName, item.pickupDate, item.origin],
          [101, 'WA D', 'ALI', '2026-10-05 08:00', 'NORTH']);
      expect([item.pickupAddressTimelist, item.pickupAddressQuantity, item.deliveryAddressQuantity, item.deliveryAddressDatelist],
          ['t', 'q', 'dq', 'dt']);
    });

    test('a row with no sale order is left out', () => expect(PlanningTransfer.item(PlanLine()), isNull));

    test('finds the driver and truck by name, and marks an outside driver', () {
      const drivers = [DriverOption(id: 85, name: 'ALI-0123'), DriverOption(id: 36, name: 'OUTSIDE DRIVER')];
      const trucks = [TruckOption(id: 64, name: 'WA 1234')];
      final items = PlanningTransfer.items([
        PlanLine(saleOrderMasterRefId: 1, driverName: 'ali-0123', truckName: 'WA1234'),
        PlanLine(saleOrderMasterRefId: 2, driverName: 'RAJU (typed)'),
        PlanLine(saleOrderMasterRefId: 3, driverName: 'RAJU', driverRefid: 36),
        PlanLine(saleOrderMasterRefId: 4),
      ], drivers: drivers, trucks: trucks);
      expect([items[0].driverRefId, items[0].truckRefId, items[0].isOutsideDriver], [85, 64, false]);
      expect([items[1].driverRefId, items[1].isOutsideDriver], [0, true]);
      expect([items[2].driverRefId, items[2].isOutsideDriver], [36, true]);
      expect(items[3].isOutsideDriver, isFalse);
    });
  });

  group('expiry and leave colours (truckExpiryWarnings.ts, driverExpiryWarnings.ts)', () {
    final today = DateTime(2026, 10, 5);

    test('truck: warning from 10 days (Rotex, Puspakom) or 5 days, red at 3 or fewer', () {
      expect(truckExpiryState({'rotexMyExp': '2026-10-15'}, today: today).severity, ExpirySeverity.warning);
      expect(truckExpiryState({'rotexMyExp': '2026-10-16'}, today: today).severity, ExpirySeverity.normal);
      expect(truckExpiryState({'serviceExp': '2026-10-11'}, today: today).severity, ExpirySeverity.normal);
      expect(truckExpiryState({'serviceExp': '2026-10-10'}, today: today).severity, ExpirySeverity.warning);
      final c = truckExpiryState({'puspacomExp': '2026-10-08', 'gearOilExp': '2026-10-01'}, today: today);
      expect(c.severity, ExpirySeverity.critical);
      expect(c.warnings.map((w) => w.message), ['Puspakom expires in 3 days (08/10/2026)', 'Gear Oil expired 4 days ago (01/10/2026)']);
      expect(truckExpiryState({'alignmentExp': '2026-10-05'}, today: today).warnings.single.message, 'Alignment expires today (05/10/2026)');
    });

    test('driver: licence and GDL at 7 days; approved leave is purple, pending indigo; critical wins', () {
      expect(driverExpiryState({'licenseExp': '2026-10-12'}, today: today).severity, ExpirySeverity.warning);
      expect(driverExpiryState({'gdlExp': '2026-10-07'}, today: today).severity, ExpirySeverity.critical);
      final leave = driverExpiryState({
        'leaves': [
          {'StatusName': 'Approved', 'LeaveTypeName': 'Annual', 'FromDate': '2026-10-06T00:00:00', 'ToDate': '2026-10-08T00:00:00'}
        ]
      }, today: today);
      expect(leave.severity, ExpirySeverity.leaveApproved);
      expect(leave.warnings.single.message, 'Leave (APPROVED) - Annual: 06/10/2026 to 08/10/2026');
      expect(
          driverExpiryState({
            'leaves': [
              {'StatusName': 'pending'}
            ]
          }, today: today)
              .severity,
          ExpirySeverity.leavePending);
      expect(
          driverExpiryState({
            'gdlExp': '2026-10-06',
            'leaves': [
              {'StatusName': 'APPROVED'}
            ]
          }, today: today)
              .severity,
          ExpirySeverity.critical);
    });

    test('the driver list: AccountName or name-mobile, active ones of the company, by name', () {
      final list = DriverOption.listFrom([
        {'id': 2, 'driverName': 'ZUL', 'mobileNo': '011', 'active': 1, 'companyRefId': 6},
        {'id': 3, 'driverName': 'ALI', 'active': 0},
        {'id': 4, 'driverName': 'BOB', 'companyRefId': 7},
        {'id': 5, 'driverName': 'AMIR', 'mobileNo': ''},
      ], 6);
      expect(list.map((d) => d.name), ['AMIR', 'ZUL-011']);
      expect(const DriverOption(id: 36, name: 'x').isOutsideDriver, isTrue);
      expect(const DriverOption(id: 1, name: 'outside driver').isOutsideDriver, isTrue);
    });

    test('the truck list reads truckName', () {
      expect(TruckOption.fromJava({'id': 64, 'truckName': 'WA 1234'})!.name, 'WA 1234');
      expect(TruckOption.fromJava({'id': 0, 'truckName': 'X'}), isNull);
    });
  });
}
