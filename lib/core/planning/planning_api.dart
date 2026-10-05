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

  /// The plan screen's job search, as the web's live page sends it (`helpers.ts` `buildSearchPayload`,
  /// `usePlanningListPage.ts:579-584`): `{comid, search, employeeid, fromdate, todate}` with
  /// `yyyy-MM-dd` dates or ''. The answer is unwrapped like `normalizePlanningSearchResponse`.
  Future<List<Map<String, dynamic>>> searchPlanning({String search = '', int employeeId = 0, String fromDate = '', String toDate = ''}) async =>
      _rows(await _raw(() => _dio.post<dynamic>('/api/planing/search', data: {
            'comid': companyId,
            'search': search.trim(),
            'employeeid': employeeId,
            'fromdate': fromDate,
            'todate': toDate,
          })));

  /// One plan by its number (the PLAN NO box: "PL000000782" → 782).
  Future<Map<String, dynamic>> editByNumber(int planningNo) async => JsonRead.map(await _raw(() =>
      _dio.get<dynamic>('/api/planing/edit', queryParameters: {'companyId': companyId, 'planningNo': planningNo})));

  /// The newest RTI of each sale order (`POST /api/rti-details/rti-status`, body: the ids):
  /// `[{saleOrderMasterRefId, rtiMasterRefId, rtiNo}]`; sale orders without an RTI are left out.
  Future<List<Map<String, dynamic>>> rtiStatus(List<int> saleOrderIds) async {
    final ids = saleOrderIds.where((id) => id > 0).toSet().toList();
    if (ids.isEmpty) return const [];
    final answer = await _raw(() => _dio.post<dynamic>('/api/rti-details/rti-status', data: ids));
    return answer is List ? JsonRead.listOfMaps(answer) : const [];
  }

  /// What "Create All RTI" would create (`GET /api/planing/{id}/rti-batch/preview`).
  Future<Map<String, dynamic>> rtiBatchPreview(int planningId, {List<int> jobIds = const [], bool includeExisting = false}) async =>
      _data1(await _raw(() => _dio.get<dynamic>('/api/planing/$planningId/rti-batch/preview', queryParameters: {
            'companyId': companyId,
            if (jobIds.isNotEmpty) 'jobIds': jobIds.join(','),
            if (includeExisting) 'includeExisting': true,
          })));

  /// Creates the ticked groups' RTIs in one transaction (`POST /api/planing/{id}/rti-batch`).
  Future<Map<String, dynamic>> rtiBatchCreate(int planningId, Map<String, dynamic> request) async =>
      _data1(await _raw(() => _dio.post<dynamic>('/api/planing/$planningId/rti-batch', data: request)));

  /// `Data1 ?? Data ?? body`, as `planningRtiBatchApi.ts` reads it.
  static Map<String, dynamic> _data1(dynamic body) {
    final m = JsonRead.map(body);
    final inner = m['Data1'] ?? m['data1'] ?? m['Data'] ?? m['data'];
    return inner is Map ? JsonRead.map(inner) : m;
  }

  /// `normalizePlanningSearchResponse` (`planningSearch.ts:34-51`).
  static List<Map<String, dynamic>> _rows(dynamic r) {
    if (r is List) return JsonRead.listOfMaps(r);
    if (r is! Map) return const [];
    if (r['data1'] is List) return JsonRead.listOfMaps(r['data1']);
    final data = r['data'];
    if (data is List) return JsonRead.listOfMaps(data);
    if (data is Map) {
      for (final k in ['items', 'list', 'rows']) {
        if (data[k] is List) return JsonRead.listOfMaps(data[k]);
      }
    }
    return const [];
  }

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
