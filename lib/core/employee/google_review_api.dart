import 'package:dio/dio.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// Staff Google reviews, from the shared Java `/api/google-reviews` (ported
/// from .NET EmployeeApp and SP_GoogleReview, change
/// `google-review-on-shared-java-api`). A refusal is an [ApiFailure] with the
/// server's message. A save is posted to the staff WhatsApp group by the server.
class GoogleReviewApi {
  GoogleReviewApi(this._dio, {required int Function() companyId}) : _companyId = companyId;

  final Dio _dio;
  final int Function() _companyId;

  int get companyId => _companyId();

  /// Reviews dated in the days (`yyyy-MM-dd`), one employee's when
  /// [employeeId] is not 0: `id, refDate, employeeRefId, employeeName,
  /// googleReview, googleMsg, shopName, mobileNo`.
  Future<List<Map<String, dynamic>>> list({required String fromDate, required String toDate, int employeeId = 0}) async =>
      JsonRead.listOfMaps(await _send(() => _dio.get<dynamic>('/api/google-reviews', queryParameters: {
            'companyId': companyId,
            'fromDate': fromDate,
            'toDate': toDate,
            if (employeeId != 0) 'employeeId': employeeId,
          })));

  /// Adds (id 0) or updates a review; answers the id.
  Future<int> save({
    int id = 0,
    required String refDate,
    required int employeeId,
    required int googleReview,
    required String googleMsg,
    required String shopName,
    required String mobileNo,
  }) async =>
      JsonRead.integer(await _send(() => _dio.post<dynamic>('/api/google-reviews',
          queryParameters: {'companyId': companyId},
          data: {
            'id': id,
            'refDate': refDate,
            'employeeRefId': employeeId,
            'googleReview': googleReview,
            'googleMsg': googleMsg,
            'shopName': shopName,
            'mobileNo': mobileNo,
          })));

  Future<void> delete(int id) async {
    await _send(() => _dio.delete<dynamic>('/api/google-reviews/$id', queryParameters: {'companyId': companyId}));
  }

  Future<dynamic> _send(Future<Response<dynamic>> Function() call) async {
    try {
      return JavaResponse.data((await call()).data);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }
}
