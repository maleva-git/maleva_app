import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import '../../../../../../core/theme/tokens.dart';
import '../bloc/rtiview_bloc.dart';
import '../bloc/rtiview_event.dart';
import '../bloc/rtiview_state.dart';

// ── Entry Point ───────────────────────────────────────────────────────────────
class RTIDetailsPage extends StatelessWidget {
  const RTIDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RTIDetailsBloc(context),
      child: const _RTIDetailsBody(),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────
class _RTIDetailsBody extends StatelessWidget {
  const _RTIDetailsBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RTIDetailsBloc, RTIDetailsState>(
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
                  (d) => context.read<RTIDetailsBloc>().add(SelectRTIDetailsFromDateEvent(d)),
            ),
            onToTap: () => _pickDate(
              context, toDate,
                  (d) => context.read<RTIDetailsBloc>().add(SelectRTIDetailsToDateEvent(d)),
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
                    Icon(Icons.folder_open_rounded,
                        size: 13, color: AppTokens.brandGradientStart),
                    const SizedBox(width: 4),
                    Text("${s!.masters.length} records",
                        style: GoogleFonts.lato(
                            color: AppTokens.brandGradientStart,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
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
              padding:
              const EdgeInsets.fromLTRB(14, 4, 14, 20),
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
    if (s is RTIDetailsError)  return s.fromDate;
    return DateTime(DateTime.now().year, 1, 1);
  }

  DateTime _getTo(RTIDetailsState s) {
    if (s is RTIDetailsLoaded) return s.toDate;
    if (s is RTIDetailsError)  return s.toDate;
    return DateTime(DateTime.now().year, 12, 31);
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
      decoration: BoxDecoration(
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
              color: AppTokens.brandGradientStart.withOpacity(0.5), size: 18),

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
                AppTokens.brandGradientStart.withOpacity(0.4),
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
                    style: GoogleFonts.lato(
                        color: colour.kWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
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
        color: AppTokens.brandLight.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTokens.brandLight, width: 1.5),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: AppTokens.brandGradientStart.withOpacity(0.12),
              borderRadius: BorderRadius.circular(7)),
          child: Icon(Icons.calendar_today_rounded,
              color: AppTokens.brandGradientStart, size: 13),
        ),
        const SizedBox(width: 7),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: GoogleFonts.lato(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 1),
          Text(value,
              style: GoogleFonts.lato(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTokens.brandDark)),
        ]),
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
        SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
              color: AppTokens.brandGradientStart, strokeWidth: 3),
        ),
        const SizedBox(height: 16),
        Text("Fetching RTI records…",
            style: GoogleFonts.lato(
                color: Colors.grey.shade500, fontSize: 13)),
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
              style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTokens.brandDark)),
          const SizedBox(height: 6),
          Text(message,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text("Try Again",
                style:
                GoogleFonts.lato(fontWeight: FontWeight.bold)),
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
          decoration: BoxDecoration(
              color: AppTokens.brandLight, shape: BoxShape.circle),
          child: Icon(Icons.receipt_long_outlined,
              size: 44,
              color: AppTokens.brandGradientStart.withOpacity(0.4)),
        ),
        const SizedBox(height: 16),
        Text("No Records Found",
            style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTokens.brandDark)),
        const SizedBox(height: 4),
        Text("Try changing the date range and search again",
            style: GoogleFonts.lato(
                fontSize: 13, color: Colors.grey.shade400)),
      ]),
    );
  }
}

// ── Master Expansion Card ─────────────────────────────────────────────────────
class _RTIDetailsCard extends StatelessWidget {
  final RTIMasterViewModel master;
  final List<RTIDetailsViewModel> details;

  const _RTIDetailsCard({
    required this.master,
    required this.details,
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
          data: Theme.of(context)
              .copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,

            // ── Header ───────────────────────────────────────
            title: _CardHeader(master: master),

            // ── Expanded — Details Table ──────────────────────
            children: [
              // Gradient divider line
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

              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 14),
                child: _DetailsTable(details: details),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Card Header ───────────────────────────────────────────────────────────────
class _CardHeader extends StatelessWidget {
  final RTIMasterViewModel master;
  const _CardHeader({required this.master});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

        // Driver avatar circle
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              color: colour.kWhite.withOpacity(0.15),
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
                Text(master.DriverName ?? '-',
                    style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: colour.kWhite),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Row(children: [
                  Icon(Icons.tag_rounded,
                      size: 11, color: colour.kWhite.withOpacity(0.7)),
                  const SizedBox(width: 3),
                  Text(master.RTINoDisplay,
                      style: GoogleFonts.lato(
                          fontSize: 12,
                          color: colour.kWhite.withOpacity(0.85))),
                ]),
              ]),
        ),

        // PDF button
        GestureDetector(
          onTap: () => context.read<RTIDetailsBloc>().add(
            RTIViewEvent(
              id: master.Id,
              rtiNo: master.RTINoDisplay ?? "",
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colour.kWhite.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: colour.kWhite.withOpacity(0.25), width: 1),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.picture_as_pdf_outlined,
                  color: Colors.red.shade300, size: 16),
              const SizedBox(width: 4),
              Text("PDF",
                  style: GoogleFonts.lato(
                      color: colour.kWhite,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ]),
          ),
        ),

        const SizedBox(width: 8),

        // Date badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: colour.kWhite.withOpacity(0.18),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: colour.kWhite.withOpacity(0.25), width: 1),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.calendar_today_rounded,
                size: 10, color: colour.kWhite.withOpacity(0.75)),
            const SizedBox(width: 4),
            Text(master.RTIDate.toString(),
                style: GoogleFonts.lato(
                    color: colour.kWhite,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ]),
        ),
      ]),
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
        border: Border.all(
            color: AppTokens.brandLight, width: 1.3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(AppTokens.brandLight),
            headingRowHeight: 38,
            dataRowMinHeight: 42,
            dataRowMaxHeight: 48,
            horizontalMargin: 14,
            columnSpacing: 24,
            headingTextStyle: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
                color: AppTokens.brandGradientStartDark,
                fontSize: 12),
            dataTextStyle: GoogleFonts.lato(
                fontSize: 13, color: AppTokens.brandDark),
            border: TableBorder(
              horizontalInside: BorderSide(
                  color: AppTokens.brandLight, width: 1),
            ),
            columns: [
              DataColumn(
                  label: _colLabel(Icons.work_outline_rounded, "Job No")),
              DataColumn(
                  label: _colLabel(Icons.calendar_month_outlined, "Job Date")),
              DataColumn(
                  label: _colLabel(Icons.person_outline_rounded, "Customer")),
              DataColumn(
                label: _colLabel(Icons.attach_money_rounded, "Salary"),
                numeric: true,
              ),
            ],
            rows: details.asMap().entries.map((entry) {
              final idx = entry.key;
              final d   = entry.value;
              return DataRow(
                color: MaterialStateProperty.resolveWith<Color?>((states) {
                  return idx.isOdd
                      ? AppTokens.brandLight.withOpacity(0.35)
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

  Widget _colLabel(IconData icon, String label) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: AppTokens.brandGradientStart),
      const SizedBox(width: 5),
      Text(label),
    ]);
  }
}