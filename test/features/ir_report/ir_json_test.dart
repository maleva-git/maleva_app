import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/features/ir_report/data/models/ir_json.dart';
import 'package:maleva/features/ir_report/domain/entities/ir_draft.dart';
import 'package:maleva/features/ir_report/domain/entities/ir_filter.dart';
import 'package:maleva/features/ir_report/domain/entities/ir_lookup.dart';
import 'package:maleva/features/ir_report/domain/entities/ir_report.dart';

void main() {
  test('reads an IrDetailDto', () {
    final report = IrJson.report({
      'id': 12,
      'companyRefId': 6,
      'irDate': '2026-09-10T08:15:00',
      'irStatusRefId': 1,
      'statusCode': 'OPEN',
      'statusName': 'Open',
      'statusColor': '#DC2626',
      'description': 'Truck accident',
      'reason': null,
      'departmentRefId': 1000,
      'departmentName': 'TRANSPORTATION',
      'vesselName': '',
      'truckRefId': 5,
      'truckNo': 'WLN 1234',
      'driverRefId': null,
      'driverName': 'Ali (outside)',
      'actualAmount': 4500,
      'createEmployeeRefId': 44,
      'createEmployeeName': null,
      'createdBy': 'ADMIN',
      'documentRemarks': 'Police report attached',
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
    expect(report.documentRemarks, 'Police report attached');
  });

  test('the save body is an IrSaveRequest: nothing picked is null, no user id', () {
    final draft = IrDraft(
      id: 0,
      irDate: DateTime(2026, 9, 14, 7, 5),
      status: const IrStatus(id: 1, code: 'OPEN', name: 'Open'),
      department: const LookupOption(id: 1000, name: 'TRANSPORTATION'),
      description: '  Truck accident  ',
      truck: IrParty.empty.picked(const LookupOption(id: 5, name: 'WLN 1234')),
      driver: IrParty.empty.typed('Ali (outside)'),
    );

    final body = IrJson.saveRequest(draft, companyId: 6);

    expect(body, {
      'id': null,
      'companyRefId': 6,
      'irDate': '2026-09-14T07:05:00',
      'irStatusRefId': 1,
      'description': 'Truck accident',
      'reason': null,
      'departmentRefId': 1000,
      'vesselName': null,
      'truckRefId': 5,
      'truckNo': null,
      'employeeRefId': null,
      'employeeName': null,
      'driverRefId': null,
      'driverName': 'Ali (outside)',
      'actualAmount': null,
      'documentRemarks': null,
    });
  });

  test('an edit sends the document notes back unchanged', () {
    final report = IrReport(
      id: 12,
      irDate: DateTime(2026, 9, 10),
      statusId: 1,
      description: 'Truck accident',
      departmentId: 1000,
      departmentName: 'TRANSPORTATION',
      documentRemarks: 'Police report attached',
    );
    const lookups = IrLookups(statuses: [], departments: [], trucks: [], drivers: [], employees: []);

    final draft = IrDraft.fromReport(report, lookups).copyWith(description: 'Truck accident at gate');
    final body = IrJson.saveRequest(draft, companyId: 6);

    expect(body['id'], 12);
    expect(body['documentRemarks'], 'Police report attached');
  });

  test('the search query sends plain dates and leaves out every-status and a blank search', () {
    expect(
      IrJson.searchQuery(
        IrFilter(fromDate: DateTime(2026, 9, 1), toDate: DateTime(2026, 9, 14), search: ' sea '),
        companyId: 6,
      ),
      {'companyRefId': 6, 'fromDate': '2026-09-01', 'toDate': '2026-09-14', 'search': 'sea'},
    );
    expect(
      IrJson.searchQuery(const IrFilter(statusId: 3, openOnly: true), companyId: 6),
      {'companyRefId': 6, 'irStatusRefId': 3, 'openOnly': true},
    );
  });

  test('picker rows', () {
    expect(IrJson.masterRow({'Id': '7', 'AccountName': ' MUTHU-DRIVER '}), const LookupOption(id: 7, name: 'MUTHU-DRIVER'));
    expect(IrJson.employee({'id': 3, 'employeeName': ' ANNA '}), const LookupOption(id: 3, name: 'ANNA'));
    expect(IrJson.status({'id': 2, 'statusCode': 'DONE', 'statusName': 'Closed', 'colorCode': '#16A34A', 'finished': true}),
        const IrStatus(id: 2, code: 'DONE', name: 'Closed', colorCode: '#16A34A', finished: true));
    expect(IrJson.department({'id': 1000, 'name': 'TRANSPORTATION'}), const LookupOption(id: 1000, name: 'TRANSPORTATION'));
  });
}
