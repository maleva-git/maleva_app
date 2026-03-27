import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;
import '../bloc/pdo_bloc.dart';
import '../bloc/pdo_event.dart';
import '../bloc/pdo_state.dart';

// ── Entry Point ───────────────────────────────────────────────────────────────
class PDOViewPage extends StatelessWidget {
  final String fromDate;
  final String toDate;
  final int driverId;
  final int truckId;
  final int employeeId;
  final String search;

  const PDOViewPage({
    super.key,
    required this.fromDate,
    required this.toDate,
    this.driverId  = 0,
    this.truckId   = 0,
    this.employeeId = 0,
    this.search    = '',
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PDOBloc(
        context,
        fromDate:   fromDate,
        toDate:     toDate,
        driverId:   driverId,
        truckId:    truckId,
        employeeId: employeeId,
        search:     search,
      ),
      child: const _PDOViewBody(),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────
class _PDOViewBody extends StatelessWidget {
  const _PDOViewBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PDOBloc, PDOViewState>(
      listener: (context, state) {
        if (state is PDOViewLoaded) {

          // ── Success dialog ──────────────────────────────────
          if (state.saveSuccessMasterId != null) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => _SuccessDialog(
                onOk: () {
                  Navigator.pop(context);
                  context
                      .read<PDOBloc>()
                      .add(const ResetPDOSaveStatusEvent());
                },
              ),
            );
          }

          // ── Error dialog ────────────────────────────────────
          if (state.saveError != null) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                title: Row(children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Text("Error",
                      style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
                ]),
                content: Text(state.saveError!,
                    style: GoogleFonts.lato()),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context
                          .read<PDOBloc>()
                          .add(const ResetPDOSaveStatusEvent());
                    },
                    child: Text("OK",
                        style: GoogleFonts.lato(color: colour.kPrimary)),
                  ),
                ],
              ),
            );
          }
        }
      },
      builder: (context, state) {

        if (state is PDOViewLoading) {
          return const Center(
              child: CircularProgressIndicator(color: colour.kPrimary));
        }



        // ── Error ───────────────────────────────────────────
        if (state is PDOViewError) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(state.message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context
                    .read<PDOBloc>()
                    .add(const LoadPDOViewEvent()),
                icon: const Icon(Icons.refresh),
                label: const Text("Retry"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: colour.kPrimary),
              ),
            ]),
          );
        }

        // ── Loaded ──────────────────────────────────────────
        final s = state as PDOViewLoaded;

        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Page title ────────────────────────────────────
                Row(children: [
                  Container(
                    width: 32, height: 32,
                    decoration: const BoxDecoration(
                        color: colour.kAccent, shape: BoxShape.circle),
                    child: const Icon(Icons.receipt_long_rounded,
                        color: colour.kPrimary, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Text("RTI Details",
                      style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colour.kPrimaryDark)),
                  const Spacer(),
                  if (s.filteredMasters.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: colour.kAccent,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text("${s.filteredMasters.length} records",
                          style: GoogleFonts.lato(
                              color: colour.kPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ),
                ]),

                const SizedBox(height: 10),

                // ── Search ────────────────────────────────────────
                TextField(
                  onChanged: (v) =>
                      context.read<PDOBloc>().add(SearchPDOEvent(v)),
                  style: GoogleFonts.lato(color: colour.kPrimaryDark),
                  decoration: InputDecoration(
                    hintText: "Search RTI No / Driver / Truck",
                    hintStyle: GoogleFonts.lato(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: colour.kPrimary),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 14),
                    filled: true,
                    fillColor: colour.kAccent,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: colour.kPrimary, width: 1.5)),
                  ),
                ),

                const SizedBox(height: 12),

                // ── List ──────────────────────────────────────────
                Expanded(
                  child: s.filteredMasters.isEmpty
                      ? Center(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.receipt_long_outlined,
                                size: 60, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text("No Records Found",
                                style: GoogleFonts.lato(
                                    fontSize: 16, color: Colors.grey)),
                          ]))
                      : ListView.builder(
                    itemCount: s.filteredMasters.length,
                    itemBuilder: (context, index) {
                      final m = s.filteredMasters[index];

                      // Only show masters that have detail rows with images
                      final detailsWithImg =
                      s.detailsWithImageFor(m.Id);
                      if (detailsWithImg.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return _RTIMasterCard(
                        master:  m,
                        details: s.detailsFor(m.Id),
                        isSaving: s.isSaving,
                      );
                    },
                  ),
                ),
              ]),
        );
      },
    );
  }
}

// ── Master Expansion Card ─────────────────────────────────────────────────────
class _RTIMasterCard extends StatelessWidget {
  final RTIMasterViewModel master;
  final List<RTIDetailsViewModel> details;
  final bool isSaving;

  const _RTIMasterCard({
    required this.master,
    required this.details,
    required this.isSaving,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colour.kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colour.kAccent, width: 1.5),
        boxShadow: [
          BoxShadow(
              color: colour.kPrimary.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Theme(
          // Remove default ExpansionTile divider lines
          data: Theme.of(context)
              .copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,

            // ── Header ───────────────────────────────────────
            title: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              decoration: const BoxDecoration(
                color: colour.kPrimary,
              ),
              child: Row(children: [
                // RTI No
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(master.RTINoDisplay,
                            style: GoogleFonts.lato(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: colour.kWhite)),
                        const SizedBox(height: 3),
                        Text(master.RTIDate,
                            style: GoogleFonts.lato(
                                fontSize: 11,
                                color: colour.kWhite.withOpacity(0.75))),
                      ]),
                ),
                // Amount badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: colour.kWhite.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text("RM ${master.Amount}",
                      style: GoogleFonts.lato(
                          color: colour.kWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                ),
              ]),
            ),

            // ── Expanded children ─────────────────────────────
            children: [
              // Master info card
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colour.kAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow("Driver",  master.DriverName),
                      _infoRow("Truck",   master.TruckName),
                      _infoRow("Remarks", master.Remarks),
                    ]),
              ),

              // ── Verify button ───────────────────────────────
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding:
                      const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    onPressed: isSaving
                        ? null
                        : () => context
                        .read<PDOBloc>()
                        .add(SavePDOEvent(master.Id)),
                    icon: isSaving
                        ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(
                            color: colour.kWhite, strokeWidth: 2))
                        : const Icon(Icons.verified_rounded,
                        color: colour.kWhite, size: 18),
                    label: Text("Verify",
                        style: GoogleFonts.lato(
                            color: colour.kWhite,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                  ),
                ),
              ),

              // ── Detail rows ─────────────────────────────────
              ...details.map((d) => _RTIDetailRow(
                detail: d,
                masterId: master.Id,
              )),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Detail Row ────────────────────────────────────────────────────────────────
class _RTIDetailRow extends StatelessWidget {
  final RTIDetailsViewModel detail;
  final int masterId;

  const _RTIDetailRow({required this.detail, required this.masterId});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colour.kWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: colour.kPrimaryLight.withOpacity(0.25), width: 1.2),
        boxShadow: [
          BoxShadow(
              color: colour.kPrimary.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Job No + verify checkbox
        Row(children: [
          Expanded(
            child: Text(detail.JobNo,
                style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: colour.kPrimaryDark)),
          ),
          // Verify checkbox as icon toggle
          GestureDetector(
            onTap: () => context.read<PDOBloc>().add(
                TogglePDOVerifyEvent(
                    detailId: detail.Id, value: !detail.isVerified)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: detail.isVerified
                    ? Colors.green.shade600
                    : colour.kAccent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(
                  detail.isVerified
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  color: detail.isVerified
                      ? colour.kWhite
                      : colour.kPrimary,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  detail.isVerified ? "Verified" : "Verify",
                  style: GoogleFonts.lato(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: detail.isVerified
                          ? colour.kWhite
                          : colour.kPrimary),
                ),
              ]),
            ),
          ),
        ]),

        const SizedBox(height: 6),

        _infoRow("Customer", detail.CustomerName),

        // Image thumbnail
        if ((detail.imagePath ?? '').isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildImageThumbnail(context, detail.imagePath),
        ],
      ]),
    );
  }
}

// ── Image thumbnail + popup ───────────────────────────────────────────────────
Widget _buildImageThumbnail(BuildContext context, String? path) {
  if (path == null || path.isEmpty) return const SizedBox.shrink();

  Widget imageWidget;

  if (path.startsWith("http")) {
    imageWidget = Image.network(path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
        const Icon(Icons.broken_image, color: Colors.red));
  } else if (path.startsWith("/data/")) {
    imageWidget = Image.file(File(path),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
        const Icon(Icons.broken_image, color: Colors.red));
  } else if (path.startsWith("/")) {
    final url = objfun.port + path;
    imageWidget = Image.network(url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
        const Icon(Icons.broken_image, color: Colors.red));
  } else {
    return const SizedBox.shrink();
  }

  return GestureDetector(
    onTap: () => _showImagePopup(context, imageWidget),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 90, height: 90,
        decoration: BoxDecoration(
          border: Border.all(
              color: colour.kPrimaryLight.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: imageWidget,
      ),
    ),
  );
}

void _showImagePopup(BuildContext context, Widget imageWidget) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.black87,
      insetPadding: const EdgeInsets.all(10),
      child: Stack(children: [
        InteractiveViewer(child: imageWidget),
        Positioned(
          top: 10, right: 10,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(17)),
              child: const Icon(Icons.close,
                  color: colour.kWhite, size: 18),
            ),
          ),
        ),
      ]),
    ),
  );
}

// ── Info row ──────────────────────────────────────────────────────────────────
Widget _infoRow(String label, String? value) {
  if (value == null || value.isEmpty) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        width: 70,
        child: Text(label,
            style: GoogleFonts.lato(
                fontSize: 12,
                color: Colors.grey[500],
                fontWeight: FontWeight.w600)),
      ),
      const Text(" : ",
          style: TextStyle(color: Colors.grey, fontSize: 12)),
      Expanded(
        child: Text(value,
            style: GoogleFonts.lato(
                fontSize: 13, color: colour.kPrimaryDark)),
      ),
    ]),
  );
}

// ── Success Dialog ────────────────────────────────────────────────────────────
class _SuccessDialog extends StatelessWidget {
  final VoidCallback onOk;
  const _SuccessDialog({required this.onOk});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      title: Row(children: [
        const Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
        const SizedBox(width: 10),
        Text("Success",
            style: GoogleFonts.lato(
                fontWeight: FontWeight.bold, color: colour.kPrimaryDark)),
      ]),
      content: Text("Saved successfully!",
          style: GoogleFonts.lato(fontSize: 14)),
      actions: [
        ElevatedButton(
          onPressed: onOk,
          style: ElevatedButton.styleFrom(
              backgroundColor: colour.kPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8))),
          child: Text("OK",
              style: GoogleFonts.lato(
                  color: colour.kWhite, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}