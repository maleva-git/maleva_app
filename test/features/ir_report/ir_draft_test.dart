import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/features/ir_report/domain/entities/ir_draft.dart';
import 'package:maleva/features/ir_report/domain/entities/ir_lookup.dart';
import 'package:maleva/features/ir_report/domain/entities/ir_report.dart';

void main() {
  const open = IrStatus(id: 1, code: 'OPEN', name: 'Open', colorCode: '#DC2626');
  const transportation = LookupOption(id: 1000, name: 'TRANSPORTATION');
  const truck = LookupOption(id: 5, name: 'WLN 1234');

  IrDraft complete() => IrDraft(
        irDate: DateTime(2026, 9, 14, 10, 30),
        status: open,
        department: transportation,
        description: 'Spare dropped into the sea while loading',
      );

  group('validate', () {
    test('a blank draft names every required field', () {
      final errors = const IrDraft().validate();

      expect(
        errors.keys,
        containsAll([IrField.irDate, IrField.status, IrField.department, IrField.description]),
      );
    });

    test('a complete draft has no errors', () {
      expect(complete().validate(), isEmpty);
    });

    test('a description of only spaces is still missing', () {
      final errors = complete().copyWith(description: '   ').validate();

      expect(errors[IrField.description], isNotNull);
    });

    test('an amount with decimals is rejected, because the column is an int', () {
      final draft = complete().copyWith(amountText: '300.50');

      expect(draft.validate()[IrField.amount], 'Whole ringgit only, no decimals');
      expect(draft.amount, isNull);
    });

    test('a whole amount is accepted', () {
      final draft = complete().copyWith(amountText: ' 300 ');

      expect(draft.validate(), isEmpty);
      expect(draft.amount, 300);
    });

    test('a reason longer than the column is rejected', () {
      final errors = complete().copyWith(reason: 'x' * 1001).validate();

      expect(errors[IrField.reason], isNotNull);
    });

    test('a typed lorry plate longer than the column is rejected', () {
      final draft = complete().withParty(IrField.truck, IrParty.empty.typed('x' * 101));

      expect(draft.validate()[IrField.truck], isNotNull);
    });
  });

  group('IrParty', () {
    test('a picked row sends its id and no name', () {
      final party = IrParty.empty.picked(truck);

      expect(party.refId, 5);
      expect(party.name, '');
    });

    test('a typed name sends the name with id 0', () {
      final party = IrParty.empty.typed('  Hired lorry BKA 9 ');

      expect(party.refId, 0);
      expect(party.name, 'Hired lorry BKA 9');
    });

    test('switching back to the list drops the typed name', () {
      final party = IrParty.empty.typed('Outside driver').withManual(false);

      expect(party.manual, isFalse);
      expect(party.refId, 0);
      expect(party.name, '');
    });
  });

  group('fromReport', () {
    const lookups = IrLookups(
      statuses: [open],
      departments: [transportation],
      trucks: [truck],
    );

    IrReport saved({int? truckId, String? truckNo, int? driverId, String? driverName}) => IrReport(
          id: 12,
          irDate: DateTime(2026, 9, 10, 8, 15),
          statusId: 1,
          description: 'Truck accident',
          departmentId: 1000,
          departmentName: 'TRANSPORTATION',
          truckId: truckId,
          truckNo: truckNo,
          driverId: driverId,
          driverName: driverName,
          actualAmount: 4500,
        );

    test('resolves the saved ids against the dropdown lists', () {
      final draft = IrDraft.fromReport(saved(truckId: 5, truckNo: 'WLN 1234'), lookups);

      expect(draft.id, 12);
      expect(draft.status, open);
      expect(draft.department, transportation);
      expect(draft.truck.selected, truck);
      expect(draft.amountText, '4500');
    });

    test('keeps a truck that is no longer in the list, with its stored plate', () {
      final draft = IrDraft.fromReport(saved(truckId: 9, truckNo: 'OLD 1'), lookups);

      expect(draft.truck.selected, const LookupOption(id: 9, name: 'OLD 1'));
      expect(draft.truck.refId, 9);
    });

    test('a name without an id is an outside driver, typed', () {
      final draft = IrDraft.fromReport(saved(driverName: 'Ali (outside)'), lookups);

      expect(draft.driver.manual, isTrue);
      expect(draft.driver.name, 'Ali (outside)');
      expect(draft.driver.refId, 0);
    });
  });
}
