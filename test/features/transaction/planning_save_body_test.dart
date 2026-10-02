import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/features/transaction/planning/data/planning_save_body.dart';

/// The Java `PlanningRequest` the Planning page saves, built as the web's
/// `buildPlanningSavePayload` (change planning-on-shared-java-api).
void main() {
  Map<String, dynamic> body({int id = 0, List<Map<String, dynamic>> lines = const []}) => planningSaveBody(
        id: id,
        companyId: 6,
        planNo: 'PL000000124',
        planDate: '02/10/2026',
        fromDate: '01/10/2026',
        toDate: '03/10/2026',
        remarks: ' night run ',
        lines: lines,
        truckId: (name) => name == 'WXY 1234' ? 31 : 0,
        driverId: (name) => name == 'ALI' ? 52 : 0,
        employeeId: 7,
      );

  test('the plan: slash dates, the number and its digits', () {
    final plan = body(id: 70);

    expect(plan['id'], 70);
    expect(plan['companyRefId'], 6);
    expect(plan['employeeRefId'], 7);
    expect(plan['userRefId'], isNull);
    expect(plan['saleDate'], '2026/10/02');
    expect(plan['fDate'], '2026/10/01');
    expect(plan['tDate'], '2026/10/03');
    expect(plan['cNumberDisplay'], 'PL000000124');
    expect(plan['cNumber'], 124);
    expect(plan['remarks'], 'night run');
  });

  test('a row per planned job with the picked truck and driver ids', () {
    final plan = body(lines: [
      {
        'saleOrderId': 40,
        'truck': 'WXY 1234',
        'driver': 'ALI',
        'pDate': '02/10/2026',
        'dDate': '2026-10-03 14:30:00',
        'origin': 'PKG',
        'destination': 'JB',
        'remarks': 'first',
        'SortByD': 2,
      },
      {'saleOrderId': 0, 'truck': 'NO JOB'},
    ]);

    expect(plan['saleDetails'], [
      {
        'saleOrderMasterRefId': 40,
        'truckRefid': 31,
        'driverRefid': 52,
        'DriverRefId': 52,
        'remarks': 'first',
        'originD': 'PKG',
        'destinationD': 'JB',
        'truckNameD': 'WXY 1234',
        'driverNameD': 'ALI',
        'driverName': 'ALI',
        'sortBy': 2,
        'pickupDateD': '2026/10/02 00:00',
        'deliveryDateD': '2026/10/03 14:30',
      }
    ]);
  });

  test('page and server dates are read; blanks are null', () {
    expect(planDateOf('02/10/2026 08:15'), DateTime(2026, 10, 2, 8, 15));
    expect(planDateOf('2026-10-02 08:15:00'), DateTime(2026, 10, 2, 8, 15));
    expect(planDateOf(' '), isNull);
    expect(planDateOf('not a date'), isNull);
  });
}
