import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../../core/colors/colors.dart' as colour;
import '../../../../../../core/di/injection.dart';
import '../bloc/airfreightsales_bloc.dart';
import '../bloc/airfreightsales_event.dart';
import '../bloc/airfreightsales_state.dart';

// ─── Page ─────────────────────────────────────────────────────────────────────
class AirfreightSales extends StatelessWidget {
  const AirfreightSales({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AirfreightBloc>(),
      child: const _AirfreightView(),
    );
  }
}

// ─── View ─────────────────────────────────────────────────────────────────────
class _AirfreightView extends StatelessWidget {
  const _AirfreightView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AirfreightBloc, AirfreightState>(
      builder: (context, state) {
        if (state.isLoading && state.rulesTypeEmployee.isEmpty) {
          return const Scaffold(
            backgroundColor: colour.kPageBg,
            body: Center(
              child: CircularProgressIndicator(color: colour.kPrimary),
            ),
          );
        }

        return Scaffold(
          backgroundColor: colour.kPageBg,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeader(context, state),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                sliver: SliverToBoxAdapter(
                  child: _buildStatsGrid(state),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                sliver: SliverToBoxAdapter(
                  child: _buildStatusSection(state),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 30),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Header Section ──
  Widget _buildHeader(BuildContext context, AirfreightState state) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [colour.kPrimary, colour.kPrimaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: colour.kShadow,
            blurRadius: 15,
            offset: Offset(0, 8),
          )
        ],
      ),
      padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Air Freight Sales',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMMM yyyy').format(DateTime.now()),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                ),
                child: const Icon(Icons.flight_takeoff_rounded, color: Colors.white, size: 26),
              )
            ],
          ),
          const SizedBox(height: 24),
          // Glassmorphism Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                dropdownColor: colour.kPrimary, // Match theme
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
                value: state.dropdownValueEmp.isEmpty ? null : state.dropdownValueEmp,
                hint: Text(
                  'Select Employee',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
                ),
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                onChanged: (String? value) {
                  if (value != null) {
                    context.read<AirfreightBloc>().add(EmployeeChangedEvent(value));
                  }
                },
                items: state.rulesTypeEmployee.map<DropdownMenuItem<String>>((item) {
                  return DropdownMenuItem<String>(
                    value: item['Id'].toString(),
                    child: Text(item['AccountName']!),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats Grid ──
  Widget _buildStatsGrid(AirfreightState state) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _PremiumStatCard(
          title: 'Total Orders',
          value: state.totalCount.toString(),
          icon: Icons.list_alt_rounded,
          gradientColors: const [colour.kPrimary, colour.kPrimaryLight],
        ),
        _PremiumStatCard(
          title: 'Without Invoice',
          value: state.withoutInvoiceCount.toString(),
          icon: Icons.receipt_long_rounded,
          gradientColors: const [colour.kAccentRed, colour.cRose],
        ),
        _PremiumStatCard(
          title: 'Billed',
          value: state.totalBilledCount.toString(),
          icon: Icons.check_circle_outline_rounded,
          gradientColors: const [colour.kSuccess, colour.kGreen],
        ),
        _PremiumStatCard(
          title: 'Unbilled',
          value: state.totalUnBilledCount.toString(),
          icon: Icons.hourglass_empty_rounded,
          gradientColors: const [colour.kGold, colour.kOrange],
        ),
      ],
    );
  }

  // ── Status Section ──
  Widget _buildStatusSection(AirfreightState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'STATUS BREAKDOWN',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: const Color(0xFF8B95A5),
            ),
          ),
        ),
        if (state.salesReport.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.inbox_rounded, size: 54, color: const Color(0xFFD2D6E0)),
                const SizedBox(height: 12),
                Text(
                  'No data found',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: const Color(0xFF8B95A5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: state.salesReport.length,
              separatorBuilder: (_, __) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Divider(height: 1, color: Colors.grey.shade100, thickness: 1.5),
              ),
              itemBuilder: (context, index) {
                final item = state.salesReport[index];
                final int dayCount = int.tryParse(item['DayCount'].toString()) ?? 0;
                final double progress = (dayCount / 100).clamp(0.0, 1.0);
                final Color themeColor = _statusThemeColor(index);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Row(
                    children: [
                      // Icon/Dot
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: themeColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.insights_rounded,
                          color: themeColor,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Title
                      Expanded(
                        child: Text(
                          item['JobStatus'].toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2D3748),
                          ),
                        ),
                      ),
                      // Progress and Text
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                dayCount.toString(),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: themeColor,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'days',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFFA0AEC0),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: 80,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: themeColor.withOpacity(0.15),
                                valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                                minHeight: 6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Color _statusThemeColor(int index) {
    const colors = [
      colour.brand, // Blue
      colour.kSuccess, // Teal
      colour.cRose, // Red
      colour.kGold, // Amber
      colour.kNavy, // Navy instead of purple
      colour.kBlue, // Cyan
    ];
    return colors[index % colors.length];
  }
}

// ── Premium Stat Card ──────────────────────────────────────────────────────────
class _PremiumStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradientColors;

  const _PremiumStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.12),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                Icon(Icons.arrow_outward_rounded, color: Colors.grey.shade300, size: 18),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A202C),
                    height: 1.2,
                  ),
                ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
