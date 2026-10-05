import 'package:dio/dio.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// Forwarding salaries, from the shared Java `/api/forwarding-salaries/entries`
/// (ported from .NET ForwardingSalaryApp / SP_ForwardingSalary, change
/// `forwarding-salary-on-shared-java-api`). A row is `id`, `rtiMasterRefId`,
/// `rtiNo`, `employeeMasterRefId` (seal) with `sealEmployeeName`,
/// `employeeMasterRefId1` (break seal) with `breakEmployeeName`, `salary1`,
/// `salary2`. A refusal is an [ApiFailure] with the server's reason.
class ForwardingSalaryApi {
  ForwardingSalaryApi(this._dio, {required int Function() companyId}) : _companyId = companyId;

  final Dio _dio;
  final int Function() _companyId;

  int get companyId => _companyId();

  /// The RTI's forwarding salary (the first saved), or null when it has none.
  Future<Map<String, dynamic>?> forRti(int rtiId) async {
    final rows = JsonRead.listOfMaps(await _send(() => _dio.get<dynamic>('/api/forwarding-salaries/entries',
        queryParameters: {'companyId': companyId, 'rtiId': rtiId})));
    return rows.isEmpty ? null : rows.first;
  }

  /// Adds ([id] 0) or updates the RTI's forwarding salary; 0 means no employee.
  /// Answers its id.
  Future<int> save({
    required int id,
    required int rtiId,
    required int sealEmployeeId,
    required int breakSealEmployeeId,
    required double salary1,
    required double salary2,
  }) async {
    final saved = await _send(() => _dio.post<dynamic>('/api/forwarding-salaries/entries',
        queryParameters: {'companyId': companyId},
        data: {
          'id': id,
          'rtiMasterRefId': rtiId,
          'employeeMasterRefId': sealEmployeeId == 0 ? null : sealEmployeeId,
          'employeeMasterRefId1': breakSealEmployeeId == 0 ? null : breakSealEmployeeId,
          'salary1': salary1,
          'salary2': salary2,
        }));
    return JsonRead.integer(saved);
  }

  Future<dynamic> _send(Future<Response<dynamic>> Function() call) async {
    try {
      return JavaResponse.data((await call()).data);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }
}
