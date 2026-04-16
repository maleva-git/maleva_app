import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

import '../bloc/driverlicense_bloc.dart';
import '../bloc/driverlicense_event.dart';
import '../bloc/driverlicense_state.dart';



// ─── Design Tokens ────────────────────────────────────────────────────────────
const kHeaderGradStart = Color(0xFF1A3A8F);
const kHeaderGradEnd   = Color(0xFF4A6FD4);
const kCardBorder      = Color(0xFFC5D0EE);
const kPageBg          = Color(0xFFF4F6FB);
const kTextDark        = Color(0xFF1E2D5E);
const kTextMid         = Color(0xFF4A5A8A);
const kTextMuted       = Color(0xFF8A96BF);
const kDetailBg        = Color(0xFFF0F4FF);
const kChipBg          = Color(0xFFEEF2FF);
const kAccentRed       = Color(0xFFB33040);

const kGradient = LinearGradient(
  colors: [kHeaderGradStart, kHeaderGradEnd],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const double kTabletBreak = 600;

// All 11 field keys shown in each driver card (label + map key)
const List<(String, String)> kDriverFields = [
  ('License Exp',   'licenseExp'),
  ('GDL Exp',       'GDLExp'),
  ('Kuantan Port',  'KuantanPort'),
  ('Northport',     'NorthportPort'),
  ('PKFZ Port',     'PkfzPort'),
  ('KLIA Port',     'KliaPort'),
  ('PGU Port',      'PguPort'),
  ('Tanjung Port',  'TanjungPort'),
  ('Penang Port',   'PenangPort'),
  ('PTP Port',      'PtpPort'),
  ('Westport',      'WestportPort'),
];

// ─── Embeddable Dashboard Widget ─────────────────────────────────────────────
class DriverLicenseExpiryWidget extends StatelessWidget {
  const DriverLicenseExpiryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DriverLicenseExpiryBloc()
        ..add(DriverLicenseExpiryStarted()),
      child: const _DriverLicenseExpiryView(),
    );
  }
}

// ─── View ─────────────────────────────────────────────────────────────────────
class _DriverLicenseExpiryView extends StatelessWidget {
  const _DriverLicenseExpiryView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverLicenseExpiryBloc,
        DriverLicenseExpiryState>(
      builder: (context, state) {
        if (state is DriverLicenseExpiryInitial ||
            state is DriverLicenseExpiryLoading) {
          return const Center(
            child: SpinKitFoldingCube(
                color: kHeaderGradEnd, size: 35),
          );
        }
        if (state is DriverLicenseExpiryLoaded) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isTablet =
                  constraints.maxWidth > kTabletBreak;
              return _DriverLicenseExpiryBody(
                state:    state,
                isTablet: isTablet,
              );
            },
          );
        }
        if (state is DriverLicenseExpiryError) {
          return Center(
            child: Text(state.message,
                style: GoogleFonts.lato(
                    color: kAccentRed, fontSize: 13)),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────
class _DriverLicenseExpiryBody extends StatelessWidget {
  final DriverLicenseExpiryLoaded state;
  final bool isTablet;

  const _DriverLicenseExpiryBody(
      {required this.state, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          isTablet ? 20 : 10, 15, isTablet ? 20 : 10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 7),

          // ── Title ─────────────────────────────────────
          Center(
            child: Text(
              'DRIVER LICENSE EXPIRY',
              style: GoogleFonts.lato(
                color: kAccentRed,
                fontWeight: FontWeight.w700,
                fontSize: isTablet
                    ? objfun.FontLarge + 2
                    : objfun.FontLarge,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ── List / Grid ──────────────────────────────
          Expanded(
            child: state.driverExpiryList.isEmpty
                ? _EmptyState(isTablet: isTablet)
                : isTablet
                ? _TabletGrid(state: state)
                : _MobileList(state: state),
          ),
        ],
      ),
    );
  }
}

// ─── Mobile: single column ListView ──────────────────────────────────────────
class _MobileList extends StatelessWidget {
  final DriverLicenseExpiryLoaded state;
  const _MobileList({required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: state.driverExpiryList.length,
      itemBuilder: (ctx, i) => _DriverCard(
        item:     state.driverExpiryList[i],
        isTablet: false,
      ),
    );
  }
}

// ─── Tablet: 2-column GridView ────────────────────────────────────────────────
class _TabletGrid extends StatelessWidget {
  final DriverLicenseExpiryLoaded state;
  const _TabletGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:   2,
        crossAxisSpacing: 12,
        mainAxisSpacing:  12,
        childAspectRatio: 0.70,
      ),
      itemCount: state.driverExpiryList.length,
      itemBuilder: (ctx, i) => _DriverCard(
        item:     state.driverExpiryList[i],
        isTablet: true,
      ),
    );
  }
}

// ─── Single Driver Card ───────────────────────────────────────────────────────
class _DriverCard extends StatelessWidget {
  final dynamic item; // Map<String, dynamic>
  final bool    isTablet;

  const _DriverCard(
      {required this.item, required this.isTablet});

  String _safe(dynamic v) =>
      (v == null || v.toString() == 'null') ? '' : v.toString();

  @override
  Widget build(BuildContext context) {
    final labelStyle = GoogleFonts.lato(
      color: kTextMid,
      fontWeight: FontWeight.w600,
      fontSize:
      isTablet ? objfun.FontLow + 1 : objfun.FontLow,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kCardBorder, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: kHeaderGradStart.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Top gradient accent ──────────────────────
            Container(
                height: 3,
                decoration: const BoxDecoration(
                    gradient: kGradient)),

            // ── Driver name header ───────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 9),
              decoration: const BoxDecoration(
                  gradient: kGradient),
              child: Row(
                children: [
                  const Icon(Icons.person_outline_rounded,
                      size: 16, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _safe(item['DriverName']).isEmpty
                          ? '-'
                          : _safe(item['DriverName']),
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: isTablet
                            ? objfun.FontLow + 1
                            : objfun.FontLow,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // ── All 11 field rows ────────────────────────
            ...kDriverFields.map((f) => _FieldRow(
              label:      f.$1,
              value:      _safe(item[f.$2]),
              labelStyle: labelStyle,
            )),

            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}

// ─── Single Field Row ─────────────────────────────────────────────────────────
class _FieldRow extends StatelessWidget {
  final String    label;
  final String    value;
  final TextStyle labelStyle;

  const _FieldRow({
    required this.label,
    required this.value,
    required this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 5),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label,
                style: labelStyle,
                overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.isEmpty ? '-' : value,
              style: GoogleFonts.lato(
                color: kTextDark,
                fontWeight: FontWeight.w600,
                fontSize: labelStyle.fontSize,
              ),
              overflow: TextOverflow.ellipsis,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
                color: kChipBg,
                borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.badge_outlined,
                size: 32, color: kHeaderGradEnd),
          ),
          const SizedBox(height: 14),
          Text('No Driver Records',
              style: GoogleFonts.lato(
                  color: kTextDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 15)),
        ],
      ),
    );
  }
}