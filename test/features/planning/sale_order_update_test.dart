import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/features/planning/data/sale_order_update.dart';
import 'package:maleva/features/planning/models/plan_line.dart';

/// The cases of `P/utils/planningSaleOrderUpdate.test.ts`.
SaleOrderDraft draft() => const SaleOrderDraft(
      saleOrderId: 21507,
      pickupDate: '2026-09-15T08:30',
      deliveryDate: '2026-09-16T17:00:00',
      originRefId: '5',
      destinationRefId: '',
      quantity: '4',
      weight: '114.96',
      origin: 'KLANG',
      destination: 'SINGAPORE',
      warehouseAddress: 'WESTPORT WAREHOUSE 3',
      warehouseEnterDate: '2026-09-15T10:00',
      warehouseExitDate: '',
      loadedPickupIds: [11, 12, 13],
      loadedDeliveryIds: [21],
      pickups: [
        StopRow(key: 'pickup-1', dbId: 11, address: 'WESTPORT', datetime: '2026-09-15T08:30', dateRequired: true, weight: '60', quantity: '2'),
        StopRow(key: 'pickup-2', dbId: 12, address: 'NORTHPORT', datetime: '2026-09-15T09:30', dateRequired: false, weight: '', quantity: '2'),
        StopRow(key: 'new-1', address: 'PORT KLANG', datetime: '', dateRequired: true, weight: '54.96', quantity: ''),
        StopRow(key: 'new-2', address: '', datetime: '', dateRequired: true, weight: '', quantity: ''),
      ],
      deliveries: [
        StopRow(key: 'delivery-1', dbId: 21, address: 'JURONG', datetime: '2026-09-16T17:00', dateRequired: true, weight: '114.96', quantity: '4'),
      ],
    );

void main() {
  group('buildPlanningJobUpdatePayload', () {
    test('sends only what the Update window edits - never totals or line items', () {
      final p = SaleOrderUpdateRules.payload(draft(), saleOrderId: 21507, companyId: 6, employeeId: 15);
      expect(p.keys.toList()..sort(), [
        'companyId',
        'deliveries',
        'deliveryDate',
        'destination',
        'destinationRefId',
        'employeeId',
        'origin',
        'originRefId',
        'pickupDate',
        'pickups',
        'quantity',
        'removedDeliveryIds',
        'removedPickupIds',
        'saleOrderId',
        'totalWeight',
        'wareHouseAddress',
        'wareHouseEnterDate',
        'wareHouseExitDate',
      ]);
      expect(p, containsPair('saleOrderId', 21507));
      expect(p, containsPair('companyId', 6));
      expect(p, containsPair('employeeId', 15));
      expect(p, containsPair('pickupDate', '2026-09-15T08:30'));
      expect(p, containsPair('deliveryDate', '2026-09-16T17:00:00'));
      expect(p, containsPair('origin', 'KLANG'));
      expect(p, containsPair('destination', 'SINGAPORE'));
      expect(p, containsPair('originRefId', 5));
      expect(p, containsPair('destinationRefId', null));
      expect(p, containsPair('quantity', '4'));
      expect(p, containsPair('totalWeight', '114.96'));
      expect(p, containsPair('wareHouseEnterDate', '2026-09-15T10:00'));
      expect(p, containsPair('wareHouseExitDate', null));
      expect(p, containsPair('wareHouseAddress', 'WESTPORT WAREHOUSE 3'));
    });

    test('sends saved stops with their id, new stops without one, and drops an empty new row', () {
      final p = SaleOrderUpdateRules.payload(draft(), saleOrderId: 21507, companyId: 6, employeeId: 0);
      expect(p['pickups'], [
        {'id': 11, 'address': 'WESTPORT', 'time': '2026-09-15T08:30', 'weight': '60', 'quantity': '2'},
        {'id': 12, 'address': 'NORTHPORT', 'time': null, 'weight': '', 'quantity': '2'},
        {'id': null, 'address': 'PORT KLANG', 'time': null, 'weight': '54.96', 'quantity': ''},
      ]);
      expect(p['deliveries'], [
        {'id': 21, 'address': 'JURONG', 'time': '2026-09-16T17:00', 'weight': '114.96', 'quantity': '4'},
      ]);
      expect(p['employeeId'], isNull);
    });

    test('states removed stops explicitly - only ones the job had when the window opened', () {
      final p = SaleOrderUpdateRules.payload(draft(), saleOrderId: 21507, companyId: 6, employeeId: 15);
      expect(p['removedPickupIds'], [13]);
      expect(p['removedDeliveryIds'], isEmpty);
    });
  });

  group('applySaleOrderUpdateToRows', () {
    final saved = {
      'ok': true,
      'saleOrderId': 21507,
      'pickupDate': '2026-09-15 08:30',
      'deliveryDate': '',
      'origin': 'KLANG',
      'destination': 'SINGAPORE',
      'packageType': '4/114.96',
      'wareHouseEnterDate': '2026-09-15 10:00',
      'wareHouseExitDate': '',
      'wareHouseAddress': 'WESTPORT WAREHOUSE 3',
      'pickupAddress': 'WESTPORT{@}NORTHPORT',
      'deliveryAddress': 'JURONG',
      'pickupQuantityList': '2{@}2',
      'deliveryQuantityList': '4',
    };

    test('updates every line of that job, clones included, and nothing else', () {
      final rows = [
        PlanLine(
            saleOrderMasterRefId: 21507, sdId: 1, truckName: 'WA 1234', remarks: '1ST TRIP', sPickupDate: '2026-09-14 08:00', packageType: '3/90'),
        PlanLine(saleOrderMasterRefId: 21500, sdId: 2, truckName: 'WB 55', sPickupDate: '2026-09-10 07:00', packageType: '1/10'),
        PlanLine(saleOrderMasterRefId: 21507, sdId: 0, truckName: '', sPickupDate: '2026-09-14 08:00', packageType: '3/90'),
      ];
      final next = SaleOrderUpdateRules.applyToRows(rows, saved);
      final a = next[0];
      expect([a.truckName, a.remarks, a.sPickupDate, a.sDeliveryDate, a.origin, a.packageType, a.pickupQuantitylist],
          ['WA 1234', '1ST TRIP', '2026-09-15 08:30', '', 'KLANG', '4/114.96', '2{@}2']);
      expect([next[2].sdId, next[2].packageType], [0, '4/114.96']);
      expect(identical(next[1], rows[1]), isTrue);
    });

    test('leaves the grid untouched when the response names no job', () {
      final rows = [PlanLine(saleOrderMasterRefId: 21507, sPickupDate: 'x')];
      expect(identical(SaleOrderUpdateRules.applyToRows(rows, {}), rows), isTrue);
      expect(identical(SaleOrderUpdateRules.applyToRows(rows, null), rows), isTrue);
    });
  });

  group('the draft from the sale order edit read', () {
    test('maps the job, the warehouse and the stops (React buildPlanningSaleOrderUpdateState)', () {
      final d = SaleOrderUpdateRules.draftFrom(21507, {
        'id': 21507,
        'cNumberDisplay': 'TR0026-0420',
        'customerName': 'SAMPLE TRADING',
        'pickupDate': '2026-09-15T08:30:00',
        'deliveryDate': null,
        'origin': 'KLANG',
        'destination': 'SINGAPORE',
        'originRefId': 5,
        'quantity': '4',
        'totalWeight': '114.96',
        'wareHouseAddress': 'WH 3',
        'wareHouseEnterDate': '0001-01-01T00:00:00',
      }, [
        {'id': 11, 'pickupAddress': 'WESTPORT', 'pickupTime': '2026-09-15T08:30:00', 'pickupWeight': '60', 'pickupQuantity': '2'},
      ], [])!;
      expect([d.orderNo, d.customerName, d.pickupDate, d.deliveryDate, d.originRefId, d.destinationRefId, d.weight, d.warehouseEnterDate],
          ['TR0026-0420', 'SAMPLE TRADING', '2026-09-15T08:30', '', '5', '', '114.96', '']);
      expect(d.pickups.single.dbId, 11);
      expect(d.pickups.single.datetime, '2026-09-15T08:30');
      expect(d.loadedPickupIds, [11]);
      expect(d.deliveries, isEmpty);
    });

    test('with one stop, its date follows the job date', () {
      final d = SaleOrderUpdateRules.draftFrom(1, {
        'id': 1
      }, [
        {'id': 3, 'pickupAddress': 'A', 'pickupTime': null}
      ], [])!;
      final next = d.withPickupDate('2026-10-05T09:00');
      expect([next.pickupDate, next.pickups.single.datetime, next.pickups.single.dateRequired], ['2026-10-05T09:00', '2026-10-05T09:00', true]);
    });

    test('no order is no draft', () => expect(SaleOrderUpdateRules.draftFrom(1, {}, [], []), isNull));
  });
}
