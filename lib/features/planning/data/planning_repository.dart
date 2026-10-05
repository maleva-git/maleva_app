import 'package:dio/dio.dart';
import 'package:maleva/core/access/screen_access_api.dart';
import 'package:maleva/core/fleet/driver_api.dart';
import 'package:maleva/core/fleet/truck_api.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/planning/planning_api.dart';
import 'package:maleva/core/sale_order/sale_order_api.dart';
import 'package:maleva/core/utils/json_read.dart';
import 'package:maleva/features/planning/data/js_values.dart';
import 'package:maleva/features/planning/data/sale_order_update.dart';
import 'package:maleva/features/planning/models/fleet_options.dart';
import 'package:maleva/features/planning/models/plan_header.dart';
import 'package:maleva/features/planning/models/plan_line.dart';
import 'package:maleva/features/planning/models/rti_batch.dart';

/// What the plan screen reads and writes: the shared Java APIs the web's Planning page uses.
abstract interface class PlanningRepository {
  int get companyId;

  /// The signed-in user (the Java session's user, which is also the employee).
  int get userId;
  int get employeeId;

  /// The role's actions on the Planning screen (`GET /api/screen-access/planning/me`).
  Future<Set<String>> access();
  Future<String> nextNumber();
  Future<List<EmployeeOption>> employees();
  Future<List<String>> ports();
  Future<List<TruckOption>> trucks();
  Future<List<DriverOption>> drivers();
  Future<List<PlanLine>> search(Map<String, dynamic> payload);
  Future<LoadedPlan?> load({int? id, int? planningNo});

  /// The save answer: `{ok, message, name, id}`; a refusal is an [ApiFailure].
  Future<Map<String, dynamic>> save(Map<String, dynamic> request);
  Future<void> delete(int id);
  Future<List<Map<String, dynamic>>> rtiStatus(List<int> saleOrderIds);
  Future<RtiBatchPreview> batchPreview(int planningId, {bool includeExisting = false, List<int> jobIds = const []});
  Future<RtiBatchResult> batchCreate(int planningId, Map<String, dynamic> request);
  Future<SaleOrderDraft?> saleOrderDraft(int saleOrderId);
  Future<Map<String, dynamic>> updateSaleOrder(Map<String, dynamic> payload);
}

class JavaPlanningRepository implements PlanningRepository {
  JavaPlanningRepository({
    required Dio dio,
    required PlanningApi planning,
    required ScreenAccessApi screenAccess,
    required TruckApi truckApi,
    required DriverApi driverApi,
    required SaleOrderApi saleOrders,
    required int Function() companyId,
    required int Function() userId,
  })  : _dio = dio,
        _planning = planning,
        _screenAccess = screenAccess,
        _truckApi = truckApi,
        _driverApi = driverApi,
        _saleOrders = saleOrders,
        _companyId = companyId,
        _userId = userId;

  final Dio _dio;
  final PlanningApi _planning;
  final ScreenAccessApi _screenAccess;
  final TruckApi _truckApi;
  final DriverApi _driverApi;
  final SaleOrderApi _saleOrders;
  final int Function() _companyId;
  final int Function() _userId;

  @override
  int get companyId => _companyId();

  @override
  int get userId => _userId();

  @override
  int get employeeId => _userId();

  @override
  Future<Set<String>> access() async => (await _screenAccess.mine('planning')).actions;

  @override
  Future<String> nextNumber() => _planning.nextNumber();

  /// `useEmployeesByCompany` (`GET /api/employees/company/{id}/all?type=ALL`), as
  /// `createEmployeeOptions` lists them: `{id, employeeName}`.
  @override
  Future<List<EmployeeOption>> employees() async {
    final rows = _rows(await _get('/api/employees/company/$companyId/all', {'type': 'ALL'}));
    return [
      for (final r in rows)
        if (Js.positiveInt(Js.nn(r, ['id', 'employeeId', 'EmployeeId', 'employeeRefId', 'Id'])) > 0 &&
            Js.text(Js.nn(r, ['name', 'employeeName'])).isNotEmpty)
          EmployeeOption(
              Js.positiveInt(Js.nn(r, ['id', 'employeeId', 'EmployeeId', 'employeeRefId', 'Id'])), Js.text(Js.nn(r, ['name', 'employeeName']))),
    ];
  }

  /// `usePorts` (`GET /api/port-masters/company/{id}/active`): the port names, once each; a
  /// failure is an empty list as on the web.
  @override
  Future<List<String>> ports() async {
    try {
      final seen = <String>{};
      for (final r in _rows(await _get('/api/port-masters/company/$companyId/active'))) {
        final name = Js.text(Js.nn(r, ['portName', 'PortName'])).trim();
        if (name.isNotEmpty) seen.add(name);
      }
      return seen.toList();
    } on ApiFailure {
      return const [];
    }
  }

  /// The truck picker (`useTruckCombo`); a failure is an empty list as on the web.
  @override
  Future<List<TruckOption>> trucks() async {
    try {
      return (await _truckApi.allDetailCombo()).map(TruckOption.fromJava).whereType<TruckOption>().toList();
    } on ApiFailure {
      return const [];
    }
  }

  /// The driver picker (`useDriverCombo`); a failure is an empty list as on the web.
  @override
  Future<List<DriverOption>> drivers() async {
    try {
      return DriverOption.listFrom(await _driverApi.allDetails(), companyId);
    } on ApiFailure {
      return const [];
    }
  }

  @override
  Future<List<PlanLine>> search(Map<String, dynamic> payload) async {
    final rows = await _planning.searchPlanning(
      search: JsonRead.string(payload['search']),
      employeeId: JsonRead.integer(payload['employeeid']),
      fromDate: JsonRead.string(payload['fromdate']),
      toDate: JsonRead.string(payload['todate']),
    );
    return [for (var i = 0; i < rows.length; i++) PlanLine.fromSearch(rows[i])];
  }

  @override
  Future<LoadedPlan?> load({int? id, int? planningNo}) async {
    final body = (id ?? 0) > 0 ? await _planning.edit(id!) : await _planning.editByNumber(planningNo ?? 0);
    return LoadedPlan.fromJava(body);
  }

  /// `PlanningApi` words a refusal without a message its own way; the web says "Error saving planning".
  @override
  Future<Map<String, dynamic>> save(Map<String, dynamic> request) async {
    try {
      return await _planning.save(request);
    } on ApiFailure catch (e) {
      if (e.message == 'Planning was not saved') throw ApiFailure('Error saving planning', statusCode: e.statusCode);
      rethrow;
    }
  }

  @override
  Future<void> delete(int id) async {
    try {
      await _planning.delete(id);
    } on ApiFailure catch (e) {
      if (e.message == 'Planning was not deleted') throw ApiFailure('Error deleting planning', statusCode: e.statusCode);
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> rtiStatus(List<int> saleOrderIds) => _planning.rtiStatus(saleOrderIds);

  @override
  Future<RtiBatchPreview> batchPreview(int planningId, {bool includeExisting = false, List<int> jobIds = const []}) async =>
      RtiBatchPreview.fromJava(await _planning.rtiBatchPreview(planningId, jobIds: jobIds, includeExisting: includeExisting));

  @override
  Future<RtiBatchResult> batchCreate(int planningId, Map<String, dynamic> request) async =>
      RtiBatchResult.fromJava(await _planning.rtiBatchCreate(planningId, request));

  @override
  Future<SaleOrderDraft?> saleOrderDraft(int saleOrderId) async {
    final edit = await _saleOrders.edit(id: saleOrderId);
    return SaleOrderUpdateRules.draftFrom(saleOrderId, edit.master, edit.pickups, edit.deliveries);
  }

  /// The Update window's save (`POST /api/planing/update-dates`, the web's 18 keys). The answer
  /// is `{ok, message, saleOrderId, pickupDate, ...}`.
  @override
  Future<Map<String, dynamic>> updateSaleOrder(Map<String, dynamic> payload) async {
    try {
      final r = await _dio.post<dynamic>('/api/planing/update-dates', data: payload);
      return JsonRead.map(r.data);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }

  static List<Map<String, dynamic>> _rows(dynamic body) {
    if (body is List) return JsonRead.listOfMaps(body);
    if (body is Map) {
      final inner = body['Data1'] ?? body['data1'] ?? body['data'] ?? body['Data'];
      if (inner is List) return JsonRead.listOfMaps(inner);
    }
    return const [];
  }

  Future<dynamic> _get(String path, [Map<String, dynamic>? query]) async {
    try {
      return (await _dio.get<dynamic>(path, queryParameters: query)).data;
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }
}
