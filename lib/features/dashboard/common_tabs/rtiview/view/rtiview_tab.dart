import 'package:maleva/core/theme/app_typography.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/tokens.dart';
import '../bloc/rtiview_bloc.dart';
import '../bloc/rtiview_event.dart';
import '../bloc/rtiview_state.dart';
import 'package:maleva/core/models/shared/r_t_i_master_view_model.dart';
import 'package:maleva/core/models/shared/r_t_i_details_view_model.dart';

// ── Entry Point ───────────────────────────────────────────────────────────────
class RTIDetailsPage extends StatelessWidget {
  const RTIDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RTIDetailsBloc>(),
      child: const _RTIDetailsBody(),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────
class _RTIDetailsBody extends StatelessWidget {
  const _RTIDetailsBody();

  @override
  Widget build(BuildContext context) {

    return BlocConsumer<RTIDetailsBloc, RTIDetailsState>(


      listenWhen: (prev, curr) =>
      curr is RTIPdfLaunchSuccess || curr is RTIActionError,

      listener: (context, state) async  {
        if (state is RTIPdfLaunchSuccess) {
          debugPrint('Launch PDF: ${state.url}');
          await _openPdf(context, state.url);
        } else if (state is RTIActionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message,
                  style: GoogleFonts.lato(color: colour.kWhite)),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      },

      buildWhen: (prev, curr) =>
      curr is RTIDetailsLoaded || curr is RTIDetailsError,

      builder: (context, state) {
        final s         = state is RTIDetailsLoaded ? state : null;
        final isLoading = s?.isLoading ?? false;
        final fromDate  = _getFrom(state);
        final toDate    = _getTo(state);

        return Column(children: [

          // ── Page Header ─────────────────────────────────────────
          _PageHeader(
            fromDate:  fromDate,
            toDate:    toDate,
            isLoading: isLoading,
            onFromTap: () => _pickDate(
              context, fromDate,
                  (d) => context.read<RTIDetailsBloc>().add(
                  SelectRTIDetailsFromDateEvent(d)),
            ),
            onToTap: () => _pickDate(
              context, toDate,
                  (d) => context.read<RTIDetailsBloc>().add(
                  SelectRTIDetailsToDateEvent(d)),
            ),
            onSearch: () =>
                context.read<RTIDetailsBloc>().add(const SearchRTIDetailsEvent()),
          ),

          // ── Record count badge ──────────────────────────────────
          if (!isLoading && (s?.masters.isNotEmpty ?? false))
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTokens.brandLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.folder_open_rounded,
                        size: 13, color: AppTokens.brandGradientStart),
                    const SizedBox(width: 4),
                    Text("${s!.masters.length} records",
                        style: AppTypography.bodyMedium(color: AppTokens.brandGradientStart, fontWeight: FontWeight.bold)),
                  ]),
                ),
              ]),
            ),

          const SizedBox(height: 8),

          // ── List ────────────────────────────────────────────────
          Expanded(
            child: isLoading
                ? _LoadingView()
                : state is RTIDetailsError
                ? _ErrorView(
              message: state.message,
              onRetry: () => context
                  .read<RTIDetailsBloc>()
                  .add(const LoadRTIDetailsEvent()),
            )
                : (s == null || s.masters.isEmpty)
                ? _EmptyState()
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 20),
              itemCount: s.masters.length,
              itemBuilder: (context, index) {
                final master  = s.masters[index];
                final details = s.detailsFor(master.Id);
                return _RTIDetailsCard(
                  master:  master,
                  details: details,
                );
              },
            ),
          ),
        ]);
      },
    );
  }

  Future<void> _pickDate(
      BuildContext context,
      DateTime initial,
      ValueChanged<DateTime> onPicked,
      ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(
                primary: AppTokens.brandGradientStart)),
        child: child!,
      ),
    );
    if (picked != null) onPicked(picked);
  }

  DateTime _getFrom(RTIDetailsState s) {
    if (s is RTIDetailsLoaded) return s.fromDate;
    if (s is RTIDetailsError)  return s.fromDate ?? DateTime(DateTime.now().year, 1, 1);
    return DateTime(DateTime.now().year, 1, 1);
  }

  DateTime _getTo(RTIDetailsState s) {
    if (s is RTIDetailsLoaded) return s.toDate;
    if (s is RTIDetailsError)  return s.toDate ?? DateTime(DateTime.now().year, 12, 31);
    return DateTime(DateTime.now().year, 12, 31);
  }

  // ── Download PDF to temp file then open with device viewer ──────────────────
  Future<void> _openPdf(BuildContext context, String url) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const CircularProgressIndicator(color: AppTokens.brandGradientStart),
            const SizedBox(height: 16),
            Text("Loading PDF…",
                style: AppTypography.bodyLarge(color: AppTokens.brandDark)),
          ]),
        ),
      ),
    );

    try {
      // Download PDF bytes
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        if (context.mounted) Navigator.of(context).pop();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Failed to download PDF (${response.statusCode})",
                style: GoogleFonts.lato(color: Colors.white)),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ));
        }
        return;
      }

      // Save to temp directory
      final dir  = await getTemporaryDirectory();
      final file = File('${dir.path}/rti_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(response.bodyBytes);

      // Dismiss loading dialog
      if (context.mounted) Navigator.of(context).pop();

      // Open with device PDF viewer
      final result = await OpenFile.open(file.path);

      if (result.type != ResultType.done && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Could not open PDF: ${result.message}",
              style: GoogleFonts.lato(color: Colors.white)),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ));
      }
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Error: ${e.toString()}",
              style: GoogleFonts.lato(color: Colors.white)),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ));
      }
    }
  }
}

// ── Page Header with Date Filter ──────────────────────────────────────────────
class _PageHeader extends StatelessWidget {
  final DateTime fromDate;
  final DateTime toDate;
  final bool isLoading;
  final VoidCallback onFromTap;
  final VoidCallback onToTap;
  final VoidCallback onSearch;

  const _PageHeader({
    required this.fromDate,
    required this.toDate,
    required this.isLoading,
    required this.onFromTap,
    required this.onToTap,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: const BoxDecoration(
        color: colour.kWhite,
        border: Border(
            bottom: BorderSide(color: AppTokens.brandLight, width: 1.5)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Title row
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTokens.brandGradientStart,
                  AppTokens.brandGradientStart.withValues(alpha: 0.75),
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
                style: AppTypography.heading1(color: AppTokens.brandGradientStartDark, fontWeight: FontWeight.bold)),
            Text("Return to Inventory",
                style: AppTypography.bodySmall(color: Colors.grey.shade500)),
          ]),
        ]),

        const SizedBox(height: 14),

        // Date filter row
        Row(children: [

          // From date picker
          Expanded(
            child: GestureDetector(
              onTap: onFromTap,
              child: _DatePickerCard(
                label: "From Date",
                value: DateFormat('dd/MM/yyyy').format(fromDate),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Arrow
          Icon(Icons.arrow_forward_rounded,
              color: AppTokens.brandGradientStart.withValues(alpha: 0.5), size: 18),

          const SizedBox(width: 10),

          // To date picker
          Expanded(
            child: GestureDetector(
              onTap: onToTap,
              child: _DatePickerCard(
                label: "To Date",
                value: DateFormat('dd/MM/yyyy').format(toDate),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Search button
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading ? null : onSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTokens.brandGradientStart,
                disabledBackgroundColor:
                AppTokens.brandGradientStart.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: isLoading
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    color: colour.kWhite, strokeWidth: 2),
              )
                  : Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.search_rounded,
                    color: colour.kWhite, size: 16),
                const SizedBox(width: 5),
                Text("Search",
                    style: AppTypography.heading3(color: colour.kWhite, fontWeight: FontWeight.bold)),
              ]),
            ),
          ),
        ]),
      ]),
    );
  }
}

// ── Date Picker Card ──────────────────────────────────────────────────────────
class _DatePickerCard extends StatelessWidget {
  final String label;
  final String value;
  const _DatePickerCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: AppTokens.brandLight.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTokens.brandLight, width: 1.5),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: AppTokens.brandGradientStart.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(7)),
          child: const Icon(Icons.calendar_today_rounded,
              color: AppTokens.brandGradientStart, size: 13),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTypography.badgeText(color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                const SizedBox(height: 1),
                Text(value,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.heading3(color: AppTokens.brandDark, fontWeight: FontWeight.bold)),
              ]),
        ),
      ]),
    );
  }
}

// ── Loading View ──────────────────────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
              color: AppTokens.brandGradientStart, strokeWidth: 3),
        ),
        const SizedBox(height: 16),
        Text("Fetching RTI records…",
            style: AppTypography.bodyLarge(color: Colors.grey.shade500)),
      ]),
    );
  }
}

// ── Error View ────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.red.shade50, shape: BoxShape.circle),
            child:
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 40),
          ),
          const SizedBox(height: 16),
          Text("Something went wrong",
              style: AppTypography.heading1(color: AppTokens.brandDark, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyLarge(color: Colors.grey)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text("Try Again",
                style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTokens.brandGradientStart,
              foregroundColor: colour.kWhite,
              padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ]),
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
          decoration: const BoxDecoration(
              color: AppTokens.brandLight, shape: BoxShape.circle),
          child: Icon(Icons.receipt_long_outlined,
              size: 44,
              color: AppTokens.brandGradientStart.withValues(alpha: 0.4)),
        ),
        const SizedBox(height: 16),
        Text("No Records Found",
            style: AppTypography.heading1(color: AppTokens.brandDark, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text("Try changing the date range and search again",
            style: AppTypography.bodyLarge(color: Colors.grey.shade400)),
      ]),
    );
  }
}

// ── Master Expansion Card ─────────────────────────────────────────────────────
// Uses StatefulWidget + AnimatedCrossFade instead of ExpansionTile so we have
// full tap control — no ExpansionTile interference on the PDF button.
class _RTIDetailsCard extends StatefulWidget {
  final RTIMasterViewModel master;
  final List<RTIDetailsViewModel> details;

  const _RTIDetailsCard({
    required this.master,
    required this.details,
  });

  @override
  State<_RTIDetailsCard> createState() => _RTIDetailsCardState();
}

class _RTIDetailsCardState extends State<_RTIDetailsCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: colour.kWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: AppTokens.brandLight.withValues(alpha: 0.8), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: AppTokens.brandGradientStart.withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, 4)),
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 1)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(children: [

          // ── Header row ──────────────────────────────────────────────────
          Container(
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

              // Left: avatar + name + RTI no — tap to expand/collapse
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(children: [

                      // Avatar circle
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: colour.kWhite.withValues(alpha: 0.15),
                            shape: BoxShape.circle),
                        child: const Icon(Icons.person_rounded,
                            color: colour.kWhite, size: 20),
                      ),

                      const SizedBox(width: 10),

                      // Driver name + RTI No
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.master.DriverName ?? '-',
                                  style: AppTypography.heading3(color: colour.kWhite, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 3),
                              Row(children: [
                                Icon(Icons.tag_rounded,
                                    size: 11,
                                    color: colour.kWhite.withValues(alpha: 0.7)),
                                const SizedBox(width: 3),
                                Flexible(
                                  child: Text(
                                    widget.master.RTINoDisplay,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: AppTypography.bodyMedium(color: colour.kWhite.withValues(alpha: 0.85)),
                                  ),
                                ),
                              ]),
                            ]),
                      ),
                    ]),
                  ),
                ),
              ),

              // Right: PDF button + date badge + chevron
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(mainAxisSize: MainAxisSize.min, children: [

                  // ✅ PDF button — own GestureDetector, fully independent
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => context.read<RTIDetailsBloc>().add(
                      RTIViewEvent(
                        id: widget.master.Id,
                        rtiNo: widget.master.RTINoDisplay ?? "",
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: colour.kWhite.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: colour.kWhite.withValues(alpha: 0.25), width: 1),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.picture_as_pdf_outlined,
                            color: Colors.red.shade300, size: 16),
                        const SizedBox(width: 4),
                        Text("PDF",
                            style: AppTypography.bodySmall(color: colour.kWhite, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Date badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: colour.kWhite.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: colour.kWhite.withValues(alpha: 0.25), width: 1),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 10, color: colour.kWhite.withValues(alpha: 0.75)),
                      const SizedBox(width: 4),
                      Text(widget.master.RTIDate.toString(),
                          style: AppTypography.bodySmall(color: colour.kWhite, fontWeight: FontWeight.w600)),
                    ]),
                  ),

                  const SizedBox(width: 8),

                  // Chevron — tapping also toggles expand
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: AnimatedRotation(
                      turns: _expanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(Icons.keyboard_arrow_down_rounded,
                          color: colour.kWhite.withValues(alpha: 0.9), size: 22),
                    ),
                  ),
                ]),
              ),
            ]),
          ),

          // ── Expandable body ─────────────────────────────────────────────
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Column(children: [

              // Gradient divider
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    AppTokens.brandGradientStart.withValues(alpha: 0.0),
                    AppTokens.brandGradientStart.withValues(alpha: 0.3),
                    AppTokens.brandGradientStart.withValues(alpha: 0.0),
                  ]),
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
                      style: AppTypography.bodyMedium(color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                ]),
              ),

              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 14),
                child: _DetailsTable(details: widget.details),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ── Details Table ─────────────────────────────────────────────────────────────
class _DetailsTable extends StatelessWidget {
  final List<RTIDetailsViewModel> details;
  const _DetailsTable({required this.details});

  @override
  Widget build(BuildContext context) {
    if (details.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text("No Details Found",
              style: GoogleFonts.lato(color: Colors.grey)),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTokens.brandLight, width: 1.3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppTokens.brandLight),
            headingRowHeight: 38,
            dataRowMinHeight: 42,
            dataRowMaxHeight: 48,
            horizontalMargin: 12,
            columnSpacing: 16,
            headingTextStyle: AppTypography.bodyMedium(color: AppTokens.brandGradientStartDark, fontWeight: FontWeight.bold),
            dataTextStyle: AppTypography.bodyLarge(color: AppTokens.brandDark),
            border: const TableBorder(
              horizontalInside: BorderSide(
                  color: AppTokens.brandLight, width: 1),
            ),
            columns: const [
              DataColumn(label: Text("Job No")),
              DataColumn(label: Text("Job Date")),
              DataColumn(label: Text("Customer")),
              DataColumn(label: Text("Salary"), numeric: true),
            ],
            rows: details.asMap().entries.map((entry) {
              final idx = entry.key;
              final d   = entry.value;
              return DataRow(
                color: WidgetStateProperty.resolveWith<Color?>((states) {
                  return idx.isOdd
                      ? AppTokens.brandLight.withValues(alpha: 0.35)
                      : null;
                }),
                cells: [
                  DataCell(Text(d.JobNo,
                      style: GoogleFonts.lato(
                          fontWeight: FontWeight.w600,
                          color: AppTokens.brandGradientStart))),
                  DataCell(Text(d.JobDate)),
                  DataCell(Text(d.CustomerName)),
                  DataCell(Text(d.Salary.toStringAsFixed(2),
                      style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700))),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}