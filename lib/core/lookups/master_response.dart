import 'package:dio/dio.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// The master-data controllers (customers, job types, locations) answer the
/// `agentcompany` wrapper `{success, statusCode, message, data}`, not the usual
/// `ApiResponse`; this reads it as it is (rule 2: the app adapts, the API does
/// not change).
class MasterResponse {
  MasterResponse._();

  /// `data` of a successful answer. A 404 is [emptyOn404] (some lists answer
  /// 404 when the company has none); any other refusal is an [ApiFailure].
  static Future<dynamic> data(Future<Response<dynamic>> Function() call, {bool emptyOn404 = false}) async {
    final Response<dynamic> response;
    try {
      response = await call();
    } on DioException catch (e) {
      if (emptyOn404 && e.response?.statusCode == 404) return const [];
      throw JavaResponse.fromDio(e);
    }
    final body = response.data;
    // some lists answer 204 No Content when the company has none
    if (response.statusCode == 204 || body == null || (body is String && body.trim().isEmpty)) return const [];
    if (body is! Map || !JsonRead.boolean(body['success'])) {
      throw ApiFailure(body is Map ? JsonRead.string(body['message']) : 'Unexpected response from server');
    }
    return body['data'];
  }
}
