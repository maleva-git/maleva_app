import 'package:dio/dio.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// Fuel entries, from the shared Java `/api/fuel-entries` (the web's API; the
/// .NET FuelEntryApp is no longer called, change `fuel-entry-on-shared-java-api`).
/// Answers the Java data as it is (camelCase fields); a refusal is an
/// [ApiFailure] with the server's message. For a driver token the server keeps
/// the list, save and delete to the driver's own app entries.
class FuelEntryApi {
  FuelEntryApi(this._dio, {required int Function() companyId}) : _companyId = companyId;

  final Dio _dio;
  final int Function() _companyId;

  int get companyId => _companyId();

  /// The list rows (`id`, `cNumberDisplay`, `saleDate`, `truckRefId`,
  /// `truckName`, `driverRefId`, `driverName`, `aliter`, `aAmount`, `pliter`,
  /// `pAmount`, `pRate`, `gliter`, `gAmount`, `diffLiter`, `diffAmount`,
  /// `fStatus`, `remarks`, `filePath`). Dates are `yyyy-MM-dd` (a longer
  /// value is cut to its date); a truck or driver of 0 means any.
  Future<List<Map<String, dynamic>>> list({
    required String fromDate,
    required String toDate,
    int truckId = 0,
    int driverId = 0,
  }) async {
    final data = await _send(() => _dio.get<dynamic>('/api/fuel-entries', queryParameters: {
          'companyRefId': companyId,
          if (_dateOnly(fromDate) != null) 'fromDate': _dateOnly(fromDate),
          if (_dateOnly(toDate) != null) 'toDate': _dateOnly(toDate),
          if (truckId != 0) 'truckRefId': truckId,
          if (driverId != 0) 'driverRefId': driverId,
        }));
    return data is Map ? JsonRead.listOfMaps(data['items']) : const [];
  }

  /// The number the next new entry will take, e.g. `FE000000072`.
  Future<String> nextNumber() async => JsonRead.string(
      await _send(() => _dio.get<dynamic>('/api/fuel-entries/next-no', queryParameters: {'companyRefId': companyId})));

  /// Creates (id 0) or updates an entry; [entry] is the Java save request
  /// (`id`, `truckRefId`, `driverRefId`, `employeeRefId`, `saleDate`, `aliter`,
  /// `aAmount`, `pliter`, `gliter`, `pRate`, `remarks`, `filePath`, `fStatus`).
  /// The company is added here. Answers the saved entry.
  Future<Map<String, dynamic>> save(Map<String, dynamic> entry) async => JsonRead.map(await _send(() =>
      _dio.post<dynamic>('/api/fuel-entries', data: {...entry, 'companyRefId': companyId})));

  /// Soft delete; [mobile] keeps it to driver-app rows.
  Future<void> delete(int id, {bool mobile = false}) async {
    await _send(() => _dio.delete<dynamic>('/api/fuel-entries/$id',
        queryParameters: {'companyRefId': companyId, 'mobile': mobile}));
  }

  static String? _dateOnly(String value) {
    final text = value.trim();
    if (text.isEmpty) return null;
    return text.length >= 10 ? text.substring(0, 10) : text;
  }

  Future<dynamic> _send(Future<Response<dynamic>> Function() call) async {
    try {
      return JavaResponse.data((await call()).data);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }
}
