// lib/features/dashboard/common_tabs/receiptview/data/receipt_repository.dart
//
// Customers owing for the period: the shared Java
// `/api/customer-reports/period-balance/rows` (was .NET
// TransactionReportApp/SelectCustomerBalance). Rows: `customerName`,
// `balance`, `billAmount`, ...

import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/reports/transaction_report_api.dart';

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

// ── Real implementation ────────────────────────────────────────────────────────
class ReceiptRepositoryImpl implements ReceiptRepository {
  @override
  Future<ReceiptResult?> getReceipts({
    required String fromDate,
    required String toDate,
  }) async {
    final rows = await sl<TransactionReportApi>().customerBalances(fromDate: fromDate, toDate: toDate);
    return ReceiptResult(masterList: rows, detailList: const []);
  }
}
