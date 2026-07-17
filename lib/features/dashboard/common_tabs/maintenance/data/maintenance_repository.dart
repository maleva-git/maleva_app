import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/features/transport/models/maintenance_model.dart';

class MaintenanceRepository {
  // ── 1. Fetch Current Month Stats ──────────────────────────────────────────
  Future<Map<String, dynamic>> fetchCurrentMonthStats(String fromDate, String toDate) async {
    try {
      final comid = AppPreferences.getComid();
      final url = '${ApiConstants.apiGetMaintenance2}$comid&Fromdate=$fromDate&Todate=$toDate';

      final response = await ApiClient.postRequest(url, null);

      List<MaintenanceModel> statsData = [];
      if (response != null && response is List) {
        statsData = response
            .map((e) => MaintenanceModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      int breakdownCount = 0;
      double breakdownAmount = 0.0;
      int repairCount = 0;
      double repairAmount = 0.0;
      int serviceCount = 0;
      double serviceAmount = 0.0;
      int sparePartsCount = 0;
      double sparePartsAmount = 0.0;

      for (final item in statsData) {
        switch (item.Description.toString().toUpperCase()) {
          case 'BREAKDOWN':
            breakdownCount = int.tryParse(item.PStatus.toString()) ?? 0;
            breakdownAmount = double.tryParse(item.Amount.toString()) ?? 0.0;
            break;
          case 'REPAIR':
            repairCount = int.tryParse(item.PStatus.toString()) ?? 0;
            repairAmount = double.tryParse(item.Amount.toString()) ?? 0.0;
            break;
          case 'SERVICE':
            serviceCount = int.tryParse(item.PStatus.toString()) ?? 0;
            serviceAmount = double.tryParse(item.Amount.toString()) ?? 0.0;
            break;
          case 'SPARE PARTS':
            sparePartsCount = int.tryParse(item.PStatus.toString()) ?? 0;
            sparePartsAmount = double.tryParse(item.Amount.toString()) ?? 0.0;
            break;
        }
      }

      return {
        'breakdownCount': breakdownCount,
        'breakdownAmount': breakdownAmount,
        'repairCount': repairCount,
        'repairAmount': repairAmount,
        'serviceCount': serviceCount,
        'serviceAmount': serviceAmount,
        'sparePartsCount': sparePartsCount,
        'sparePartsAmount': sparePartsAmount,
      };
    } catch (e) {
      throw Exception('Failed to load stats: $e');
    }
  }

  // ── 2. Fetch Pending Maintenance (6 Months) ───────────────────────────────
  Future<List<dynamic>> fetchPendingMaintenance() async {
    try {
      final comid = AppPreferences.getComid();
      final url = '${ApiConstants.apiGetMaintenance}$comid';

      final response = await ApiClient.postRequest(url, null);

      if (response != null && response is List && response.isNotEmpty) {
        return response
            .map((e) => MaintenanceModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load pending maintenance: $e');
    }
  }

  // ── 3. Fetch Summary Maintenance (1 Year) ─────────────────────────────────
  Future<List<dynamic>> fetchSummaryMaintenance(String fromDate, String toDate) async {
    try {
      final comid = AppPreferences.getComid();
      final url = '${ApiConstants.apiGetMaintenance1}$comid&Fromdate=$fromDate&Todate=$toDate';

      final response = await ApiClient.postRequest(url, null);

      if (response != null && response is List && response.isNotEmpty) {
        return response
            .map((e) => MaintenanceModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load summary maintenance: $e');
    }
  }
}