import 'package:maleva/core/dashboard/dashboard_api.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/utils/app_preferences.dart';

/// K8 numbers not yet released, from the shared Java `GET /api/dashboard/k8-unreleased/{comid}`.
class UnReleaseSMKRepository {
  UnReleaseSMKRepository({DashboardApi? api}) : _api = api;

  final DashboardApi? _api;

  /// `[{Id, BillNoDisplay, DayCount, Remarks}]`.
  Future<List<Map<String, dynamic>>> fetchUnReleaseSMKData() async {
    try {
      return await (_api ?? sl<DashboardApi>()).k8Unreleased(AppPreferences.getComid());
    } catch (e) {
      throw Exception('Failed to fetch UnRelease SMK data: $e');
    }
  }
}
