// lib/features/dashboard/common_tabs/invoice/data/invoice_repository.dart
//
// The invoice desk:
//   1. sales summary            → Java GET /api/dashboard/sales/{comid}?type=0
//   2. waiting bills            → .NET MasterReportApp/SelectChecksalesinvoice (not moved yet)
//   3. employee breakdown       → Java GET /api/dashboard/employee-invoice/{comid}?type=

import 'package:intl/intl.dart';
import 'package:maleva/core/dashboard/dashboard_api.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/network/api_services/auth_api.dart';
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
    final today = DateFormat('yyyy/MM/dd').format(DateTime.now());

    final master = {
      'Comid': comid,
      "DashboardStatus": 0,
      'Fromdate': '2025/08/16',
      "Employeeid ": 0,
      'Id': 0,
      "Invoice": true,
      'Offvesselname': "",
      "Invoicecheck": false,
      'Remarks': 2,
      "Search": 3,
      'Todate': today,
      "completestatusnotshow": false,
    };

    final results = await Future.wait<dynamic>([
      _dashboard.sales(comid, type),
      AuthApi.getSalesInvoiceCheck(master),
    ]);

    final salesData    = results[0] as Map<String, dynamic>?;
    final waitingBills = List<dynamic>.from(results[1] ?? []);

    return (salesData, waitingBills);
  }

  @override
  Future<List<dynamic>> getWaitingBills() async {
    final comid = AppPreferences.getComid();
    final today = DateFormat('yyyy/MM/dd').format(DateTime.now());

    final master = {
      'Comid': comid,
      "DashboardStatus": 0,
      'Fromdate': '2025/08/16',
      "Employeeid ": 0,
      'Id': 0,
      "Invoice": true,
      'Offvesselname': "",
      "Invoicecheck": false,
      'Remarks': 2,
      "Search": 3,
      'Todate': today,
      "completestatusnotshow": false,
    };

    // Same as original LoadWaitingBills handler
    final result = await AuthApi.getSalesInvoiceCheck(master);

    return List<dynamic>.from(result ?? []);
  }

  @override
  Future<List<dynamic>> getEmployeeInvData({required int type}) async {
    return _dashboard.employeeInvoices(AppPreferences.getComid(), type);
  }
}