import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../bloc/forecast/forecast_bloc.dart';
import '../../domain/models/sales_forecast_model.dart';

class AISalesForecastWidget extends StatelessWidget {
  const AISalesForecastWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_graph_rounded, color: Colors.deepPurple, size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  "AI Revenue Forecast",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "3 Months",
                    style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                )
              ],
            ),
            const SizedBox(height: 30),

            // Chart Section
            SizedBox(
              height: 260,
              child: BlocBuilder<ForecastBloc, ForecastState>(
                builder: (context, state) {
                  if (state is ForecastLoading) {
                    return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
                  } else if (state is ForecastError) {
                    return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
                  } else if (state is ForecastLoaded) {
                    return _buildChart(state.data);
                  }
                  return const Center(child: Text("Initializing AI..."));
                },
              ),
            ),
            const SizedBox(height: 24),

            // Legends Section
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegend(
                    gradient: const LinearGradient(colors: [Colors.blue, Colors.indigoAccent]),
                    text: "Actual Sales"
                ),
                const SizedBox(width: 24),
                _buildLegend(
                    gradient: const LinearGradient(colors: [Colors.orangeAccent, Colors.deepOrange]),
                    text: "AI Predicted"
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(color: Colors.black12, thickness: 1),
            const SizedBox(height: 16),

            // 🔥 NEW: AI Insights Section
            BlocBuilder<ForecastBloc, ForecastState>(
              builder: (context, state) {
                if (state is ForecastLoaded) {
                  return _buildAIInsightsBox(state.data);
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 NEW FUNCTION: Generates dynamic reason based on data trends
  Widget _buildAIInsightsBox(List<SalesDataPoint> data) {
    if (data.isEmpty) return const SizedBox();

    final actualData = data.where((e) => !e.isForecast).toList();
    final forecastData = data.where((e) => e.isForecast).toList();

    String insightTitle = "AI Reasoning";
    String insightText = "Analyzing data to generate insights...";
    IconData insightIcon = Icons.psychology_outlined;
    Color iconColor = Colors.deepPurple;

    if (actualData.length >= 3 && forecastData.isNotEmpty) {
      double lastActual = actualData.last.amount;
      double firstForecast = forecastData.first.amount;

      double difference = firstForecast - lastActual;
      double percentage = (difference / (lastActual == 0 ? 1 : lastActual)) * 100;

      if (percentage > 5) {
        insightTitle = "Growth Trend Detected";
        insightText = "Based on the 3-month moving average and recent momentum, the AI detected an upward trend. Sales are projected to increase by ~${percentage.toStringAsFixed(1)}% next month.";
        insightIcon = Icons.trending_up_rounded;
        iconColor = Colors.green;
      } else if (percentage < -5) {
        insightTitle = "Conservative Projection";
        insightText = "Recent data shows a slight dip. The AI applied a trend-adjusted smoothing algorithm to forecast a conservative change of ~${percentage.toStringAsFixed(1)}% before stabilizing.";
        insightIcon = Icons.trending_down_rounded;
        iconColor = Colors.orange;
      } else {
        insightTitle = "Stable Revenue Flow";
        insightText = "Sales patterns appear stable. The AI used historical baselines to project a steady revenue flow with minimal fluctuations for the upcoming quarter.";
        insightIcon = Icons.trending_flat_rounded;
        iconColor = Colors.blue;
      }
    } else {
      insightText = "Insufficient past data for deep analysis. Generating baseline forecast based on available metrics.";
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                ]
            ),
            child: Icon(insightIcon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insightTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 6),
                Text(
                  insightText,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLegend({required Gradient gradient, required String text}) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(4)
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700], fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildChart(List<SalesDataPoint> data) {
    double maxY = 0;
    if (data.isNotEmpty) {
      maxY = data.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
    }

    if (maxY <= 0 || maxY.isNaN) {
      maxY = 1000;
    } else {
      maxY = maxY + (maxY * 0.25);
    }

    double interval = maxY / 4;
    if (interval <= 0 || interval.isNaN) interval = 250;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.black.withOpacity(0.8),
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${data[group.x.toInt()].monthName}\n',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                children: <TextSpan>[
                  TextSpan(
                    text: '₹${rod.toY.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: data[group.x.toInt()].isForecast ? Colors.orangeAccent : Colors.lightBlueAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < 0 || value.toInt() >= data.length) return const SizedBox();
                final isForecast = data[value.toInt()].isForecast;
                return Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    data[value.toInt()].monthName,
                    style: TextStyle(
                      color: isForecast ? Colors.deepOrange : Colors.grey[600],
                      fontWeight: isForecast ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.15),
            strokeWidth: 1.5,
            dashArray: [4, 4],
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(data.length, (index) {
          final point = data[index];
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: point.amount,
                gradient: point.isForecast
                    ? const LinearGradient(
                  colors: [Colors.orangeAccent, Colors.deepOrange],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                )
                    : const LinearGradient(
                  colors: [Colors.lightBlue, Colors.indigoAccent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),  
                width: 22,
                borderRadius: BorderRadius.circular(6),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY,
                  color: point.isForecast
                      ? Colors.orange.withOpacity(0.05)
                      : Colors.blue.withOpacity(0.05),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}