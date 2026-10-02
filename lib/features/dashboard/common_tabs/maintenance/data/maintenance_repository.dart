import 'package:maleva/core/dashboard/dashboard_api.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/features/transport/models/maintenance_model.dart';

/// The maintenance widget, from the shared Java `/api/dashboard` (ported from .NET
/// SelectStatusBO, LoadSupplierExpenseData and LoadExpenseData; the rows keep the .NET names).
class MaintenanceRepository {
  MaintenanceRepository({DashboardApi? api}) : _api = api;

  final DashboardApi? _api;

  DashboardApi get _dashboard => _api ?? sl<DashboardApi>();

  // ── 1. Fetch Current Month Stats ──────────────────────────────────────────
  Future<Map<String, dynamic>> fetchCurrentMonthStats(String fromDate, String toDate) async {
    try {
      final response = await _dashboard.maintenanceStatus(AppPreferences.getComid(), fromDate, toDate);

      List<MaintenanceModel> statsData = [];
      if (response.isNotEmpty) {
        statsData = response
            .map(MaintenanceModel.fromJson)
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
      final response = await _dashboard.supplierExpenses(AppPreferences.getComid());

      if (response.isNotEmpty) {
        return response
            .map(MaintenanceModel.fromJson)
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
      final response = await _dashboard.runningExpenses(AppPreferences.getComid(), fromDate, toDate);

      if (response.isNotEmpty) {
        return response
            .map(MaintenanceModel.fromJson)
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load summary maintenance: $e');
    }
  }
}