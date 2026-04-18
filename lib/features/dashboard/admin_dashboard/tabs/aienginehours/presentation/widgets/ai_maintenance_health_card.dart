import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/ai_maintenance_bloc.dart';
import '../../domain/models/ai_maintenance_risk_model.dart';

class AIMaintenanceHealthCard extends StatelessWidget {
  const AIMaintenanceHealthCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  "AI Maintenance Alert",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87),
                ),
                const Spacer(),
                const Text(
                  "High Risk",
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Trucks predicted to need service within next 500 hours based on engine usage patterns.",
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // List of Risky Trucks
            BlocBuilder<AIMaintenanceBloc, AIMaintenanceState>(
              builder: (context, state) {
                if (state is AIMaintenanceLoading) {
                  return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
                } else if (state is AIMaintenanceLoaded) {
                  // Only show High and Medium risk trucks
                  final riskyTrucks = state.risks.where((t) => t.riskLevel != "Low").toList();

                  if (riskyTrucks.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text("All trucks are in good health! 🎉", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: riskyTrucks.length,
                    separatorBuilder: (context, index) => const Divider(height: 24),
                    itemBuilder: (context, index) {
                      return _buildTruckRiskRow(riskyTrucks[index]);
                    },
                  );
                } else if (state is AIMaintenanceError) {
                  return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTruckRiskRow(AIMaintenanceRisk truck) {
    Color riskColor = truck.riskLevel == "High" ? Colors.redAccent : Colors.orangeAccent;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Percentage Circle
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: riskColor, width: 3),
          ),
          child: Center(
            child: Text(
              "${truck.riskPercentage}%",
              style: TextStyle(color: riskColor, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Truck Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                truck.truckNo,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                "Current: ${truck.currentEngineHours.toInt()} hrs | Predicted Fail: ${truck.predictedBreakdownHours.toInt()} hrs",
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 6),
              Text(
                truck.recommendation,
                style: TextStyle(fontSize: 12, color: riskColor, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}