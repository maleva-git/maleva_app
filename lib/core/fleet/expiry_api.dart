import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// The truck and driver expiry lists, from the shared Java
/// `/api/master-reports/{trucks,drivers}/rows` (ports of .NET TruckReportView /
/// DriverReportView, change `master-reports-on-shared-java-api`). A driver
/// token gets only the truck on their record, or their own driver record.
/// A refusal is an [ApiFailure] with the server's message.
class ExpiryApi {
  ExpiryApi(this._dio, {required int Function() companyId}) : _companyId = companyId;

  final Dio _dio;
  final int Function() _companyId;

  int get companyId => _companyId();

  static final DateFormat _day = DateFormat('yyyy-MM-dd');

  /// Trucks (`id, truckNumber, truckNumber1, vehicleType`, the expiry and
  /// last-done dates as `yyyy-MM-dd`). With [until], only trucks with a date
  /// due by its window's end ([apadBonamUntil] / [serviceUntil] default to it).
  Future<List<Map<String, dynamic>>> trucks({
    int truckId = 0,
    DateTime? until,
    DateTime? apadBonamUntil,
    DateTime? serviceUntil,
  }) async =>
      _rows('/api/master-reports/trucks/rows', {
        if (truckId != 0) 'truckId': truckId,
        if (until != null) 'until': _day.format(until),
        if (until != null && apadBonamUntil != null) 'apadBonamUntil': _day.format(apadBonamUntil),
        if (until != null && serviceUntil != null) 'serviceUntil': _day.format(serviceUntil),
      });

  /// Drivers (`id, driverName, licenseNo, licenseExp, gdlExp`, the port
  /// passes ...). With [until], only drivers with a date due by then.
  Future<List<Map<String, dynamic>>> drivers({int driverId = 0, DateTime? until}) async =>
      _rows('/api/master-reports/drivers/rows', {
        if (driverId != 0) 'driverId': driverId,
        if (until != null) 'until': _day.format(until),
      });

  Future<List<Map<String, dynamic>>> _rows(String path, Map<String, dynamic> query) async {
    try {
      final response = await _dio.get<dynamic>(path, queryParameters: {'companyId': companyId, ...query});
      return JsonRead.listOfMaps(JavaResponse.data(response.data));
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }

  /// A Java date (`2026-10-05`) as .NET wrote these lists' dates: `2026/10/05`;
  /// no date is blank.
  static String legacyDate(dynamic value) {
    final d = JsonRead.date(value);
    return d == null ? '' : DateFormat('yyyy/MM/dd').format(d);
  }
}
