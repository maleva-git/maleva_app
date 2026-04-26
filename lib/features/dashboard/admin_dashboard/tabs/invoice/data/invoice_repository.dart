// lib/features/dashboard/admin_dashboard/tabs/invoice/data/invoice_repository.dart
//
// Real API calls — exact same endpoints as original bloc.
// objfun removed, AppPreferences + ApiConstants use pannuvom.
//
// Original bloc calls:
//   1. AuthApi.getSalesData(type)            → apiGetSalesData
//   2. AuthApi.getSalesInvoiceCheck(master)  → apiSelectSaleorderinvoicecheck
//   3. ApiClient.postRequest(apiGetEmployeeInvData + comid + type)

import 'package:intl/intl.dart';
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/network/api_services/auth_api.dart';
import 'package:maleva/core/utils/app_preferences.dart';

// ─────────────────────────────────────────────────────────────
// ABSTRACT INTERFACE — BLoC depends only on this
// ─────────────────────────────────────────────────────────────
abstract class InvoiceRepository {
  /// Parallel fetch: sales summary + waiting bills
  /// Same as original: Future.wait([getSalesData, getSalesInvoiceCheck])
  Future<(Map<String, dynamic>?, List<dynamic>)> loadDashboard({
    required int type,
  });

  /// Waiting bills — on-demand, same endpoint as initial load
  Future<List<dynamic>> getWaitingBills();

  /// Employee breakdown per month index
  /// Original: "${objfun.apiGetEmployeeInvData}${objfun.Comid}&type=$type"
  Future<List<dynamic>> getEmployeeInvData({required int type});
}

// ─────────────────────────────────────────────────────────────
// REAL IMPLEMENTATION — exact same API calls as original bloc
// ─────────────────────────────────────────────────────────────
class InvoiceRepositoryImpl implements InvoiceRepository {
  @override
  Future<(Map<String, dynamic>?, List<dynamic>)> loadDashboard({
    required int type,
  }) async {
    final comid = AppPreferences.getComid();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Exact same as original bloc — parallel Future.wait
    final results = await Future.wait([
      AuthApi.getSalesData(type),          // existing static method ✅
      AuthApi.getSalesInvoiceCheck({       // existing static method ✅
        'Comid': comid,
        'Todate': today,
      }),
    ]);

    final salesData    = results[0] as Map<String, dynamic>?;
    final waitingBills = List<dynamic>.from(results[1] ?? []);

    return (salesData, waitingBills);
  }

  @override
  Future<List<dynamic>> getWaitingBills() async {
    final comid = AppPreferences.getComid();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Same as original LoadWaitingBills handler
    // Original used: ApiClient.postRequest(objfun.apiSelectSaleorderinvoicecheck, master)
    final result = await AuthApi.getSalesInvoiceCheck({
      'Comid': comid,
      'Todate': today,
    });

    return List<dynamic>.from(result ?? []);
  }

  @override
  Future<List<dynamic>> getEmployeeInvData({required int type}) async {
    // AuthApi.getEmployeeInvData added to auth_api.dart (see auth_api_addition.dart)
    // Original: "${objfun.apiGetEmployeeInvData}${objfun.Comid}&type=$type"
    final result = await AuthApi.getEmployeeInvData(type: type);
    return List<dynamic>.from(result?['Data1'] ?? []);
  }
}