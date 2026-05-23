// license_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:maleva/core/theme/tokens.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

import '../../../../../../core/di/injection.dart';
import '../../../../../../core/theme/palette.dart';
import '../bloc/license_bloc.dart';
import '../bloc/license_event.dart';
import '../bloc/license_state.dart';


// ─── Page ─────────────────────────────────────────────────────────────────────
class DriverLicensePage extends StatelessWidget {
  const DriverLicensePage({super.key});

  @override
  Widget build(BuildContext context) {
    return
      BlocProvider(
        create: (context) => sl<LicenseBloc>()
          ..add(const LoadLicenseEvent()),
        child: const LicenseView(),
      );
  }
}

// ─── View ─────────────────────────────────────────────────────────────────────
class LicenseView extends StatelessWidget {
  const LicenseView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LicenseBloc, LicenseState>(
      listener: (context, state) {
        if (state is LicenseError) {
          objfun.msgshow(
            state.errorMessage, '',
            Colors.white, Colors.red, null,
            18.00 - objfun.reducesize,
            objfun.tll, objfun.tgc, context, 2,
          );
        }
      },
      builder: (context, state) {
        return Container(
          color: AppTokens.surfacePage,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header + Search ──────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
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
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Palette.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.badge_outlined,
                              color: Palette.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Driver's License",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Palette.white,
                                )),
                            Text("License records",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Palette.white.withOpacity(0.7),
                                )),
                          ],
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => context
                              .read<LicenseBloc>()
                              .add(const LoadLicenseEvent()),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Palette.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Palette.white.withOpacity(0.3)),
                            ),
                            child: const Icon(Icons.refresh_rounded,
                                color: Palette.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Search bar
                    Container(
                      decoration: BoxDecoration(
                        color: Palette.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (query) => context
                            .read<LicenseBloc>()
                            .add(SearchLicenseEvent(query: query)),
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: AppTokens.textPrimary),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: AppTokens.brandPrimary, size: 20),
                          hintText: 'Search by name or category...',
                          hintStyle: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppTokens.textSecondary),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── List ────────────────────────────────────────────────────
              Expanded(child: _buildBody(context, state)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, LicenseState state) {
    if (state is LicenseLoading || state is LicenseInitial) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
                color: AppTokens.brandPrimary, strokeWidth: 3),
            const SizedBox(height: 16),
            Text("Loading licenses...",
                style: GoogleFonts.poppins(
                    color: AppTokens.textSecondary, fontSize: 13)),
          ],
        ),
      );
    }

    if (state is LicenseError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Palette.redDanger.withOpacity(0.08),
                    shape: BoxShape.circle),
                child: Icon(Icons.wifi_off_rounded,
                    color: Palette.redDanger, size: 40),
              ),
              const SizedBox(height: 16),
              Text("Failed to load",
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTokens.textPrimary)),
              const SizedBox(height: 8),
              Text(state.errorMessage,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: AppTokens.textSecondary)),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => context
                    .read<LicenseBloc>()
                    .add(const LoadLicenseEvent()),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTokens.brandPrimary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.refresh_rounded,
                          color: Palette.white, size: 16),
                      const SizedBox(width: 8),
                      Text("Try Again",
                          style: GoogleFonts.poppins(
                              color: Palette.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state is LicenseLoaded) {
      if (state.filteredRecords.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: const BoxDecoration(
                    color: Palette.blue50, shape: BoxShape.circle),
                child: const Icon(Icons.badge_outlined,
                    size: 40, color: AppTokens.brandPrimary),
              ),
              const SizedBox(height: 14),
              Text(
                state.searchQuery.isNotEmpty
                    ? 'No results for "${state.searchQuery}"'
                    : 'No licenses found',
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTokens.textSecondary),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
        itemCount: state.filteredRecords.length,
        itemBuilder: (context, index) {
          final record = state.filteredRecords[index];
          return _LicenseCard(record: record, index: index);
        },
      );
    }

    return const SizedBox.shrink();
  }
}

// ─── License Card ─────────────────────────────────────────────────────────────
class _LicenseCard extends StatelessWidget {
  final dynamic record;
  final int index;

  const _LicenseCard({required this.record, required this.index});

  // ── Date formatter ──
  String _fmt(dynamic date) {
    if (date == null) return '—';
    final s = date.toString().trim();
    if (s.isEmpty || s.startsWith('1900') || s.startsWith('01/01/1900')) {
      return '—';
    }
    final formats = [
      'MM/dd/yyyy HH:mm:ss',
      'MM/dd/yyyy',
      'yyyy-MM-dd',
      "yyyy-MM-dd'T'HH:mm:ss",
    ];
    for (final fmt in formats) {
      try {
        return DateFormat('dd MMM yyyy').format(DateFormat(fmt).parse(s));
      } catch (_) {}
    }
    return s;
  }

  bool get _isActive => (record.Active ?? 0) != 0;

  // API fields: licenseExp, JoiningDate
  dynamic get _licenseExp => record.licenseExp;
  dynamic get _joiningDate => record.JoiningDate;
  String get _driverName => record.DriverName ?? 'Unknown Driver';
  String get _licenseNo => record.licenseNo ?? '—';
  String get _accountCode => record.AccountCode ?? '';

  bool get _isExpiringSoon {
    try {
      if (_licenseExp == null) return false;
      final s = _licenseExp.toString();
      if (s.startsWith('1900') || s.startsWith('01/01/1900')) return false;
      final expiry = DateFormat('MM/dd/yyyy HH:mm:ss').parse(s);
      final diff = expiry.difference(DateTime.now()).inDays;
      return diff >= 0 && diff <= 30;
    } catch (_) {
      return false;
    }
  }

  bool get _isExpired {
    try {
      if (_licenseExp == null) return false;
      final s = _licenseExp.toString();
      if (s.startsWith('1900') || s.startsWith('01/01/1900')) return false;
      final expiry = DateFormat('MM/dd/yyyy HH:mm:ss').parse(s);
      return expiry.isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = _isActive;
    final expiringSoon = _isExpiringSoon;
    final expired = _isExpired;

    final statusColor = isActive ? Palette.greenEco : Palette.redDanger;
    final expiryColor = expired
        ? Palette.redDanger
        : expiringSoon
        ? Palette.amber
        : AppTokens.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTokens.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? Palette.greenEco.withOpacity(0.15)
              : Palette.redDanger.withOpacity(0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTokens.brandPrimary.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Accent top strip
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: isActive ? Palette.greenEco : Palette.redDanger,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Header Row ──────────────────────────────────────────
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppTokens.brandPrimary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.person_rounded,
                          color: AppTokens.brandPrimary, size: 24),
                    ),
                    const SizedBox(width: 12),

                    // Name + License No + Account Code
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _driverName,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTokens.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                _accountCode,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: AppTokens.brandPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (_licenseNo.isNotEmpty &&
                                  _licenseNo != '—') ...[
                                Text(' · ',
                                    style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: AppTokens.textSecondary)),
                                Expanded(
                                  child: Text(
                                    _licenseNo,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: AppTokens.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border:
                        Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isActive
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            color: statusColor,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isActive ? 'Active' : 'Inactive',
                            style: GoogleFonts.poppins(
                              color: statusColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Divider(color: AppTokens.surfaceBorder, height: 1),
                const SizedBox(height: 12),

                // ── Info Chips ───────────────────────────────────────────
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.event_available_rounded,
                      label: "Joined",
                      value: _fmt(_joiningDate),
                      iconColor: AppTokens.brandPrimary,
                      bgColor: Palette.blue50,
                    ),
                    const SizedBox(width: 10),
                    _InfoChip(
                      icon: expired
                          ? Icons.event_busy_rounded
                          : expiringSoon
                          ? Icons.warning_amber_rounded
                          : Icons.calendar_today_rounded,
                      label: "License Exp",
                      value: _fmt(_licenseExp),
                      iconColor: expiryColor,
                      bgColor: expiryColor.withOpacity(0.08),
                      valueColor: expiryColor,
                    ),
                  ],
                ),

                // ── Expiry Warning ───────────────────────────────────────
                if (expired || expiringSoon) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: expired
                          ? Palette.redDanger.withOpacity(0.06)
                          : Palette.amber.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: expired
                            ? Palette.redDanger.withOpacity(0.2)
                            : Palette.amber.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          expired
                              ? Icons.error_outline_rounded
                              : Icons.info_outline_rounded,
                          size: 14,
                          color:
                          expired ? Palette.redDanger : Palette.amber,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          expired
                              ? 'License has expired'
                              : 'Expiring within 30 days',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: expired
                                ? Palette.redDanger
                                : Palette.amber,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Info Chip ────────────────────────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final Color bgColor;
  final Color? valueColor;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.bgColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppTokens.textSecondary,
                        fontWeight: FontWeight.w500,
                      )),
                  Text(value,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: valueColor ?? AppTokens.textPrimary,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}