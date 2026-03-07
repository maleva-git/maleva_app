import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/ExpenseReport/bloc/expensereport_bloc.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/ExpenseReport/bloc/expensereport_event.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/ExpenseReport/bloc/expensereport_state.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;



class ExpenseReportPage extends StatelessWidget {
  const ExpenseReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExpenseReportBloc(context)
        ..add(LoadExpReportEvent(
          fromDate: DateFormat("yyyy-MM-dd").format(DateTime.now()),
          toDate:   DateFormat("yyyy-MM-dd").format(DateTime.now()),
        )),
      child: const ExpenseReportView(),
    );
  }
}

// ─── View ──────────────────────────────────────────────────────────────────────
class ExpenseReportView extends StatelessWidget {
  const ExpenseReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExpenseReportBloc, ExpReportState>(
      listener: (context, state) {
        if (state.status == ExpStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage,
                  style: GoogleFonts.poppins(color: colour.kWhite)),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.status == ExpStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(color: colour.kPrimary),
          );
        }

        return Container(
          color: const Color(0xFFF4F6FF),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            children: [
              // ── Header ──────────────────────────────────────────────────────
              _SectionHeader(title: 'Expense Report'),
              const SizedBox(height: 16),

              // ── Summary Card ─────────────────────────────────────────────────
              _SummaryCard(saleExpReport: state.saleExpReport),
              const SizedBox(height: 20),

              // ── Date Picker Row ───────────────────────────────────────────────
              _DatePickerCard(),
              const SizedBox(height: 20),

              // ── Detail List Header ────────────────────────────────────────────
              _ListHeader(),
              const SizedBox(height: 8),

              // ── Detail Items ──────────────────────────────────────────────────
              ...List.generate(state.saleExpReport2.length, (index) {
                final item        = state.saleExpReport2[index];
                final expenseName = item["ExpenseName"] ?? "-";
                final expAmount   = (item["ExpAmount"] ?? 0).toDouble();
                final expCount    = (item["ExpCount"]  ?? 0).toDouble();

                return _ExpenseItemCard(
                  name:   expenseName,
                  count:  expCount.toStringAsFixed(0),
                  amount: expAmount.toStringAsFixed(0),
                  index:  index,
                  onTap:  () => context.read<ExpenseReportBloc>().add(
                    LoadExpReportEvent(
                      fromDate: state.dtpFromDate,
                      toDate:   state.dtpToDate,
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 26,
          decoration: BoxDecoration(
            color: colour.kPrimary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title.toUpperCase(),
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: colour.kPrimaryDark,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

// ─── Summary Card ─────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final List<dynamic> saleExpReport;
  const _SummaryCard({required this.saleExpReport});

  String _val(String key) {
    if (saleExpReport.isEmpty) return '0';
    return (saleExpReport[0][key] ?? 0).toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final rows = [
      {'label': 'Today',     'sales': _val('TodaySales'),     'amount': _val('TodayAmount')},
      {'label': 'Yesterday', 'sales': _val('YesterdaySales'), 'amount': _val('YesterdayAmount')},
      {'label': 'Weekly',    'sales': _val('WeekSales'),      'amount': _val('WeekAmount')},
      {'label': 'Monthly',   'sales': _val('MonthSales'),     'amount': _val('MonthAmount')},
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [colour.kPrimary, colour.kPrimaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colour.kPrimary.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // Card title bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text('Period',
                        style: GoogleFonts.poppins(
                            color: colour.kWhite.withOpacity(0.75),
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Count',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            color: colour.kWhite.withOpacity(0.75),
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Amount',
                        textAlign: TextAlign.end,
                        style: GoogleFonts.poppins(
                            color: colour.kWhite.withOpacity(0.75),
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1),

            // Data rows
            ...rows.map((row) => _SummaryRow(
              label:  row['label']!,
              count:  row['sales']!,
              amount: row['amount']!,
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label, count, amount;
  const _SummaryRow(
      {required this.label, required this.count, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(label,
                style: GoogleFonts.poppins(
                    color: colour.kWhite,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            flex: 2,
            child: Text(count,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    color: colour.kAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ),
          Expanded(
            flex: 2,
            child: Text(amount,
                textAlign: TextAlign.end,
                style: GoogleFonts.poppins(
                    color: colour.kAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ─── Date Picker Card ─────────────────────────────────────────────────────────
class _DatePickerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseReportBloc, ExpReportState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: colour.kWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colour.kAccent, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: colour.kPrimary.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // From Date
              Expanded(
                child: _DateField(
                  label: 'From',
                  date: DateFormat("dd MMM yyyy")
                      .format(DateTime.parse(state.dtpFromDate)),
                  onTap: () async {
                    final value = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2050),
                      builder: (ctx, child) => Theme(
                        data: Theme.of(ctx).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: colour.kPrimary,
                            onPrimary: colour.kWhite,
                            surface: colour.kWhite,
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (value != null) {
                      context.read<ExpenseReportBloc>().add(
                        ChangeFromDateEvent(
                            fromDate: DateFormat("yyyy-MM-dd").format(value)),
                      );
                    }
                  },
                ),
              ),

              // Divider
              Container(
                height: 36,
                width: 1,
                color: colour.kAccent,
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),

              // To Date
              Expanded(
                child: _DateField(
                  label: 'To',
                  date: DateFormat("dd MMM yyyy")
                      .format(DateTime.parse(state.dtpToDate)),
                  onTap: () async {
                    final value = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2050),
                      builder: (ctx, child) => Theme(
                        data: Theme.of(ctx).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: colour.kPrimary,
                            onPrimary: colour.kWhite,
                            surface: colour.kWhite,
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (value != null) {
                      context.read<ExpenseReportBloc>().add(
                        ChangeToDateEvent(
                            toDate: DateFormat("yyyy-MM-dd").format(value)),
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

class _DateField extends StatelessWidget {
  final String label;
  final String date;
  final VoidCallback onTap;
  const _DateField(
      {required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: colour.kAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.calendar_today_rounded,
                  size: 16, color: colour.kPrimary),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: colour.kPrimaryLight,
                        fontWeight: FontWeight.w500)),
                Text(date,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: colour.kPrimaryDark,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── List Header ──────────────────────────────────────────────────────────────
class _ListHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: colour.kAccent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text('Expense',
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colour.kPrimaryDark)),
          ),
          Expanded(
            flex: 2,
            child: Text('Count',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colour.kPrimaryDark)),
          ),
          Expanded(
            flex: 2,
            child: Text('Amount',
                textAlign: TextAlign.end,
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colour.kPrimaryDark)),
          ),
        ],
      ),
    );
  }
}

// ─── Expense Item Card ────────────────────────────────────────────────────────
class _ExpenseItemCard extends StatelessWidget {
  final String name, count, amount;
  final int index;
  final VoidCallback onTap;

  const _ExpenseItemCard({
    required this.name,
    required this.count,
    required this.amount,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: colour.kWhite,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: colour.kAccent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colour.kAccent, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: colour.kPrimary.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Index badge
                Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: colour.kAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: colour.kPrimary),
                  ),
                ),

                Expanded(
                  flex: 3,
                  child: Text(name,
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colour.kPrimaryDark)),
                ),
                Expanded(
                  flex: 2,
                  child: Text(count,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: colour.kPrimaryLight)),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colour.kAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(amount,
                        textAlign: TextAlign.end,
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: colour.kPrimary)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}