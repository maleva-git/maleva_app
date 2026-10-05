import 'package:dio/dio.dart';
import 'package:maleva/core/models/shared/employee_model.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// Employees for the pickers, from the shared Java employee APIs the web's
/// dropdowns use (the .NET EmployeeApp is no longer called for these, change
/// `employee-lookups-on-shared-java-api`). A failure is an [ApiFailure].
class EmployeeApi {
  EmployeeApi(this._dio, {required int Function() companyId}) : _companyId = companyId;

  final Dio _dio;
  final int Function() _companyId;

  int get companyId => _companyId();

  /// The active employees of the company, by name, for one or two employee
  /// types (.NET GetEmployee `type` / `type1`; blank or `ALL` means any).
  /// `/api/employees/company/{id}/all` takes one type, so two types are two
  /// calls, merged. The picker shows `Name-Type`, as .NET's AccountName did.
  Future<List<EmployeeModel>> dropdown({String type = '', String type1 = ''}) async {
    final types = <String>{
      for (final t in [type, type1])
        if (t.trim().isNotEmpty && t.trim().toUpperCase() != 'ALL') t.trim().toUpperCase(),
    };
    final rows = <Map<String, dynamic>>[];
    if (types.isEmpty) {
      rows.addAll(await _all(null));
    } else {
      for (final t in types) {
        rows.addAll(await _all(t));
      }
    }
    final byId = <int, Map<String, dynamic>>{};
    for (final r in rows) {
      // .NET listed Active = 1 only; the Java list also carries inactive (0) ones
      if (JsonRead.integer(r['active'], fallback: 1) != 1) continue;
      byId[JsonRead.integer(r['id'])] = r;
    }
    final list = byId.values.toList()
      ..sort((a, b) => JsonRead.string(a['employeeName']).toLowerCase().compareTo(JsonRead.string(b['employeeName']).toLowerCase()));
    return list.map(EmployeeModel.fromJava).toList();
  }

  /// The names of the ports assigned to [employeeId] (.NET GetEmployeeport):
  /// the active assignments of `/api/employee-ports`, named from `/api/port-masters`.
  Future<List<String>> portNames(int employeeId) async {
    final assigned = JsonRead.listOfMaps(JavaResponse.data(
        (await _get('/api/employee-ports/company/$companyId/employee/$employeeId')).data));
    final ports = JsonRead.listOfMaps((await _get('/api/port-masters')).data);
    final names = {for (final p in ports) JsonRead.integer(p['id']): JsonRead.string(p['portName'])};
    return [
      for (final a in assigned)
        if (JsonRead.integer(a['active'], fallback: 1) == 1 && names[JsonRead.integer(a['portRefId'])] != null)
          names[JsonRead.integer(a['portRefId'])]!,
    ];
  }

  // ------------------------------------------------------------ Employee Master

  /// Employee Master's list (`POST /api/employees/search`, the web's search):
  /// up to [pageCount] employees not deleted, the Java rows as they come
  /// (passwords are never sent).
  Future<List<Map<String, dynamic>>> search({int pageCount = 100, String keyword = '', String type = ''}) async {
    final data = await _send(() => _dio.post<dynamic>('/api/employees/search', data: {
          'comid': companyId,
          'startindex': 0,
          'pageCount': pageCount,
          'keyword': keyword,
          'column': 'All',
          'type': type,
        }));
    return JsonRead.listOfMaps(data is Map ? data['data1'] : data);
  }

  /// The roles an employee can hold (`GET /api/employees/types`): `{id, name}`.
  Future<List<Map<String, dynamic>>> roles() async => [
        for (final r in JsonRead.listOfMaps(await _send(() => _dio.get<dynamic>('/api/employees/types'))))
          {'id': JsonRead.integer(r['id']), 'name': JsonRead.string(r['customerName'])},
      ];

  /// Saves one employee (`POST /api/employees/bulk/{companyId}`, the web's save
  /// of .NET SP_Employee): id 0 adds, anything else updates; a blank password
  /// keeps the current one. Answers the saved id.
  Future<int> save(Map<String, dynamic> employee) async {
    try {
      final response = await _dio.post<dynamic>('/api/employees/bulk/$companyId', data: [employee]);
      final body = response.data;
      JavaResponse.data(body); // refuses IsSuccess = false
      return JsonRead.integer((body as Map)['Data2']);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }

  /// Soft delete, only an employee of the company (`DELETE /api/employees/{id}?companyRefId=`).
  Future<void> delete(int id) async {
    await _send(() => _dio.delete<dynamic>('/api/employees/$id', queryParameters: {'companyRefId': companyId}),
        allowEmpty: true);
  }

  Future<dynamic> _send(Future<Response<dynamic>> Function() call, {bool allowEmpty = false}) async {
    try {
      final response = await call();
      if (allowEmpty && (response.statusCode == 204 || response.data == null || response.data == '')) return null;
      return JavaResponse.data(response.data);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }

  Future<List<Map<String, dynamic>>> _all(String? type) async {
    final response = await _get('/api/employees/company/$companyId/all', type == null ? null : {'type': type});
    final body = response.data;
    // a bare list; read a wrapped one too
    return JsonRead.listOfMaps(body is Map ? JavaResponse.data(body) : body);
  }

  Future<Response<dynamic>> _get(String path, [Map<String, dynamic>? query]) async {
    try {
      return await _dio.get<dynamic>(path, queryParameters: query);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }
}
