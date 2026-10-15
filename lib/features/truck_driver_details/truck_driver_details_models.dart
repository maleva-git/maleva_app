import 'package:maleva/core/utils/json_read.dart';

/// The Truck & Driver Details sheet, read straight from the shared Java
/// `GET /api/truck-driver-details` (the same answer the web page reads):
/// `Data1 = {vehicle, driver}`, either half null when it was not asked for.

class SheetVehicle {
  const SheetVehicle({
    required this.truckId,
    this.truckNumber = '',
    this.truckNumber1 = '',
    this.capacity = '',
    this.sealType = '',
    this.bondNo = '',
    this.bondExp = '',
    this.driverRefId,
  });

  factory SheetVehicle.fromJava(Map<String, dynamic> json) => SheetVehicle(
        truckId: JsonRead.integer(json['truckId']),
        truckNumber: JsonRead.string(json['truckNumber']).trim(),
        truckNumber1: JsonRead.string(json['truckNumber1']).trim(),
        capacity: JsonRead.string(json['capacity']).trim(),
        sealType: JsonRead.string(json['sealType']).trim(),
        bondNo: JsonRead.string(json['bondNo']).trim(),
        bondExp: JsonRead.string(json['bondExp']).trim(),
        driverRefId: JsonRead.intOrNull(json['driverRefId']),
      );

  final int truckId;
  final String truckNumber;

  /// Trailer plate; blank when the truck has none.
  final String truckNumber1;
  final String capacity;
  final String sealType;
  final String bondNo;

  /// `yyyy-MM-dd`, blank when not set.
  final String bondExp;

  /// The driver who normally drives this truck.
  final int? driverRefId;

  /// Head and trailer plates as one Truck No: `JTB 7151 /T/JA3749`.
  String get truckNo {
    final trailer = truckNumber1.replaceFirst(RegExp(r'^/?\s*T\s*/', caseSensitive: false), '').trim();
    if (trailer.isEmpty) return truckNumber;
    return truckNumber.isEmpty ? trailer : '$truckNumber /T/$trailer';
  }

  List<SheetRow> get rows => [
        SheetRow('TRUCK NO', truckNo),
        SheetRow('CAPACITY', capacity),
        SheetRow('SEAL', sealType),
        SheetRow('BOND NO', bondNo),
        SheetRow('BOND EXP DATE', sheetDate(bondExp)),
      ];
}

class SheetDriver {
  const SheetDriver({
    required this.driverId,
    this.driverName = '',
    this.nricNo = '',
    this.mobileNo = '',
    this.passportNo = '',
  });

  factory SheetDriver.fromJava(Map<String, dynamic> json) => SheetDriver(
        driverId: JsonRead.integer(json['driverId']),
        driverName: JsonRead.string(json['driverName']).trim(),
        nricNo: JsonRead.string(json['nricNo']).trim(),
        mobileNo: JsonRead.string(json['mobileNo']).trim(),
        passportNo: JsonRead.string(json['passportNo']).trim(),
      );

  final int driverId;
  final String driverName;
  final String nricNo;
  final String mobileNo;
  final String passportNo;

  List<SheetRow> get rows => [
        SheetRow('DRIVER NAME', driverName),
        SheetRow('NRIC NO', nricNo),
        SheetRow('CONTACT NO', mobileNo),
        SheetRow('PASSPORT NO', passportNo),
      ];
}

/// One printed line of the sheet.
class SheetRow {
  const SheetRow(this.label, this.value);
  final String label;
  final String value;
}

/// `yyyy-MM-dd` as `dd-MM-yyyy`, the way the sheet prints dates.
String sheetDate(String value) {
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(value.trim());
  return match == null ? value.trim() : '${match[3]}-${match[2]}-${match[1]}';
}

/// A file name from what is printed, safe on every phone: Truck-Driver-Details-...,
/// or Vehicle-Details-... / Driver-Details-... for one half.
String sheetFileName(SheetVehicle? vehicle, SheetDriver? driver) {
  final prefix = vehicle != null && driver == null
      ? 'Vehicle-Details'
      : driver != null && vehicle == null
          ? 'Driver-Details'
          : 'Truck-Driver-Details';
  final parts = [vehicle?.truckNumber ?? '', driver?.driverName ?? '']
      .where((part) => part.trim().isNotEmpty)
      .map((part) => part.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '-').replaceAll(RegExp(r'^-+|-+$'), ''))
      .toList();
  return '$prefix${parts.isEmpty ? '' : '-${parts.join('-')}'}.pdf';
}
