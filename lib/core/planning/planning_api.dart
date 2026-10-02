import 'package:dio/dio.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// Saved plans and their rows as the select endpoints answer them (`{salemaster, saledetails}`,
/// .NET names: `Id`, `PLANINGNoDisplay` / `VESSELPLANINGNoDisplay`, `PLANINGMasterRefId` ...).
class PlanList {
  const PlanList(this.masters, this.details);

  factory PlanList.fromJava(dynamic data) {
    final m = JsonRead.map(data);
    return PlanList(JsonRead.listOfMaps(m['salemaster']), JsonRead.listOfMaps(m['saledetails']));
  }

  final List<Map<String, dynamic>> masters;
  final List<Map<String, dynamic>> details;
}

/// Transport planning, on the shared Java `/api/planing` and `/api/planning/reports` the web
/// uses (change `planning-on-shared-java-api`). The answers are read as they are; a refusal is
/// an [ApiFailure] with the server's message.
class PlanningApi {
  PlanningApi(this._dio, {required int Function() companyId}) : _companyId = companyId;

  final Dio _dio;
  final int Function() _companyId;

  int get companyId => _companyId();

  /// The next plan number (`PL000000124`); it is taken only when a plan is saved.
  Future<String> nextNumber() async =>
      JsonRead.string(JsonRead.map(await _raw(() => _dio.post<dynamic>('/api/planing/max-planning-no/$companyId')))['sequenceNumber']);

  /// Saved plans, newest first. A [search] (plan number) ignores the dates; [employeeId] 0 is everyone.
  Future<PlanList> list({required DateTime from, required DateTime to, String search = '', int employeeId = 0}) async =>
      PlanList.fromJava(await _raw(() => _dio.post<dynamic>('/api/planing/select-planning', data: {
            'comid': companyId,
            'employeeid': employeeId,
            'search': search.trim(),
            'fromdate': _ymd(from),
            'todate': _ymd(to),
          })));

  /// One plan with its rows (`SaleDetails`: `Id`, `SaleOrderMasterRefId`, `JobNo`, `TruckName`,
  /// `DriverName`, `Origin`, `Destination`, `SPickupDate`, `SDeliveryDate`, `CustomerName`, ...).
  Future<Map<String, dynamic>> edit(int id) async =>
      JsonRead.map(await _raw(() => _dio.get<dynamic>('/api/planing/edit', queryParameters: {'id': id, 'companyId': companyId})));

  /// Jobs to plan: picked up in the range, at the [ports] (comma separated). Rows: `Id` (the
  /// sale order), `JobNo`, `CustomerName`, `Origin`, `Destination`, `SWareHouseEnterDate`, ...
  Future<List<Map<String, dynamic>>> searchJobs({required DateTime from, required DateTime to, String ports = '', int employeeId = 0}) async =>
      JsonRead.listOfMaps(await _raw(() => _dio.post<dynamic>('/api/planing/search', data: {
            'comid': companyId,
            'search': ports,
            'employeeid': employeeId == 0 ? '' : '$employeeId',
            'fromdate': _ymd(from),
            'todate': _ymd(to),
          })));

  /// Saves the plan ([plan] is the web's `PlanningRequest`; see `planningSaveBody`) and answers
  /// `{ok, message, name (plan number), id}`; a refusal is an [ApiFailure].
  Future<Map<String, dynamic>> save(Map<String, dynamic> plan) async {
    final answer = await _raw(() => _dio.post<dynamic>('/api/planing/save',
        data: [plan], options: Options(headers: {'Comid': '$companyId'})));
    final first = answer is List && answer.isNotEmpty ? JsonRead.map(answer.first) : JsonRead.map(answer);
    _refusedUnlessOk(first, 'Planning was not saved');
    return first;
  }

  Future<void> delete(int id) async {
    _refusedUnlessOk(JsonRead.map(await _raw(() => _dio.delete<dynamic>('/api/planing/$id',
        queryParameters: {'companyId': companyId}))), 'Planning was not deleted');
  }

  /// The plan's report path (`/api/planning/reports/pdf/{ticket}/{file}.pdf`, open with `javaReportUrl`).
  Future<String> reportPath(int id, {DateTime? reportDate}) async => JsonRead.string(JsonRead.map(JavaResponse.data(
      await _raw(() => _dio.get<dynamic>('/api/planning/reports/$id/pdf-ticket', queryParameters: {
            'companyId': companyId,
            if (reportDate != null) 'reportDate': _ymd(reportDate),
          }))))['Url']);

  static void _refusedUnlessOk(Map<String, dynamic> answer, String fallback) {
    if (answer['ok'] != true) throw ApiFailure(JsonRead.stringOrNull(answer['message']) ?? fallback);
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
  static String _ymd(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';

  Future<dynamic> _raw(Future<Response<dynamic>> Function() call) async {
    try {
      return (await call()).data;
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }
}
