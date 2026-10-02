import 'package:maleva/core/dashboard/dashboard_api.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/sale_order/sale_order_api.dart';
import 'package:maleva/core/utils/json_read.dart';

class VesselReportRepository {
  VesselReportRepository({DashboardApi? api, SaleOrderApi? saleOrders})
      : _api = api,
        _saleOrders = saleOrders;

  final DashboardApi? _api;
  final SaleOrderApi? _saleOrders;

  /// The vessel planning board, from the shared Java `POST /api/dashboard/vessel-planning`
  /// (ported from .NET VESSELPLANINGDB); camelCase rows with every boarding officer.
  Future<List<Map<String, dynamic>>> fetchVesselPlanningData({
    required int comid,
    required String fromDate,
    required String toDate,
    String search = '',
  }) =>
      (_api ?? sl<DashboardApi>()).vesselPlanning(comid, fromDate: fromDate, toDate: toDate, search: search);

  /// The Update window (shared Java `POST /api/vessel-plannings/sale-order-update`, as
  /// the web): status, the six dates (null keeps) and the loading and off-vessel
  /// officers (the server sets their amounts). Answers the server's message.
  Future<String> updateVesselPlanningDates(Map<String, dynamic> u) async {
    List<int> ids(dynamic l) => [for (final v in (l as List? ?? const [])) JsonRead.integer(v)];
    final saved = await (_saleOrders ?? sl<SaleOrderApi>()).vesselUpdate(
      JsonRead.integer(u['saleOrderId']),
      jobStatusId: u['jobStatusId'] as int?,
      eta: u['eta'] as String?,
      etb: u['etb'] as String?,
      etd: u['etd'] as String?,
      oeta: u['oeta'] as String?,
      oetb: u['oetb'] as String?,
      oetd: u['oetd'] as String?,
      loadingOfficers: ids(u['loadingOfficers']),
      offOfficers: ids(u['offOfficers']),
    );
    return JsonRead.stringOrNull(saved['message']) ?? 'Success';
  }
}
