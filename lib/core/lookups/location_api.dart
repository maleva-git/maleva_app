import 'package:dio/dio.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// Locations, from the shared Java
/// `/api/location-master/company/{companyId}/active` (the port of .NET
/// LocationApp/SelectLocation: the company's locations that are not deleted,
/// change `location-on-shared-java-api`). That endpoint answers
/// `{success, statusCode, message, data}`, not the usual `ApiResponse`; it is
/// read as it is. A location is `id`, `companyRefId`, `location`, `active`.
class LocationApi {
  LocationApi(this._dio, {required int Function() companyId}) : _companyId = companyId;

  final Dio _dio;
  final int Function() _companyId;

  int get companyId => _companyId();

  Future<List<Map<String, dynamic>>> locations() async {
    final Response<dynamic> response;
    try {
      response = await _dio.get<dynamic>('/api/location-master/company/$companyId/active');
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
    final body = response.data;
    if (body is! Map || !JsonRead.boolean(body['success'])) {
      throw ApiFailure(body is Map ? JsonRead.string(body['message']) : 'Unexpected response from server');
    }
    return JsonRead.listOfMaps(body['data']);
  }
}
