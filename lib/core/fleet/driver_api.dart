import 'package:dio/dio.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// Drivers, from the shared Java `/api/driver-masters/search` that React's
/// driver list uses (the port of .NET DriverApp/SelectDriver, change
/// `license-on-shared-java-api`). A driver is the Java `DriverMasterDto`:
/// `id`, `driverName`, `mobileNo`, `email`, `active`, `licenseNo`,
/// `licenseExp` / `gdlExp` / `joiningDate` (`yyyy-MM-dd`), `gdlNo`,
/// `accountCode`, ...
class DriverApi {
  DriverApi(this._dio, {required int Function() companyId}) : _companyId = companyId;

  final Dio _dio;
  final int Function() _companyId;

  int get companyId => _companyId();

  /// The company's drivers that are not deleted, by id: [pageCount] from
  /// [startIndex] (0 = all). [column] DriverName, MobileNo, Id or All filters
  /// by [keyword].
  Future<List<Map<String, dynamic>>> search({
    int startIndex = 0,
    int pageCount = 0,
    String keyword = '',
    String column = 'All',
  }) async {
    try {
      final response = await _dio.get<dynamic>('/api/driver-masters/search', queryParameters: {
        'companyId': companyId,
        'startIndex': startIndex,
        'pageCount': pageCount,
        'keyword': keyword,
        'column': column,
      });
      return JsonRead.listOfMaps(JsonRead.map(JavaResponse.data(response.data))['items']);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }

  /// The active drivers for a picker (optionally of a [type]), from the shared
  /// Java `GET /api/driver-combo` (the port of .NET DriverApp/GetDriver; change
  /// `driver-lookups-on-shared-java-api`): `{Id, AccountName = "name-mobile"}`
  /// rows (the Java model names them so) in a `{isSuccess, data1}` wrapper.
  Future<List<Map<String, dynamic>>> combo({String? type}) async {
    final Response<dynamic> response;
    try {
      response = await _dio.get<dynamic>('/api/driver-combo', queryParameters: {
        'companyId': companyId,
        if (type != null && type.isNotEmpty) 'type': type,
      });
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
    final body = response.data;
    if (body is! Map || !JsonRead.boolean(JsonRead.field(body, 'isSuccess'))) {
      throw ApiFailure(body is Map ? JsonRead.string(JsonRead.field(body, 'message')) : 'Unexpected response from server');
    }
    return JsonRead.listOfMaps(JsonRead.field(body, 'data1'));
  }

  /// Every driver with licence expiry dates and leaves, as the web's Planning and RTI pickers
  /// load them (`GET /api/driver-masters/selectalldriverDetails?companyId`,
  /// `FE/api/driverApi.ts:149-168`): `DriverMasterDto` rows in `Data1`.
  Future<List<Map<String, dynamic>>> allDetails() async {
    try {
      final r = await _dio.get<dynamic>('/api/driver-masters/selectalldriverDetails', queryParameters: {'companyId': companyId});
      return JsonRead.listOfMaps(JavaResponse.data(r.data));
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }
}
