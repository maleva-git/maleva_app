// lib/features/dashboard/admin_dashboard/tabs/receiptview/data/receipt_repository.dart
//
// Original API call in bloc:
//   ReportsApi.getCustomerBalance(master, header)
//   master = { "tilldate": toDate, "fromdate": fromDate, "CompanyRefId": objfun.Comid }
//   header = { 'Content-Type': 'application/json; charset=UTF-8' }
//
// Same call — objfun.Comid replaced with AppPreferences.getComid()

import 'package:maleva/core/network/api_services/reports_api.dart';
import 'package:maleva/core/utils/app_preferences.dart';

// ── Result model — clean typed return ─────────────────────────────────────────
class ReceiptResult {
  final List<dynamic> masterList;
  final List<dynamic> detailList;

  const ReceiptResult({
    required this.masterList,
    required this.detailList,
  });
}

// ── Abstract interface ─────────────────────────────────────────────────────────
abstract class ReceiptRepository {
  Future<ReceiptResult?> getReceipts({
    required String fromDate,
    required String toDate,
  });
}

// ── Real implementation — exact same API as original bloc ──────────────────────
class ReceiptRepositoryImpl implements ReceiptRepository {
  @override
  Future<ReceiptResult?> getReceipts({
    required String fromDate,
    required String toDate,
  }) async {
    // AppPreferences replaces objfun.Comid
    final comid = AppPreferences.getComid();

    // Exact same master + header as original bloc
    final master = {
      'tilldate':      toDate,
      'fromdate':      fromDate,
      'CompanyRefId':  comid,
    };

    final header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    // Same API call: ReportsApi.getCustomerBalance(master, header)
    final resultData = await ReportsApi.getCustomerBalance(master, header);

    if (resultData == null || resultData.isEmpty) return null;

    return ReceiptResult(
      masterList: resultData['Data1'] is List ? resultData['Data1'] : [],
      detailList: resultData['Data2'] is List ? resultData['Data2'] : [],
    );
  }
}