import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/features/truck_driver_details/truck_driver_details_models.dart';
import 'package:maleva/features/truck_driver_details/truck_driver_details_pdf.dart';

void main() {
  final vehicle = SheetVehicle.fromJava({
    'truckId': 12,
    'truckNumber': 'JTB 7151',
    'truckNumber1': 'JA3749',
    'capacity': '40FT',
    'sealType': '5-SEAL',
    'bondNo': '10000037/25',
    'bondExp': '2027-05-05',
    'driverRefId': 40,
  });
  final driver = SheetDriver.fromJava({
    'driverId': 40,
    'driverName': 'MUHAMMAD NAZRUL HADI BIN AHMAD KARAMI',
    'nricNo': '970423055263',
    'mobileNo': '+60 18-218 5263',
    'passportNo': 'A63412298',
  });

  test('reads the Java fields into the sheet rows', () {
    expect(vehicle.rows.map((r) => r.value),
        ['JTB 7151 /T/JA3749', '40FT', '5-SEAL', '10000037/25', '05-05-2027']);
    expect(vehicle.driverRefId, 40);
    expect(driver.rows.map((r) => r.label), ['DRIVER NAME', 'NRIC NO', 'CONTACT NO', 'PASSPORT NO']);
    expect(driver.rows[1].value, '970423055263');
  });

  test('a trailer typed with its T/ prefix is not given a second one', () {
    expect(SheetVehicle.fromJava({'truckId': 1, 'truckNumber': 'JTB 7151', 'truckNumber1': 'T/JA3749'}).truckNo,
        'JTB 7151 /T/JA3749');
    expect(SheetVehicle.fromJava({'truckId': 1, 'truckNumber': 'JTB 7151'}).truckNo, 'JTB 7151');
  });

  test('names the file after the truck and the driver', () {
    expect(sheetFileName(vehicle, driver), 'Truck-Driver-Details-JTB-7151-MUHAMMAD-NAZRUL-HADI-BIN-AHMAD-KARAMI.pdf');
    expect(sheetFileName(vehicle, null), 'Vehicle-Details-JTB-7151.pdf');
    expect(sheetFileName(null, driver), 'Driver-Details-MUHAMMAD-NAZRUL-HADI-BIN-AHMAD-KARAMI.pdf');
    expect(sheetFileName(null, null), 'Truck-Driver-Details.pdf');
  });

  test('builds the PDF for both halves and for each one alone', () async {
    for (final part in SheetPart.values) {
      final bytes = await buildTruckDriverDetailsPdf(vehicle, driver, part: part);
      expect(String.fromCharCodes(bytes.take(4)), '%PDF', reason: part.name);
    }
  });
}
