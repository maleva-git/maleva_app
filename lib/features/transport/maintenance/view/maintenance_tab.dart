import 'package:flutter/Material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../MasterSearch/Truck.dart';
import '../../../../core/models/model.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/clsfunction.dart' as objfun;
import '../../../../menu/menulist.dart';
import '../bloc/maintenance_bloc.dart';
import '../bloc/maintenance_event.dart';
import '../bloc/maintenance_state.dart';




const kGradient = LinearGradient(
  colors: [AppTokens.invoiceHeaderStart, AppTokens.invoiceHeaderEnd],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// LayoutBuilder breakpoint: <= 600 = mobile, > 600 = tablet
const double kTabletBreak = 600;

// ─── Root ─────────────────────────────────────────────────────────────────────
class Maintenance extends StatelessWidget {
  const Maintenance({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      TruckMaintenanceBloc()..add(TruckMaintenanceStarted()),
      child: const _MaintenancePage(),
    );
  }
}

// ─── Page ─────────────────────────────────────────────────────────────────────
class _MaintenancePage extends StatelessWidget {
  const _MaintenancePage();

  @override
  Widget build(BuildContext context) {
    final userName = objfun.storagenew.getString('Username') ?? '';

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppTokens.invoicePageBg,
        appBar: _buildAppBar(context, userName),
        drawer: const Menulist(),
        body: BlocBuilder<TruckMaintenanceBloc, TruckMaintenanceState>(
          builder: (context, state) {
            if (state is TruckMaintenanceInitial ||
                state is TruckMaintenanceLoading) {
              return const Center(
                child: SpinKitFoldingCube(color: AppTokens.invoiceHeaderEnd, size: 35),
              );
            }
            if (state is TruckMaintenanceLoaded) {
              return _MaintenanceBody(state: state);
            }
            if (state is TruckMaintenanceError) {
              return Center(
                child: Text(state.message,
                    style: GoogleFonts.lato(color: AppTokens.kExpiredRed)),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, String userName) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      toolbarHeight: 62,
      flexibleSpace:
      Container(decoration: const BoxDecoration(gradient: kGradient)),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        color: Colors.white,
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Truck Maintenance',
              style: GoogleFonts.lato(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  letterSpacing: 0.3)),
          const SizedBox(height: 2),
          Text(userName,
              style: GoogleFonts.lato(
                  color: Colors.white.withOpacity(0.65),
                  fontWeight: FontWeight.w500,
                  fontSize: 12)),
        ],
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────
class _MaintenanceBody extends StatelessWidget {
  final TruckMaintenanceLoaded state;
  const _MaintenanceBody({required this.state});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > kTabletBreak;
        final hPad = isTablet ? constraints.maxWidth * 0.05 : 14.0;

        return Column(
          children: [
            // ── Truck selector (hidden for driver login) ─────────────
            if (state.visibleTruck)
              Padding(
                padding: EdgeInsets.fromLTRB(hPad, 14, hPad, 0),
                child: _TruckSelector(
                    state: state, isTablet: isTablet),
              ),

            const SizedBox(height: 8),

            // ── List ────────────────────────────────────────────────
            Expanded(
              child: state.truckDetails.isEmpty
                  ? _EmptyState()
                  : isTablet
                  ? _TruckDetailGridList(
                  state: state,
                  hPad: hPad,
                  constraints: constraints)
                  : _TruckDetailList(
                  state: state, hPad: hPad),
            ),
          ],
        );
      },
    );
  }
}

// ─── Truck Selector ───────────────────────────────────────────────────────────
class _TruckSelector extends StatelessWidget {
  final TruckMaintenanceLoaded state;
  final bool isTablet;
  const _TruckSelector(
      {required this.state, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (state.truckName.isEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                const Truck(Searchby: 1, SearchId: 0)),
          ).then((_) {
            final sel = objfun.SelectTruckList;
            if (sel.Id != 0) {
              context.read<TruckMaintenanceBloc>().add(
                  TruckMaintenanceTruckSelected(
                      truckId: sel.Id,
                      truckName: sel.AccountName));
              objfun.SelectTruckList = GetTruckModel.Empty();
            }
          });
        } else {
          context
              .read<TruckMaintenanceBloc>()
              .add(TruckMaintenanceTruckCleared());
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppTokens.maintDetailBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTokens.maintCardBorder, width: 0.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.local_shipping_outlined,
                size: 20, color: AppTokens.invoiceHeaderEnd),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                state.truckName.isEmpty
                    ? 'Select Truck No'
                    : state.truckName,
                style: GoogleFonts.lato(
                  color: state.truckName.isEmpty
                      ? AppTokens.planTextMuted
                      : AppTokens.maintTextDark,
                  fontWeight: state.truckName.isEmpty
                      ? FontWeight.w500
                      : FontWeight.w600,
                  fontSize: isTablet
                      ? objfun.FontLow + 1
                      : objfun.FontLow,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              state.truckName.isNotEmpty
                  ? Icons.close_rounded
                  : Icons.search_rounded,
              size: 20,
              color: AppTokens.invoiceHeaderEnd,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Mobile: single-column list of cards ─────────────────────────────────────
class _TruckDetailList extends StatelessWidget {
  final TruckMaintenanceLoaded state;
  final double hPad;
  const _TruckDetailList(
      {required this.state, required this.hPad});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 24),
      itemCount: state.truckDetails.length,
      itemBuilder: (ctx, i) => _TruckCard(
        item: state.truckDetails[i],
        state: state,
        isTablet: false,
      ),
    );
  }
}

// ─── Tablet: 2-column grid of cards ──────────────────────────────────────────
class _TruckDetailGridList extends StatelessWidget {
  final TruckMaintenanceLoaded state;
  final double hPad;
  final BoxConstraints constraints;

  const _TruckDetailGridList({
    required this.state,
    required this.hPad,
    required this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:   2,
        crossAxisSpacing: 12,
        mainAxisSpacing:  12,
        childAspectRatio: 0.72,
      ),
      itemCount: state.truckDetails.length,
      itemBuilder: (ctx, i) => _TruckCard(
        item: state.truckDetails[i],
        state: state,
        isTablet: true,
      ),
    );
  }
}

// ─── Truck Card ───────────────────────────────────────────────────────────────
class _TruckCard extends StatelessWidget {
  final TruckDetailsModel item;
  final TruckMaintenanceLoaded state;
  final bool isTablet;

  const _TruckCard(
      {required this.item,
        required this.state,
        required this.isTablet});

  // Expiry color helpers — pure functions, no setState needed
  Color _expColor(String date) =>
      _isExpired(date, state.expDate) ? AppTokens.kExpiredRed : AppTokens.maintTextDark;

  Color _apadBonamColor(String date) =>
      _isExpired(date, state.expApadBonam) ? AppTokens.kExpiredRed : AppTokens.maintTextDark;

  Color _serviceAlignGreeceColor(String date) =>
      _isExpired(date, state.expServiceAlignGreece)
          ? AppTokens.kExpiredRed
          : AppTokens.maintTextDark;

  bool _isExpired(String licenseDate, String threshold) {
    if (threshold.isEmpty || licenseDate == 'null' || licenseDate.isEmpty) {
      return false;
    }
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

  String _safe(String v) => v == 'null' ? '' : v;

  @override
  Widget build(BuildContext context) {
    final labelStyle = GoogleFonts.lato(
      color: AppTokens.maintTextMid,
      fontWeight: FontWeight.w600,
      fontSize: isTablet ? objfun.FontLow + 1 : objfun.FontLow,
    );

    // All field rows for this card
    final fields = [
      // Truck 1 header
      _FieldSection(
        isHeader: true,
        label: 'Truck 1',
        value: item.TruckNumber,
        valueColor: Colors.white,
        isTablet: isTablet,
      ),
      _FieldRow('RotexMy Exp',  _safe(item.RotexMyExp),  _expColor(item.RotexMyExp),  labelStyle),
      _FieldRow('RotexSG Exp',  _safe(item.RotexSGExp),  _expColor(item.RotexSGExp),  labelStyle),
      _FieldRow('PushpaCom',    _safe(item.PuspacomExp), _expColor(item.PuspacomExp), labelStyle),
      _FieldRow('Insurance',    _safe(item.InsuratnceExp),_expColor(item.InsuratnceExp),labelStyle),
      _FieldRow('Bonam Exp',    _safe(item.BonamExp),    _apadBonamColor(item.BonamExp),  labelStyle),
      _FieldRow('Apad Exp',     _safe(item.ApadExp),     _apadBonamColor(item.ApadExp),   labelStyle),
      // Truck 2 header
      _FieldSection(
        isHeader: true,
        label: 'Truck 2',
        value: _safe(item.TruckNumber1),
        valueColor: Colors.white,
        isTablet: isTablet,
      ),
      _FieldRow('RotexMy1',     _safe(item.RotexMyExp1),  _expColor(item.RotexMyExp1),  labelStyle),
      _FieldRow('RotexSG1',     _safe(item.RotexSGExp1),  _expColor(item.RotexSGExp1),  labelStyle),
      _FieldRow('PushpaCom1',   _safe(item.PuspacomExp1), _expColor(item.PuspacomExp1), labelStyle),
      _FieldRow('Service Exp',  _safe(item.ServiceExp),   _serviceAlignGreeceColor(item.ServiceExp),  labelStyle),
      _FieldRow('Service Last', _safe(item.ServiceLast),  AppTokens.maintTextDark, labelStyle),
      _FieldRow('AlignmentExp', _safe(item.AlignmentExp), _serviceAlignGreeceColor(item.AlignmentExp), labelStyle),
      _FieldRow('Alignment Last',_safe(item.AlignmentLast),AppTokens.maintTextDark, labelStyle),
      _FieldRow('Greece Exp',   _safe(item.GreeceExp),    _serviceAlignGreeceColor(item.GreeceExp),   labelStyle),
      _FieldRow('Greece Last',  _safe(item.GreeceLast),   AppTokens.maintTextDark, labelStyle),
      _FieldRow('GearOil Exp',  _safe(item.GearOilExp),   _serviceAlignGreeceColor(item.GearOilExp),  labelStyle),
      _FieldRow('GearOil Last', _safe(item.GearOilLast),  AppTokens.maintTextDark, labelStyle),
      _FieldRow('PTPSticker Exp',_safe(item.PTPStickerExp),_serviceAlignGreeceColor(item.PTPStickerExp),labelStyle),
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTokens.maintCardBorder, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: AppTokens.invoiceHeaderStart.withOpacity(0.07),
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
            // Top gradient accent
            Container(
                height: 3,
                decoration:
                const BoxDecoration(gradient: kGradient)),

            // Expiry notice
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 14, color: AppTokens.planTextMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Expiry till: ${state.expDate}',
                      style: GoogleFonts.lato(
                        color: AppTokens.planTextMuted,
                        fontWeight: FontWeight.w500,
                        fontSize: isTablet ? 12 : 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTokens.maintDetailBg),

            // Field rows
            ...fields,
          ],
        ),
      ),
    );
  }
}

// ─── Section header row (Truck 1 / Truck 2) ──────────────────────────────────
class _FieldSection extends StatelessWidget {
  final bool   isHeader;
  final String label;
  final String value;
  final Color  valueColor;
  final bool   isTablet;

  const _FieldSection({
    required this.isHeader,
    required this.label,
    required this.value,
    required this.valueColor,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
          gradient: kGradient),
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
              value,
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

// ─── Single field row ─────────────────────────────────────────────────────────
class _FieldRow extends StatelessWidget {
  final String label;
  final String value;
  final Color  valueColor;
  final TextStyle labelStyle;

  const _FieldRow(
      this.label, this.value, this.valueColor, this.labelStyle);

  @override
  Widget build(BuildContext context) {
    // Expired values get a red background tint
    final isExpired = valueColor == AppTokens.kExpiredRed;

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 6),
      color: isExpired
          ? AppTokens.kExpiredRed.withOpacity(0.06)
          : Colors.transparent,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: labelStyle,
              overflow: TextOverflow.ellipsis,
            ),
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
                      color: AppTokens.kExpiredRed,
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
              color: AppTokens.maintChipBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.local_shipping_outlined,
                size: 32, color: AppTokens.invoiceHeaderEnd),
          ),
          const SizedBox(height: 14),
          Text('No Truck Selected',
              style: GoogleFonts.lato(
                  color: AppTokens.maintTextDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 15)),
          const SizedBox(height: 4),
          Text('Search for a truck to view maintenance details',
              style: GoogleFonts.lato(
                  color: AppTokens.planTextMuted, fontSize: 12)),
        ],
      ),
    );
  }
}