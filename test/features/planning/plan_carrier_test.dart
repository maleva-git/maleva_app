import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/features/planning/data/planning_rules.dart';
import 'package:maleva/features/planning/data/planning_save_payload.dart';
import 'package:maleva/features/planning/data/planning_transfer.dart';
import 'package:maleva/features/planning/models/fleet_options.dart';
import 'package:maleva/features/planning/models/plan_line.dart';
import 'package:maleva/features/rti/data/rti_mapper.dart';
import 'package:maleva/features/rti/data/rti_save_payload.dart';
import 'package:maleva/features/rti/models/rti_form.dart';

/// Fleet D2 on the app (change d2-carrier-by-id): carrier ids read, shown, saved and carried to the RTI.
void main() {
  PlanLine outsideRow() => PlanLine(
        saleOrderMasterRefId: 501,
        truckName: 'RG MAJU',
        truckRefid: 68,
        driverName: 'ALI',
        driverRefid: outsideDriverPlaceholderId,
        outsideVehicleRefId: 3,
        outsidePlateNo: 'WA1229R',
        outsideDriverRefId: 9,
      );

  test('the edit answer gives the carrier fields', () {
    final row = PlanLine.fromEdit({
      'SaleOrderMasterRefId': 501, 'TruckRefid': 68, 'TruckName': 'RG MAJU', 'DriverName': 'ALI', 'DriverRefid': 22,
      'CarrierKind': 'subcontractor', 'OutsideVehicleRefId': 3, 'OutsidePlateNo': 'WA1229R', 'OutsideDriverRefId': 9,
    }, 0);
    expect([row.carrierKind, row.outsideVehicleRefId, row.outsidePlateNo, row.outsideDriverRefId], ['SUBCONTRACTOR', 3, 'WA1229R', 9]);
    expect(row.driverLabel, 'WA1229R · ALI');
  });

  test('an own row shows the driver name only', () {
    final row = PlanLine(driverName: 'BOB', driverRefid: 85);
    expect([row.carrierSummary, row.driverLabel], ['', 'BOB']);
  });

  test('the save sends the ids only when picked', () {
    final detail = PlanningSavePayload.detail(outsideRow())!;
    expect([detail['outsideVehicleRefId'], detail['outsideDriverRefId']], [3, 9]);

    final own = PlanningSavePayload.detail(PlanLine(saleOrderMasterRefId: 502, truckRefid: 64, driverRefid: 85))!;
    expect(own.containsKey('outsideVehicleRefId'), isFalse);
    expect(own.containsKey('outsideDriverRefId'), isFalse);
  });

  test('a clone starts with no truck and no carrier', () {
    final copy = PlanningRules.cloneOf(outsideRow());
    expect([copy.truckRefid, copy.outsideVehicleRefId, copy.outsidePlateNo, copy.outsideDriverRefId], [0, 0, '', 0]);
  });

  test('the transfer and the RTI form carry the ids; the truck number is the Outside Truck', () {
    final items = PlanningTransfer.items([outsideRow()]);
    expect([items.single.outsideVehicleRefId, items.single.outsidePlateNo, items.single.outsideDriverRefId], [3, 'WA1229R', 9]);

    final form = RtiMapper.planningForm(items);
    expect([form.outsideVehicleRefId, form.outsideDriverRefId], [3, 9]);
  });

  test('the RTI save sends the ids only when there are some; an edit reads them back', () {
    const form = RtiForm(rtiDate: '2026-10-23', truckRefId: '68', driverRefId: '22', outsideVehicleRefId: 3, outsideDriverRefId: 9);
    final m = RtiSavePayloadBuilder.build(form, const [], const [], companyId: 6, employeeRefId: 1).master;
    expect([m['outsideVehicleRefId'], m['outsideDriverRefId']], [3, 9]);

    final own = RtiSavePayloadBuilder.build(const RtiForm(rtiDate: '2026-10-23'), const [], const [], companyId: 6, employeeRefId: 1).master;
    expect(own.containsKey('outsideVehicleRefId'), isFalse);

    final read = RtiMapper.form({'id': 5, 'outsideVehicleRefId': 3, 'outsideDriverRefId': 9});
    expect([read.outsideVehicleRefId, read.outsideDriverRefId], [3, 9]);
  });
}
