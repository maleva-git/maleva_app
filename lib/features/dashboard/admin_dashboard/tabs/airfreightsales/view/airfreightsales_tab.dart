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
  Widget build(BuildContext context) {
    // final double height = MediaQuery.of(context).size.height; // Retained if you need it later

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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                // ── Modern Header ──
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppTokens.invoiceHeaderStart,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppTokens.invoiceHeaderStart.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.dashboard_rounded,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sales Dashboard',
                            style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: colour.commonColor)),
                        Text(
                          'Air Freight · ${DateFormat('MMMM yyyy').format(DateTime.now())}',
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: colour.commonColor.withOpacity(0.5)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Employee Dropdown ──
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: state.dropdownValueEmp.isEmpty
                          ? null
                          : state.dropdownValueEmp,
                      hint: Text('Select Employee',
                          style: GoogleFonts.poppins(
                              fontSize: 14,
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
                const SizedBox(height: 20),

                // ── Stats Grid ──
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.45,
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
                const SizedBox(height: 24),

                // ── Section Label ──
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text('STATUS BREAKDOWN',
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: colour.commonColor.withOpacity(0.4))),
                ),
                const SizedBox(height: 10),

                // ── Status List ──
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.salesReport.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: Colors.grey.shade100),
                      itemBuilder: (context, index) {
                        final item = state.salesReport[index];
                        final int dayCount =
                            int.tryParse(item['DayCount'].toString()) ?? 0;
                        final double progress =
                        (dayCount / 100).clamp(0.0, 1.0);

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              // Status dot
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: _statusColor(index),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: _statusColor(index).withOpacity(0.4),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Status name
                              Expanded(
                                child: Text(
                                  item['JobStatus'].toString(),
                                  style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: colour.commonColor),
                                ),
                              ),
                              // Progress bar
                              SizedBox(
                                width: 70,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    backgroundColor: Colors.grey.shade100,
                                    color: _statusColor(index),
                                    minHeight: 6,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Day count
                              SizedBox(
                                width: 30, // Fixed width for alignment
                                child: Text(
                                  dayCount.toString(),
                                  textAlign: TextAlign.right,
                                  style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: colour.commonColor),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text('days',
                                  style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: colour.commonColor
                                          .withOpacity(0.4))),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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

// ── Refined Stat Card Widget ──
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Accent top bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: Colors.grey.shade500)),
                  Text(value,
                      style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: colour.commonColor,
                          height: 1)),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(badge,
                        style: GoogleFonts.poppins(
                            fontSize: 9.5,
                            color: badgeTextColor,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}