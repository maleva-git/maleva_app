import 'package:maleva/features/planning/data/planning_repository.dart';
import 'package:maleva/features/planning/models/fleet_options.dart';
import 'package:maleva/features/planning/models/plan_line.dart';
import 'package:maleva/features/rti/data/rti_from_planning.dart';
import 'package:maleva/features/rti/models/planning_transfer_item.dart';
import 'package:mocktail/mocktail.dart';

class MockPlanningRepository extends Mock implements PlanningRepository {}

/// The RTI feature's Create RTI, faked: answers [answer] or throws [error], and keeps the items.
class FakeRtiFromPlanning implements RtiFromPlanning {
  FakeRtiFromPlanning({this.answer = const CreatedRti(id: 77, rtiNo: 'RTI000000077'), this.error});

  final CreatedRti answer;
  final Object? error;
  final List<List<PlanningTransferItem>> calls = [];

  @override
  Future<CreatedRti> create(List<PlanningTransferItem> items) async {
    calls.add(items);
    if (error != null) throw error!;
    return answer;
  }
}

MockPlanningRepository stubbedRepo({Set<String> actions = const {'VIEW', 'CREATE', 'EDIT', 'DELETE'}}) {
  final repo = MockPlanningRepository();
  when(() => repo.companyId).thenReturn(6);
  when(() => repo.userId).thenReturn(15);
  when(() => repo.employeeId).thenReturn(15);
  when(() => repo.access()).thenAnswer((_) async => actions);
  when(() => repo.ports()).thenAnswer((_) async => ['PKG', 'WPK']);
  when(() => repo.trucks()).thenAnswer((_) async => const [TruckOption(id: 64, name: 'WA 1234'), TruckOption(id: 13, name: 'WB 8020')]);
  when(() => repo.drivers()).thenAnswer((_) async => const [DriverOption(id: 85, name: 'ALI-0123'), DriverOption(id: 36, name: 'OUTSIDE DRIVER')]);
  when(() => repo.employees()).thenAnswer((_) async => const [EmployeeOption(12, 'SITI')]);
  when(() => repo.nextNumber()).thenAnswer((_) async => 'PL000000783');
  when(() => repo.rtiStatus(any())).thenAnswer((_) async => const []);
  return repo;
}

PlanLine line(int so,
        {String jobNo = '', String truck = '', int truckId = 0, String driver = '', int driverId = 0, bool tick = false, String sort = ''}) =>
    PlanLine(
      saleOrderMasterRefId: so,
      jobNo: jobNo.isEmpty ? 'TR$so' : jobNo,
      truckName: truck,
      truckRefid: truckId,
      driverName: driver,
      driverRefid: driverId,
      print: tick,
      sortByD: sort,
      customerName: 'CUSTOMER $so',
      status: 'Pending',
    );
