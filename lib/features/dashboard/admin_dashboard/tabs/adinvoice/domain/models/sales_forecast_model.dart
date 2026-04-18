// lib/features/dashboard/admin_dashboard/tabs/invoice/domain/models/sales_forecast_model.dart

class SalesDataPoint {
  final String monthName;
  final double amount;
  final bool isForecast;

  SalesDataPoint({
    required this.monthName,
    required this.amount,
    this.isForecast = false,
  });
}