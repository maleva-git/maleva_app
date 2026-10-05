import 'package:dio/dio.dart';
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
}
