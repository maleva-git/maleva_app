import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;
import '../../../../../../core/theme/tokens.dart';
import '../bloc/enginehours_bloc.dart';
import '../bloc/enginehours_event.dart';
import '../bloc/enginehours_state.dart';

// ── Entry Point ───────────────────────────────────────────────────────────────
class EngineHoursPage extends StatelessWidget {
  const EngineHoursPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      EngineHoursBloc(context)..add(LoadEngineHoursReport()),
      child: const _EngineHoursBody(),
    );
  }
}
class _EngineHoursBody extends StatefulWidget {
  const _EngineHoursBody();

  @override
  State<_EngineHoursBody> createState() => _EngineHoursBodyState();
}

// ── Body ──────────────────────────────────────────────────────────────────────
class _EngineHoursBodyState extends State<_EngineHoursBody> {
  DateTime _fromDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _toDate   = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);

  void _pickDate({required bool isFrom}) async {
    final DateTime? picked = await showDatePicker(
      context:     context,
      initialDate: isFrom ? _fromDate : _toDate,
      firstDate:   DateTime(2020),
      lastDate:    DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary:   AppTokens.brandGradientStart,
            onPrimary: Colors.white,
            surface:   Colors.white,
          ),
        ),
        child: child!,
      ),
    );

    if (picked == null) return;

    setState(() {
      if (isFrom) {
        _fromDate = picked;
        if (_toDate.isBefore(_fromDate)) _toDate = _fromDate;
      } else {
        _toDate = picked;
        if (_fromDate.isAfter(_toDate)) _fromDate = _toDate;
      }
    });

    if (mounted) {
      context.read<EngineHoursBloc>().add(
        LoadEngineHoursReport(fromDate: _fromDate, toDate: _toDate),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    return isTablet
        ? _buildTabletLayout(context)
        : _buildMobileLayout(context);
  }

  // ══════════════════════════════════════════════════════
  // TABLET
  // ══════════════════════════════════════════════════════
  Widget _buildTabletLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── LEFT (240px)
          SizedBox(
            width: 240,
            child: BlocBuilder<EngineHoursBloc, EngineHoursState>(
              builder: (context, state) {
                final count = state is EngineHoursLoaded
                    ? state.engineHoursRecords.length
                    : 0;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        width: 4, height: 30,
                        decoration: BoxDecoration(
                          color: AppTokens.brandGradientStart,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text("ENGINE",
                          style: GoogleFonts.lato(
                            fontSize:      20,
                            fontWeight:    FontWeight.bold,
                            color:         AppTokens.brandDark,
                            letterSpacing: 1.2,
                          )),
                    ]),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.only(left: 14),
                      child: Text("Hours Details",
                          style: GoogleFonts.lato(
                            fontSize:   14,
                            color:      AppTokens.brandMid,
                            fontWeight: FontWeight.w500,
                          )),
                    ),
                    const SizedBox(height: 20),
                    _CountBadge(count: count),
                    const SizedBox(height: 20),

                    // ── Date filter — tablet left panel
                    _DateFilterBar(
                      fromDate:  _fromDate,
                      toDate:    _toDate,
                      isTablet:  true,
                      onFromTap: () => _pickDate(isFrom: true),
                      onToTap:   () => _pickDate(isFrom: false),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(width: 16),

          // ── RIGHT — List
          Expanded(
            child: BlocBuilder<EngineHoursBloc, EngineHoursState>(
              builder: (context, state) {
                if (state is EngineHoursLoading) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: AppTokens.brandGradientStart));
                }
                if (state is EngineHoursError) {
                  return _ErrorState(message: state.message, isTablet: true);
                }
                if (state is EngineHoursLoaded) {
                  if (state.engineHoursRecords.isEmpty) {
                    return _EmptyState(isTablet: true);
                  }
                  return ListView.builder(
                    itemCount: state.engineHoursRecords.length,
                    itemBuilder: (context, index) => _EngineHoursCard(
                      record:   state.engineHoursRecords[index],
                      isTablet: true,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // MOBILE
  // ══════════════════════════════════════════════════════
  Widget _buildMobileLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(children: [
        Text("Engine Hours",
            style: GoogleFonts.lato(
              fontSize:   objfun.FontLarge,
              fontWeight: FontWeight.bold,
              color:      AppTokens.brandDark,
            )),
        const SizedBox(height: 10),

        // ── Date filter — mobile top row
        _DateFilterBar(
          fromDate:  _fromDate,
          toDate:    _toDate,
          isTablet:  false,
          onFromTap: () => _pickDate(isFrom: true),
          onToTap:   () => _pickDate(isFrom: false),
        ),
        const SizedBox(height: 10),

        Expanded(
          child: BlocBuilder<EngineHoursBloc, EngineHoursState>(
            builder: (context, state) {
              if (state is EngineHoursLoading) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: AppTokens.brandGradientStart));
              }
              if (state is EngineHoursError) {
                return _ErrorState(message: state.message, isTablet: false);
              }
              if (state is EngineHoursLoaded) {
                if (state.engineHoursRecords.isEmpty) {
                  return _EmptyState(isTablet: false);
                }
                return ListView.builder(
                  itemCount: state.engineHoursRecords.length,
                  itemBuilder: (context, index) => _EngineHoursCard(
                    record:   state.engineHoursRecords[index],
                    isTablet: false,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ]),
    );
  }
}

// ─── Date Filter Bar ──────────────────────────────────────────────────────────
class _DateFilterBar extends StatelessWidget {
  final DateTime     fromDate;
  final DateTime     toDate;
  final bool         isTablet;
  final VoidCallback onFromTap;
  final VoidCallback onToTap;

  const _DateFilterBar({
    required this.fromDate,
    required this.toDate,
    required this.isTablet,
    required this.onFromTap,
    required this.onToTap,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy');

    if (isTablet) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DateButton(
            label:    'From',
            value:    fmt.format(fromDate),
            onTap:    onFromTap,
            isTablet: isTablet,
          ),
          const SizedBox(height: 10),
          _DateButton(
            label:    'To',
            value:    fmt.format(toDate),
            onTap:    onToTap,
            isTablet: isTablet,
          ),
        ],
      );
    }

    return Row(children: [
      Expanded(
        child: _DateButton(
          label:    'From',
          value:    fmt.format(fromDate),
          onTap:    onFromTap,
          isTablet: isTablet,
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: _DateButton(
          label:    'To',
          value:    fmt.format(toDate),
          onTap:    onToTap,
          isTablet: isTablet,
        ),
      ),
    ]);
  }
}

// ─── Date Button ──────────────────────────────────────────────────────────────
class _DateButton extends StatelessWidget {
  final String       label;
  final String       value;
  final VoidCallback onTap;
  final bool         isTablet;

  const _DateButton({
    required this.label,
    required this.value,
    required this.onTap,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 14 : 12,
          vertical:   isTablet ? 12 : 10,
        ),
        decoration: BoxDecoration(
          color:         colour.kWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppTokens.brandGradientStart.withOpacity(0.4),
              width: 1.5),
          boxShadow: [
            BoxShadow(
              color:      AppTokens.brandGradientStart.withOpacity(0.07),
              blurRadius: 8,
              offset:     const Offset(0, 3),
            ),
          ],
        ),
        child: Row(children: [
          Icon(Icons.calendar_today_rounded,
              size:  isTablet ? 16 : 14,
              color: AppTokens.brandGradientStart),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.lato(
                    fontSize:      isTablet ? 11 : 10,
                    color:         Colors.grey[500],
                    fontWeight:    FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.lato(
                    fontSize:   isTablet ? 13 : 12,
                    fontWeight: FontWeight.bold,
                    color:      AppTokens.brandDark,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_drop_down_rounded,
              color: AppTokens.brandGradientStart,
              size:  isTablet ? 20 : 18),
        ]),
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
      padding: const EdgeInsets.symmetric(
          horizontal: 20, vertical: 18),
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
          child: const Icon(Icons.timer_rounded,
              color: colour.kWhite, size: 22),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Records',
                style: GoogleFonts.lato(
                  fontSize:   12,
                  color:      colour.kWhite.withOpacity(0.75),
                  fontWeight: FontWeight.w500,
                )),
            Text('$count',
                style: GoogleFonts.lato(
                  fontSize:   28,
                  color:      colour.kWhite,
                  fontWeight: FontWeight.bold,
                )),
          ],
        ),
      ]),
    );
  }
}

// ─── Engine Hours Card ────────────────────────────────────────────────────────
class _EngineHoursCard extends StatelessWidget {
  final EngineHoursdata record;
  final bool isTablet;
  const _EngineHoursCard(
      {required this.record, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetailsDialog(context),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: isTablet ? 6 : 8),
        decoration: BoxDecoration(
          color:         colour.kWhite,
          borderRadius: BorderRadius.circular(isTablet ? 18 : 16),
          border: Border.all(color: AppTokens.brandLight, width: 1.5),
          boxShadow: [
            BoxShadow(
              color:     AppTokens.brandGradientStart.withOpacity(0.08),
              blurRadius: 10,
              offset:    const Offset(0, 4),
            ),
          ],
        ),
        child: Row(children: [
          // ── Left panel
          Container(
            width: isTablet ? 80 : 70,
            padding: EdgeInsets.symmetric(
                vertical: isTablet ? 22 : 20),
            decoration: const BoxDecoration(
              color: AppTokens.brandLight,
              borderRadius: BorderRadius.only(
                topLeft:    Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Container(
                width:  isTablet ? 50 : 44,
                height: isTablet ? 50 : 44,
                decoration: const BoxDecoration(
                  color: AppTokens.brandGradientStart,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.timer_rounded,
                    color: colour.kWhite,
                    size:  isTablet ? 26 : 22),
              ),
            ),
          ),

          // ── Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 18 : 14,
                vertical:   isTablet ? 18 : 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.TruckName ?? "-",
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize:   isTablet ? 17 : 16,
                      color:      AppTokens.brandDark,
                    ),
                  ),
                  SizedBox(height: isTablet ? 8 : 6),
                  Row(children: [
                    Icon(Icons.speed_rounded,
                        size:  isTablet ? 16 : 14,
                        color: AppTokens.brandMid),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        "Mileage: ${record.mileage.isNotEmpty ? record.mileage : 'Not Available'}",
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lato(
                          fontSize: isTablet ? 14 : 13,
                          color:    Colors.grey[600],
                        ),
                      ),
                    ),
                  ]),
                  SizedBox(height: isTablet ? 8 : 6),
                  Row(children: [
                    Flexible(
                      child: _MiniChip(
                        icon:      Icons.play_arrow_rounded,
                        label:     record.beginTime.isNotEmpty
                            ? record.beginTime
                            : "N/A",
                        bgColor:   AppTokens.brandGradientStart.withOpacity(0.1),
                        textColor: AppTokens.brandGradientStart,
                        isTablet:  isTablet,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: _MiniChip(
                        icon:      Icons.stop_rounded,
                        label:     record.endTime.isNotEmpty
                            ? record.endTime
                            : "N/A",
                        bgColor:   Colors.orange.withOpacity(0.1),
                        textColor: Colors.orange.shade700,
                        isTablet:  isTablet,
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),

          // ── Arrow
          Padding(
            padding: EdgeInsets.only(right: isTablet ? 16 : 14),
            child: Container(
              width:  isTablet ? 36 : 32,
              height: isTablet ? 36 : 32,
              decoration: BoxDecoration(
                color:         AppTokens.brandLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.arrow_forward_ios_rounded,
                  size:  isTablet ? 16 : 14,
                  color: AppTokens.brandGradientStart),
            ),
          ),
        ]),
      ),
    );
  }

  void _showDetailsDialog(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    showGeneralDialog(
      context:            context,
      barrierDismissible: true,
      barrierLabel:       '',
      barrierColor:       Colors.black54,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, __, ___) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: isTablet
                ? 480
                : MediaQuery.of(context).size.width * 0.88,
            decoration: BoxDecoration(
              color:         colour.kWhite,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color:     AppTokens.brandGradientStart.withOpacity(0.18),
                  blurRadius: 30,
                  offset:    const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical:   isTablet ? 22 : 20,
                    horizontal: isTablet ? 28 : 24,
                  ),
                  decoration: const BoxDecoration(
                    color: AppTokens.brandGradientStart,
                    borderRadius: BorderRadius.only(
                      topLeft:  Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(children: [
                    Icon(Icons.timer_rounded,
                        color: colour.kWhite,
                        size:  isTablet ? 28 : 26),
                    const SizedBox(width: 12),
                    Text("Engine Hours Details",
                        style: GoogleFonts.lato(
                          fontSize:   isTablet ? 22 : 20,
                          fontWeight: FontWeight.bold,
                          color:      colour.kWhite,
                        )),
                  ]),
                ),

                // Body
                Padding(
                  padding: EdgeInsets.all(isTablet ? 28 : 24),
                  child: Column(children: [
                    _buildInfoRow(Icons.local_shipping_rounded,
                        "Truck Name", record.TruckName,
                        isTablet: isTablet),
                    _buildDivider(),
                    _buildInfoRow(Icons.play_arrow_rounded,
                        "Begin Time",
                        record.beginTime.isNotEmpty
                            ? record.beginTime
                            : null,
                        isTablet: isTablet),
                    _buildDivider(),
                    _buildInfoRow(Icons.stop_rounded, "End Time",
                        record.endTime.isNotEmpty
                            ? record.endTime
                            : null,
                        isTablet: isTablet),
                    _buildDivider(),
                    _buildInfoRow(Icons.place_rounded,
                        "Begin Location",
                        record.beginLocation.isNotEmpty
                            ? record.beginLocation
                            : null,
                        isTablet: isTablet),
                    _buildDivider(),
                    _buildInfoRow(Icons.flag_rounded,
                        "End Location",
                        record.endLocation.isNotEmpty
                            ? record.endLocation
                            : null,
                        isTablet: isTablet),
                    _buildDivider(),
                    _buildInfoRow(Icons.timer_rounded,
                        "Total Time",
                        record.totalTime.isNotEmpty
                            ? record.totalTime
                            : null,
                        isTablet: isTablet),
                    _buildDivider(),
                    _buildInfoRow(Icons.pause_circle_rounded,
                        "Idling",
                        record.idling.isNotEmpty
                            ? record.idling
                            : null,
                        isTablet: isTablet),
                    SizedBox(height: isTablet ? 28 : 24),

                    // Close button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTokens.brandGradientStart,
                          padding: EdgeInsets.symmetric(
                              vertical: isTablet ? 16 : 14),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: () =>
                            Navigator.of(context).pop(),
                        child: Text("Close",
                            style: GoogleFonts.lato(
                              color:      colour.kWhite,
                              fontSize:   isTablet ? 17 : 16,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
      transitionBuilder: (_, anim, __, child) => ScaleTransition(
        scale: CurvedAnimation(
            parent: anim, curve: Curves.easeOutBack),
        child: FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  Widget _buildDivider() =>
      Divider(color: AppTokens.brandLight, thickness: 1.5, height: 24);

  Widget _buildInfoRow(
      IconData icon, String label, String? value,
      {required bool isTablet}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width:  isTablet ? 40 : 36,
          height: isTablet ? 40 : 36,
          decoration: BoxDecoration(
            color:         AppTokens.brandLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon,
              color: AppTokens.brandGradientStart,
              size:  isTablet ? 20 : 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.lato(
                    fontSize:      isTablet ? 13 : 12,
                    color:         Colors.grey[500],
                    fontWeight:    FontWeight.w600,
                    letterSpacing: 0.5,
                  )),
              const SizedBox(height: 2),
              Text(
                value?.isNotEmpty == true
                    ? value!
                    : "Not Available",
                style: GoogleFonts.lato(
                  fontSize:   isTablet ? 16 : 15,
                  fontWeight: FontWeight.w700,
                  color:      AppTokens.brandDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Mini Chip ────────────────────────────────────────────────────────────────
class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Color    bgColor;
  final Color    textColor;
  final bool     isTablet;

  const _MiniChip({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.textColor,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 10 : 8,
        vertical:   isTablet ? 5  : 4,
      ),
      decoration: BoxDecoration(
        color:         bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size:  isTablet ? 14 : 12,
              color: textColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: GoogleFonts.lato(
                fontSize:   isTablet ? 12 : 11,
                fontWeight: FontWeight.bold,
                color:      textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Error State ──────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String message;
  final bool   isTablet;
  const _ErrorState(
      {required this.message, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline,
              color: Colors.red,
              size:  isTablet ? 60 : 48),
          SizedBox(height: isTablet ? 16 : 12),
          Text(message,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                  color:    Colors.red,
                  fontSize: isTablet ? 15 : 14)),
          SizedBox(height: isTablet ? 20 : 16),
          ElevatedButton.icon(
            onPressed: () => context
                .read<EngineHoursBloc>()
                .add(LoadEngineHoursReport()),
            icon:  Icon(Icons.refresh,
                size: isTablet ? 20 : 18),
            label: Text("Retry",
                style: GoogleFonts.lato(
                    fontSize: isTablet ? 15 : 14)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTokens.brandGradientStart,
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 28 : 20,
                vertical:   isTablet ? 12 : 10,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
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
      child: Text(
        "No engine hours records found.",
        style: GoogleFonts.lato(
          fontSize: isTablet ? 18 : 16,
          color:    Colors.grey,
        ),
      ),
    );
  }
}