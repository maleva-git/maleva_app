import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import '../bloc/fuelreport_bloc.dart';
import '../bloc/fuelreport_event.dart';
import '../bloc/fuelreport_state.dart';
import 'package:maleva/core/colors/colors.dart' as colour;



// ── Entry Point ───────────────────────────────────────────────────────────────
class FuelDiffPage extends StatelessWidget {
  const FuelDiffPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FuelDiffBloc(context),
      child: const _FuelDiffBody(),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────
class _FuelDiffBody extends StatelessWidget {
  const _FuelDiffBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FuelDiffBloc, FuelDiffState>(
      listener: (context, state) {
        if (state is FuelDiffError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        // ── Loading ──
        if (state is FuelDiffLoading) {
          return const Center(
              child: CircularProgressIndicator(color: colour.kPrimary));
        }

        // ── Error ──
        if (state is FuelDiffError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text(state.message,
                    textAlign: TextAlign.center,
                    style:
                    GoogleFonts.lato(color: Colors.red, fontSize: 14)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context
                      .read<FuelDiffBloc>()
                      .add(const LoadFuelDiffEvent()),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Retry"),
                  style:
                  ElevatedButton.styleFrom(backgroundColor: colour.kPrimary),
                ),
              ],
            ),
          );
        }

        // ── Loaded ──
        if (state is FuelDiffLoaded) {
          return Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [

                // ── Title ──
                Text(
                  "Fuel Different",
                  style: GoogleFonts.lato(
                    fontSize: objfun.FontLarge,
                    fontWeight: FontWeight.bold,
                    color: colour.kPrimaryDark,
                  ),
                ),

                const SizedBox(height: 10),

                // ── Date Filter Bar ──────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: colour.kAccent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: colour.kPrimaryLight.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      // From Date
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("From",
                                style: GoogleFonts.lato(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w600)),
                            Text(
                              DateFormat("dd-MM-yy").format(
                                  DateTime.parse(state.fromDate)),
                              style: GoogleFonts.lato(
                                  fontWeight: FontWeight.bold,
                                  fontSize: objfun.FontLow,
                                  color: colour.kPrimaryDark),
                            ),
                          ],
                        ),
                      ),

                      // From Date Picker
                      _DatePickerButton(
                        onDateSelected: (date) => context
                            .read<FuelDiffBloc>()
                            .add(SelectFromDateEvent(date)),
                      ),

                      Container(
                        width: 1,
                        height: 30,
                        color: colour.kPrimaryLight.withOpacity(0.3),
                        margin:
                        const EdgeInsets.symmetric(horizontal: 8),
                      ),

                      // To Date
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("To",
                                style: GoogleFonts.lato(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w600)),
                            Text(
                              DateFormat("dd-MM-yy")
                                  .format(DateTime.parse(state.toDate)),
                              style: GoogleFonts.lato(
                                  fontWeight: FontWeight.bold,
                                  fontSize: objfun.FontLow,
                                  color: colour.kPrimaryDark),
                            ),
                          ],
                        ),
                      ),

                      // To Date Picker
                      _DatePickerButton(
                        onDateSelected: (date) => context
                            .read<FuelDiffBloc>()
                            .add(SelectToDateEvent(date)),
                      ),

                      const SizedBox(width: 8),

                      // View Button
                      ElevatedButton(
                        onPressed: () => context
                            .read<FuelDiffBloc>()
                            .add(const LoadFuelDiffEvent()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colour.kPrimary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: Text("View",
                            style: GoogleFonts.lato(
                                color: colour.kWhite,
                                fontWeight: FontWeight.bold,
                                fontSize: objfun.FontLow)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // ── List ─────────────────────────────────────────────────────
                Expanded(
                  child: state.records.isEmpty
                      ? Center(
                    child: Text(
                      "No records found.",
                      style: GoogleFonts.lato(
                          fontSize: 16, color: Colors.grey),
                    ),
                  )
                      : ListView.builder(
                    itemCount: state.records.length,
                    itemBuilder: (context, index) {
                      return _FuelDiffCard(
                          record: state.records[index]);
                    },
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

// ── Date Picker Button ────────────────────────────────────────────────────────
class _DatePickerButton extends StatelessWidget {
  final ValueChanged<String> onDateSelected;
  const _DatePickerButton({required this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2050),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme:
              const ColorScheme.light(primary: colour.kPrimary),
            ),
            child: child!,
          ),
        );
        if (picked != null) {
          onDateSelected(DateFormat('yyyy-MM-dd').format(picked));
        }
      },
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: colour.kPrimary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.calendar_month_outlined,
            color: colour.kWhite, size: 18),
      ),
    );
  }
}

// ── Fuel Diff Card ────────────────────────────────────────────────────────────
class _FuelDiffCard extends StatelessWidget {
  final FuelselectModel record;
  const _FuelDiffCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final double aAmount = record.aAmount ?? 0.0;
    final double gAmount = record.gAmount ?? 0.0;
    final double aliter = record.aliter ?? 0.0;
    final double gliter = record.gliter ?? 0.0;
    final double difference = gliter - aliter;
    final String driverName = record.driverName ?? "Unknown Driver";
    final String truckName = record.truckName ?? "No Truck";

    Color diffColor;
    IconData diffIcon;
    if (difference > 0) {
      diffColor = Colors.green;
      diffIcon = Icons.trending_up;
    } else if (difference < 0) {
      diffColor = Colors.red;
      diffIcon = Icons.trending_down;
    } else {
      diffColor = Colors.grey;
      diffIcon = Icons.remove;
    }

    return GestureDetector(
      onTap: () => _showDetailsDialog(context, driverName, truckName,
          aAmount, gAmount, aliter, gliter),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: colour.kWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colour.kAccent, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: colour.kPrimary.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                        color: colour.kAccent, shape: BoxShape.circle),
                    child: const Icon(Icons.local_shipping_rounded,
                        color: colour.kPrimary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(driverName,
                            style: GoogleFonts.lato(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colour.kPrimaryDark)),
                        Text(truckName,
                            style: GoogleFonts.lato(
                                fontSize: 13, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Divider(color: colour.kAccent, thickness: 1),

              // ── Amount Row ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoTile("A Amount",
                      "RM ${aAmount.toStringAsFixed(2)}", colour.kPrimary),
                  _infoTile("G Amount",
                      "RM ${gAmount.toStringAsFixed(2)}", colour.kPrimaryLight),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoTile("A Liter",
                      "${aliter.toStringAsFixed(2)} L", colour.kPrimary),
                  _infoTile("G Liter",
                      "${gliter.toStringAsFixed(2)} L", colour.kPrimaryLight),
                ],
              ),

              const SizedBox(height: 10),

              // ── Difference Badge ──
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: diffColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(diffIcon, color: diffColor, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      "Difference: ${difference >= 0 ? '+' : ''}${difference.toStringAsFixed(2)}",
                      style: GoogleFonts.lato(
                          color: diffColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 15),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.lato(
                fontSize: 11,
                color: Colors.grey[500],
                fontWeight: FontWeight.w600)),
        Text(value,
            style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color)),
      ],
    );
  }

  void _showDetailsDialog(
      BuildContext context,
      String driverName,
      String truckName,
      double aAmount,
      double gAmount,
      double aliter,
      double gliter,
      ) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: colour.kWhite,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // ── Dialog Header ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
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
                          color: colour.kWhite, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        "Fuel Details",
                        style: GoogleFonts.lato(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colour.kWhite),
                      ),
                    ],
                  ),
                ),

                // ── Dialog Body — Scrollable ──
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _dialogRow(Icons.person_rounded, "Driver", driverName),
                        _divider(),
                        _dialogRow(Icons.local_shipping_rounded, "Truck", truckName),
                        _divider(),
                        _dialogRow(Icons.calendar_month_rounded, "Fuel Date",
                            record.sSaleDate ?? "-"),
                        _divider(),
                        _dialogRow(Icons.local_gas_station_rounded, "P Rate",
                            record.pRate.toString()),
                        _divider(),
                        _dialogRow(Icons.local_gas_station_outlined, "P Litre",
                            record.pliter.toString()),
                        _divider(),
                        _dialogRow(Icons.currency_rupee_rounded, "P Amount",
                            "RM ${record.pAmount}"),
                        _divider(),
                        _dialogRow(Icons.check_circle_rounded, "A Amount",
                            "RM ${aAmount.toStringAsFixed(2)}"),
                        _divider(),
                        _dialogRow(Icons.format_list_numbered_rounded, "A Liter",
                            "${aliter.toStringAsFixed(2)} L"),
                        _divider(),
                        _dialogRow(Icons.attach_money_rounded, "G Amount",
                            "RM ${gAmount.toStringAsFixed(2)}"),
                        _divider(),
                        _dialogRow(Icons.local_gas_station_rounded, "G Liter",
                            "${gliter.toStringAsFixed(2)} L"),
                        _divider(),
                        _dialogRow(Icons.balance_rounded, "Diff Liter",
                            record.dPliter.toString()),
                        _divider(),
                        _dialogRow(Icons.money_off_rounded, "Diff Amount",
                            record.dPAmount.toString()),
                        _divider(),
                        _dialogRow(Icons.note_rounded, "Remarks",
                            record.remarks.toString()),
                        const SizedBox(height: 20),

                        // ── Close Button ──
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colour.kPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "Close",
                              style: GoogleFonts.lato(
                                  color: colour.kWhite,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider() =>
      Divider(color: colour.kAccent, thickness: 1.5, height: 20);

  Widget _dialogRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
              color: colour.kAccent, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: colour.kPrimary, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.lato(
                      fontSize: 11,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w600)),
              Text(
                value.isNotEmpty ? value : "Not Available",
                style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colour.kPrimaryDark),
              ),
            ],
          ),
        ),
      ],
    );
  }
}