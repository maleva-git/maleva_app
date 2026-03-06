import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../bloc/forwardingreport_bloc.dart';
import '../bloc/forwardingreport_event.dart';
import '../bloc/forwardingreport_state.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;

// ── Brand Color ──────────────────────────────────────────────────────────────

class ForwardingReportPage extends StatelessWidget {
  const ForwardingReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ForwardingReportBloc(context)
        ..add(LoadFWDataEvent(
          fromDate: DateFormat("yyyy-MM-dd").format(DateTime.now()),
          toDate: DateFormat("yyyy-MM-dd").format(DateTime.now()),
        )),
      child: const ForwardingReportView(),
    );
  }
}

class ForwardingReportView extends StatelessWidget {
  const ForwardingReportView({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return BlocConsumer<ForwardingReportBloc, ForwardingReportState>(
      listener: (context, state) {
        if (state.status == FWStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.status == FWStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(color: colour.kPrimary),
          );
        }

        return Container(
          color: const Color(0xFFF0F4FF), // light blue-tinted background
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0, left: 12.0, right: 12.0),
            child: ListView(
              children: [
                const SizedBox(height: 7),

                // ── Title ─────────────────────────────────────────────────
                _TitleBadge(),

                const SizedBox(height: 16),

                // ── Summary Card ──────────────────────────────────────────
                _SummaryCard(state: state),

                const SizedBox(height: 14),

                // ── Date Picker Row ───────────────────────────────────────
                _DatePickerRow(),

                const SizedBox(height: 14),

                // ── K1/K2/K3/K8 Card ─────────────────────────────────────
                _KTypeCard(state: state),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Title Badge ───────────────────────────────────────────────────────────────
class _TitleBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [colour.kPrimary, colour.kPrimaryLight],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: colour.kPrimary.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          'FORWARDING REPORT',
          style: GoogleFonts.lato(
            textStyle: const TextStyle(
              color: colour.kWhite,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Summary Card ──────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final dynamic state;
  const _SummaryCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final rows = [
      {'label': 'Today', 'countKey': 'TodayCount', 'withKey': 'TodayWithRelease', 'withoutKey': 'TodayRelease'},
      {'label': 'Yesterday', 'countKey': 'YesterdayCount', 'withKey': 'YesterdayWithRelease', 'withoutKey': 'YesterdayRelease'},
      {'label': 'Weekly', 'countKey': 'WeekCount', 'withKey': 'WeekWithRelease', 'withoutKey': 'WeekRelease'},
      {'label': 'Monthly', 'countKey': 'MonthCount', 'withKey': 'MonthWithRelease', 'withoutKey': 'MonthRelease'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: colour.kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colour.kPrimary.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [colour.kPrimary, colour.kPrimaryLight],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(flex: 3, child: _headerText('')),
                Expanded(flex: 2, child: _headerText('Total')),
                Expanded(flex: 2, child: _headerText('With')),
                Expanded(flex: 2, child: _headerText('Without')),
              ],
            ),
          ),
          // Rows
          ...rows.asMap().entries.map((entry) {
            final i = entry.key;
            final row = entry.value;
            final isEven = i % 2 == 0;
            final data = state.saleFWReport;

            return Container(
              color: isEven ? colour.kAccent.withOpacity(0.4) : colour.kWhite,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      row['label']!,
                      style: GoogleFonts.lato(
                        textStyle: TextStyle(
                          color: colour.kPrimaryDark,
                          fontWeight: FontWeight.bold,
                          fontSize: objfun.FontLow - 1,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: _valueChip(
                      data.isEmpty ? '0' : data[0][row['countKey']]?.toStringAsFixed(0) ?? '0',
                      colour.kPrimary,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: _valueChip(
                      data.isEmpty ? '0' : data[0][row['withKey']]?.toStringAsFixed(0) ?? '0',
                      Colors.green.shade600,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: _valueChip(
                      data.isEmpty ? '0' : data[0][row['withoutKey']]?.toStringAsFixed(0) ?? '0',
                      Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _headerText(String text) => Text(
    text,
    textAlign: TextAlign.center,
    style: GoogleFonts.lato(
      textStyle: const TextStyle(
        color: colour.kWhite,
        fontWeight: FontWeight.bold,
        fontSize: 13,
        letterSpacing: 0.5,
      ),
    ),
  );

  Widget _valueChip(String value, Color color) => Center(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        value,
        style: GoogleFonts.lato(
          textStyle: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    ),
  );
}

// ── Date Picker Row ───────────────────────────────────────────────────────────
class _DatePickerRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForwardingReportBloc, ForwardingReportState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colour.kWhite,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: colour.kPrimary.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // From Date
              Expanded(
                child: _DateTile(
                  label: 'From',
                  date: DateFormat("dd MMM yyyy").format(DateTime.parse(state.dtpFromDate)),
                  onTap: () async {
                    final value = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2050),
                      builder: (context, child) => Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme: const ColorScheme.light(primary: colour.kPrimary),
                        ),
                        child: child!,
                      ),
                    );
                    if (value != null) {
                      context.read<ForwardingReportBloc>().add(
                        ChangFromDateEvent(fromDate: DateFormat("yyyy-MM-dd").format(value)),
                      );
                    }
                  },
                ),
              ),
              Container(
                height: 40,
                width: 1,
                color: colour.kPrimary.withOpacity(0.2),
                margin: const EdgeInsets.symmetric(horizontal: 10),
              ),
              // To Date
              Expanded(
                child: _DateTile(
                  label: 'To',
                  date: DateFormat("dd MMM yyyy").format(DateTime.parse(state.dtpToDate)),
                  onTap: () async {
                    final value = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2050),
                      builder: (context, child) => Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme: const ColorScheme.light(primary: colour.kPrimary),
                        ),
                        child: child!,
                      ),
                    );
                    if (value != null) {
                      context.read<ForwardingReportBloc>().add(
                        ChangeToDateEvent(toDate: DateFormat("yyyy-MM-dd").format(value)),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final String date;
  final VoidCallback onTap;

  const _DateTile({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: colour.kAccent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.calendar_today_rounded, color: colour.kPrimary, size: 18),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    color: colour.kPrimary.withOpacity(0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                date,
                style: GoogleFonts.lato(
                  textStyle: const TextStyle(
                    color: colour.kPrimaryDark,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── K1/K2/K3/K8 Card ─────────────────────────────────────────────────────────
class _KTypeCard extends StatelessWidget {
  final dynamic state;
  const _KTypeCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final ktypes = [
      {'label': 'K1', 'countKey': 'K1Count', 'withKey': 'K1WithRelease', 'withoutKey': 'K1Release'},
      {'label': 'K2', 'countKey': 'K2Count', 'withKey': 'K2WithRelease', 'withoutKey': 'K2Release'},
      {'label': 'K3', 'countKey': 'K3Count', 'withKey': 'K3WithRelease', 'withoutKey': 'K3Release'},
      {'label': 'K8', 'countKey': 'K8Count', 'withKey': 'K8WithRelease', 'withoutKey': 'K8Release'},
    ];

    final data = state.saleFWReport2;

    return Container(
      decoration: BoxDecoration(
        color: colour.kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colour.kPrimary.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [colour.kPrimaryDark, colour.kPrimary],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(flex: 2, child: _headerText('Type')),
                Expanded(flex: 2, child: _headerText('Total')),
                Expanded(flex: 2, child: _headerText('With')),
                Expanded(flex: 2, child: _headerText('Without')),
              ],
            ),
          ),
          // K type rows
          ...ktypes.asMap().entries.map((entry) {
            final i = entry.key;
            final k = entry.value;
            final isEven = i % 2 == 0;

            return Container(
              color: isEven ? colour.kAccent.withOpacity(0.4) : colour.kWhite,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // K label badge
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colour.kPrimary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        k['label']!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                            color: colour.kWhite,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Text(
                        data.isEmpty ? '0' : data[0][k['countKey']]?.toString() ?? '0',
                        style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                            color: colour.kPrimaryDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Text(
                        data.isEmpty ? '0' : data[0][k['withKey']]?.toString() ?? '0',
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Text(
                        data.isEmpty ? '0' : data[0][k['withoutKey']]?.toString() ?? '0',
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _headerText(String text) => Text(
    text,
    textAlign: TextAlign.center,
    style: GoogleFonts.lato(
      textStyle: const TextStyle(
        color: colour.kWhite,
        fontWeight: FontWeight.bold,
        fontSize: 13,
        letterSpacing: 0.5,
      ),
    ),
  );
}