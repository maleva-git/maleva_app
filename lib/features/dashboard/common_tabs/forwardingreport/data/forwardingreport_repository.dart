import 'package:maleva/core/dashboard/dashboard_api.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/utils/app_preferences.dart';

class ForwardingReportResult {
  /// One row with the period block: `todayCount`, `todayRelease`, `todayWithRelease`, ... `month*`.
  final List<Map<String, dynamic>> data1;

  /// One row with the K block in the chosen dates: `k1Count`, `k1Release`, `k1WithRelease`, ... `k8*`.
  final List<Map<String, dynamic>> data2;

  ForwardingReportResult({required this.data1, required this.data2});
}

/// The forwarding report, from the shared Java `GET /api/dashboard/forwarding/{comid}`.
/// Both blocks come in one Java answer; each screen part reads its own keys.
class ForwardingReportRepository {
  ForwardingReportRepository({DashboardApi? api}) : _api = api;

  final DashboardApi? _api;

  /// [fromDate] and [toDate] are `yyyy-MM-dd`.
  Future<ForwardingReportResult?> getForwardingReport({
    required String fromDate,
    required String toDate,
  }) async {
    try {
      final data = await (_api ?? sl<DashboardApi>()).forwarding(AppPreferences.getComid(), fromDate, toDate);
      if (data.isEmpty) return null;
      return ForwardingReportResult(data1: [data], data2: [data]);
    } catch (e) {
      throw Exception('Failed to load forwarding report: $e');
    }
  }
}
