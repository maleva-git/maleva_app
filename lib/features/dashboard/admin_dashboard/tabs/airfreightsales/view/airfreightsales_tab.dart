import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../../core/colors/colors.dart' as colour;
import '../../../../../../core/theme/tokens.dart';
import '../bloc/airfreightsales_bloc.dart';
import '../bloc/airfreightsales_event.dart';
import '../bloc/airfreightsales_state.dart';


class CustomerDashboardScreen extends StatelessWidget {
  const CustomerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CustomerDashboardBloc()..add(LoadRulesTypeEvent()),
      child: const _CustomerDashboardView(),
    );
  }
}

class _CustomerDashboardView extends StatelessWidget {
  const _CustomerDashboardView();

  @override
  // _CustomerDashboardView — replace your existing build method content

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;

    return BlocBuilder<CustomerDashboardBloc, CustomerDashboardState>(
      builder: (context, state) {
        if (state.isLoading && state.rulesTypeEmployee.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF1555F3)),
          );
        }
        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F0),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              children: [

                // ── Header ──
                Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: AppTokens.invoiceHeaderStart,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.dashboard_rounded,
                          color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sales Dashboard',
                            style: GoogleFonts.poppins(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: colour.commonColor)),
                        Text(
                          'Air Freight · ${DateFormat('MMMM yyyy').format(DateTime.now())}',
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: colour.commonColor.withOpacity(0.5)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Employee Dropdown ──
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: state.dropdownValueEmp.isEmpty
                          ? null
                          : state.dropdownValueEmp,
                      hint: Text('Select Employee',
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey.shade500)),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: Colors.grey),
                      onChanged: (String? value) {
                        if (value != null) {
                          context
                              .read<CustomerDashboardBloc>()
                              .add(EmployeeChangedEvent(value));
                        }
                      },
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colour.commonColor,
                      ),
                      items: state.rulesTypeEmployee
                          .map<DropdownMenuItem<String>>(
                            (item) => DropdownMenuItem<String>(
                          value: item['Id'].toString(),
                          child: Text(item['AccountName']!),
                        ),
                      )
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // ── Stats Grid ──
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.5,
                  children: [
                    _StatCard(
                      label: 'Total Orders',
                      value: state.totalCount.toString(),
                      badge: 'This month',
                      accentColor: const Color(0xFF1555F3),
                      badgeColor: const Color(0xFFE6F1FB),
                      badgeTextColor: const Color(0xFF185FA5),
                    ),
                    _StatCard(
                      label: 'Without Invoice',
                      value: state.withoutInvoiceCount.toString(),
                      badge: 'Since Oct 2024',
                      accentColor: const Color(0xFFD85A30),
                      badgeColor: const Color(0xFFFAECE7),
                      badgeTextColor: const Color(0xFF993C1D),
                    ),
                    _StatCard(
                      label: 'Billed',
                      value: state.totalBilledCount.toString(),
                      badge: 'Completed',
                      accentColor: const Color(0xFF1D9E75),
                      badgeColor: const Color(0xFFE1F5EE),
                      badgeTextColor: const Color(0xFF0F6E56),
                    ),
                    _StatCard(
                      label: 'Unbilled',
                      value: state.totalUnBilledCount.toString(),
                      badge: 'Pending',
                      accentColor: const Color(0xFFBA7517),
                      badgeColor: const Color(0xFFFAEEDA),
                      badgeTextColor: const Color(0xFF854F0B),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Section Label ──
                Text('STATUS BREAKDOWN',
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: colour.commonColor.withOpacity(0.5))),
                const SizedBox(height: 8),

                // ── Status List ──
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.salesReport.length,
                    separatorBuilder: (_, __) => Divider(
                        height: 1, color: Colors.grey.shade100),
                    itemBuilder: (context, index) {
                      final item = state.salesReport[index];
                      final int dayCount =
                          int.tryParse(item['DayCount'].toString()) ?? 0;
                      final double progress =
                      (dayCount / 100).clamp(0.0, 1.0);

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 11),
                        child: Row(
                          children: [
                            // Status dot
                            Container(
                              width: 8, height: 8,
                              decoration: BoxDecoration(
                                color: _statusColor(index),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Status name
                            Expanded(
                              child: Text(
                                item['JobStatus'].toString(),
                                style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTokens.invoiceHeaderStart),
                              ),
                            ),
                            // Progress bar
                            SizedBox(
                              width: 60,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: Colors.grey.shade100,
                                  color: _statusColor(index),
                                  minHeight: 4,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Day count
                            Text(
                              dayCount.toString(),
                              style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: colour.commonColor),
                            ),
                            const SizedBox(width: 4),
                            Text('days',
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: colour.commonColor
                                        .withOpacity(0.4))),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _statusColor(int index) {
    const colors = [
      Color(0xFF1555F3), // blue
      Color(0xFF1D9E75), // teal
      Color(0xFFBA7517), // amber
      Color(0xFFD85A30), // coral
      Color(0xFF888780), // gray
    ];
    return colors[index % colors.length];
  }


}
// ── Stat Card Widget — file bottom la add panu ──

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String badge;
  final Color accentColor;
  final Color badgeColor;
  final Color badgeTextColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.badge,
    required this.accentColor,
    required this.badgeColor,
    required this.badgeTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Accent top bar
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(),
                    style: GoogleFonts.poppins(
                        fontSize: 10,
                        letterSpacing: 0.4,
                        color: Colors.grey.shade500)),
                const SizedBox(height: 4),
                Text(value,
                    style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: colour.commonColor,
                        height: 1)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(badge,
                      style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: badgeTextColor,
                          fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}