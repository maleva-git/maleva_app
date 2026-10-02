import 'package:maleva/core/dashboard/dashboard_api.dart';
import 'package:maleva/core/di/injection.dart';

/// The sales desk's numbers, from the shared Java `/api/dashboard`.
class AirfreightRepository {
  AirfreightRepository({DashboardApi? api}) : _api = api;

  final DashboardApi? _api;

  DashboardApi get _dashboard => _api ?? sl<DashboardApi>();

  /// `[{Id, AccountName}]`: the employees [empId] may look at.
  Future<List<Map<String, dynamic>>> fetchRules(int comId, int empId) => _dashboard.employeeRules(comId, empId);

  /// The four counts and the open orders by status for [empId].
  Future<SalesDeskNumbers> fetchSalesDesk(int comId, int empId) => _dashboard.salesDesk(comId, empId);
}
