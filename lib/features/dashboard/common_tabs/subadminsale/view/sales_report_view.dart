// salesreport_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/utils/app_globals.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/theme/tokens.dart';
import '../bloc/sales_report_bloc.dart';
import '../bloc/sales_report_event.dart';
import '../bloc/sales_report_state.dart';
import '../data/salesreport_repository.dart';


// ─── Page ─────────────────────────────────────────────────────────────────────
class SalesReportPage extends StatelessWidget {
  const SalesReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SalesReportBloc(
        repository: sl<SalesReportRepository>(),
      ),
      child: const _SalesReportView(),
    );
  }
}

// ─── View ─────────────────────────────────────────────────────────────────────
class _SalesReportView extends StatelessWidget {
  const _SalesReportView();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return BlocConsumer<SalesReportBloc, SalesReportState>(
      listener: (context, state) {
        if (state is SalesReportEmpDetailLoaded) {
          _showDialogEmpDetails(context, state.empSalesReport);
        }
        if (state is SalesReportError) {
          msgshow(
            state.errorMessage, '',
            Palette.white, Palette.red, null,
            18.00 - AppGlobals.reducesize,
            AppGlobals.tll, AppGlobals.tgc, context, 2,
          );
        }
      },
      builder: (context, state) {

        // ── Loading ────────────────────────────────────────────────────────
        if (state is SalesReportLoading || state is SalesReportInitial) {
          return Container(
            color: AppTokens.surfacePage,
            child: const Center(
              child: CircularProgressIndicator(
                color: AppTokens.brandPrimary,
                strokeWidth: 3,
              ),
            ),
          );
        }

        // ── Error ──────────────────────────────────────────────────────────
        if (state is SalesReportError) {
          return Container(
            color: AppTokens.surfacePage,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Palette.red.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.wifi_off_rounded,
                          color: Palette.red, size: 40),
                    ),
                    const SizedBox(height: 16),
                    Text("Something went wrong",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTokens.textPrimary,
                        )),
                    const SizedBox(height: 8),
                    Text(state.errorMessage,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTokens.textSecondary,
                        )),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () => context
                          .read<SalesReportBloc>()
                          .add(const LoadSalesReportEvent()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 13),
                        decoration: BoxDecoration(
                          color: AppTokens.brandPrimary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppTokens.brandPrimary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.refresh_rounded,
                                color: Palette.white, size: 16),
                            const SizedBox(width: 8),
                            Text("Retry",
                                style: GoogleFonts.poppins(
                                  color: Palette.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // ── Loaded ─────────────────────────────────────────────────────────
        if (state is SalesReportLoaded) {
          return Container(
            color: AppTokens.surfacePage,
            child: Column(
              children: [
                // ── Gradient Header ──────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  decoration: const BoxDecoration(
                    gradient: AppTokens.headerGradient,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Sales Report",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Palette.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Monthly overview",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Palette.white.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Employee Dropdown ──────────────────────────────
                      Container(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Palette.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Palette.white.withValues(alpha: 0.25)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            dropdownColor: AppTokens.brandDark,
                            iconEnabledColor: Palette.white,
                            value: state.rulesTypeEmployee.any((e) =>
                            e['Id'].toString() ==
                                state.dropdownValueEmp)
                                ? state.dropdownValueEmp
                                : null,
                            hint: Text(
                              "Select Employee",
                              style: GoogleFonts.poppins(
                                color: Palette.white.withValues(alpha: 0.8),
                                fontSize: 13,
                              ),
                            ),
                            onChanged: (String? value) {
                              context.read<SalesReportBloc>().add(
                                  ChangeEmployeeEvent(employeeId: value));
                            },
                            items: state.rulesTypeEmployee
                                .map<DropdownMenuItem<String>>(
                                  (item) => DropdownMenuItem<String>(
                                value: item['Id'].toString(),
                                child: Text(
                                  item['AccountName'] ?? "",
                                  style: GoogleFonts.poppins(
                                    color: Palette.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            )
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: ListView(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                    children: [

                      // ── Summary Cards Row ────────────────────────────
                      Row(
                        children: [
                          _StatCard(
                            label: "Without\nInvoice",
                            value: state.withoutInvoiceCount.toString(),
                            icon: Icons.receipt_long_outlined,
                            iconBg: Palette.redDanger.withValues(alpha: 0.1),
                            iconColor: Palette.redDanger,
                            valueColor: Palette.redDanger,
                          ),
                          const SizedBox(width: 10),
                          _StatCard(
                            label: "Total\nCount",
                            value: state.totalCount.toString(),
                            icon: Icons.bar_chart_rounded,
                            iconBg: AppTokens.brandPrimary.withValues(alpha: 0.1),
                            iconColor: AppTokens.brandPrimary,
                            valueColor: AppTokens.brandPrimary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _StatCard(
                            label: "Billed",
                            value: state.totalBilledCount.toString(),
                            icon: Icons.check_circle_outline_rounded,
                            iconBg: Palette.greenEco.withValues(alpha: 0.1),
                            iconColor: Palette.greenEco,
                            valueColor: Palette.greenEco,
                          ),
                          const SizedBox(width: 10),
                          _StatCard(
                            label: "UnBilled",
                            value: state.totalUnBilledCount.toString(),
                            icon: Icons.pending_outlined,
                            iconBg: Palette.amber.withValues(alpha: 0.1),
                            iconColor: Palette.amber,
                            valueColor: Palette.amber,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── Sales Report List Header ─────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: AppTokens.headerGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text("Job Status",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Palette.white,
                                  )),
                            ),
                            Text("Day Count",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Palette.white.withValues(alpha: 0.85),
                                )),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ── Sales Report List ────────────────────────────
                      if (state.salesReport.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 32),
                          child: Column(
                            children: [
                              const Icon(Icons.inbox_outlined,
                                  size: 48,
                                  color: AppTokens.textDim),
                              const SizedBox(height: 12),
                              Text("No data found",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: AppTokens.textSecondary,
                                  )),
                            ],
                          ),
                        )
                      else
                        ...List.generate(state.salesReport.length,
                                (index) {
                              final item = state.salesReport[index];
                              final isEven = index % 2 == 0;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                decoration: BoxDecoration(
                                  color: isEven
                                      ? AppTokens.surfaceCard
                                      : Palette.blue50,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isEven
                                        ? AppTokens.surfaceBorder
                                        : Palette.blue400.withValues(alpha: 0.2),
                                  ),
                                  boxShadow: isEven
                                      ? [
                                    BoxShadow(
                                      color: AppTokens.brandPrimary
                                          .withValues(alpha: 0.04),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                      : [],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  child: Row(
                                    children: [
                                      // Index badge
                                      Container(
                                        width: 26,
                                        height: 26,
                                        decoration: BoxDecoration(
                                          color: AppTokens.brandPrimary
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                          BorderRadius.circular(7),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '${index + 1}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: AppTokens.brandPrimary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          item["JobStatus"]?.toString() ??
                                              "-",
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppTokens.textPrimary,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppTokens.brandPrimary
                                              .withValues(alpha: 0.08),
                                          borderRadius:
                                          BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          item["DayCount"]?.toString() ??
                                              "-",
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: AppTokens.brandPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),

                      const SizedBox(height: 20),
                    ],
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

  // ── Employee Detail Dialog ───────────────────────────────────────────────────
  void _showDialogEmpDetails(BuildContext context, List<dynamic> data) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dialog Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
              decoration: const BoxDecoration(
                gradient: AppTokens.headerGradient,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_rounded,
                      color: Palette.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Employee Details",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Palette.white,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Palette.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.close_rounded,
                          color: Palette.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),

            // Dialog Body
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: data.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              item.keys.first.toString(),
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppTokens.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              item.values.first?.toString() ?? '-',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTokens.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stat Card Widget ─────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Color valueColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTokens.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTokens.surfaceBorder),
          boxShadow: [
            BoxShadow(
              color: AppTokens.brandPrimary.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: valueColor,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: AppTokens.textSecondary,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}