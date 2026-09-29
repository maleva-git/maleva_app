import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/features/ir_report/data/models/ir_json.dart';
import 'package:maleva/features/ir_report/domain/entities/ir_draft.dart';
import 'package:maleva/features/ir_report/domain/entities/ir_filter.dart';
import 'package:maleva/features/ir_report/domain/entities/ir_lookup.dart';

void main() {
  test('reads a row the way IRServices writes it', () {
    final report = IrJson.report({
      'Id': 12,
      'CompanyRefId': 6,
      'IRDate': '2026-09-10T08:15:00',
      'IRStatusRefId': 1,
      'StatusCode': 'OPEN',
      'StatusName': 'Open',
      'StatusColor': '#DC2626',
      'Description': 'Truck accident',
      'Reason': null,
      'DepartmentRefId': 1000,
      'DepartmentName': 'TRANSPORTATION',
      'VesselName': '',
      'TruckRefId': 5,
      'TruckNo': 'WLN 1234',
      'DriverRefId': null,
      'DriverName': 'Ali (outside)',
      'ActualAmount': 4500,
      'CreateEmployeeRefId': 44,
      'CreateEmployeeName': null,
      'Created_By': 'ADMIN',
    });

    expect(report.id, 12);
    expect(report.irDate, DateTime(2026, 9, 10, 8, 15));
    expect(report.statusName, 'Open');
    expect(report.reason, isNull);
    expect(report.vesselName, isNull, reason: 'blank strings read as no value');
    expect(report.truckId, 5);
    expect(report.driverId, isNull);
    expect(report.driverName, 'Ali (outside)');
    expect(report.actualAmount, 4500);
    expect(report.reporterId, 44);
    expect(report.reporter, 'ADMIN');
  });

  test('the save body uses the IRSaveModel names and sends 0 for anything not picked', () {
    final draft = IrDraft(
      id: 0,
      irDate: DateTime(2026, 9, 14, 7, 5),
      status: const IrStatus(id: 1, code: 'OPEN', name: 'Open'),
      department: const LookupOption(id: 1000, name: 'TRANSPORTATION'),
      description: '  Truck accident  ',
      truck: IrParty.empty.picked(const LookupOption(id: 5, name: 'WLN 1234')),
      driver: IrParty.empty.typed('Ali (outside)'),
    );

    final body = IrJson.saveRequest(draft, companyId: 6, userRefId: 44);

    expect(body['Id'], 0);
    expect(body['CompanyRefId'], 6);
    expect(body['UserRefId'], 44);
    expect(body['IRDate'], '2026-09-14T07:05:00');
    expect(body['IRStatusRefId'], 1);
    expect(body['DepartmentRefId'], 1000);
    expect(body['Description'], 'Truck accident');
    expect(body['TruckRefId'], 5);
    expect(body['TruckNo'], '');
    expect(body['DriverRefId'], 0);
    expect(body['DriverName'], 'Ali (outside)');
    expect(body['EmployeeRefId'], 0);
    expect(body['ActualAmount'], isNull);
  });

  test('the search body sends plain dates and 0 for every status', () {
    final body = IrJson.searchRequest(
      IrFilter(fromDate: DateTime(2026, 9, 1), toDate: DateTime(2026, 9, 14), search: ' sea '),
      companyId: 6,
    );

    expect(body, {
      'Comid': 6,
      'FromDate': '2026-09-01',
      'ToDate': '2026-09-14',
      'IRStatusRefId': 0,
      'OpenOnly': false,
      'Search': 'sea',
    });
  });

  test('master list rows are {Id, AccountName}', () {
    expect(
      IrJson.masterRow({'Id': '7', 'AccountName': ' MUTHU-DRIVER '}),
      const LookupOption(id: 7, name: 'MUTHU-DRIVER'),
    );
  });
}
