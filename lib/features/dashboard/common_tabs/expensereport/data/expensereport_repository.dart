import 'package:maleva/core/dashboard/dashboard_api.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/utils/app_preferences.dart';

class ExpenseReportResult {
  /// One row: `{TodaySales, TodayAmount, ..., MonthSales, MonthAmount}` (fixed periods).
  final List<Map<String, dynamic>> data1;

  /// `[{ExpenseName, ExpCount, ExpAmount}]` in the chosen dates.
  final List<Map<String, dynamic>> data2;

  ExpenseReportResult({required this.data1, required this.data2});
}

/// The expense report, from the shared Java `GET /api/dashboard/expense/{comid}`.
class ExpenseReportRepository {
  ExpenseReportRepository({DashboardApi? api}) : _api = api;

  final DashboardApi? _api;

  /// [fromDate] and [toDate] are `yyyy-MM-dd`.
  Future<ExpenseReportResult?> getExpenseReport({
    required String fromDate,
    required String toDate,
  }) async {
    try {
      final data = await (_api ?? sl<DashboardApi>()).expenses(AppPreferences.getComid(), fromDate, toDate);
      if (data.isEmpty) return null;
      return ExpenseReportResult(
        data1: [Map<String, dynamic>.from(data)..remove('expenses')],
        data2: List<Map<String, dynamic>>.from(
            (data['expenses'] as List? ?? const []).whereType<Map>().map(Map<String, dynamic>.from)),
      );
    } catch (e) {
      throw Exception('Failed to load expense report: $e');
    }
  }
}
