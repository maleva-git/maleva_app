import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/app_globals.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/palette.dart';
import '../bloc/drivermaintenance_bloc.dart';
import '../bloc/drivermaintenance_event.dart';
import '../bloc/drivermaintenance_state.dart';
import 'package:maleva/core/models/shared/truck_details_model.dart';




const kGradient = LinearGradient(
  colors: [Palette.blue700, Palette.blue400],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const double kTabletBreak = 600;

class TruckMaintenanceDashboardWidget extends StatelessWidget {
  final bool showHeading;
  const TruckMaintenanceDashboardWidget({super.key, this.showHeading = true});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<TruckMaintDashBloc>()..add(TruckMaintDashStarted()),
      child: TruckMaintDashView(showHeading: showHeading),
    );
  }
}

class TruckMaintDashView extends StatelessWidget {
  final bool showHeading;
  const TruckMaintDashView({super.key, this.showHeading = true});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TruckMaintDashBloc, TruckMaintDashState>(
      builder: (context, state) {

        // Use this to debug if the state is getting stuck
        debugPrint("Current TruckMaintDashState: $state");

        if (state is TruckMaintDashInitial || state is TruckMaintDashLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: SpinKitFoldingCube(color: Palette.blue400, size: 35),
            ),
          );
        }
        else if (state is TruckMaintDashLoaded) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth > kTabletBreak;
              return _TruckMaintDashBody(state: state, isTablet: isTablet, showHeading: showHeading);
            },
          );
        }
        else if (state is TruckMaintDashError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                state.message,
                style: GoogleFonts.lato(color: Palette.kExpiredRed, fontSize: 13),
              ),
            ),
          );
        }

        // Catch-all Fallback
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.red),
          ),
          child: Text(
            'Unhandled State Error: $state\nPlease check your Bloc logic.',
            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}

class _TruckMaintDashBody extends StatelessWidget {
  final TruckMaintDashLoaded state;
  final bool isTablet;
  final bool showHeading;

  const _TruckMaintDashBody({required this.state, required this.isTablet, required this.showHeading});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(isTablet ? 20 : 10, 15, isTablet ? 20 : 10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 7),

          if (showHeading)
            Center(
              child: Text(
                'TRUCK MAINTENANCE',
                style: GoogleFonts.lato(
                  color: Palette.kExpiredRed,
                  fontWeight: FontWeight.w700,
                  fontSize: isTablet ? AppGlobals.FontLarge + 2 : AppGlobals.FontLarge,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          if (showHeading)
            const SizedBox(height: 14),

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

class _MobileCardList extends StatelessWidget {
  final TruckMaintDashLoaded state;
  const _MobileCardList({required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(

      itemCount: state.truckDetails.length,
      itemBuilder: (ctx, i) => _TruckDashCard(
        item: state.truckDetails[i],
        state: state,
        isTablet: false,
      ),
    );
  }
}

class _TabletCardGrid extends StatelessWidget {
  final TruckMaintDashLoaded state;
  const _TabletCardGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(

      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.65,
      ),
      itemCount: state.truckDetails.length,
      itemBuilder: (ctx, i) => _TruckDashCard(
        item: state.truckDetails[i],
        state: state,
        isTablet: true,
      ),
    );
  }
}


class _TruckDashCard extends StatelessWidget {
  final TruckDetailsModel item;
  final TruckMaintDashLoaded state;
  final bool isTablet;

  const _TruckDashCard({
    required this.item,
    required this.state,
    required this.isTablet,
  });

  Color _expColor(String date) =>
      _isExpired(date, state.expDate) ? Palette.kExpiredRed : Palette.textDark2;

  Color _apadBonamColor(String date) =>
      _isExpired(date, state.expApadBonam) ? Palette.kExpiredRed : Palette.textDark2;

  Color _serviceAlignGreeceColor(String date) =>
      _isExpired(date, state.expServiceAlignGreece) ? Palette.kExpiredRed : Palette.textDark2;

  bool _isExpired(String licenseDate, String threshold) {
    if (threshold.isEmpty || licenseDate == 'null' || licenseDate.isEmpty) return false;
    try {
      final lic = DateFormat('yyyy/MM/dd').parse(licenseDate);
      final thr = DateFormat('yyyy-MM-dd').parse(threshold);
      return lic.isBefore(thr) || lic.isAtSameMomentAs(thr);
    } catch (_) {
      return false;
    }
  }

  String _safe(String v) => (v == 'null' || v.isEmpty) ? '' : v;

  @override
  Widget build(BuildContext context) {
    final labelStyle = GoogleFonts.lato(
      color: Palette.textMid,
      fontWeight: FontWeight.w600,
      fontSize: isTablet ? AppGlobals.FontLow + 1 : AppGlobals.FontLow,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Palette.cardBorder, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Palette.blue700.withValues(alpha: 0.07),
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
            Container(height: 3, decoration: const BoxDecoration(gradient: kGradient)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 13, color: Palette.kTextMuted),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'Expiry till: ${state.expDate}',
                      style: GoogleFonts.lato(
                          color: Palette.kTextMuted,
                          fontWeight: FontWeight.w500,
                          fontSize: isTablet ? 12 : 10),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Palette.grey200p),
            _SectionHeader(label: 'Truck 1', value: item.TruckNumber, isTablet: isTablet),
            _FieldRow('RotexMy Exp', _safe(item.RotexMyExp), _expColor(item.RotexMyExp), labelStyle),
            _FieldRow('RotexSG Exp', _safe(item.RotexSGExp), _expColor(item.RotexSGExp), labelStyle),
            _FieldRow('PushpaCom', _safe(item.PuspacomExp), _expColor(item.PuspacomExp), labelStyle),
            _FieldRow('Insurance', _safe(item.InsuratnceExp), _expColor(item.InsuratnceExp), labelStyle),
            _FieldRow('Bonam Exp', _safe(item.BonamExp), _apadBonamColor(item.BonamExp), labelStyle),
            _FieldRow('Apad Exp', _safe(item.ApadExp), _apadBonamColor(item.ApadExp), labelStyle),
            _SectionHeader(label: 'Truck 2', value: _safe(item.TruckNumber1), isTablet: isTablet),
            _FieldRow('RotexMy1', _safe(item.RotexMyExp1), _expColor(item.RotexMyExp1), labelStyle),
            _FieldRow('RotexSG1', _safe(item.RotexSGExp1), _expColor(item.RotexSGExp1), labelStyle),
            _FieldRow('PushpaCom1', _safe(item.PuspacomExp1), _expColor(item.PuspacomExp1), labelStyle),
            _FieldRow('Service Exp', _safe(item.ServiceExp), _serviceAlignGreeceColor(item.ServiceExp), labelStyle),
            _FieldRow('Service Last', _safe(item.ServiceLast), Palette.textDark2, labelStyle),
            _FieldRow('AlignmentExp', _safe(item.AlignmentExp), _serviceAlignGreeceColor(item.AlignmentExp), labelStyle),
            _FieldRow('AlignmentLast', _safe(item.AlignmentLast), Palette.textDark2, labelStyle),
            _FieldRow('Greece Exp', _safe(item.GreeceExp), _serviceAlignGreeceColor(item.GreeceExp), labelStyle),
            _FieldRow('Greece Last', _safe(item.GreeceLast), Palette.textDark2, labelStyle),
            _FieldRow('GearOil Exp', _safe(item.GearOilExp), _serviceAlignGreeceColor(item.GearOilExp), labelStyle),
            _FieldRow('GearOil Last', _safe(item.GearOilLast), Palette.textDark2, labelStyle),
            _FieldRow('PTPSticker', _safe(item.PTPStickerExp), _serviceAlignGreeceColor(item.PTPStickerExp), labelStyle),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final String value;
  final bool isTablet;

  const _SectionHeader({required this.label, required this.value, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(gradient: kGradient),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.lato(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: isTablet ? AppGlobals.FontLow + 1 : AppGlobals.FontLow,
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
                fontSize: isTablet ? AppGlobals.FontLow + 1 : AppGlobals.FontLow,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final TextStyle labelStyle;

  const _FieldRow(this.label, this.value, this.valueColor, this.labelStyle);

  @override
  Widget build(BuildContext context) {
    final isExpired = valueColor == Palette.kExpiredRed;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      color: isExpired ? Palette.kExpiredRed.withValues(alpha: 0.06) : Colors.transparent,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: labelStyle, overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                if (isExpired) ...[
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(color: Palette.kExpiredRed, shape: BoxShape.circle),
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

class _EmptyState extends StatelessWidget {
  final bool isTablet;
  const _EmptyState({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: Palette.grey200q, borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.local_shipping_outlined, size: 32, color: Palette.blue400),
          ),
          const SizedBox(height: 14),
          Text('No Truck Data',
              style: GoogleFonts.lato(color: Palette.textDark2, fontWeight: FontWeight.w600, fontSize: 15)),
        ],
      ),
    );
  }
}