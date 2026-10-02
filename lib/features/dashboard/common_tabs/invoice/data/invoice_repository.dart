// lib/features/dashboard/common_tabs/invoice/data/invoice_repository.dart
//
// The invoice desk:
//   1. sales summary            → Java GET /api/dashboard/sales/{comid}?type=0
//   2. waiting bills            → Java POST /api/sale-orders/check-invoice (invoice: true)
//   3. employee breakdown       → Java GET /api/dashboard/employee-invoice/{comid}?type=

import 'package:maleva/core/dashboard/dashboard_api.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/utils/app_preferences.dart';

// ─────────────────────────────────────────────────────────────
// ABSTRACT INTERFACE — BLoC depends only on this
// ─────────────────────────────────────────────────────────────
abstract class InvoiceRepository {
  /// Parallel fetch: sales summary (`{TodaySales, ..., monthlySales}`) + waiting bills
  Future<(Map<String, dynamic>?, List<dynamic>)> loadDashboard({
    required int type,
  });

  /// Waiting bills — on-demand, same endpoint as initial load
  Future<List<dynamic>> getWaitingBills();

  /// Employee breakdown `[{EmployeeName, SalesCount, Amount}]` per period index
  Future<List<dynamic>> getEmployeeInvData({required int type});
}

// ─────────────────────────────────────────────────────────────
// REAL IMPLEMENTATION — exact same API calls as original bloc
// ─────────────────────────────────────────────────────────────
class InvoiceRepositoryImpl implements InvoiceRepository {
  InvoiceRepositoryImpl({DashboardApi? api}) : _api = api;

  final DashboardApi? _api;

  DashboardApi get _dashboard => _api ?? sl<DashboardApi>();

  @override
  Future<(Map<String, dynamic>?, List<dynamic>)> loadDashboard({
    required int type,
  }) async {
    final comid = AppPreferences.getComid();
    final results = await Future.wait<dynamic>([
      _dashboard.sales(comid, type),
      _dashboard.waitingInvoices(comid),
    ]);

    final salesData    = results[0] as Map<String, dynamic>?;
    final waitingBills = List<dynamic>.from(results[1] ?? []);

    return (salesData, waitingBills);
  }

  @override
  Future<List<dynamic>> getWaitingBills() async {
    return _dashboard.waitingInvoices(AppPreferences.getComid());
  }

  @override
  Future<List<dynamic>> getEmployeeInvData({required int type}) async {
    return _dashboard.employeeInvoices(AppPreferences.getComid(), type);
  }
}