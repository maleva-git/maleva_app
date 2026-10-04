import 'package:dio/dio.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// Job orders, from the shared Java `/api/job-orders` (the web's API; the
/// .NET JobOrderMasterApp is no longer called, change
/// `job-orders-on-shared-java-api`). Answers the Java data as it is (camelCase
/// fields); a failure is an [ApiFailure] with the server's message.
class JobOrderApi {
  JobOrderApi(this._dio, {required int Function() companyId}) : _companyId = companyId;

  final Dio _dio;
  final int Function() _companyId;

  int get companyId => _companyId();

  /// Active job orders of the company (`id`, `cNumberDisplay`, `statusRefId`,
  /// `statusName`, `truckName`, `driverName`, `jobTypeName`, `jobDate`,
  /// `expectedCompletionDate`, `remarks`, ... and their `details`).
  /// [statusId] or [truckId] 0 means any.
  Future<List<Map<String, dynamic>>> list({int statusId = 0, int truckId = 0}) async =>
      JsonRead.listOfMaps(await _send(() => _dio.post<dynamic>('/api/job-orders/list', data: {
            'companyRefId': companyId,
            'statusRefId': statusId,
            'truckMasterRefId': truckId,
          })));

  /// Active job order statuses (`id`, `name`).
  Future<List<Map<String, dynamic>>> statuses() async =>
      JsonRead.listOfMaps(await _send(() => _dio.get<dynamic>('/api/job-orders/statuses')));

  /// Sets only the status of job order [id]; answers the updated job order.
  Future<Map<String, dynamic>> updateStatus(int id, int statusId) async => JsonRead.map(await _send(() =>
      _dio.put<dynamic>('/api/job-orders/$id/status',
          queryParameters: {'companyRefId': companyId, 'statusRefId': statusId})));

  /// The company's product names by id (`/api/product-masters/company/{id}`,
  /// which answers a bare list of `{id, pname}`).
  Future<Map<int, String>> productNames() async {
    try {
      final response = await _dio.get<dynamic>('/api/product-masters/company/$companyId');
      return {
        for (final p in JsonRead.listOfMaps(response.data)) JsonRead.integer(p['id']): JsonRead.string(p['pname']),
      };
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }

  Future<dynamic> _send(Future<Response<dynamic>> Function() call) async {
    try {
      return JavaResponse.data((await call()).data);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }
}
