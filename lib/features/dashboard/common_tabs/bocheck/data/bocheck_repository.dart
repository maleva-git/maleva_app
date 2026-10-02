import 'package:dio/dio.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/models/shared/bo_detail_response.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_api_client.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// Bill order check, on the shared Java `POST /api/bills-order/select-bills-order-view`
/// (the same .NET `SelectBillsOrderView` the old `GetBillordercheck` called).
class BoCheckRepository {
  BoCheckRepository({Dio? dio}) : _dio = dio;

  final Dio? _dio;

  /// The bills and their lines for [body] (the search filter, .NET names); an empty
  /// result when nothing matches.
  Future<BoDetailResponse> fetchBocData({required Map<String, dynamic> body}) async {
    try {
      final response = await (_dio ?? sl<JavaApiClient>().dio)
          .post<dynamic>('/api/bills-order/select-bills-order-view', data: body);
      final m = JsonRead.map(response.data);
      if (m['ok'] != true) {
        // "No records found" is an ok:false answer, not a failure
        if (m['data'] == null && '${m['message']}'.contains('No records')) {
          return BoDetailResponse(masters: const [], details: const []);
        }
        throw ApiFailure(JsonRead.stringOrNull(m['message']) ?? 'Failed to load');
      }
      return BoDetailResponse.fromJava(JsonRead.map(m['data']));
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }
}
