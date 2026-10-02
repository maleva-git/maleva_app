import 'package:maleva/core/dashboard/dashboard_api.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/utils/app_preferences.dart';

/// Forwarding numbers not yet released, from the shared Java `/api/dashboard`.
class UnReleaseRepository {
  UnReleaseRepository({DashboardApi? api}) : _api = api;

  final DashboardApi? _api;

  /// `[{Id, BillNoDisplay, DayCount, Remarks}]`; [type] 1 = K8 numbers, otherwise all.
  Future<List<Map<String, dynamic>>> fetchUnReleaseData(int type) async {
    try {
      final api = _api ?? sl<DashboardApi>();
      final comid = AppPreferences.getComid();
      return type == 1 ? await api.k8Unreleased(comid) : await api.unreleased(comid);
    } catch (e) {
      throw Exception('Failed to fetch unrelease data: $e');
    }
  }
}
