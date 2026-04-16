import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/models/model.dart';

import '../bloc/drivermaintenance_bloc.dart';
import '../bloc/drivermaintenance_event.dart';
import '../bloc/drivermaintenance_state.dart';

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
const kExpiredRed      = Color(0xFFD32F2F);

const kGradient = LinearGradient(
  colors: [kHeaderGradStart, kHeaderGradEnd],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const double kTabletBreak = 600;

// ─── Embeddable Dashboard Widget ─────────────────────────────────────────────
// Usage inside dashboard tab:
//   child: const TruckMaintenanceDashboardWidget()
class TruckMaintenanceDashboardWidget extends StatelessWidget {
  const TruckMaintenanceDashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      TruckMaintDashBloc()..add(TruckMaintDashStarted()),
      child: const _TruckMaintDashView(),
    );
  }
}

// ─── View ─────────────────────────────────────────────────────────────────────
class _TruckMaintDashView extends StatelessWidget {
  const _TruckMaintDashView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TruckMaintDashBloc, TruckMaintDashState>(
      builder: (context, state) {
        if (state is TruckMaintDashInitial ||
            state is TruckMaintDashLoading) {
          return const Center(
            child: SpinKitFoldingCube(
                color: kHeaderGradEnd, size: 35),
          );
        }
        if (state is TruckMaintDashLoaded) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth > kTabletBreak;
              return _TruckMaintDashBody(
                  state: state, isTablet: isTablet);
            },
          );
        }
        if (state is TruckMaintDashError) {
          return Center(
            child: Text(state.message,
                style: GoogleFonts.lato(
                    color: kExpiredRed, fontSize: 13)),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────
class _TruckMaintDashBody extends StatelessWidget {
  final TruckMaintDashLoaded state;
  final bool isTablet;

  const _TruckMaintDashBody(
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

          // ── Title ────────────────────────────────────────
          Center(
            child: Text(
              'TRUCK MAINTENANCE',
              style: GoogleFonts.lato(
                color: kExpiredRed,
                fontWeight: FontWeight.w700,
                fontSize: isTablet
                    ? objfun.FontLarge + 2
                    : objfun.FontLarge,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ── List / Grid ───────────────────────────────────
          Expanded(
            child: state.truckDetails.isEmpty
                ? _EmptyState(isTablet: isTablet)
                : isTablet
                ? _TabletCardGrid(state: state)
                : _MobileCardList(state: state),
          ),
        ],
      ),
    );
  }
}

// ─── Mobile: single column ListView ──────────────────────────────────────────
class _MobileCardList extends StatelessWidget {
  final TruckMaintDashLoaded state;
  const _MobileCardList({required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: state.truckDetails.length,
      itemBuilder: (ctx, i) => _TruckDashCard(
        item:     state.truckDetails[i],
        state:    state,
        isTablet: false,
      ),
    );
  }
}

// ─── Tablet: 2-column GridView ────────────────────────────────────────────────
class _TabletCardGrid extends StatelessWidget {
  final TruckMaintDashLoaded state;
  const _TabletCardGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:   2,
        crossAxisSpacing: 12,
        mainAxisSpacing:  12,
        childAspectRatio: 0.65,
      ),
      itemCount: state.truckDetails.length,
      itemBuilder: (ctx, i) => _TruckDashCard(
        item:     state.truckDetails[i],
        state:    state,
        isTablet: true,
      ),
    );
  }
}

// ─── Single Truck Card ────────────────────────────────────────────────────────
class _TruckDashCard extends StatelessWidget {
  final TruckDetailsModel      item;
  final TruckMaintDashLoaded   state;
  final bool                   isTablet;

  const _TruckDashCard({
    required this.item,
    required this.state,
    required this.isTablet,
  });

  // ── Expiry color helpers ──────────────────────────────────────────────────
  Color _expColor(String date) =>
      _isExpired(date, state.expDate) ? kExpiredRed : kTextDark;

  Color _apadBonamColor(String date) =>
      _isExpired(date, state.expApadBonam) ? kExpiredRed : kTextDark;

  Color _serviceAlignGreeceColor(String date) =>
      _isExpired(date, state.expServiceAlignGreece)
          ? kExpiredRed
          : kTextDark;

  bool _isExpired(String licenseDate, String threshold) {
    if (threshold.isEmpty ||
        licenseDate == 'null' ||
        licenseDate.isEmpty) return false;
    try {
      final lic =
      DateFormat('yyyy/MM/dd').parse(licenseDate);
      final thr =
      DateFormat('yyyy-MM-dd').parse(threshold);
      return lic.isBefore(thr) ||
          lic.isAtSameMomentAs(thr);
    } catch (_) {
      return false;
    }
  }

  String _safe(String v) =>
      (v == 'null' || v.isEmpty) ? '' : v;

  @override
  Widget build(BuildContext context) {
    final labelStyle = GoogleFonts.lato(
      color: kTextMid,
      fontWeight: FontWeight.w600,
      fontSize: isTablet ? objfun.FontLow + 1 : objfun.FontLow,
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
            // ── Top gradient accent ─────────────────────
            Container(
                height: 3,
                decoration:
                const BoxDecoration(gradient: kGradient)),

            // ── Expiry note ─────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 13, color: kTextMuted),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'Expiry till: ${state.expDate}',
                      style: GoogleFonts.lato(
                          color: kTextMuted,
                          fontWeight: FontWeight.w500,
                          fontSize: isTablet ? 12 : 10),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: kDetailBg),

            // ── Truck 1 header ──────────────────────────
            _SectionHeader(
                label: 'Truck 1',
                value: item.TruckNumber,
                isTablet: isTablet),

            _FieldRow('RotexMy Exp',  _safe(item.RotexMyExp),   _expColor(item.RotexMyExp),   labelStyle),
            _FieldRow('RotexSG Exp',  _safe(item.RotexSGExp),   _expColor(item.RotexSGExp),   labelStyle),
            _FieldRow('PushpaCom',    _safe(item.PuspacomExp),  _expColor(item.PuspacomExp),  labelStyle),
            _FieldRow('Insurance',    _safe(item.InsuratnceExp),_expColor(item.InsuratnceExp),labelStyle),
            _FieldRow('Bonam Exp',    _safe(item.BonamExp),     _apadBonamColor(item.BonamExp), labelStyle),
            _FieldRow('Apad Exp',     _safe(item.ApadExp),      _apadBonamColor(item.ApadExp),  labelStyle),

            // ── Truck 2 header ──────────────────────────
            _SectionHeader(
                label: 'Truck 2',
                value: _safe(item.TruckNumber1),
                isTablet: isTablet),

            _FieldRow('RotexMy1',     _safe(item.RotexMyExp1),  _expColor(item.RotexMyExp1),  labelStyle),
            _FieldRow('RotexSG1',     _safe(item.RotexSGExp1),  _expColor(item.RotexSGExp1),  labelStyle),
            _FieldRow('PushpaCom1',   _safe(item.PuspacomExp1), _expColor(item.PuspacomExp1), labelStyle),
            _FieldRow('Service Exp',  _safe(item.ServiceExp),   _serviceAlignGreeceColor(item.ServiceExp),  labelStyle),
            _FieldRow('Service Last', _safe(item.ServiceLast),  kTextDark, labelStyle),
            _FieldRow('AlignmentExp', _safe(item.AlignmentExp), _serviceAlignGreeceColor(item.AlignmentExp), labelStyle),
            _FieldRow('AlignmentLast',_safe(item.AlignmentLast),kTextDark, labelStyle),
            _FieldRow('Greece Exp',   _safe(item.GreeceExp),    _serviceAlignGreeceColor(item.GreeceExp),   labelStyle),
            _FieldRow('Greece Last',  _safe(item.GreeceLast),   kTextDark, labelStyle),
            _FieldRow('GearOil Exp',  _safe(item.GearOilExp),   _serviceAlignGreeceColor(item.GearOilExp),  labelStyle),
            _FieldRow('GearOil Last', _safe(item.GearOilLast),  kTextDark, labelStyle),
            _FieldRow('PTPSticker',   _safe(item.PTPStickerExp),_serviceAlignGreeceColor(item.PTPStickerExp), labelStyle),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─── Section Header (Truck 1 / Truck 2) ──────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  final String value;
  final bool   isTablet;

  const _SectionHeader({
    required this.label,
    required this.value,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 8),
      decoration:
      const BoxDecoration(gradient: kGradient),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.lato(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: isTablet
                    ? objfun.FontLow + 1
                    : objfun.FontLow,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.isEmpty ? '-' : value,
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
    );
  }
}

// ─── Single Field Row ─────────────────────────────────────────────────────────
class _FieldRow extends StatelessWidget {
  final String    label;
  final String    value;
  final Color     valueColor;
  final TextStyle labelStyle;

  const _FieldRow(
      this.label, this.value, this.valueColor, this.labelStyle);

  @override
  Widget build(BuildContext context) {
    final isExpired = valueColor == kExpiredRed;

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 5),
      color: isExpired
          ? kExpiredRed.withOpacity(0.06)
          : Colors.transparent,
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
            child: Row(
              children: [
                if (isExpired) ...[
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: kExpiredRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                ],
                Expanded(
                  child: Text(
                    value.isEmpty ? '-' : value,
                    style: GoogleFonts.lato(
                      color: valueColor,
                      fontWeight: FontWeight.w600,
                      fontSize: labelStyle.fontSize,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
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
            child: const Icon(
                Icons.local_shipping_outlined,
                size: 32,
                color: kHeaderGradEnd),
          ),
          const SizedBox(height: 14),
          Text('No Truck Data',
              style: GoogleFonts.lato(
                  color: kTextDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 15)),
        ],
      ),
    );
  }
}