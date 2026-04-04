import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import '../../../../../../core/theme/tokens.dart';
import '../bloc/driverdetails_bloc.dart';
import '../bloc/driverdetails_event.dart';
import '../bloc/driverdetails_state.dart';

class DriverDetailsScreen extends StatelessWidget {
  const DriverDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DriverBloc(context)
        ..add(const LoadDriverEvent()),
      child: const DriverDetailsView(),
    );
  }
}

class DriverDetailsView extends StatelessWidget {
  const DriverDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FF),
      body: SafeArea(
        child: isTablet
            ? _buildTabletLayout(context)
            : _buildMobileLayout(context),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // TABLET — Two Column
  // ══════════════════════════════════════════════════════
  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ── LEFT (30%) — Header + Count Badge
        SizedBox(
          width: 260,
          child: Column(
            children: [
              // Gradient header — full left panel
              _GradientHeader(isTablet: true),
              const SizedBox(height: 20),

              // Count badge
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: BlocBuilder<DriverBloc, DriverState>(
                  builder: (context, state) {
                    final count = state is DriverLoaded
                        ? state.driverData.length
                        : 0;
                    return _CountBadge(count: count);
                  },
                ),
              ),
            ],
          ),
        ),

        // ── RIGHT (70%) — Driver Grid
        Expanded(
          child: BlocBuilder<DriverBloc, DriverState>(
            builder: (context, state) {
              if (state is DriverLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                      color: AppTokens.brandGradientStart),
                );
              }

              if (state is DriverError) {
                return _ErrorState(
                    message: state.errorMessage, isTablet: true);
              }

              if (state is DriverLoaded) {
                if (state.driverData.isEmpty) {
                  return _EmptyState(isTablet: true);
                }

                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:   2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing:  12,
                    childAspectRatio: 3.0,
                  ),
                  itemCount: state.driverData.length,
                  itemBuilder: (context, index) {
                    return _DriverCard(
                      driver:   state.driverData[index],
                      index:    index,
                      isTablet: true,
                    );
                  },
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════
  // MOBILE — Single Column
  // ══════════════════════════════════════════════════════
  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        _GradientHeader(isTablet: false),

        Expanded(
          child: BlocBuilder<DriverBloc, DriverState>(
            builder: (context, state) {
              if (state is DriverLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                      color: AppTokens.brandGradientStart),
                );
              }

              if (state is DriverError) {
                return _ErrorState(
                    message: state.errorMessage, isTablet: false);
              }

              if (state is DriverLoaded) {
                if (state.driverData.isEmpty) {
                  return _EmptyState(isTablet: false);
                }

                return ListView.builder(
                  padding:
                  const EdgeInsets.fromLTRB(16, 20, 16, 20),
                  itemCount: state.driverData.length,
                  itemBuilder: (context, index) {
                    return _DriverCard(
                      driver:   state.driverData[index],
                      index:    index,
                      isTablet: false,
                    );
                  },
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

// ─── Gradient Header ──────────────────────────────────────────────────────────
class _GradientHeader extends StatelessWidget {
  final bool isTablet;
  const _GradientHeader({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        isTablet ? 28 : 24,
        20,
        isTablet ? 32 : 28,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTokens.brandGradientStart, AppTokens.brandDark],
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
        ),
        borderRadius: isTablet
            ? const BorderRadius.only(
          bottomRight: Radius.circular(28),
        )
            : const BorderRadius.only(
          bottomLeft:  Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: const [
          BoxShadow(
            color:     Color(0x401555F3),
            blurRadius: 20,
            offset:    Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: EdgeInsets.all(isTablet ? 12 : 10),
              decoration: BoxDecoration(
                color:         colour.kWhite.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.airline_seat_recline_extra_rounded,
                color: colour.kWhite,
                size:  isTablet ? 26 : 22,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                "Driver Details",
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize:   isTablet ? 26 : 22,
                  fontWeight: FontWeight.w700,
                  color:      colour.kWhite,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ]),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              "All registered drivers",
              style: GoogleFonts.poppins(
                fontSize:   isTablet ? 14 : 13,
                color:      colour.kWhite.withOpacity(0.75),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Count Badge ──────────────────────────────────────────────────────────────
class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTokens.brandGradientStart, AppTokens.brandDark],
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:     AppTokens.brandGradientStart.withOpacity(0.30),
            blurRadius: 16,
            offset:    const Offset(0, 6),
          ),
        ],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colour.kWhite.withOpacity(0.20),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.airline_seat_recline_extra_rounded,
            color: colour.kWhite,
            size:  22,
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Drivers',
                style: GoogleFonts.poppins(
                  fontSize:   12,
                  color:      colour.kWhite.withOpacity(0.75),
                  fontWeight: FontWeight.w500,
                )),
            Text('$count',
                style: GoogleFonts.poppins(
                  fontSize:   28,
                  color:      colour.kWhite,
                  fontWeight: FontWeight.w700,
                )),
          ],
        ),
      ]),
    );
  }
}

// ─── Driver Card ──────────────────────────────────────────────────────────────
class _DriverCard extends StatelessWidget {
  final dynamic driver;
  final int index;
  final bool isTablet;

  const _DriverCard({
    required this.driver,
    required this.index,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 0 : 12),
      decoration: BoxDecoration(
        color:         colour.kWhite,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 16),
        boxShadow: const [
          BoxShadow(
            color:     Color(0x141555F3),
            blurRadius: 12,
            offset:    Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 12 : 16,
          vertical:   isTablet ? 10 : 14,
        ),
        child: Row(children: [
          // Avatar
          Container(
            width:  isTablet ? 40 : 48,
            height: isTablet ? 40 : 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTokens.brandGradientStartLight, AppTokens.brandGradientStart],
                begin: Alignment.topLeft,
                end:   Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(isTablet ? 12 : 14),
            ),
            child: Center(
              child: Text(
                (driver.DriverName != null &&
                    driver.DriverName!.isNotEmpty)
                    ? driver.DriverName![0].toUpperCase()
                    : "D",
                style: GoogleFonts.poppins(
                  color:      colour.kWhite,
                  fontSize:   isTablet ? 17 : 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  driver.DriverName ?? "-",
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize:   isTablet ? 13 : 15,
                    fontWeight: FontWeight.w600,
                    color:      const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 3),
                Row(children: [
                  const Icon(Icons.circle,
                      size: 7, color: Color(0xFF22C55E)),
                  const SizedBox(width: 5),
                  Text(
                    "Active Driver",
                    style: GoogleFonts.poppins(
                      fontSize:   isTablet ? 11 : 12,
                      color:      Colors.grey.shade500,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ]),
              ],
            ),
          ),

          // Arrow
          Container(
            width:  isTablet ? 28 : 34,
            height: isTablet ? 28 : 34,
            decoration: BoxDecoration(
              color:         AppTokens.brandLight,
              borderRadius: BorderRadius.circular(isTablet ? 8 : 10),
            ),
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              size:  isTablet ? 12 : 14,
              color: AppTokens.brandGradientStart,
            ),
          ),
        ]),
      ),
    );
  }
}

// ─── Error State ──────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String message;
  final bool isTablet;
  const _ErrorState({required this.message, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isTablet ? 24 : 20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline_rounded,
                  color: Colors.red.shade400,
                  size:  isTablet ? 56 : 48),
            ),
            SizedBox(height: isTablet ? 20 : 16),
            Text(
              "Something went wrong",
              style: GoogleFonts.poppins(
                fontSize:   isTablet ? 18 : 16,
                fontWeight: FontWeight.w600,
                color:      Colors.red.shade400,
              ),
            ),
            SizedBox(height: isTablet ? 10 : 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: isTablet ? 14 : 13,
                color:    Colors.grey.shade600,
              ),
            ),
            SizedBox(height: isTablet ? 24 : 20),
            ElevatedButton.icon(
              onPressed: () => context
                  .read<DriverBloc>()
                  .add(const LoadDriverEvent()),
              icon:  Icon(Icons.refresh_rounded,
                  size: isTablet ? 20 : 18),
              label: Text("Retry",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize:   isTablet ? 14 : 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTokens.brandGradientStart,
                foregroundColor: colour.kWhite,
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 36 : 28,
                  vertical:   isTablet ? 14 : 12,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isTablet;
  const _EmptyState({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 28 : 24),
            decoration: const BoxDecoration(
              color: AppTokens.brandLight,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_off_rounded,
                color: AppTokens.brandGradientStart,
                size:  isTablet ? 52 : 44),
          ),
          SizedBox(height: isTablet ? 20 : 16),
          Text(
            "No drivers found",
            style: GoogleFonts.poppins(
              fontSize:   isTablet ? 18 : 16,
              fontWeight: FontWeight.w600,
              color:      Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}