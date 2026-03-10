import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

import '../bloc/fuelfillings_bloc.dart';
import '../bloc/fuelfillings_event.dart';
import '../bloc/fuelfillings_state.dart';

import 'package:maleva/core/colors/colors.dart' as colour;


// ── Entry Point ───────────────────────────────────────────────────────────────
class FuelFillingPage extends StatelessWidget {
  const FuelFillingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FuelFillingBloc(context)..add(LoadFuelFillingReport()),
      child: const _FuelFillingBody(),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────
class _FuelFillingBody extends StatelessWidget {
  const _FuelFillingBody();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Text(
            "Fuel Filling",
            style: GoogleFonts.lato(
              fontSize: objfun.FontLarge,
              fontWeight: FontWeight.bold,
              color: colour.kPrimaryDark,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: BlocBuilder<FuelFillingBloc, FuelFillingState>(
              builder: (context, state) {

                // ── Loading ──
                if (state is FuelFillingLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: colour.kPrimary),
                  );
                }

                // ── Error ──
                if (state is FuelFillingError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                              color: Colors.red, fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => context
                              .read<FuelFillingBloc>()
                              .add(LoadFuelFillingReport()),
                          icon: const Icon(Icons.refresh),
                          label: const Text("Retry"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: colour.kPrimary),
                        ),
                      ],
                    ),
                  );
                }

                // ── Loaded ──
                if (state is FuelFillingLoaded) {
                  if (state.fuelFillingRecords.isEmpty) {
                    return Center(
                      child: Text(
                        "No fuel filling records found.",
                        style: GoogleFonts.lato(
                            fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: state.fuelFillingRecords.length,
                    itemBuilder: (context, index) {
                      return _FuelFillingCard(
                          record: state.fuelFillingRecords[index]);
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

// ── Card ──────────────────────────────────────────────────────────────────────
class _FuelFillingCard extends StatelessWidget {
  final FuelFilling record;
  const _FuelFillingCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetailsDialog(context),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: colour.kWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colour.kAccent, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: colour.kPrimary.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Left Blue Panel ──
            Container(
              width: 70,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: const BoxDecoration(
                color: colour.kAccent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: colour.kPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_gas_station_rounded,
                    color: colour.kWhite,
                    size: 22,
                  ),
                ),
              ),
            ),

            // ── Content ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.vehicle ?? "-",
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: colour.kPrimaryDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.person_outline,
                            size: 14, color: colour.kPrimaryLight),
                        const SizedBox(width: 4),
                        Text(
                          record.driver.isNotEmpty
                              ? record.driver
                              : "Not Available",
                          style: GoogleFonts.lato(
                              fontSize: 13, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Flexible(
                          child: _MiniChip(
                            icon: Icons.local_gas_station_rounded,
                            label: record.filled.isNotEmpty ? "${record.filled} L" : "N/A",
                            bgColor: colour.kPrimary.withOpacity(0.1),
                            textColor: colour.kPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: _MiniChip(
                            icon: Icons.place_rounded,
                            label: record.location.isNotEmpty ? record.location : "N/A",
                            bgColor: Colors.orange.withOpacity(0.1),
                            textColor: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),

            // ── Arrow ──
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colour.kAccent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: colour.kPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Details Dialog ────────────────────────────────────────────────────────
  void _showDetailsDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, __, ___) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.88,
            decoration: BoxDecoration(
              color: colour.kWhite,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colour.kPrimary.withOpacity(0.18),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Header ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 20, horizontal: 24),
                  decoration: const BoxDecoration(
                    color: colour.kPrimary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_gas_station_rounded,
                          color: colour.kWhite, size: 26),
                      const SizedBox(width: 12),
                      Text(
                        "Fuel Filling Details",
                        style: GoogleFonts.lato(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colour.kWhite,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Body ──
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        Icons.local_shipping_rounded,
                        "Truck Name",
                        record.vehicle,
                      ),
                      _buildDivider(),
                      _buildInfoRow(
                        Icons.place_rounded,
                        "Location",
                        record.location.isNotEmpty ? record.location : null,
                      ),
                      _buildDivider(),
                      _buildInfoRow(
                        Icons.format_list_numbered_rounded,
                        "Count",
                        record.count.isNotEmpty ? record.count : null,
                      ),
                      _buildDivider(),
                      _buildInfoRow(
                        Icons.local_gas_station_rounded,
                        "Filled",
                        record.filled.isNotEmpty ? record.filled : null,
                      ),
                      _buildDivider(),
                      _buildInfoRow(
                        Icons.person_rounded,
                        "Driver",
                        record.driver.isNotEmpty ? record.driver : null,
                      ),
                      _buildDivider(),
                      _buildInfoRow(
                        Icons.access_time_rounded,
                        "Time",
                        record.time.isNotEmpty ? record.time : null,
                      ),
                      const SizedBox(height: 24),

                      // ── Close Button ──
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colour.kPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            "Close",
                            style: GoogleFonts.lato(
                              color: colour.kWhite,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      transitionBuilder: (_, anim, __, child) => ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
        child: FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  Widget _buildDivider() =>
      Divider(color: colour.kAccent, thickness: 1.5, height: 24);

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colour.kAccent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: colour.kPrimary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.lato(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value?.isNotEmpty == true ? value! : "Not Available",
                style: GoogleFonts.lato(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: colour.kPrimaryDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Mini Badge Chip ───────────────────────────────────────────────────────────
class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bgColor;
  final Color textColor;

  const _MiniChip({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: GoogleFonts.lato(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}