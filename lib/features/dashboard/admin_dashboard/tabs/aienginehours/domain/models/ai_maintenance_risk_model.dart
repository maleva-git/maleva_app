class AIMaintenanceRisk {
  final String truckNo;
  final double currentEngineHours;
  final double predictedBreakdownHours; // Eppo breakdown aakum
  final int riskPercentage; // 0 to 100
  final String riskLevel; // High, Medium, Low
  final String recommendation;

  AIMaintenanceRisk({
    required this.truckNo,
    required this.currentEngineHours,
    required this.predictedBreakdownHours,
    required this.riskPercentage,
    required this.riskLevel,
    required this.recommendation,
  });
}