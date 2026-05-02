import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// Make sure this path is correct for your project's injection file
import '../../../../../../core/di/injection.dart';
import '../../../../../../core/theme/tokens.dart';

import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;

import 'package:maleva/features/dashboard/admin_dashboard/tabs/expensereport/bloc/expensereport_bloc.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/expensereport/bloc/expensereport_event.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/expensereport/bloc/expensereport_state.dart';

class ExpenseReportPage extends StatelessWidget {
  const ExpenseReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // ✅ Use sl (GetIt) to create the Bloc. It automatically injects the repository.
      create: (_) => sl<ExpenseReportBloc>()
        ..add(const LoadExpenseReportEvent()), // ✅ New Event Name (Handles default dates internally)
      child: const ExpenseReportView(),
    );
  }
}

// ─── View ──────────────────────────────────────────────────────────────────────
class ExpenseReportView extends StatelessWidget {
  const ExpenseReportView({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return BlocConsumer<ExpenseReportBloc, ExpenseReportState>( // ✅ New State Name
      listener: (context, state) {
        if (state.status == ExpenseReportStatus.error) { // ✅ New Enum Name
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
        if (state.status == ExpenseReportStatus.loading) { // ✅ New Enum Name
          return const Center(
            child: CircularProgressIndicator(color: AppTokens.brandGradientStart),
          );
        }

        return Container(
          color: const Color(0xFFF4F6FF),
          child: isTablet
              ? _buildTabletLayout(context, state)
              : _buildMobileLayout(context, state),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════
  // TABLET — Two Column
  // ══════════════════════════════════════════════════════
  Widget _buildTabletLayout(
      BuildContext context, ExpenseReportState state) { // ✅ New State Name
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── LEFT (50%) — Header + Summary + DatePicker
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(title: 'Expense Report', isTablet: true),
                  const SizedBox(height: 20),
                  _SummaryCard(
                      saleExpReport: state.saleExpReport,
                      isTablet: true),
                  const SizedBox(height: 20),
                  _DatePickerCard(isTablet: true),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          const SizedBox(width: 16),

          // ── RIGHT (50%) — Expense List
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ListHeader(isTablet: true),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: state.saleExpReport2.length,
                    itemBuilder: (context, index) {
                      final item        = state.saleExpReport2[index];
                      final expenseName = item["ExpenseName"] ?? "-";
                      final expAmount   =
                      (item["ExpAmount"] ?? 0).toDouble();
                      final expCount    =
                      (item["ExpCount"] ?? 0).toDouble();

                      return _ExpenseItemCard(
                        name:    expenseName,
                        count:   expCount.toStringAsFixed(0),
                        amount:  expAmount.toStringAsFixed(0),
                        index:   index,
                        isTablet: true,
                        onTap: () =>
                            context.read<ExpenseReportBloc>().add(
                              const LoadExpenseReportEvent(isDateSearch: true), // ✅ Refactored Event
                            ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // MOBILE — Single Column
  // ══════════════════════════════════════════════════════
  Widget _buildMobileLayout(
      BuildContext context, ExpenseReportState state) { // ✅ New State Name
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      children: [
        _SectionHeader(title: 'Expense Report', isTablet: false),
        const SizedBox(height: 16),

        _SummaryCard(
            saleExpReport: state.saleExpReport, isTablet: false),
        const SizedBox(height: 20),

        _DatePickerCard(isTablet: false),
        const SizedBox(height: 20),

        _ListHeader(isTablet: false),
        const SizedBox(height: 8),

        ...List.generate(state.saleExpReport2.length, (index) {
          final item        = state.saleExpReport2[index];
          final expenseName = item["ExpenseName"] ?? "-";
          final expAmount   = (item["ExpAmount"] ?? 0).toDouble();
          final expCount    = (item["ExpCount"]  ?? 0).toDouble();

          return _ExpenseItemCard(
            name:    expenseName,
            count:   expCount.toStringAsFixed(0),
            amount:  expAmount.toStringAsFixed(0),
            index:   index,
            isTablet: false,
            onTap: () => context.read<ExpenseReportBloc>().add(
              const LoadExpenseReportEvent(isDateSearch: true), // ✅ Refactored Event
            ),
          );
        }),
      ],
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isTablet;
  const _SectionHeader(
      {required this.title, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 4,
        height: isTablet ? 30 : 26,
        decoration: BoxDecoration(
          color: AppTokens.brandGradientStart,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      const SizedBox(width: 10),
      Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: isTablet ? 20 : 17,
          fontWeight: FontWeight.w700,
          color: AppTokens.brandDark,
          letterSpacing: 1.2,
        ),
      ),
    ]);
  }
}

// ─── Summary Card ─────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final List<dynamic> saleExpReport;
  final bool isTablet;
  const _SummaryCard(
      {required this.saleExpReport, required this.isTablet});

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
          colors: [AppTokens.brandGradientStart, AppTokens.brandDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
        boxShadow: [
          BoxShadow(
            color: AppTokens.brandGradientStart.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
        child: Column(children: [
          // Column headers
          Padding(
            padding: EdgeInsets.fromLTRB(
                isTablet ? 24 : 20,
                isTablet ? 18 : 16,
                isTablet ? 24 : 20,
                8),
            child: Row(children: [
              Expanded(
                flex: 3,
                child: Text('Period',
                    style: GoogleFonts.poppins(
                        color: colour.kWhite.withOpacity(0.75),
                        fontSize: isTablet ? 13 : 12,
                        fontWeight: FontWeight.w600)),
              ),
              Expanded(
                flex: 2,
                child: Text('Count',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        color: colour.kWhite.withOpacity(0.75),
                        fontSize: isTablet ? 13 : 12,
                        fontWeight: FontWeight.w600)),
              ),
              Expanded(
                flex: 2,
                child: Text('Amount',
                    textAlign: TextAlign.end,
                    style: GoogleFonts.poppins(
                        color: colour.kWhite.withOpacity(0.75),
                        fontSize: isTablet ? 13 : 12,
                        fontWeight: FontWeight.w600)),
              ),
            ]),
          ),

          const Divider(color: Colors.white24, height: 1),

          // Data rows
          ...rows.map((row) => _SummaryRow(
            label:    row['label']!,
            count:    row['sales']!,
            amount:   row['amount']!,
            isTablet: isTablet,
          )),

          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label, count, amount;
  final bool isTablet;
  const _SummaryRow({
    required this.label,
    required this.count,
    required this.amount,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 20,
        vertical:   isTablet ? 11 : 9,
      ),
      child: Row(children: [
        Expanded(
          flex: 3,
          child: Text(label,
              style: GoogleFonts.poppins(
                  color: colour.kWhite,
                  fontSize: isTablet ? 14 : 13,
                  fontWeight: FontWeight.w500)),
        ),
        Expanded(
          flex: 2,
          child: Text(count,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  color: AppTokens.brandLight,
                  fontSize: isTablet ? 14 : 13,
                  fontWeight: FontWeight.w600)),
        ),
        Expanded(
          flex: 2,
          child: Text(amount,
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(
                  color: AppTokens.brandLight,
                  fontSize: isTablet ? 14 : 13,
                  fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}

// ─── Date Picker Card ─────────────────────────────────────────────────────────
class _DatePickerCard extends StatelessWidget {
  final bool isTablet;
  const _DatePickerCard({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseReportBloc, ExpenseReportState>( // ✅ New State Name
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 20 : 16,
            vertical:   isTablet ? 16 : 14,
          ),
          decoration: BoxDecoration(
            color: colour.kWhite,
            borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
            border: Border.all(color: AppTokens.brandLight, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppTokens.brandGradientStart.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(children: [
            // From Date
            Expanded(
              child: _DateField(
                label: 'From',
                // ✅ Replaced DateTime.parse with direct state.fromDate usage
                date: DateFormat("dd MMM yyyy")
                    .format(state.fromDate ?? DateTime.now()),
                isTablet: isTablet,
                onTap: () async {
                  final value = await showDatePicker(
                    context: context,
                    initialDate: state.fromDate ?? DateTime.now(), // ✅ Smarter initial date
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2050),
                    builder: (ctx, child) => Theme(
                      data: Theme.of(ctx).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: AppTokens.brandGradientStart,
                          onPrimary: colour.kWhite,
                          surface: colour.kWhite,
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  if (value != null) {
                    context.read<ExpenseReportBloc>().add(
                      SelectFromDateEvent(value), // ✅ New Event takes DateTime directly
                    );
                  }
                },
              ),
            ),

            Container(
              height: isTablet ? 44 : 36,
              width: 1,
              color: AppTokens.brandLight,
              margin: const EdgeInsets.symmetric(horizontal: 12),
            ),

            // To Date
            Expanded(
              child: _DateField(
                label: 'To',
                // ✅ Replaced DateTime.parse with direct state.toDate usage
                date: DateFormat("dd MMM yyyy")
                    .format(state.toDate ?? DateTime.now()),
                isTablet: isTablet,
                onTap: () async {
                  final value = await showDatePicker(
                    context: context,
                    initialDate: state.toDate ?? DateTime.now(), // ✅ Smarter initial date
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2050),
                    builder: (ctx, child) => Theme(
                      data: Theme.of(ctx).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: AppTokens.brandGradientStart,
                          onPrimary: colour.kWhite,
                          surface: colour.kWhite,
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  if (value != null) {
                    context.read<ExpenseReportBloc>().add(
                      SelectToDateEvent(value), // ✅ New Event takes DateTime directly
                    );
                  }
                },
              ),
            ),
          ]),
        );
      },
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String date;
  final VoidCallback onTap;
  final bool isTablet;
  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 9 : 7),
            decoration: BoxDecoration(
              color: AppTokens.brandLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.calendar_today_rounded,
                size: isTablet ? 20 : 16,
                color: AppTokens.brandGradientStart),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.poppins(
                      fontSize: isTablet ? 11 : 10,
                      color: AppTokens.brandMid,
                      fontWeight: FontWeight.w500)),
              Text(date,
                  style: GoogleFonts.poppins(
                      fontSize: isTablet ? 14 : 13,
                      color: AppTokens.brandDark,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ]),
      ),
    );
  }
}

// ─── List Header ──────────────────────────────────────────────────────────────
class _ListHeader extends StatelessWidget {
  final bool isTablet;
  const _ListHeader({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 20 : 16,
        vertical:   isTablet ? 13 : 10,
      ),
      decoration: BoxDecoration(
        color: AppTokens.brandLight,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
      ),
      child: Row(children: [
        Expanded(
          flex: 3,
          child: Text('Expense',
              style: GoogleFonts.poppins(
                  fontSize: isTablet ? 13 : 12,
                  fontWeight: FontWeight.w700,
                  color: AppTokens.brandDark)),
        ),
        Expanded(
          flex: 2,
          child: Text('Count',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: isTablet ? 13 : 12,
                  fontWeight: FontWeight.w700,
                  color: AppTokens.brandDark)),
        ),
        Expanded(
          flex: 2,
          child: Text('Amount',
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(
                  fontSize: isTablet ? 13 : 12,
                  fontWeight: FontWeight.w700,
                  color: AppTokens.brandDark)),
        ),
      ]),
    );
  }
}

// ─── Expense Item Card ────────────────────────────────────────────────────────
class _ExpenseItemCard extends StatelessWidget {
  final String name, count, amount;
  final int index;
  final bool isTablet;
  final VoidCallback onTap;

  const _ExpenseItemCard({
    required this.name,
    required this.count,
    required this.amount,
    required this.index,
    required this.isTablet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 12 : 10),
      child: Material(
        color: colour.kWhite,
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
          splashColor: AppTokens.brandLight,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 20 : 16,
              vertical:   isTablet ? 16 : 14,
            ),
            decoration: BoxDecoration(
              borderRadius:
              BorderRadius.circular(isTablet ? 20 : 16),
              border: Border.all(color: AppTokens.brandLight, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: AppTokens.brandGradientStart.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(children: [
              // Index badge
              Container(
                width:  isTablet ? 32 : 28,
                height: isTablet ? 32 : 28,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: AppTokens.brandLight,
                  borderRadius:
                  BorderRadius.circular(isTablet ? 10 : 8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: GoogleFonts.poppins(
                      fontSize: isTablet ? 12 : 11,
                      fontWeight: FontWeight.w700,
                      color: AppTokens.brandGradientStart),
                ),
              ),

              Expanded(
                flex: 3,
                child: Text(name,
                    style: GoogleFonts.poppins(
                        fontSize: isTablet ? 14 : 13,
                        fontWeight: FontWeight.w600,
                        color: AppTokens.brandDark)),
              ),
              Expanded(
                flex: 2,
                child: Text(count,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        fontSize: isTablet ? 14 : 13,
                        fontWeight: FontWeight.w500,
                        color: AppTokens.brandGradientStartLight)),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 10 : 8,
                    vertical:   isTablet ? 5  : 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTokens.brandLight,
                    borderRadius:
                    BorderRadius.circular(isTablet ? 10 : 8),
                  ),
                  child: Text(amount,
                      textAlign: TextAlign.end,
                      style: GoogleFonts.poppins(
                          fontSize: isTablet ? 14 : 13,
                          fontWeight: FontWeight.w700,
                          color: AppTokens.brandGradientStart)),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}