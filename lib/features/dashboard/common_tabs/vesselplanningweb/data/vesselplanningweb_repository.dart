import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/network/java_report.dart';
import 'package:maleva/core/planning/vessel_planning_api.dart';
import 'package:maleva/core/sale_order/sale_order_api.dart';
import 'package:maleva/core/utils/json_read.dart';
import '../models/vesselplanningweb_model.dart';

/// Vessel Planning (web) on the shared Java APIs the web uses: `/api/vessel-plannings` for the
/// plans, `/api/vessel-plannings/sale-order-update` for a job's update. A refusal is thrown with
/// the server's message (the .NET calls reported "Success" on any failure).
class VesselPlanningWebRepository {
  VesselPlanningWebRepository({VesselPlanningApi? api, SaleOrderApi? saleOrders})
      : _api = api,
        _saleOrderApi = saleOrders;

  final VesselPlanningApi? _api;
  final SaleOrderApi? _saleOrderApi;
  VesselPlanningApi get _plans => _api ?? sl<VesselPlanningApi>();
  SaleOrderApi get _saleOrders => _saleOrderApi ?? sl<SaleOrderApi>();

  /// Jobs to plan. [etaType] as the screen: 1 off-vessel ETA, 2 loading ETA, 3 either.
  Future<List<VesselPlanningWebModel>> getVesselPlanningSearch({
    required String fromDate,
    required String toDate,
    required int etaType,
    required String searchPorts,
    required bool deliveryDone,
    required int employeeId,
  }) async =>
      [
        for (final row in await _plans.searchJobs(
          from: DateTime.parse(fromDate),
          to: DateTime.parse(toDate),
          etaType: etaType == 1 || etaType == 2 ? etaType : 0,
          ports: searchPorts,
          hideDelivered: deliveryDone,
          employeeId: employeeId,
        ))
          VesselPlanningWebModel.fromJson(row),
      ];

  /// The update window's fields (`saleOrderId`, `ptw`, `cargo`, `eta`..`oetd`, `loadingOfficers`,
  /// `offOfficers`); answers the server's message.
  Future<String> updateSpecificJob(Map<String, dynamic> u) async {
    List<int> ids(dynamic l) => [for (final v in (l as List? ?? const [])) JsonRead.integer(v)];
    final saved = await _saleOrders.vesselUpdate(
      JsonRead.integer(u['saleOrderId']),
      ptw: u['ptw'] as String?,
      cargo: u['cargo'] as String?,
      eta: u['eta'] as String?,
      etb: u['etb'] as String?,
      etd: u['etd'] as String?,
      oeta: u['oeta'] as String?,
      oetb: u['oetb'] as String?,
      oetd: u['oetd'] as String?,
      loadingOfficers: ids(u['loadingOfficers']),
      offOfficers: ids(u['offOfficers']),
    );
    return JsonRead.stringOrNull(saved['message']) ?? 'Updated';
  }

  /// Saves the plan with the jobs in order; answers `{ok, message, name (plan number), id}`.
  Future<Map<String, dynamic>> saveVesselPlanning({
    required int id,
    required DateTime from,
    required DateTime to,
    required DateTime planDate,
    required List<int> saleOrderIds,
    required String remarks,
    required String search,
    required int employeeId,
  }) =>
      _plans.save(
        id: id,
        from: from,
        to: to,
        planDate: planDate,
        saleOrderIds: saleOrderIds,
        remarks: remarks,
        search: search,
        employeeId: employeeId,
      );

  Future<String> deleteVesselPlanning(int id) async {
    await _plans.delete(id);
    return 'Vessel planning deleted';
  }

  /// Saved plans in the range (yyyy-MM-dd), each with its job rows under `saledetails`.
  Future<List<Map<String, dynamic>>> getSavedPlannings({
    required String fromDate,
    required String toDate,
    String search = '',
    int employeeId = 0,
  }) async {
    final plans = await _plans.list(
        from: DateTime.parse(fromDate), to: DateTime.parse(toDate), search: search, employeeId: employeeId);
    return [
      for (final m in plans.masters)
        {
          ...m,
          'saledetails': [
            for (final d in plans.details)
              if (JsonRead.integer(d['VESSELPLANINGMasterRefId']) == JsonRead.integer(m['Id'])) d
          ],
        },
    ];
  }

  /// One plan: `master` (`Id`, `CNumberDisplay`, `SaleDate`, `SFDate`, `STDate`, `Remarks`,
  /// `Search`, `EmployeeRefId`) and its job rows `details`.
  Future<Map<String, dynamic>> getPlanningById(int id) async {
    final plan = await _plans.edit(id);
    return {
      'master': plan,
      'details': [for (final row in JsonRead.listOfMaps(plan['SaleDetails'])) VesselPlanningWebModel.fromJson(row)],
    };
  }

  Future<String> getMaxVesselPlanningNo() => _plans.nextNumber();

  /// The plan's report link (public for a few minutes).
  Future<String> fetchVesselPlanningPdfUrl({required int soId}) async => javaReportUrl(await _plans.reportPath(soId));
}
