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
    this.driverId = 0,
    this.truckId = 0,
    this.employeeId = 0,
    this.search = '',
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PDOBloc(
        context,
        fromDate: fromDate,
        toDate: toDate,
        driverId: driverId,
        truckId: truckId,
        employeeId: employeeId,
        search: search,
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
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.red.shade50, shape: BoxShape.circle),
                    child: Icon(Icons.error_outline,
                        color: Colors.red.shade600, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text("Error",
                      style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
                ]),
                content: Text(state.saveError!,
                    style: GoogleFonts.lato(
                        fontSize: 15, color: Colors.grey.shade800)),
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
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
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
                  strokeWidth: 3.5,
                ),
              ),
              const SizedBox(height: 20),
              Text("Loading RTI Details…",
                  style: GoogleFonts.lato(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            ]),
          );
        }

        if (state is PDOViewError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                      color: Colors.red.shade50, shape: BoxShape.circle),
                  child: Icon(Icons.error_outline,
                      color: Colors.red.shade400, size: 48),
                ),
                const SizedBox(height: 20),
                Text("Something went wrong",
                    style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTokens.brandDark)),
                const SizedBox(height: 8),
                Text(state.message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                        color: Colors.grey.shade600, fontSize: 14)),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () =>
                      context.read<PDOBloc>().add(const LoadPDOViewEvent()),
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  label: Text("Try Again",
                      style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTokens.brandGradientStart,
                    foregroundColor: colour.kWhite,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _SearchBar(
              onChanged: (v) => context.read<PDOBloc>().add(SearchPDOEvent(v)),
            ),
          ),

          const SizedBox(height: 12),

          // ── List ──────────────────────────────────────────────
          Expanded(
            child: s.filteredMasters.isEmpty
                ? const _EmptyState()
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: s.filteredMasters.length,
              itemBuilder: (context, index) {
                final m = s.filteredMasters[index];
                final detailsWithImg = s.detailsWithImageFor(m.Id);
                if (detailsWithImg.isEmpty) {
                  return const SizedBox.shrink();
                }
                return _RTIMasterCard(
                  master: m,
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: colour.kWhite,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
        border: Border(
            bottom: BorderSide(color: AppTokens.brandLight, width: 1.0)),
      ),
      child: Row(children: [
        // Icon pill
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTokens.brandGradientStart,
                AppTokens.brandGradientStart.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.receipt_long_rounded,
              color: colour.kWhite, size: 20),
        ),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("RTI Details",
              style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTokens.brandGradientStartDark)),
          const SizedBox(height: 2),
          Text("Return to Inventory",
              style: GoogleFonts.lato(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500)),
        ]),
        const Spacer(),
        if (count > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppTokens.brandLight,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.folder_open_rounded,
                  size: 14, color: AppTokens.brandGradientStart),
              const SizedBox(width: 6),
              Text("$count records",
                  style: GoogleFonts.lato(
                      color: AppTokens.brandGradientStart,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTokens.brandLight, width: 1.0),
        boxShadow: [
          BoxShadow(
              color: AppTokens.brandGradientStart.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        style: GoogleFonts.lato(color: AppTokens.brandDark, fontSize: 15),
        decoration: InputDecoration(
          hintText: "Search RTI No / Driver / Truck",
          hintStyle:
          GoogleFonts.lato(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded,
              color: AppTokens.brandGradientStart, size: 22),
          contentPadding:
          const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
              BorderSide(color: AppTokens.brandGradientStart, width: 1.5)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: AppTokens.brandLight.withOpacity(0.5),
              shape: BoxShape.circle),
          child: Icon(Icons.receipt_long_outlined,
              size: 48, color: AppTokens.brandGradientStart.withOpacity(0.5)),
        ),
        const SizedBox(height: 20),
        Text("No Records Found",
            style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTokens.brandDark)),
        const SizedBox(height: 6),
        Text("Try adjusting the date range or search",
            style: GoogleFonts.lato(
                fontSize: 14, color: Colors.grey.shade500)),
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
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colour.kWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTokens.brandLight, width: 1.0),
        boxShadow: [
          BoxShadow(
              color: AppTokens.brandGradientStart.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Theme(
          // Hide default expansion tile borders
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            // Customizing arrow icon color to match the header gradient
            iconColor: colour.kWhite,
            collapsedIconColor: colour.kWhite.withOpacity(0.9),

            // ── Header ───────────────────────────────────────
            title: _MasterCardHeader(master: master),

            // ── Expanded content ─────────────────────────────
            children: [
              const SizedBox(height: 16),

              // Master info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _MasterInfoCard(master: master),
              ),

              const SizedBox(height: 14),

              // Verify button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _VerifyButton(
                  isSaving: isSaving,
                  onTap: () =>
                      context.read<PDOBloc>().add(SavePDOEvent(master.Id)),
                ),
              ),

              const SizedBox(height: 20),

              // Section label
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppTokens.brandGradientStart,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text("JOB DETAILS",
                      style: GoogleFonts.lato(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade500,
                          letterSpacing: 0.8)),
                ]),
              ),

              const SizedBox(height: 12),

              // Detail rows
              ...details.map((d) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: _RTIDetailRow(
                  detail: d,
                  masterId: master.Id,
                ),
              )),

              const SizedBox(height: 8),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTokens.brandGradientStart,
            AppTokens.brandGradientStart.withBlue(
                (AppTokens.brandGradientStart.blue + 25).clamp(0, 255)),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(children: [
        // RTI icon circle
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: colour.kWhite.withOpacity(0.2), shape: BoxShape.circle),
          child: const Icon(Icons.receipt_rounded,
              color: colour.kWhite, size: 18),
        ),
        const SizedBox(width: 12),

        // RTI No + Date
        Expanded(
          child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(master.RTINoDisplay,
                style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: colour.kWhite)),
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.calendar_today_rounded,
                  size: 12, color: colour.kWhite.withOpacity(0.8)),
              const SizedBox(width: 6),
              Text(master.RTIDate,
                  style: GoogleFonts.lato(
                      fontSize: 12, color: colour.kWhite.withOpacity(0.9))),
            ]),
          ]),
        ),

        // Amount badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colour.kWhite.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colour.kWhite.withOpacity(0.3), width: 1),
          ),
          child: Text("RM ${master.Amount}",
              style: GoogleFonts.lato(
                  color: colour.kWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTokens.brandLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTokens.brandLight, width: 1.0),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _infoChip(Icons.person_outline_rounded, "Driver", master.DriverName),
        if ((master.DriverName ?? '').isNotEmpty &&
            (master.TruckName ?? '').isNotEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Divider(height: 16, thickness: 0.5),
          ),
        _infoChip(Icons.local_shipping_outlined, "Truck", master.TruckName),
        if ((master.TruckName ?? '').isNotEmpty &&
            (master.Remarks ?? '').isNotEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Divider(height: 16, thickness: 0.5),
          ),
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
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade600,
          disabledBackgroundColor: Colors.green.shade300,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 2,
          shadowColor: Colors.green.shade200,
        ),
        onPressed: isSaving ? null : onTap,
        child: isSaving
            ? Row(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
                color: colour.kWhite, strokeWidth: 2.5),
          ),
          const SizedBox(width: 10),
          Text("Saving…",
              style: GoogleFonts.lato(
                  color: colour.kWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
        ])
            : Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.verified_rounded,
              color: colour.kWhite, size: 20),
          const SizedBox(width: 8),
          Text("Verify RTI Request",
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
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
        isVerified ? Colors.green.shade50.withOpacity(0.5) : colour.kWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isVerified ? Colors.green.shade200 : AppTokens.brandLight,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
              color: isVerified
                  ? Colors.green.withOpacity(0.04)
                  : AppTokens.brandGradientStart.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Job No + verify toggle
        Row(children: [
          // Left accent dot
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 10),
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
                    fontSize: 15,
                    color: AppTokens.brandDark)),
          ),

          // Verify toggle pill
          GestureDetector(
            onTap: () => context.read<PDOBloc>().add(
                TogglePDOVerifyEvent(detailId: detail.Id, value: !isVerified)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isVerified ? Colors.green.shade600 : AppTokens.brandLight,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: isVerified
                        ? Colors.green.shade600
                        : AppTokens.brandGradientStart.withOpacity(0.3),
                    width: 1),
                boxShadow: isVerified
                    ? [
                  BoxShadow(
                      color: Colors.green.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2))
                ]
                    : [],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    isVerified
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    key: ValueKey(isVerified),
                    color:
                    isVerified ? colour.kWhite : AppTokens.brandGradientStart,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isVerified ? "Verified" : "Verify",
                  style: GoogleFonts.lato(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isVerified
                          ? colour.kWhite
                          : AppTokens.brandGradientStart),
                ),
              ]),
            ),
          ),
        ]),

        const SizedBox(height: 12),

        // Customer
        _infoRow("Customer", detail.CustomerName),

        // Image thumbnail
        if ((detail.imagePath ?? '').isNotEmpty) ...[
          const SizedBox(height: 12),
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
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTokens.brandLight, width: 1),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: imageWidget,
        ),
      ),
      // Expand icon overlay
      Positioned(
        bottom: 6,
        right: 6,
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.fullscreen_rounded,
              color: colour.kWhite, size: 16),
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
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Stack(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: InteractiveViewer(child: imageWidget),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle),
              child: const Icon(Icons.close_rounded,
                  color: colour.kWhite, size: 20),
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
    Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Icon(icon,
          size: 16, color: AppTokens.brandGradientStart.withOpacity(0.8)),
    ),
    const SizedBox(width: 8),
    SizedBox(
      width: 70,
      child: Text(label,
          style: GoogleFonts.lato(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600)),
    ),
    const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text(":", style: TextStyle(color: Colors.grey, fontSize: 13)),
    ),
    Expanded(
      child: Text(value,
          style: GoogleFonts.lato(
              fontSize: 14,
              color: AppTokens.brandDark,
              fontWeight: FontWeight.w500)),
    ),
  ]);
}

// ── Info row (for detail rows) ────────────────────────────────────────────────
Widget _infoRow(String label, String? value) {
  if (value == null || value.isEmpty) return const SizedBox.shrink();
  return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    SizedBox(
      width: 75,
      child: Text(label,
          style: GoogleFonts.lato(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600)),
    ),
    const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text(":", style: TextStyle(color: Colors.grey, fontSize: 13)),
    ),
    Expanded(
      child: Text(value,
          style: GoogleFonts.lato(
              fontSize: 14,
              color: AppTokens.brandDark,
              fontWeight: FontWeight.w500)),
    ),
  ]);
}

// ── Success Dialog ────────────────────────────────────────────────────────────
class _SuccessDialog extends StatelessWidget {
  final VoidCallback onOk;
  const _SuccessDialog({required this.onOk});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              color: Colors.green.shade50, shape: BoxShape.circle),
          child: Icon(Icons.check_circle_rounded,
              color: Colors.green.shade600, size: 40),
        ),
        const SizedBox(height: 16),
        Text("Saved Successfully!",
            style: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppTokens.brandDark)),
        const SizedBox(height: 8),
        Text("The RTI record has been verified.",
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
                fontSize: 14, color: Colors.grey.shade600)),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: onOk,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTokens.brandGradientStart,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text("Done",
                style: GoogleFonts.lato(
                    color: colour.kWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
        ),
      ]),
    );
  }
}