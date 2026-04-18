// lib/features/dashboard/admin_dashboard/tabs/invoice/data/repositories/sales_forecast_repository.dart

import 'package:intl/intl.dart';
import '../../../../../../../core/network/api_services/auth_api.dart';
import '../../domain/models/sales_forecast_model.dart';

// Oru chinna custom response class
class ForecastResponse {
  final String status; // 'NO_DATA', 'INSUFFICIENT', 'SUCCESS'
  final List<SalesDataPoint> data;
  ForecastResponse(this.status, this.data);
}

class SalesForecastRepository {
  Future<ForecastResponse> getSalesAndForecast(int type) async {
    try {
      final resultData = await AuthApi.getSalesData(type);

      if (resultData == null || resultData["Data2"] == null) {
        return ForecastResponse("NO_DATA", []);
      }

      List<dynamic> rawData = resultData["Data2"];
      if (rawData.isEmpty) {
        return ForecastResponse("NO_DATA", []);
      }

      // API-la index 0 = Current Month, 1 = Last Month nu varuthu.
      // Namba first 6 elements eduthu, athai 'reversed' panraom (Pazhayathu -> Puthusu)
      List<double> historicalData = rawData
          .take(6)
          .map((e) => (e['SalesAmount'] as num).toDouble())
          .toList()
          .reversed
          .toList();

      List<SalesDataPoint> finalDataPoints = [];
      DateTime now = DateTime.now();

      // Pazhaya data-vai chart model-ku maathuraom
      for (int i = 0; i < historicalData.length; i++) {
        DateTime pastMonth = DateTime(now.year, now.month - (historicalData.length - 1 - i));
        finalDataPoints.add(
          SalesDataPoint(
            monthName: DateFormat('MMM').format(pastMonth),
            amount: historicalData[i],
            isForecast: false,
          ),
        );
      }

      // 🔥 AI Prediction logic - Need minimum 3 months of data to find a trend
      if (historicalData.length < 3) {
        return ForecastResponse("INSUFFICIENT", finalDataPoints);
      }

      List<double> forecastData = _predictNextMonths(historicalData, 3);

      for (int i = 0; i < forecastData.length; i++) {
        DateTime futureMonth = DateTime(now.year, now.month + i + 1);
        finalDataPoints.add(
          SalesDataPoint(
            monthName: DateFormat('MMM').format(futureMonth),
            amount: forecastData[i],
            isForecast: true,
          ),
        );
      }

      return ForecastResponse("SUCCESS", finalDataPoints);
    } catch (e) {
      throw Exception("Forecast failed: $e");
    }
  }

  List<double> _predictNextMonths(List<double> history, int monthsToPredict) {
    List<double> predictions = [];
    List<double> dataPool = List.from(history);

    for (int i = 0; i < monthsToPredict; i++) {
      int n = dataPool.length;
      double recentTrend = (dataPool[n - 1] - dataPool[n - 3]) / 2;
      double movingAvg = (dataPool[n - 1] + dataPool[n - 2] + dataPool[n - 3]) / 3;
      double predictedValue = movingAvg + (recentTrend * 0.5);
      if (predictedValue < 0) predictedValue = 0;

      predictions.add(predictedValue);
      dataPool.add(predictedValue);
    }
    return predictions;
  }
}