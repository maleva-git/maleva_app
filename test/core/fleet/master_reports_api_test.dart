import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/fleet/expiry_api.dart';
import 'package:maleva/core/fleet/gps_api.dart';
import 'package:maleva/core/models/shared/driver_details_model.dart';
import 'package:maleva/core/models/shared/engine_hoursdata.dart';
import 'package:maleva/core/models/shared/truck_details_model.dart';
import 'package:maleva/features/transport/models/fuel_filling.dart';

import '../network/java_api_client_test.dart' show QueueAdapter;

Map<String, dynamic> ok(Object? data) => {'IsSuccess': true, 'StatusCode': 200, 'Message': 'Success', 'Data1': data};

/// The GPS lists and the truck / driver expiry lists on the shared Java APIs (master-reports-on-shared-java-api).
void main() {
  late QueueAdapter adapter;
  late Dio dio;

  setUp(() {
    adapter = QueueAdapter();
    dio = Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter;
  });

  String uri() => adapter.requests.last.uri.toString();

  test('GPS lists ask whole days, as the web does, and read the Java rows', () async {
    final gps = GpsApi(dio, companyId: () => 6);
    adapter.replies
      ..add((200, jsonEncode(ok([{'id': 1, 'truckName': 'VBC 5521', 'beginTime': '2026-10-05T08:30:00',
        'endTime': '2026-10-05T10:00:00', 'consumedByFlsInIdleRun': '1.2'}]))))
      ..add((200, jsonEncode(ok([{'id': 2, 'truckName': 'VBC 5521', 'time': '2026-10-05T09:15:00', 'filled': '40'}]))))
      ..add((200, jsonEncode(ok([]))));

    final hours = (await gps.engineHours(DateTime(2026, 10, 1), DateTime(2026, 10, 5))).map(EngineHoursdata.fromJava).single;
    expect(Uri.decodeFull(uri()),
        'https://java.test/api/gps/engine-hours?companyRefId=6&from=2026-10-01T00:00:00&to=2026-10-05T23:59:59');
    expect([hours.TruckName, hours.beginTime, hours.DbeginTime, hours.consumedbyFLSinidlerun],
        ['VBC 5521', '05/10/2026 08:30:00', '2026-10-05T08:30:00', '1.2']);

    final fill = (await gps.fuelFillings(DateTime(2026, 10, 1), DateTime(2026, 10, 5))).map(FuelFilling.fromJava).single;
    expect(uri(), startsWith('https://java.test/api/gps/fuel-fillings?'));
    expect([fill.truckName, fill.time, fill.filled], ['VBC 5521', '05/10/2026 09:15:00', '40']);

    expect(await gps.speedReports(DateTime(2026, 10, 1), DateTime(2026, 10, 5)), isEmpty);
    expect(uri(), startsWith('https://java.test/api/gps/speed-reports?'));
  });

  test('truck and driver expiry lists', () async {
    final expiry = ExpiryApi(dio, companyId: () => 6);
    adapter.replies
      ..add((200, jsonEncode(ok([{'id': 3, 'truckNumber': 'VBC 5521', 'vehicleType': 'PRIME MOVER',
        'insuranceExp': '2026-10-08', 'greaseExp': '2026-11-01', 'sidExp': null}]))))
      ..add((200, jsonEncode(ok([{'id': 7, 'driverName': 'RAVI-DRV-1', 'licenseNo': 'L1', 'licenseExp': '2026-10-09'}]))));

    final truck = (await expiry.trucks(until: DateTime(2026, 10, 10))).map(TruckDetailsModel.fromJavaExpiry).single;
    expect(uri(), 'https://java.test/api/master-reports/trucks/rows?companyId=6&until=2026-10-10');
    expect([truck.Id, truck.TruckNumber, truck.TruckType, truck.InsuratnceExp, truck.GreeceExp, truck.SIDExp],
        [3, 'VBC 5521', 'PRIME MOVER', '2026/10/08', '2026/11/01', '']);

    final driver = (await expiry.drivers(driverId: 7)).map(DriverDetailsModel.fromJava).single;
    expect(uri(), 'https://java.test/api/master-reports/drivers/rows?companyId=6&driverId=7');
    expect([driver.Id, driver.DriverName, driver.licenseNo, driver.licenseExp], [7, 'RAVI-DRV-1', 'L1', '2026-10-09']);
  });
}
