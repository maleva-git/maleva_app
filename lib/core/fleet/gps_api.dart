import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// The GPS (Wialon) lists, from the shared Java `/api/gps/*` the web's GPS
/// screens use (the .NET MasterReportApp is no longer called for these,
/// change `master-reports-on-shared-java-api`). Answers the Java rows as they
/// are; a refusal is an [ApiFailure] with the server's message.
class GpsApi {
  GpsApi(this._dio, {required int Function() companyId}) : _companyId = companyId;

  final Dio _dio;
  final int Function() _companyId;

  int get companyId => _companyId();

  static final DateFormat _day = DateFormat('yyyy-MM-dd');

  /// Engine hours whose begin time falls in the days (both included):
  /// `id, truckRefId, truckName, beginTime, endTime, beginLocation,
  /// endLocation, totalTime, inMotion, idling, mileage, consumedByFlsInIdleRun`.
  Future<List<Map<String, dynamic>>> engineHours(DateTime from, DateTime to, {int truckId = 0}) =>
      _list('/api/gps/engine-hours', from, to, truckId);

  /// Fuel fillings in the days: `id, truckRefId, truckName, vehicle, time,
  /// location, count, filled, driver`.
  Future<List<Map<String, dynamic>>> fuelFillings(DateTime from, DateTime to, {int truckId = 0}) =>
      _list('/api/gps/fuel-fillings', from, to, truckId);

  /// Speeding records in the days, the same fields as fuel fillings.
  Future<List<Map<String, dynamic>>> speedReports(DateTime from, DateTime to, {int truckId = 0}) =>
      _list('/api/gps/speed-reports', from, to, truckId);

  /// Whole days, as the web sends them: from 00:00:00 to 23:59:59.
  Future<List<Map<String, dynamic>>> _list(String path, DateTime from, DateTime to, int truckId) async =>
      JsonRead.listOfMaps(await _send(() => _dio.get<dynamic>(path, queryParameters: {
            'companyRefId': companyId,
            if (truckId != 0) 'truckRefId': truckId,
            'from': '${_day.format(from)}T00:00:00',
            'to': '${_day.format(to)}T23:59:59',
          })));

  Future<dynamic> _send(Future<Response<dynamic>> Function() call) async {
    try {
      return JavaResponse.data((await call()).data);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }

  /// A Java date-time as .NET formatted it for these lists: `dd/MM/yyyy HH:mm:ss`.
  static String display(dynamic value) {
    final d = JsonRead.date(value);
    return d == null ? '' : DateFormat('dd/MM/yyyy HH:mm:ss').format(d);
  }
}
