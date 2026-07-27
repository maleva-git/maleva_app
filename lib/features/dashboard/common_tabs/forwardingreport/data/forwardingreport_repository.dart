import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/network/legacy_api_repository.dart';
import 'package:maleva/core/di/injection.dart';

class ForwardingReportResult {
  final List<Map<String, dynamic>> data1;
  final List<Map<String, dynamic>> data2;

  ForwardingReportResult({required this.data1, required this.data2});
}

class ForwardingReportRepository {
  Future<ForwardingReportResult?> getForwardingReport({
    required String fromDate,
    required String toDate,
  }) async {
    try {
      final String comId = (AppPreferences.getComid()).toString();

      Map<String, String> header = {
        'Content-Type': 'application/json; charset=UTF-8',
      };

      // Removed BuildContext since it shouldn't be in the data layer.
      // Ensure your apiAllinoneSelectArray is updated to handle context optionally or via a global navigator key if needed for token expiry dialogs.
      final resultData = await sl<LegacyApiRepository>().apiAllinoneSelectArray(
        "${ApiConstants.apiGetFWData}$comId&startDate=$fromDate&endDate=$toDate",
        null,
        header,
        null, // Pass null for context
      );

      if (resultData != null && resultData is Map && resultData.isNotEmpty) {
        return ForwardingReportResult(
          data1: List<Map<String, dynamic>>.from(resultData["Data1"] ?? []),
          data2: List<Map<String, dynamic>>.from(resultData["Data2"] ?? []),
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load forwarding report: $e');
    }
  }
}