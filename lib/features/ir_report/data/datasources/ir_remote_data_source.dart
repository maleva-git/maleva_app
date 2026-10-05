import 'package:maleva/core/fleet/truck_api.dart';
import 'package:dio/dio.dart';
import 'package:maleva/core/fleet/driver_api.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// The HTTP calls behind the IR screens: the Java `/api/ir` API the web app
/// uses, plus the pickers' lists. Sent through `JavaApiClient`'s Dio (session
/// token, refresh on 401).
///
/// Returns raw JSON; turning it into entities is the repository's job. Every
/// failure leaves here as an `ApiFailure` with the server's message.
class IrRemoteDataSource {
  IrRemoteDataSource(this._dio);

  final Dio _dio;

  /// `{items, count, totalAmount}`.
  Future<Map<String, dynamic>> search(Map<String, dynamic> query) async =>
      JsonRead.map(await _data(() => _dio.get<dynamic>('/api/ir', queryParameters: query)));

  Future<Map<String, dynamic>> getById(int id, int companyId) async => JsonRead.map(
      await _data(() => _dio.get<dynamic>('/api/ir/$id', queryParameters: {'companyRefId': companyId})));

  Future<Map<String, dynamic>> save(Map<String, dynamic> body) async =>
      JsonRead.map(await _data(() => _dio.post<dynamic>('/api/ir', data: body)));

  Future<void> delete(int id, int companyId) =>
      _data(() => _dio.delete<dynamic>('/api/ir/$id', queryParameters: {'companyRefId': companyId}));

  Future<List<Map<String, dynamic>>> statuses(int companyId) async => JsonRead.listOfMaps(
      await _data(() => _dio.get<dynamic>('/api/ir/statuses', queryParameters: {'companyRefId': companyId})));

  Future<List<Map<String, dynamic>>> departments() async =>
      JsonRead.listOfMaps(await _data(() => _dio.get<dynamic>('/api/ir/departments')));

  /// Every active employee of the company (a bare list, `{id, employeeName}`).
  Future<List<Map<String, dynamic>>> employees(int companyId) =>
      _list(() => _dio.get<dynamic>('/api/employees/company/$companyId/all'));

  // The truck and driver pickers read the shared lookups (`{Id, AccountName}` rows).

  // the shared Java /api/truck-combo rows ({Id, AccountName})
  Future<List<Map<String, dynamic>>> trucks(int companyId) => TruckApi(_dio, companyId: () => companyId).combo();

  // the shared Java /api/driver-combo rows ({Id, AccountName})
  Future<List<Map<String, dynamic>>> drivers(int companyId) => DriverApi(_dio, companyId: () => companyId).combo();

  Future<dynamic> _data(Future<Response<dynamic>> Function() call) async {
    try {
      return JavaResponse.data((await call()).data);
    } on DioException catch (error) {
      throw JavaResponse.fromDio(error);
    }
  }

  Future<List<Map<String, dynamic>>> _list(Future<Response<dynamic>> Function() call) async {
    try {
      return JsonRead.listOfMaps((await call()).data);
    } on DioException catch (error) {
      throw JavaResponse.fromDio(error);
    }
  }
}
