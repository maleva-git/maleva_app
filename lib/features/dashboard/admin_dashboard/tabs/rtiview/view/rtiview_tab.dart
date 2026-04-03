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

        return Padding(
          padding: const EdgeInsets.all(8),
          child: Column(children: [

            // ════════════════════════════════════════════════════
            // DATE FILTER ROW
            // ════════════════════════════════════════════════════
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppTokens.brandLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppTokens.brandMid.withOpacity(0.3)),
              ),
              child: Row(children: [

                // From Date
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickDate(
                      context,
                      fromDate,
                          (d) => context
                          .read<RTIDetailsBloc>()
                          .add(SelectRTIDetailsFromDateEvent(d)),
                    ),
                    child: _DateTile(
                      label: "From Date",
                      value: DateFormat('dd/MM/yyyy').format(fromDate),
                    ),
                  ),
                ),

                // Divider
                Container(
                    width: 1, height: 30,
                    color: AppTokens.brandMid.withOpacity(0.3),
                    margin:
                    const EdgeInsets.symmetric(horizontal: 8)),

                // To Date
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickDate(
                      context,
                      toDate,
                          (d) => context
                          .read<RTIDetailsBloc>()
                          .add(SelectRTIDetailsToDateEvent(d)),
                    ),
                    child: _DateTile(
                      label: "To Date",
                      value: DateFormat('dd/MM/yyyy').format(toDate),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Search Button
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () => context
                      .read<RTIDetailsBloc>()
                      .add(const SearchRTIDetailsEvent()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTokens.brandGradientStart,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: Text("Search",
                      style: GoogleFonts.lato(
                          color: colour.kWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                ),
              ]),
            ),

            const SizedBox(height: 8),

            // Record count
            if (!isLoading && (s?.masters.isNotEmpty ?? false))
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: AppTokens.brandLight,
                        borderRadius: BorderRadius.circular(8)),
                    child: Text("${s!.masters.length} records",
                        style: GoogleFonts.lato(
                            color: AppTokens.brandGradientStart,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ),
                ]),
              ),

            // ════════════════════════════════════════════════════
            // LIST
            // ════════════════════════════════════════════════════
            Expanded(
              child: isLoading
                  ? const Center(
                  child: CircularProgressIndicator(
                      color: AppTokens.brandGradientStart))
                  : state is RTIDetailsError
                  ? _errorView(context, state.message)
                  : (s == null || s.masters.isEmpty)
                  ? Center(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 60,
                            color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text("No Records Found",
                            style: GoogleFonts.lato(
                                fontSize: 16,
                                color: Colors.grey)),
                      ]))
                  : ListView.builder(
                itemCount: s.masters.length,
                itemBuilder: (context, index) {
                  final master = s.masters[index];
                  final details =
                  s.detailsFor(master.Id);
                  return _RTIDetailsCard(
                    master:  master,
                    details: details,
                  );
                },
              ),
            ),
          ]),
        );
      },
    );
  }

  // ── Date pick helper ──────────────────────────────────────────────────────
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
            colorScheme:
            const ColorScheme.light(primary: AppTokens.brandGradientStart)),
        child: child!,
      ),
    );
    if (picked != null) onPicked(picked);
  }

  Widget _errorView(BuildContext context, String msg) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 48),
        const SizedBox(height: 12),
        Text(msg,
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(color: Colors.red)),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => context
              .read<RTIDetailsBloc>()
              .add(const LoadRTIDetailsEvent()),
          icon: const Icon(Icons.refresh),
          label: const Text("Retry"),
          style: ElevatedButton.styleFrom(
              backgroundColor: AppTokens.brandGradientStart),
        ),
      ]),
    );
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
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colour.kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTokens.brandLight, width: 1.5),
        boxShadow: [
          BoxShadow(
              color: AppTokens.brandGradientStart.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Theme(
          data: Theme.of(context)
              .copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,

            // ── Header ─────────────────────────────────────────
            title: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              decoration: const BoxDecoration(color: AppTokens.brandGradientStart),
              child: Row(children: [

                // Driver icon
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: colour.kWhite.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_rounded,
                      color: colour.kWhite, size: 20),
                ),

                const SizedBox(width: 10),

                // Driver + RTI No
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
                        const SizedBox(height: 2),
                        Text(master.RTINoDisplay,
                            style: GoogleFonts.lato(
                                fontSize: 12,
                                color: colour.kWhite.withOpacity(0.8))),
                      ]),
                ),

                // Date badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colour.kWhite.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    master.RTIDate.toString(),
                    style: GoogleFonts.lato(
                        color: colour.kWhite,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ]),
            ),

            // ── Expanded — DataTable ────────────────────────────
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: _detailsGrid(details),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── DataTable ─────────────────────────────────────────────────────────────
  Widget _detailsGrid(List<RTIDetailsViewModel> details) {
    if (details.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text("No Details Found",
              style: GoogleFonts.lato(color: Colors.grey)),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(AppTokens.brandLight),
        headingTextStyle: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            color: AppTokens.brandDark,
            fontSize: 13),
        dataTextStyle:
        GoogleFonts.lato(fontSize: 13, color: AppTokens.brandDark),
        border: TableBorder.all(
          color: AppTokens.brandMid.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        columns: const [
          DataColumn(label: Text("Job No")),
          DataColumn(label: Text("Job Date")),
          DataColumn(label: Text("Customer")),
          DataColumn(label: Text("Salary")),
        ],
        rows: details.map((d) {
          return DataRow(
            cells: [
              DataCell(Text(d.JobNo)),
              DataCell(Text(d.JobDate)),
              DataCell(Text(d.CustomerName)),
              DataCell(Text(d.Salary.toStringAsFixed(2))),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ── Date Tile ─────────────────────────────────────────────────────────────────
class _DateTile extends StatelessWidget {
  final String label;
  final String value;
  const _DateTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Icon(Icons.calendar_today_rounded,
          color: AppTokens.brandGradientStart, size: 16),
      const SizedBox(width: 6),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: GoogleFonts.lato(
                fontSize: 10,
                color: Colors.grey[500],
                fontWeight: FontWeight.w600)),
        Text(value,
            style: GoogleFonts.lato(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTokens.brandDark)),
      ]),
    ]);
  }
}