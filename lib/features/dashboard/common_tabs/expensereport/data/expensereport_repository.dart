import 'package:maleva/core/network/api_legacy_helper.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/utils/app_preferences.dart';

class ExpenseReportResult {
  final List<Map<String, dynamic>> data1;
  final List<Map<String, dynamic>> data2;

  ExpenseReportResult({required this.data1, required this.data2});
}

class ExpenseReportRepository {
  Future<ExpenseReportResult?> getExpenseReport({
    required String fromDate,
    required String toDate,
  }) async {
    try {
      final String comId = (AppPreferences.getComid()).toString();

      Map<String, String> header = {
        'Content-Type': 'application/json; charset=UTF-8',
      };

      // Ensure your apiAllinoneSelectArray is updated to handle context optionally
      final resultData = await ApiLegacyHelper.apiAllinoneSelectArray(
        "${ApiConstants.apiGetExpData}$comId&startDate=$fromDate&endDate=$toDate",
        null,
        header,
        null, // Pass null for context
      );

      if (resultData != null && resultData is Map && resultData.isNotEmpty) {
        return ExpenseReportResult(
          data1: List<Map<String, dynamic>>.from(resultData["Data1"] ?? []),
          data2: List<Map<String, dynamic>>.from(resultData["Data2"] ?? []),
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load expense report: $e');
    }
  }
}