import 'package:dio/dio.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// Boarding officers' salary, from the shared Java
/// `/api/boarding-settlement/monthly-salary` that the React Boarding Salary
/// page uses (was .NET BoardingSalaryApp, change
/// `boarding-salary-on-shared-java-api`). A row is one officer on one vessel on
/// one day: `employeeRefId`, `employeeName`, `vesselName`, `boardingDate`
/// (yyyy-MM-dd), `calculatedRate` (RM50 alone, RM30 for two, RM20 for three or
/// more on the vessel that day), `relatedJobs`, `tagTypes`, `portName`.
class BoardingSalaryApi {
  BoardingSalaryApi(this._dio, {required int Function() companyId}) : _companyId = companyId;

  final Dio _dio;
  final int Function() _companyId;

  int get companyId => _companyId();

  /// The company's rows for the period (dates `yyyy-MM-dd`); [employeeId] 0 is
  /// every officer.
  Future<List<Map<String, dynamic>>> monthly({
    required String fromDate,
    required String toDate,
    int employeeId = 0,
  }) async {
    try {
      final response = await _dio.get<dynamic>('/api/boarding-settlement/monthly-salary', queryParameters: {
        'fromDate': fromDate,
        'toDate': toDate,
        if (employeeId > 0) 'employeeId': employeeId,
        'companyId': companyId,
      });
      return JsonRead.listOfMaps(JavaResponse.data(response.data));
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }
}
