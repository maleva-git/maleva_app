import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/features/planning/data/planning_save_payload.dart';
import 'package:maleva/features/planning/models/plan_header.dart';
import 'package:maleva/features/planning/models/plan_line.dart';

void main() {
  const header = PlanHeader(
    planningNo: 'PL000000782',
    planningDate: '2026-10-05',
    pickupFromDate: '2026-10-05',
    pickupToDate: '2026-10-06',
    employee: '',
    remarks: '  plan notes ',
    searchText: ' PKG ',
  );

  PlanLine row({int so = 101, String sort = '', String original = ''}) => PlanLine(
        saleOrderMasterRefId: so,
        truckName: 'WA 1234',
        truckRefid: 64,
        driverName: 'ALI-0123',
        driverRefid: 85,
        driverNameD: 'OLD',
        remarks: ' 1ST TRIP ',
        origin: 'NORTHPORT',
        destination: 'WESTPORT',
        originD: '',
        destinationD: 'D-DEST',
        sortByD: sort,
        originalSortByD: original,
        pickupDateD: '2026-10-05 08:30:00',
        deliveryDateD: '',
        pickupDate: '2026-10-04 07:00:00',
        pickuptimelist: ' 2026-10-05 08:30 ',
        pickupQuantitylist: '2{@}2',
        deliveryQuantitylist: '4',
        delivertimelist: '',
      );

  test('builds the web payload exactly (planningSavePayload.ts)', () {
    final p = PlanningSavePayload.build(companyId: 6, editId: 752, header: header, rows: [row(original: '3')], userId: 15, employeeId: 15);
    expect(p, {
      'id': 752,
      'companyRefId': 6,
      'userRefId': 15,
      'employeeRefId': 15,
      'fDate': '2026/10/05',
      'tDate': '2026/10/06',
      'saleDate': '2026/10/05',
      'cNumberDisplay': 'PL000000782',
      'cNumber': 782,
      'remarks': 'plan notes',
      'search': 'PKG',
      'saleDetails': [
        {
          'saleOrderMasterRefId': 101,
          'truckRefid': 64,
          'driverRefid': 85,
          'DriverRefId': 85,
          'remarks': '1ST TRIP',
          'originD': 'NORTHPORT',
          'destinationD': 'D-DEST',
          'truckNameD': 'WA 1234',
          'driverNameD': 'ALI-0123',
          'driverName': 'ALI-0123',
          'sortBy': 3,
          'pickupDateD': '2026/10/05 08:30',
          'deliveryDateD': null,
          'pickuptimelist': '2026-10-05 08:30',
          'pickupQuantitylist': '2{@}2',
          'deliveryQuantitylist': '4',
          'delivertimelist': '',
        }
      ],
    });
  });

  test('SORT typed wins over the loaded sort; nothing usable is 0', () {
    Map<String, dynamic> d(PlanLine r) => PlanningSavePayload.detail(r)!;
    expect(d(row(sort: '7', original: '3'))['sortBy'], 7);
    expect(d(row(sort: '', original: ''))['sortBy'], 0);
    expect(d(row(sort: 'x'))['sortBy'], 0);
  });

  test('rows without a sale order are left out; employee and user fall back to null', () {
    final p = PlanningSavePayload.build(companyId: 6, editId: 0, header: header, rows: [row(so: 0), row()], userId: 0, employeeId: 0);
    expect(p['id'], 0);
    expect(p['userRefId'], isNull);
    expect(p['employeeRefId'], isNull);
    expect((p['saleDetails'] as List), hasLength(1));
  });

  test('the employee of the form wins over the signed-in one', () {
    final p = PlanningSavePayload.build(companyId: 6, editId: 0, header: header.copyWith(employee: '44'), rows: [row()], userId: 15, employeeId: 15);
    expect(p['employeeRefId'], 44);
  });

  test('from / to fall back to the plan date', () {
    final p = PlanningSavePayload.build(
        companyId: 6, editId: 0, header: header.copyWith(pickupFromDate: '', pickupToDate: ''), rows: [row()], userId: 1, employeeId: 1);
    expect([p['fDate'], p['tDate']], ['2026/10/05', '2026/10/05']);
  });

  group('validatePlanningSavePayload messages, in order', () {
    test('every refusal', () {
      expect(PlanningSavePayload.validate({'companyRefId': 0, 'saleDate': '', 'fDate': '', 'tDate': '', 'saleDetails': []}), [
        'Company ID is required',
        'Planning date is required',
        'From date is required',
        'To date is required',
        'Please add at least one valid row in the table before saving',
      ]);
    });

    test('no plan date: the first shown is the plan date', () {
      final p = PlanningSavePayload.build(companyId: 6, editId: 0, header: const PlanHeader(), rows: [row()], userId: 1, employeeId: 1);
      expect(PlanningSavePayload.refusal(p), 'Planning date is required');
    });

    test('no valid row', () {
      final p = PlanningSavePayload.build(companyId: 6, editId: 0, header: header, rows: [row(so: 0)], userId: 1, employeeId: 1);
      expect(PlanningSavePayload.refusal(p), 'Please add at least one valid row in the table before saving');
    });

    test('a valid plan passes', () {
      final p = PlanningSavePayload.build(companyId: 6, editId: 0, header: header, rows: [row()], userId: 1, employeeId: 1);
      expect(PlanningSavePayload.refusal(p), isNull);
    });
  });

  test('date reading: yyyy-MM-dd, T form, slashes, dd MMM yy', () {
    expect(PlanningSavePayload.date('2026-10-05'), '2026/10/05');
    expect(PlanningSavePayload.dateTime('2026-10-05T08:30:00.000'), '2026/10/05 08:30');
    expect(PlanningSavePayload.dateTime('2026/10/05 08:30'), '2026/10/05 08:30');
    expect(PlanningSavePayload.dateTime('05 Oct 26 07:15'), '2026/10/05 07:15');
    expect(PlanningSavePayload.dateTime(''), isNull);
    expect(PlanningSavePayload.date('nonsense'), '');
  });
}
