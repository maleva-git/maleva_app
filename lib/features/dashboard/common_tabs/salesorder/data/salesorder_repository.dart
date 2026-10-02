import 'package:maleva/core/dashboard/dashboard_api.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/utils/app_preferences.dart';

/// The sale-order desk's numbers, from the shared Java `/api/dashboard`.
class SalesOrderRepository {
  SalesOrderRepository({DashboardApi? api, int Function()? comid})
      : _api = api,
        _comid = comid ?? AppPreferences.getComid;

  final DashboardApi? _api;
  final int Function() _comid;

  DashboardApi get _dashboard => _api ?? sl<DashboardApi>();

  /// `{TodaySales, ..., MonthAmount, monthlySales: [...]}`; [type] 1 all, 2 with invoice, 3 without.
  Future<Map<String, dynamic>> fetchSalesData(int type) => _dashboard.sales(_comid(), type);

  /// `[{EmployeeName, SalesCount, Amount}]`.
  Future<List<Map<String, dynamic>>> fetchEmployeeSalesData(int type) => _dashboard.employeeSales(_comid(), type);

  /// `[{EmployeeName, SalesCount, Amount}]` for the invoice desk.
  Future<List<Map<String, dynamic>>> fetchEmployeeInvData(int type) => _dashboard.employeeInvoices(_comid(), type);
}
