import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import '../../../../../../core/models/model.dart';
import '../bloc/speeding_bloc.dart';
import 'package:maleva/core/colors/colors.dart' as colour;


class SpeedingScreen extends StatelessWidget {
  const SpeedingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SpeedingBloc(context)..add(LoadSpeedingReport()),
      child: const _SpeedingBody(),
    );
  }
}

class _SpeedingBody extends StatelessWidget {
  const _SpeedingBody();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Text(
            "Speeding Details",
            style: GoogleFonts.lato(
              fontSize: objfun.FontLarge,
              fontWeight: FontWeight.bold,
              color: colour.commonColor,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: BlocBuilder<SpeedingBloc, SpeedingState>(
              builder: (context, state) {
                if (state is SpeedingLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.deepOrange),
                  );
                }

                if (state is SpeedingError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 12),
                        Text(state.message,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lato(color: Colors.red, fontSize: 14)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () =>
                              context.read<SpeedingBloc>().add(LoadSpeedingReport()),
                          icon: const Icon(Icons.refresh),
                          label: const Text("Retry"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange),
                        ),
                      ],
                    ),
                  );
                }

                if (state is SpeedingLoaded) {
                  if (state.speedingRecords.isEmpty) {
                    return Center(
                      child: Text("No speeding records found.",
                          style: GoogleFonts.lato(fontSize: 16, color: Colors.grey)),
                    );
                  }

                  return ListView.builder(
                    itemCount: state.speedingRecords.length,
                    itemBuilder: (context, index) {
                      return _SpeedingCard(record: state.speedingRecords[index]);
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeedingCard extends StatelessWidget {
  final SpeedingView record;
  const _SpeedingCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.orange.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.deepOrange.shade100,
          child: const Icon(Icons.local_shipping, color: Colors.deepOrange, size: 20),
        ),
        title: Text(
          record.vehicle ?? "-",
          style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        subtitle: Text(
          "Driver: ${record.driver.isNotEmpty ? record.driver : 'Not Available'}",
          style: GoogleFonts.lato(fontSize: 14, color: Colors.grey[600]),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade500),
        onTap: () => _showDetailsDialog(context),
      ),
    );
  }

  void _showDetailsDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 18, offset: Offset(0, 6)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "🚚 Truck Info",
                    style: GoogleFonts.lato(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildInfoRow("🚛 Truck Name", record.vehicle),
                const SizedBox(height: 14),
                _buildInfoRow("⚠️ Limit", record.count.isNotEmpty ? record.count : "Not Available"),
                const SizedBox(height: 14),
                _buildInfoRow("💨 Speed", record.filled.isNotEmpty ? record.filled : "Not Available"),
                const SizedBox(height: 14),
                _buildInfoRow("👨‍✈️ Driver", record.driver.isNotEmpty ? record.driver : "Not Available"),
                const SizedBox(height: 14),
                _buildInfoRow("⏰ Time", record.time.isNotEmpty ? record.time : "Not Available"),
                const SizedBox(height: 26),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      backgroundColor: Colors.deepOrange,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Close",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      transitionBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label: ",
          style: GoogleFonts.lato(
              fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
        ),
        Expanded(
          child: Text(
            value?.isNotEmpty == true ? value! : "Not Available",
            style: GoogleFonts.lato(fontSize: 15, color: Colors.black54),
          ),
        ),
      ],
    );
  }
}