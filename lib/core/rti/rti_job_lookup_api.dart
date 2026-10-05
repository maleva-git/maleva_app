import 'package:dio/dio.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// The RTI form's look-ups on the shared Java APIs React's RTI page calls
/// (decision Q-JOBLOOKUP, `R/api/rtiApi.ts:452-531`):
/// - the Job No search, `POST /api/sale-orders/search` with React's 19-key filter;
///   answers `Data1.salemaster[]` rows;
/// - one sale order, `GET /api/sale-orders/{id}` (a bare `SaleOrderEditDto`
///   `{saleOrderMaster, ...}`);
/// - one truck, `GET /api/truck-masters/{id}` (the licence check, `R/hooks/useRTIQueries.ts:194-200`);
/// - the agent picker of the route activities, `GET /api/employees/company/{id}/all?type=ALL`
///   (`R/hooks/useRTIEmployees.ts:11-23`), the Java rows as they come.
class RtiJobLookupApi {
  RtiJobLookupApi(this._dio, {required int Function() companyId}) : _companyId = companyId;

  final Dio _dio;
  final int Function() _companyId;

  int get companyId => _companyId();

  /// The sale-order filter React sends for a Job No, key for key.
  static Map<String, dynamic> searchBody(int companyId, String jobNo) => {
        'Comid': companyId,
        'Id': 0,
        'JId': 0,
        'Employeeid': 0,
        'DashboardStatus': 0,
        'statusList': null,
        'Statusid': 0,
        'completestatusnotshow': false,
        'Remarks': 0,
        'Offvesselname': null,
        'Loadingvesselname': null,
        'Search': jobNo,
        'Invoice': false,
        'ETA': false,
        'ETAType': 0,
        'Fromdate': null,
        'Todate': null,
        'Pickup': false,
        'Invoicecheck': false,
      };

  /// The `salemaster` rows the search answers for [jobNo] (not yet filtered).
  Future<List<Map<String, dynamic>>> searchSaleMasters(String jobNo) async {
    final data = JsonRead.map(await _send(() => _dio.post<dynamic>('/api/sale-orders/search', data: searchBody(companyId, jobNo))));
    return JsonRead.listOfMaps(JsonRead.field(data, 'salemaster'));
  }

  /// One sale order as `GET /api/sale-orders/{id}` answers it (bare, or in `Data1`).
  Future<Map<String, dynamic>> saleOrder(int id) async {
    final body = await _bare(() => _dio.get<dynamic>('/api/sale-orders/$id'));
    if (body is Map && (body.containsKey('Data1') || body.containsKey('data1'))) {
      return JsonRead.map(body['Data1'] ?? body['data1']);
    }
    return JsonRead.map(body);
  }

  /// The truck as `GET /api/truck-masters/{id}` answers it, or null.
  Future<Map<String, dynamic>?> truck(int id) async {
    final body = await _bare(() => _dio.get<dynamic>('/api/truck-masters/$id'));
    final data = body is Map && (body.containsKey('Data1') || body.containsKey('data1')) ? body['Data1'] ?? body['data1'] : body;
    if (data is List) return data.isEmpty ? null : JsonRead.map(data.first);
    final map = JsonRead.map(data);
    return map.isEmpty ? null : map;
  }

  /// The company's employees, every type (`id`, `employeeName`, `mobileNo`, ...).
  Future<List<Map<String, dynamic>>> employees() async {
    final body = await _bare(() => _dio.get<dynamic>('/api/employees/company/$companyId/all', queryParameters: {'type': 'ALL'}));
    return JsonRead.listOfMaps(body is Map ? JavaResponse.data(body) : body);
  }

  Future<dynamic> _send(Future<Response<dynamic>> Function() call) async {
    try {
      return JavaResponse.data((await call()).data);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }

  Future<dynamic> _bare(Future<Response<dynamic>> Function() call) async {
    try {
      return (await call()).data;
    } on DioException catch (e) {
      final body = e.response?.data;
      if (body is String && body.trim().isNotEmpty) {
        throw ApiFailure(body.trim(), statusCode: e.response?.statusCode);
      }
      throw JavaResponse.fromDio(e);
    }
  }
}
