import 'package:maleva/features/rti/models/js_values.dart';
import 'package:maleva/features/rti/models/rti_dates.dart';
import 'package:maleva/features/rti/models/rti_form.dart';
import 'package:maleva/features/rti/models/rti_job_row.dart';

/// The allowances of one RTI (`R/components/RTIFormFields.tsx:170-192` `getChargeBreakdown`).
class RtiCharges {
  const RtiCharges({
    required this.sleeping,
    required this.emptyPickup,
    required this.emptyDelivery,
    required this.pickup,
    required this.drop,
    required this.manpower,
  });

  factory RtiCharges.of(RtiForm f) {
    num count(String v) => Js.toNumber(v.isEmpty ? '0' : v) ?? double.nan;
    num empty(String v) => v == 'EMPTY 80' ? 80 : (v == 'EMPTY 50' ? 50 : 0);
    return RtiCharges(
      sleeping: f.sleeping == 'YES' ? 50 : 0,
      emptyPickup: empty(f.exitYN),
      emptyDelivery: empty(f.emptyDeliveryYN),
      pickup: f.pickup == 'YES' ? count(f.pickupCount) * 30 : 0,
      drop: f.addDrop == 'YES' ? count(f.dropCount) * 30 : 0,
      manpower: f.manpw == '1' ? 50 : (f.manpw == '2' ? 100 : 0),
    );
  }

  final num sleeping;
  final num emptyPickup;
  final num emptyDelivery;
  final num pickup;
  final num drop;
  final num manpower;
}

/// The RTI amount and the save checks, as the web computes them.
abstract final class RtiRules {
  /// `RTICalculationService.calculate` (`R/services/calculationService.ts:13-59`): the jobs'
  /// salaries, sleeping 50, empty pickup / delivery 80 or 50, manpower 50 or 100, pickups
  /// and drops 30 each when YES; rounded to 2 places.
  static double total(RtiForm f, List<RtiJobRow> grid) {
    double t = 0;
    for (final row in grid) {
      t += row.salaryForTotal;
    }
    if (f.sleeping == 'YES') t += 50;
    if (f.exitYN == 'EMPTY 80') {
      t += 80;
    } else if (f.exitYN == 'EMPTY 50') {
      t += 50;
    }
    if (f.emptyDeliveryYN == 'EMPTY 80') {
      t += 80;
    } else if (f.emptyDeliveryYN == 'EMPTY 50') {
      t += 50;
    }
    if (f.manpw == '1') {
      t += 50;
    } else if (f.manpw == '2') {
      t += 100;
    }
    if (f.pickup == 'YES') t += 30 * (Js.parseFloat(f.pickupCount.isEmpty ? '0' : f.pickupCount) ?? double.nan);
    if (f.addDrop == 'YES') t += 30 * (Js.parseFloat(f.dropCount.isEmpty ? '0' : f.dropCount) ?? double.nan);
    if (!t.isFinite) return t;
    return double.parse(t.toStringAsFixed(2));
  }

  /// The grid's Salary badge: `Σ Number(row.Salary || 0)`.
  static double salaryTotal(List<RtiJobRow> grid) =>
      grid.fold<double>(0, (sum, r) => sum + (Js.toNumber(r.salary.isEmpty ? '0' : r.salary) ?? double.nan).toDouble());

  /// `RTIValidationService.validateForm` (`R/model/rti.validation.ts:46-81`): every problem,
  /// in the web's order and words.
  static List<String> validate(RtiForm f, List<RtiJobRow> grid) {
    final errors = <String>[];
    if (f.driverRefId.isEmpty) errors.add('Please select Driver Name');
    if (f.truckRefId.isEmpty) errors.add('Please select Vehicle Number');
    if (f.rtiDate.isEmpty) errors.add('Please select RTI Date');
    if (grid.isEmpty) errors.add('Please add at least one job');
    for (var i = 0; i < grid.length; i++) {
      final row = grid[i];
      if (row.jobNo.trim().isEmpty) {
        errors.add('Row ${i + 1}: Job No is required');
      } else if (!(row.saleOrderMasterRefId > 0)) {
        errors.add(rowNotFound(i, row.jobNo));
      }
    }
    return errors;
  }

  /// The message of a row whose job was never looked up.
  static String rowNotFound(int index, String jobNo) =>
      'Row ${index + 1}: job ${jobNo.trim()} was not found. Press Enter in Job No to look it up, or remove the row.';

  /// `TRUCK_LICENSE_FIELDS` (`R/model/rti.schema.ts:103-116`): field, name.
  static const truckLicenseFields = [
    ('RotexMyExp', 'RotexMy'),
    ('RotexSGExp', 'RotexSG'),
    ('PuspacomExp', 'Puspacom'),
    ('RotexMyExp1', 'RotexMyExp1'),
    ('RotexSGExp1', 'RotexSGExp1'),
    ('PuspacomExp1', 'PuspacomExp1'),
    ('InsuratnceExp', 'Insuratnce'),
    ('BonamExp', 'Bonam'),
    ('ApadExp', 'Apad'),
    ('ServiceExp', 'Service'),
    ('AlignmentExp', 'Alignment'),
    ('GreeceExp', 'Greece'),
  ];

  /// `validateTruckLicense` (`R/model/rti.validation.ts:16-41`): the licences that end within
  /// 5 days, and the web's message; null when none.
  static String? truckLicenseMessage(Map<String, dynamic>? truck, {DateTime? now}) {
    if (truck == null) return null;
    final before = (now ?? DateTime.now()).add(const Duration(days: 5));
    final expired = <String>[];
    for (final (field, name) in truckLicenseFields) {
      final value = Js.field(truck, [field]);
      if (value == null || Js.str(value).isEmpty) continue;
      final d = RtiDates.parse(value);
      if (d != null && !d.isAfter(before)) expired.add(name);
    }
    return expired.isEmpty ? null : '${expired.join(', ')} - License expired / Going to be expired !!';
  }
}
