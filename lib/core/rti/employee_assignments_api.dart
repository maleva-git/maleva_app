import 'package:dio/dio.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// Employee Assignments on the shared Java `POST /api/rti/employee-assignments` that React's
/// page uses (`R/api/employeeAssignmentsApi.ts:38-49`, `R/hooks/useEmployeeAssignments.ts`).
/// Body `{fromDate, toDate, companyId, employeeId}` (`yyyy-MM-dd`, employee 0 = everyone; the
/// server allows at most 90 days). The answer's `Data1` rows are the Java
/// `RtiEmployeeAssignmentResponse`, read as they come. A refusal is an [ApiFailure] with the
/// server's `Message`, or "Failed to fetch employee assignments" as React says.
class EmployeeAssignmentsApi {
  EmployeeAssignmentsApi(this._dio, {required int Function() companyId}) : _companyId = companyId;

  static const fallbackError = 'Failed to fetch employee assignments';

  final Dio _dio;
  final int Function() _companyId;

  int get companyId => _companyId();

  Future<List<Map<String, dynamic>>> fetch({required String fromDate, required String toDate, int employeeId = 0}) async {
    final Response<dynamic> response;
    try {
      response = await _dio.post<dynamic>('/api/rti/employee-assignments', data: {
        'fromDate': fromDate,
        'toDate': toDate,
        'companyId': companyId,
        'employeeId': employeeId,
      });
    } on DioException catch (e) {
      final failure = JavaResponse.fromDio(e);
      throw failure.message.trim().isEmpty ? const ApiFailure(fallbackError) : failure;
    }
    final body = response.data;
    if (body is! Map || !JsonRead.boolean(body['IsSuccess'])) {
      final message = body is Map ? JsonRead.stringOrNull(body['Message']) : null;
      throw ApiFailure(message ?? fallbackError);
    }
    return JsonRead.listOfMaps(body['Data1']);
  }
}
