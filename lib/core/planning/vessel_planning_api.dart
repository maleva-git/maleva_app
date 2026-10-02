import 'package:dio/dio.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/planning/planning_api.dart';
import 'package:maleva/core/utils/json_read.dart';

/// Vessel planning, on the shared Java `/api/vessel-plannings` the web uses (change
/// `planning-on-shared-java-api`). The answers are read as they are; a refusal is an
/// [ApiFailure] with the server's message. The job update of the grid is
/// `SaleOrderApi.vesselUpdate`.
class VesselPlanningApi {
  VesselPlanningApi(this._dio, {required int Function() companyId}) : _companyId = companyId;

  final Dio _dio;
  final int Function() _companyId;

  int get companyId => _companyId();

  /// The next plan number (`VPL000000046`); it is taken only when a plan is saved.
  Future<String> nextNumber() async => JsonRead.string(JsonRead.map(
      await _raw(() => _dio.post<dynamic>('/api/vessel-plannings/max-vessel-planning-no/$companyId')))['sequenceNumber']);

  /// Jobs to plan by vessel date. [etaType] 1 off-vessel ETA, 2 loading ETA, 0 either;
  /// [ports] comma separated; [hideDelivered] leaves out delivered, billed and cancelled jobs.
  /// Rows: `Id`/`SaleOrderMasterRefId`, `JobNo`, `JobStatus`, `CustomerName`, `SPort`, `OPort`,
  /// `Vessel`, `Offvesselname`, `SETA`, `SETB`, `SETD`, `SOETA`.., `PTW`, `Cargo`,
  /// `LBoardingOfficerRefid`.., `OBoardingOfficerRefid`.., ...
  Future<List<Map<String, dynamic>>> searchJobs({
    required DateTime from,
    required DateTime to,
    int etaType = 0,
    String ports = '',
    bool hideDelivered = true,
    int employeeId = 0,
  }) async =>
      JsonRead.listOfMaps(await _raw(() => _dio.post<dynamic>('/api/vessel-plannings/search', data: {
            'comid': companyId,
            'search': ports,
            'employeeid': employeeId,
            'fromdate': _ymd(from),
            'todate': _ymd(to),
            'etaType': etaType,
            'DeliveryDone': hideDelivered,
          })));

  /// Saved plans (oldest first). A [search] (plan number) ignores the dates; [employeeId] 0 is everyone.
  Future<PlanList> list({required DateTime from, required DateTime to, String search = '', int employeeId = 0}) async =>
      PlanList.fromJava(await _raw(() => _dio.post<dynamic>('/api/vessel-plannings/select-vessel-planning', data: {
            'comid': companyId,
            'employeeid': employeeId,
            'search': search.trim(),
            'fromdate': _ymd(from),
            'todate': _ymd(to),
          })));

  /// One plan: `Id`, `CNumberDisplay`, `SaleDate`/`SFDate`/`STDate` (yyyy-MM-dd), `Remarks`,
  /// `EmployeeRefId`, `Search`, and `SaleDetails` (the job rows, as [searchJobs]).
  Future<Map<String, dynamic>> edit(int id) async => JsonRead.map(
      await _raw(() => _dio.get<dynamic>('/api/vessel-plannings/edit', queryParameters: {'id': id, 'companyId': companyId})));

  /// Saves the plan and answers `{ok, message, name (plan number), id}`; a refusal is an [ApiFailure].
  /// The rows are the jobs in order; the server keeps only the job and its remark.
  Future<Map<String, dynamic>> save({
    required int id,
    required DateTime from,
    required DateTime to,
    required DateTime planDate,
    required List<int> saleOrderIds,
    String remarks = '',
    String search = '',
    int employeeId = 0,
    int userId = 0,
  }) async {
    final answer = await _raw(() => _dio.post<dynamic>('/api/vessel-plannings/save',
        options: Options(headers: {'Comid': '$companyId'}),
        data: [
          {
            'Id': id,
            'CompanyRefId': companyId,
            'UserRefId': userId > 0 ? userId : null,
            'EmployeeRefId': employeeId > 0 ? employeeId : null,
            'FDate': _slash(from),
            'TDate': _slash(to),
            'SaleDate': _slash(planDate),
            'CNumber': 0,
            'Remarks': remarks,
            'Search': search,
            'SaleDetails': [for (final s in saleOrderIds) {'SaleOrderMasterRefId': s}],
          }
        ]));
    final first = answer is List && answer.isNotEmpty ? JsonRead.map(answer.first) : JsonRead.map(answer);
    if (first['ok'] != true) throw ApiFailure(JsonRead.stringOrNull(first['message']) ?? 'Vessel planning was not saved');
    return first;
  }

  Future<void> delete(int id) async {
    final answer = JsonRead.map(await _raw(() => _dio.delete<dynamic>('/api/vessel-plannings/$id',
        queryParameters: {'companyId': companyId})));
    if (answer['ok'] != true) throw ApiFailure(JsonRead.stringOrNull(answer['message']) ?? 'Vessel planning was not deleted');
  }

  /// The plan's report path (`/api/vessel-plannings/report/{ticket}/{file}.pdf`, open with `javaReportUrl`).
  Future<String> reportPath(int id) async => JsonRead.string(JsonRead.map(JavaResponse.data(await _raw(() =>
      _dio.get<dynamic>('/api/vessel-plannings/$id/report-ticket', queryParameters: {'companyId': companyId}))))['Url']);

  static String _two(int n) => n.toString().padLeft(2, '0');
  static String _ymd(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';
  static String _slash(DateTime d) => '${d.year}/${_two(d.month)}/${_two(d.day)}';

  Future<dynamic> _raw(Future<Response<dynamic>> Function() call) async {
    try {
      return (await call()).data;
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }
}
