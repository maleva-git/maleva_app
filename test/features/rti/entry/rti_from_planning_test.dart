import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/features/rti/data/rti_from_planning.dart';
import 'package:maleva/features/rti/data/rti_from_planning_service.dart';
import 'package:maleva/features/rti/models/planning_transfer_item.dart';
import 'package:maleva/features/rti/models/rti_form.dart';
import 'package:mocktail/mocktail.dart';

import 'rti_mocks.dart';

// R/services/planningDirectCreateService.ts:121-257: the refusals in order, the placeholders.
PlanningTransferItem item({int so = 100, String truck = 'WXY 1', int truckId = 72, String driver = 'ALI', int driverId = 5, bool outside = false}) =>
    PlanningTransferItem(saleOrderMasterRefId: so, jobNo: 'TR$so', truckName: truck, truckRefId: truckId, driverName: driver, driverRefId: driverId, isOutsideDriver: outside);

void main() {
  late ({dynamic repo, MockRtiEntryApi api, dynamic lookup, MockDriverApi drivers, MockTruckApi trucks}) m;
  late RtiFromPlanningService service;
  Map<String, dynamic>? sent;

  setUp(() {
    final r = mockRepository();
    m = (repo: r.repo, api: r.api, lookup: r.lookup, drivers: r.drivers, trucks: r.trucks);
    sent = null;
    when(() => r.api.save(any(), any(), routeActivities: any(named: 'routeActivities'))).thenAnswer((i) async {
      sent = Map<String, dynamic>.from(i.positionalArguments.first as Map)..['rtiDetails'] = i.positionalArguments[1];
      return {'id': 900, 'cnumberDisplay': 'RTI000000900'};
    });
    service = RtiFromPlanningService(repository: r.repo, drivers: r.drivers, trucks: r.trucks, initialForm: () => const RtiForm(rtiDate: '2026-10-05'));
  });

  Future<String> refusal(List<PlanningTransferItem> items) async {
    try {
      await service.create(items);
    } on RtiCreateRefused catch (e) {
      return e.message;
    }
    return 'created';
  }

  test('refusals in the web order and words', () async {
    expect(await refusal([]), 'Please select orders to create RTI');
    expect(await refusal([item(so: 0)]), 'Selected rows are missing their sale order reference — save the planning first.');
    expect(await refusal([item(), item(so: 0)]), 'Some selected rows are missing their sale order reference — save the planning first.');
    expect(await refusal([item(), item(so: 101, truckId: 73, truck: 'ABC 2')]), 'Selected rows have different trucks — select rows for one truck only.');
    expect(await refusal([item(), item(so: 101, driverId: 6, driver: 'BOB')]), 'Selected rows have different drivers — select rows for one driver only.');
    expect(await refusal([item(driverId: 0, driver: '')]), 'Selected rows have no driver — assign or type a driver first.');
    expect(await refusal([item(truckId: 0, truck: 'GHOST 9')]), 'Truck "GHOST 9" was not found in the truck master — assign a valid truck first.');
    expect(await refusal([item(truckId: 0, truck: '')]), 'Selected rows have no truck — assign a truck first.');
    expect(sent, isNull);
  });

  test('no company', () async {
    final r = mockRepository(session: const FixedSession(companyId: 0));
    final s = RtiFromPlanningService(repository: r.repo, drivers: r.drivers, trucks: r.trucks);
    expect(() => s.create([item()]), throwsA(isA<RtiCreateRefused>().having((e) => e.message, 'message', 'Company is required before creating RTI.')));
  });

  test('a normal driver and truck: one RTI dated today with one line per job', () async {
    final created = await service.create([item(), item(so: 101)]);
    expect([created.id, created.rtiNo], [900, 'RTI000000900']);
    expect([sent!['driverRefId'], sent!['truckRefId'], sent!['saleDate'], sent!['outsideDriver']], [5, 72, '2026-10-05T00:00:00', '']);
    expect((sent!['rtiDetails'] as List).length, 2);
    expect(sent!.containsKey('CNumberDisplay'), isFalse);
  });

  test('a typed outside driver: OUTSIDE DRIVER by name (else 22), NONE truck by name (else 43)', () async {
    when(() => m.drivers.allDetails()).thenAnswer((_) async => [{'id': 31, 'driverName': 'Outside Driver'}]);
    when(() => m.trucks.allDetailCombo()).thenAnswer((_) async => [{'id': 44, 'truckName': 'NONE'}]);
    await service.create([item(driver: 'Ahmad Lorry', driverId: 0, truck: '', truckId: 0)]);
    expect([sent!['driverRefId'], sent!['truckRefId'], sent!['outsideDriver'], sent!['outsideTruck']], [31, 44, 'Ahmad Lorry', 'Ahmad Lorry']);
  });

  test('the OUTSIDE DRIVER picked with no typed name is refused', () async {
    when(() => m.drivers.allDetails()).thenAnswer((_) async => [{'id': 22, 'driverName': 'OUTSIDE DRIVER'}]);
    expect(await refusal([item(driverId: 22, driver: '')]), 'Type the outside driver name in the planning row first.');
  });

  test('the fallback ids when the placeholders are not in the lists', () async {
    await service.create([item(driver: 'Ahmad Lorry', driverId: 0, truck: 'OUTSIDE TRUCK', truckId: 0)]);
    expect([sent!['driverRefId'], sent!['truckRefId']], [22, 43]);
  });

  test('a driver name that is a real driver is that driver, not outside', () async {
    when(() => m.drivers.allDetails()).thenAnswer((_) async => [{'id': 8, 'driverName': 'Siti A'}]);
    await service.create([item(driver: 'SITI A', driverId: 0)]);
    expect([sent!['driverRefId'], sent!['outsideDriver']], [8, '']);
  });
}
