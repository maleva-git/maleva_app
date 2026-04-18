import '../../domain/models/ai_maintenance_risk_model.dart';
import 'package:maleva/core/network/api_services/reports_api.dart'; // ✅ Correct Absolute Import

class MaintenanceAIRepository {

  // Original API-ai call panni AI predictions return panra function
  // Input: Map<String, dynamic> filter
  Future<List<AIMaintenanceRisk>> getMaintenancePredictions(Map<String, dynamic> filter) async {
    try {
      // 1. 🔥 ORIGINAL API CALL
      final List<dynamic> apiDataList = await ReportsApi.getEngineHoursReport(filter);

      // 2. Data varalana empty return pannuvom
      if (apiDataList.isEmpty) {
        return [];
      }

      List<AIMaintenanceRisk> predictions = [];

      for (var data in apiDataList) {

        // 🚀 DATA MAPPING:
        // Unga JSON-la irukka exact keys-ai inga podunga. (e.g., "VehicleNo", "EngineHours")
        String truckNo = data["VehicleNo"]?.toString() ?? data["TruckNo"]?.toString() ?? "Unknown Truck";

        double currentHrs = double.tryParse(data["EngineHours"]?.toString() ?? "0") ?? 0.0;
        double lastServiceHrs = double.tryParse(data["LastServiceHours"]?.toString() ?? "0") ?? 0.0;

        // 🌟 AI PREDICTION LOGIC
        double maxSafeHours = 5000.0;
        double hrsSinceLastService = currentHrs - lastServiceHrs;

        // Risk percentage calculation
        double riskRatio = (hrsSinceLastService / maxSafeHours) * 100;
        int riskPercentage = riskRatio.clamp(0, 100).toInt();

        double predictedBreakdown = lastServiceHrs + maxSafeHours;

        String riskLevel = "Low";
        String recommendation = "No action needed currently.";

        if (riskPercentage >= 85) {
          riskLevel = "High";
          recommendation = "Immediate service required! High chance of engine failure.";
        } else if (riskPercentage >= 60) {
          riskLevel = "Medium";
          recommendation = "Schedule maintenance soon. Check engine oil and filters.";
        }

        predictions.add(AIMaintenanceRisk(
          truckNo: truckNo,
          currentEngineHours: currentHrs,
          predictedBreakdownHours: predictedBreakdown,
          riskPercentage: riskPercentage,
          riskLevel: riskLevel,
          recommendation: recommendation,
        ));
      }

      // Sort by Highest Risk First
      predictions.sort((a, b) => b.riskPercentage.compareTo(a.riskPercentage));

      return predictions;

    } catch (e) {
      throw Exception("Failed to generate AI predictions: $e");
    }
  }
}