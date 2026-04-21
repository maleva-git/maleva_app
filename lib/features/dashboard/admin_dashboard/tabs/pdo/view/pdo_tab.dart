import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;
import '../../../../../../core/theme/tokens.dart';
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
    this.driverId   = 0,
    this.truckId    = 0,
    this.employeeId = 0,
    this.search     = '',
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
          if (state.saveSuccessMasterId != null) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => _SuccessDialog(
                onOk: () {
                  Navigator.pop(context);
                  context.read<PDOBloc>().add(const ResetPDOSaveStatusEvent());
                },
              ),
            );
          }
          if (state.saveError != null) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                title: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle),
                    child: Icon(Icons.error_outline,
                        color: Colors.red.shade600, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text("Error",
                      style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
                ]),
                content: Text(state.saveError!, style: GoogleFonts.lato()),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context
                          .read<PDOBloc>()
                          .add(const ResetPDOSaveStatusEvent());
                    },
                    child: Text("OK",
                        style: GoogleFonts.lato(
                            color: AppTokens.brandGradientStart,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          }
        }
      },
      builder: (context, state) {
        if (state is PDOViewLoading) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  color: AppTokens.brandGradientStart,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 16),
              Text("Loading RTI Details…",
                  style: GoogleFonts.lato(
                      color: Colors.grey.shade500, fontSize: 13)),
            ]),
          );
        }

        if (state is PDOViewError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.red.shade50, shape: BoxShape.circle),
                  child: Icon(Icons.error_outline,
                      color: Colors.red.shade400, size: 40),
                ),
                const SizedBox(height: 16),
                Text("Something went wrong",
                    style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTokens.brandDark)),
                const SizedBox(height: 6),
                Text(state.message,
                    textAlign: TextAlign.center,
                    style:
                    GoogleFonts.lato(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () =>
                      context.read<PDOBloc>().add(const LoadPDOViewEvent()),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text("Try Again",
                      style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTokens.brandGradientStart,
                    foregroundColor: colour.kWhite,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ]),
            ),
          );
        }

        final s = state as PDOViewLoaded;

        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Top header band ───────────────────────────────────
          _PageHeader(count: s.filteredMasters.length),

          // ── Search bar ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: _SearchBar(
              onChanged: (v) =>
                  context.read<PDOBloc>().add(SearchPDOEvent(v)),
            ),
          ),

          const SizedBox(height: 10),

          // ── List ──────────────────────────────────────────────
          Expanded(
            child: s.filteredMasters.isEmpty
                ? _EmptyState()
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 20),
              itemCount: s.filteredMasters.length,
              itemBuilder: (context, index) {
                final m = s.filteredMasters[index];
                final detailsWithImg = s.detailsWithImageFor(m.Id);
                if (detailsWithImg.isEmpty) return const SizedBox.shrink();
                return _RTIMasterCard(
                  master:  m,
                  details: s.detailsFor(m.Id),
                  isSaving: s.isSaving,
                );
              },
            ),
          ),
        ]);
      },
    );
  }
}

// ── Page Header ───────────────────────────────────────────────────────────────
class _PageHeader extends StatelessWidget {
  final int count;
  const _PageHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: colour.kWhite,
        border: Border(
            bottom: BorderSide(
                color: AppTokens.brandLight, width: 1.5)),
      ),
      child: Row(children: [
        // Icon pill
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTokens.brandGradientStart,
                AppTokens.brandGradientStart.withOpacity(0.75),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.receipt_long_rounded,
              color: colour.kWhite, size: 18),
        ),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("RTI Details",
              style: GoogleFonts.lato(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppTokens.brandGradientStartDark)),
          Text("Return to Inventory",
              style: GoogleFonts.lato(
                  fontSize: 11, color: Colors.grey.shade500)),
        ]),
        const Spacer(),
        if (count > 0)
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppTokens.brandLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.folder_open_rounded,
                  size: 13, color: AppTokens.brandGradientStart),
              const SizedBox(width: 4),
              Text("$count records",
                  style: GoogleFonts.lato(
                      color: AppTokens.brandGradientStart,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ]),
          ),
      ]),
    );
  }
}

// ── Search Bar ────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colour.kWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTokens.brandLight, width: 1.5),
        boxShadow: [
          BoxShadow(
              color: AppTokens.brandGradientStart.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        style: GoogleFonts.lato(
            color: AppTokens.brandDark, fontSize: 14),
        decoration: InputDecoration(
          hintText: "Search RTI No / Driver / Truck",
          hintStyle:
          GoogleFonts.lato(color: Colors.grey.shade400, fontSize: 13),
          prefixIcon: Icon(Icons.search_rounded,
              color: AppTokens.brandGradientStart, size: 20),
          contentPadding:
          const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                  color: AppTokens.brandGradientStart, width: 1.5)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
              color: AppTokens.brandLight, shape: BoxShape.circle),
          child: Icon(Icons.receipt_long_outlined,
              size: 44, color: AppTokens.brandGradientStart.withOpacity(0.4)),
        ),
        const SizedBox(height: 16),
        Text("No Records Found",
            style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTokens.brandDark)),
        const SizedBox(height: 4),
        Text("Try adjusting the date range or search",
            style: GoogleFonts.lato(
                fontSize: 13, color: Colors.grey.shade400)),
      ]),
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
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: colour.kWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: AppTokens.brandLight.withOpacity(0.8), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: AppTokens.brandGradientStart.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4)),
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 1)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,

            // ── Header ───────────────────────────────────────
            title: _MasterCardHeader(master: master),

            // ── Expanded content ─────────────────────────────
            children: [
              // Divider accent line
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    AppTokens.brandGradientStart.withOpacity(0.0),
                    AppTokens.brandGradientStart.withOpacity(0.3),
                    AppTokens.brandGradientStart.withOpacity(0.0),
                  ]),
                ),
              ),

              const SizedBox(height: 12),

              // Master info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: _MasterInfoCard(master: master),
              ),

              const SizedBox(height: 10),

              // Verify button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: _VerifyButton(
                  isSaving: isSaving,
                  onTap: () => context
                      .read<PDOBloc>()
                      .add(SavePDOEvent(master.Id)),
                ),
              ),

              const SizedBox(height: 10),

              // Section label
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(children: [
                  Container(
                    width: 3,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppTokens.brandGradientStart,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text("Job Details",
                      style: GoogleFonts.lato(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade500,
                          letterSpacing: 0.5)),
                ]),
              ),

              const SizedBox(height: 8),

              // Detail rows
              ...details.map((d) => Padding(
                padding:
                const EdgeInsets.fromLTRB(14, 0, 14, 8),
                child: _RTIDetailRow(
                  detail: d,
                  masterId: master.Id,
                ),
              )),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Master Card Header ────────────────────────────────────────────────────────
class _MasterCardHeader extends StatelessWidget {
  final RTIMasterViewModel master;
  const _MasterCardHeader({required this.master});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTokens.brandGradientStart,
            AppTokens.brandGradientStart.withBlue(
                (AppTokens.brandGradientStart.blue + 30).clamp(0, 255)),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(children: [
        // RTI icon circle
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
              color: colour.kWhite.withOpacity(0.15),
              shape: BoxShape.circle),
          child: const Icon(Icons.receipt_rounded,
              color: colour.kWhite, size: 15),
        ),
        const SizedBox(width: 10),

        // RTI No + Date
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(master.RTINoDisplay,
                    style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: colour.kWhite)),
                const SizedBox(height: 2),
                Row(children: [
                  Icon(Icons.calendar_today_rounded,
                      size: 10,
                      color: colour.kWhite.withOpacity(0.7)),
                  const SizedBox(width: 4),
                  Text(master.RTIDate,
                      style: GoogleFonts.lato(
                          fontSize: 11,
                          color: colour.kWhite.withOpacity(0.75))),
                ]),
              ]),
        ),

        // Amount badge
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colour.kWhite.withOpacity(0.18),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: colour.kWhite.withOpacity(0.25), width: 1),
          ),
          child: Text("RM ${master.Amount}",
              style: GoogleFonts.lato(
                  color: colour.kWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
        ),
      ]),
    );
  }
}

// ── Master Info Card ──────────────────────────────────────────────────────────
class _MasterInfoCard extends StatelessWidget {
  final RTIMasterViewModel master;
  const _MasterInfoCard({required this.master});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTokens.brandLight.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppTokens.brandLight, width: 1.2),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoChip(
                Icons.person_outline_rounded, "Driver", master.DriverName),
            if ((master.DriverName ?? '').isNotEmpty &&
                (master.TruckName ?? '').isNotEmpty)
              const Divider(height: 12, thickness: 0.5),
            _infoChip(Icons.local_shipping_outlined, "Truck",
                master.TruckName),
            if ((master.TruckName ?? '').isNotEmpty &&
                (master.Remarks ?? '').isNotEmpty)
              const Divider(height: 12, thickness: 0.5),
            _infoChip(Icons.notes_rounded, "Remarks", master.Remarks),
          ]),
    );
  }
}

// ── Verify Button ─────────────────────────────────────────────────────────────
class _VerifyButton extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onTap;
  const _VerifyButton({required this.isSaving, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade600,
          disabledBackgroundColor: Colors.green.shade200,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        onPressed: isSaving ? null : onTap,
        child: isSaving
            ? Row(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
                color: colour.kWhite, strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text("Saving…",
              style: GoogleFonts.lato(
                  color: colour.kWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
        ])
            : Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.verified_rounded,
              color: colour.kWhite, size: 18),
          const SizedBox(width: 6),
          Text("Verify",
              style: GoogleFonts.lato(
                  color: colour.kWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
        ]),
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
    final isVerified = detail.isVerified;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: isVerified
            ? Colors.green.shade50.withOpacity(0.6)
            : colour.kWhite,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: isVerified
              ? Colors.green.shade200
              : AppTokens.brandLight,
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
              color: isVerified
                  ? Colors.green.withOpacity(0.05)
                  : AppTokens.brandGradientStart.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job No + verify toggle
            Row(children: [
              // Left accent dot
              Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: isVerified
                      ? Colors.green.shade500
                      : AppTokens.brandGradientStart,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(detail.JobNo,
                    style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppTokens.brandDark)),
              ),

              // Verify toggle pill
              GestureDetector(
                onTap: () => context.read<PDOBloc>().add(
                    TogglePDOVerifyEvent(
                        detailId: detail.Id, value: !isVerified)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 11, vertical: 6),
                  decoration: BoxDecoration(
                    color: isVerified
                        ? Colors.green.shade600
                        : AppTokens.brandLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: isVerified
                            ? Colors.green.shade600
                            : AppTokens.brandGradientStart.withOpacity(0.3),
                        width: 1),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      child: Icon(
                        isVerified
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        key: ValueKey(isVerified),
                        color: isVerified
                            ? colour.kWhite
                            : AppTokens.brandGradientStart,
                        size: 15,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isVerified ? "Verified" : "Verify",
                      style: GoogleFonts.lato(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isVerified
                              ? colour.kWhite
                              : AppTokens.brandGradientStart),
                    ),
                  ]),
                ),
              ),
            ]),

            const SizedBox(height: 8),

            // Customer
            _infoRow("Customer", detail.CustomerName),

            // Image thumbnail
            if ((detail.imagePath ?? '').isNotEmpty) ...[
              const SizedBox(height: 10),
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
            Icon(Icons.broken_image_rounded, color: Colors.red.shade300));
  } else if (path.startsWith("/data/")) {
    imageWidget = Image.file(File(path),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Icon(Icons.broken_image_rounded, color: Colors.red.shade300));
  } else if (path.startsWith("/")) {
    final url = objfun.port + path;
    imageWidget = Image.network(url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Icon(Icons.broken_image_rounded, color: Colors.red.shade300));
  } else {
    return const SizedBox.shrink();
  }

  return GestureDetector(
    onTap: () => _showImagePopup(context, imageWidget),
    child: Stack(children: [
      // Shadow container
      Container(
        width: 95,
        height: 95,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 8,
                offset: const Offset(0, 3)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: imageWidget,
        ),
      ),
      // Expand icon overlay
      Positioned(
        bottom: 5,
        right: 5,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(6)),
          child: const Icon(Icons.fullscreen_rounded,
              color: colour.kWhite, size: 13),
        ),
      ),
    ]),
  );
}

void _showImagePopup(BuildContext context, Widget imageWidget) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.black87,
      insetPadding: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: InteractiveViewer(child: imageWidget),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.close_rounded,
                  color: colour.kWhite, size: 18),
            ),
          ),
        ),
      ]),
    ),
  );
}

// ── Info chip (for master card) ───────────────────────────────────────────────
Widget _infoChip(IconData icon, String label, String? value) {
  if (value == null || value.isEmpty) return const SizedBox.shrink();
  return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon,
        size: 14, color: AppTokens.brandGradientStart.withOpacity(0.7)),
    const SizedBox(width: 6),
    SizedBox(
      width: 62,
      child: Text(label,
          style: GoogleFonts.lato(
              fontSize: 12,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600)),
    ),
    const Text(" : ",
        style: TextStyle(color: Colors.grey, fontSize: 12)),
    Expanded(
      child: Text(value,
          style: GoogleFonts.lato(
              fontSize: 13, color: AppTokens.brandDark)),
    ),
  ]);
}

// ── Info row (for detail rows) ────────────────────────────────────────────────
Widget _infoRow(String label, String? value) {
  if (value == null || value.isEmpty) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.only(bottom: 3),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        width: 68,
        child: Text(label,
            style: GoogleFonts.lato(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w600)),
      ),
      const Text(" : ",
          style: TextStyle(color: Colors.grey, fontSize: 12)),
      Expanded(
        child: Text(value,
            style:
            GoogleFonts.lato(fontSize: 13, color: AppTokens.brandDark)),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.green.shade50, shape: BoxShape.circle),
          child: Icon(Icons.check_circle_rounded,
              color: Colors.green.shade600, size: 36),
        ),
        const SizedBox(height: 14),
        Text("Saved Successfully!",
            style: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppTokens.brandDark)),
        const SizedBox(height: 6),
        Text("The RTI record has been verified.",
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
                fontSize: 13, color: Colors.grey.shade500)),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onOk,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTokens.brandGradientStart,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: 0,
            ),
            child: Text("Done",
                style: GoogleFonts.lato(
                    color: colour.kWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
          ),
        ),
      ]),
    );
  }
}