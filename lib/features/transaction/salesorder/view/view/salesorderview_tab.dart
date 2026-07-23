import 'package:flutter/material.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/features/transaction/salesorder/view/data/salesorderview_repository.dart';
import 'package:maleva/menu/menulist.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import '../../../../mastersearch/Customer.dart';
import '../../../../mastersearch/Employee.dart';
import '../../../../mastersearch/JobStatus.dart';
import '../../add/view/salesorderadd_tab.dart';
import '../bloc/salesorderview_bloc.dart';
import '../bloc/salesorderview_event.dart';
import '../bloc/salesorderview_state.dart';
import 'package:maleva/core/models/shared/customer_model.dart';
import 'package:maleva/core/models/shared/employee_model.dart';
import 'package:maleva/core/models/shared/sale_edit_detail_model.dart';
import 'package:maleva/features/transaction/salesorder/models/sale_order_master_model.dart';
import 'package:maleva/features/operations/models/job_status_model.dart';




// ── Breakpoint: <= 600 → mobile, > 600 → tablet ──────────
bool _isMobile(double width) => width <= 600;

// ════════════════════════════════════════════════════════
// Entry
// ════════════════════════════════════════════════════════
class SaleOrderView extends StatelessWidget {
  const SaleOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) =>
      SalesOrderViewBloc(ctx, sl())..add(StartupSalesOrderView()),
      child: const _SaleOrderViewBody(),
    );
  }
}

// ════════════════════════════════════════════════════════
// Body
// ════════════════════════════════════════════════════════
class _SaleOrderViewBody extends StatelessWidget {
  const _SaleOrderViewBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SalesOrderViewBloc, SalesOrderViewState>(
      builder: (context, state) {
        if (state is SalesOrderViewLoading ||
            state is SalesOrderViewInitial) {
          return const Scaffold(
            backgroundColor: colour.surface,
            body: Center(
                child: SpinKitFoldingCube(color: colour.brand, size: 35)),
          );
        }
        if (state is SalesOrderViewError) {
          return Scaffold(
            backgroundColor: colour.surface,
            body: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.error_outline, color: colour.red, size: 48),
                const SizedBox(height: 12),
                Text(state.message,
                    style: GoogleFonts.poppins(
                        color: colour.textSub, fontSize: 14)),
              ]),
            ),
          );
        }
        if (state is! SalesOrderViewLoaded) return const SizedBox();

        return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          Navigator.pop(context);
        },
          child: Scaffold(
            backgroundColor: colour.surface,
            appBar: _SaleAppBar(state: state),
            drawer: const Menulist(),
            body: state.progress == false
                ? const Center(
                child: SpinKitFoldingCube(color: colour.brand, size: 35))
                : LayoutBuilder(
              builder: (ctx, constraints) =>
              _isMobile(constraints.maxWidth)
                  ? _MobileBody(state: state)
                  : _TabletBody(state: state),
            ),
            floatingActionButton: _FilterFab(state: state),
          ),
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════
// AppBar
// ════════════════════════════════════════════════════════
class _SaleAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final SalesOrderViewLoaded state;
  const _SaleAppBar({required this.state});

  @override
  Size get preferredSize => const Size.fromHeight(62);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [colour.brand, colour.brandMid],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          boxShadow: [
            BoxShadow(
                color: Color(0x551555F3),
                blurRadius: 12,
                offset: Offset(0, 4))
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Sales Order',
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3)),
          Text(AppGlobals.storagenew.getString('Username') ?? '',
              style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white38),
          ),
          child: IconButton(
            icon: const Icon(Icons.add_rounded,
                color: Colors.white, size: 22),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const SalesOrdersAdd())),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════
// ██  MOBILE BODY
// ════════════════════════════════════════════════════════
class _MobileBody extends StatelessWidget {
  final SalesOrderViewLoaded state;
  const _MobileBody({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
        child: state.masterList.isEmpty
            ? _EmptyState()
            : ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
          itemCount: state.masterList.length,
          itemBuilder: (ctx, i) => _MobileCard(
              model: state.masterList[i],
              index: i,
              state: state),
        ),
      ),
    ]);
  }
}



// ── Mobile Card ───────────────────────────────────────────
class _MobileCard extends StatelessWidget {
  final SaleOrderMasterModel model;
  final int index;
  final SalesOrderViewLoaded state;
  const _MobileCard(
      {required this.model,
      required this.index,
      required this.state});

  Color _strip() {
    final hasPickup = model.SPickupDate.toString().isNotEmpty;
    final hasETA    = model.SETA.toString().isNotEmpty;
    final hasOETA   = model.SOETA.toString().isNotEmpty;
    if (!hasPickup && !hasETA && !hasOETA) return colour.red;
    if (!hasPickup) return colour.yellow;
    if (hasETA || hasOETA) return colour.green;
    return model.JobMasterRefId == 10 ? colour.brand : colour.green;
  }

  bool get _expanded => state.expandedIndex == index;

  @override
  Widget build(BuildContext context) {
    final bloc  = context.read<SalesOrderViewBloc>();
    final strip = _strip();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colour.border, width: 1),
        boxShadow: [
          BoxShadow(
              color: strip.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onLongPress: () => _navigateToEdit(context, model.Id, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top strip
              Container(height: 4, color: strip),

              // Header: SNo, Job No & Status
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: colour.brand.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Text('${index + 1}',
                              style: GoogleFonts.poppins(
                                  color: colour.brand,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800)),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          model.BillNoDisplay.toString(),
                          style: GoogleFonts.poppins(
                              color: colour.brandDark,
                              fontSize: 14,
                              fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: strip.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        model.JobStatus.toString().toUpperCase(),
                        style: GoogleFonts.poppins(
                            color: strip,
                            fontSize: 10,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),

              // Customer & Employee
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.business_rounded, size: 14, color: colour.brand),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            model.CustomerName.toString(),
                            style: GoogleFonts.poppins(
                                color: colour.brandDark,
                                fontSize: 13,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded, size: 14, color: colour.textSub),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            model.EmployeeName.toString(),
                            style: GoogleFonts.poppins(
                                color: colour.textSub,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Divider(height: 1, color: colour.border),
              ),

              // Vessels Grid (2 columns)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column (Loading Vessel)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoCell('Loading Vessel', model.Loadingvesselname.toString(), Icons.directions_boat_rounded),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: _infoCell('ETA', model.SETA.toString(), null)),
                              const SizedBox(width: 8),
                              Expanded(child: _infoCell('ETB', model.SETB.toString(), null)),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Right Column (Off Vessel)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoCell('Off Vessel', model.Offvesselname.toString(), Icons.directions_boat_outlined),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: _infoCell('OETA', model.SOETA.toString(), null)),
                              const SizedBox(width: 8),
                              Expanded(child: _infoCell('OETB', model.SOETB.toString(), null)),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Port & Flight
              if (model.SPort.toString().isNotEmpty || model.FlighTime.toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      if (model.SPort.toString().isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colour.brandLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.anchor_rounded, color: colour.brandMid, size: 12),
                              const SizedBox(width: 4),
                              Text(model.SPort.toString(), style: GoogleFonts.poppins(color: colour.brandDark, fontSize: 11, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      if (model.FlighTime.toString().isNotEmpty) ...[
                        const SizedBox(width: 12),
                        const Icon(Icons.flight_rounded, color: colour.brandMid, size: 14),
                        const SizedBox(width: 4),
                        Text(model.FlighTime.toString(), style: GoogleFonts.poppins(color: colour.textSub, fontSize: 11, fontWeight: FontWeight.w600)),
                      ],
                    ],
                  ),
                ),

              // Actions
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: OutlinedButton.icon(
                        onPressed: () => bloc.add(ExpandRow(index)),
                        icon: Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 18, color: colour.brand),
                        label: Text(_expanded ? 'Close' : 'Details', style: GoogleFonts.poppins(color: colour.brand, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: colour.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: ElevatedButton.icon(
                        onPressed: () => bloc.add(ShareDO(model.Id, model.BillNo)),
                        icon: const Icon(Icons.picture_as_pdf_rounded, size: 16, color: Colors.white),
                        label: Text('DO', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: strip,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Details Panel
              if (_expanded) _DetailPanel(state: state, accent: strip),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCell(String label, String val, IconData? icon) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 12, color: colour.textSub),
                const SizedBox(width: 4),
              ],
              Text(label,
                  style: GoogleFonts.poppins(
                      color: colour.textSub,
                      fontSize: 10,
                      fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            val.isEmpty ? '—' : val,
            style: GoogleFonts.poppins(
                color: val.isEmpty ? const Color(0xFFCBD5E1) : colour.textMain,
                fontSize: 11,
                fontWeight: FontWeight.w600),
          ),
        ],
      );

  Future<void> _navigateToEdit(BuildContext context, int id, int saleNo) async {
    try {
      final resultData = await sl<SalesOrderViewRepository>().editSalesOrder(id, saleNo);
      if (resultData.isNotEmpty) {
        AppGlobals.SaleEditMasterList = resultData;
        AppGlobals.SaleEditDetailList = (resultData[0]["SaleDetails"] as List).map<SaleEditDetailModel>((e) => SaleEditDetailModel.fromJson(e)).toList();
        
        if (!context.mounted) return;
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => SalesOrdersAdd(
            SaleDetails: AppGlobals.SaleEditDetailList,
            SaleMaster: AppGlobals.SaleEditMasterList,
          ),
        ));
      } else {
        if (!context.mounted) return;
        msgshow('Data empty', '', Colors.white, Colors.red, null, 18.0, AppGlobals.tll, AppGlobals.tgc, context, 2);
      }
    } catch (e) {
      if (!context.mounted) return;
      msgshow(e.toString(), '', Colors.white, Colors.red, null, 18.0, AppGlobals.tll, AppGlobals.tgc, context, 2);
    }
  }
}


// ════════════════════════════════════════════════════════
// ██  TABLET BODY
// ════════════════════════════════════════════════════════
class _TabletBody extends StatelessWidget {
  final SalesOrderViewLoaded state;
  const _TabletBody({required this.state});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const minWidth = 1200.0;
        final w = constraints.maxWidth > minWidth ? constraints.maxWidth : minWidth;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: w,
            child: Column(children: [
              // Tablet header — all columns one row
              Container(
                color: colour.brandDeep,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 11),
                child: Row(children: [
          _th('#',         flex: 1),
          _th('Status',    flex: 3),
          _th('Employee',  flex: 4),
          _th('L.Vessel',  flex: 4),
          _th('ETA',       flex: 4),
          _th('ETB',       flex: 3),
          _th('O.Vessel',  flex: 4),
          _th('OETA',      flex: 4),
          _th('OETB',      flex: 3),
          _th('Customer',  flex: 5),
          _th('Order No',  flex: 3),
          _th('Actions',   flex: 3,
              align: TextAlign.center),
        ]),
      ),
      Expanded(
        child: state.masterList.isEmpty
            ? _EmptyState()
            : ListView.builder(
          padding:
          const EdgeInsets.fromLTRB(12, 8, 12, 100),
          itemCount: state.masterList.length,
          itemBuilder: (ctx, i) => _TabletRow(
              model: state.masterList[i],
              index: i,
              state: state),
        ),
      ),
    ]),
          ),
        );
      }
    );
  }

  Widget _th(String t,
      {int flex = 1,
        TextAlign align = TextAlign.left}) =>
      Expanded(
        flex: flex,
        child: Text(t,
            textAlign: align,
            style: GoogleFonts.poppins(
                color: Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6)),
      );
}

// ── Tablet Row ────────────────────────────────────────────
class _TabletRow extends StatelessWidget {
  final SaleOrderMasterModel model;
  final int index;
  final SalesOrderViewLoaded state;
  const _TabletRow(
      {required this.model,
        required this.index,
        required this.state});

  Color _strip() {
    final hasPickup = model.SPickupDate.toString().isNotEmpty;
    final hasETA    = model.SETA.toString().isNotEmpty;
    final hasOETA   = model.SOETA.toString().isNotEmpty;
    if (!hasPickup && !hasETA && !hasOETA) return colour.red;
    if (!hasPickup) return colour.yellow;
    if (hasETA || hasOETA) return colour.green;
    return model.JobMasterRefId == 10 ? colour.brand : colour.green;
  }

  bool get _expanded => state.expandedIndex == index;

  @override
  Widget build(BuildContext context) {
    final bloc  = context.read<SalesOrderViewBloc>();
    final strip = _strip();

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: strip, width: 4)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A1555F3),
              blurRadius: 8,
              offset: Offset(0, 2))
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onLongPress: () =>
            _navigateToEdit(context, model.Id, 0),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 10),
            child: Row(children: [
              // SNo
              Expanded(
                flex: 1,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: strip.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: strip.withValues(alpha: 0.3)),
                  ),
                  alignment: Alignment.center,
                  child: Text('${index + 1}',
                      style: GoogleFonts.poppins(
                          color: strip,
                          fontSize: 11,
                          fontWeight: FontWeight.w800)),
                ),
              ),
              // Status
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 3),
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: strip.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: strip.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    model.JobStatus.toString().toUpperCase(),
                    style: GoogleFonts.poppins(
                        color: strip,
                        fontSize: 9,
                        fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              _tc(model.EmployeeName.toString(),  flex: 4),
              _tc(model.Loadingvesselname.toString(), flex: 4),
              _tc(model.SETA.toString(),          flex: 4),
              _tc(model.SETB.toString(),          flex: 3),
              _tc(model.Offvesselname.toString(), flex: 4),
              _tc(model.SOETA.toString(),         flex: 4),
              _tc(model.SOETB.toString(),         flex: 3),
              // Customer + Port
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(model.CustomerName.toString(),
                        style: GoogleFonts.poppins(
                            color: colour.brandDark,
                            fontSize: 11,
                            fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis),
                    Text(model.SPort.toString(),
                        style: GoogleFonts.poppins(
                            color: colour.textSub,
                            fontSize: 10),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  model.BillNoDisplay.toString(),
                  style: GoogleFonts.poppins(
                      color: colour.brand,
                      fontSize: 11,
                      fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Actions
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    _iconBtn(
                      icon: _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.expand_more_rounded,
                      color: colour.brand,
                      onTap: () =>
                          bloc.add(ExpandRow(index)),
                    ),
                    const SizedBox(width: 6),
                    _iconBtn(
                      icon: Icons.picture_as_pdf_rounded,
                      color: strip,
                      onTap: () => bloc.add(
                          ShareDO(model.Id, model.BillNo)),
                    ),
                  ],
                ),
              ),
            ]),
          ),
          if (_expanded)
            _DetailPanel(state: state, accent: strip),
        ]),
      ),
    );
  }

  Widget _tc(String val, {int flex = 1}) => Expanded(
    flex: flex,
    child: Text(
      val.isEmpty ? '—' : val,
      style: GoogleFonts.poppins(
          color: val.isEmpty
              ? const Color(0xFFCBD5E1)
              : colour.textMain,
          fontSize: 11,
          fontWeight: val.isEmpty
              ? FontWeight.w400
              : FontWeight.w600),
      overflow: TextOverflow.ellipsis,
    ),
  );

  Widget _iconBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, color: color, size: 17),
        ),
      );

  Future<void> _navigateToEdit(BuildContext context, int id, int saleNo) async {
    try {
      final resultData = await sl<SalesOrderViewRepository>().editSalesOrder(id, saleNo);
      if (resultData.isNotEmpty) {
        AppGlobals.SaleEditMasterList = resultData;
        AppGlobals.SaleEditDetailList = (resultData[0]["SaleDetails"] as List).map<SaleEditDetailModel>((e) => SaleEditDetailModel.fromJson(e)).toList();
        
        if (!context.mounted) return;
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => SalesOrdersAdd(
            SaleDetails: AppGlobals.SaleEditDetailList,
            SaleMaster: AppGlobals.SaleEditMasterList,
          ),
        ));
      } else {
        if (!context.mounted) return;
        msgshow('Data empty', '', Colors.white, Colors.red, null, 18.0, AppGlobals.tll, AppGlobals.tgc, context, 2);
      }
    } catch (e) {
      if (!context.mounted) return;
      msgshow(e.toString(), '', Colors.white, Colors.red, null, 18.0, AppGlobals.tll, AppGlobals.tgc, context, 2);
    }
  }
}

// ════════════════════════════════════════════════════════
// Shared — Detail Panel
// ════════════════════════════════════════════════════════
class _DetailPanel extends StatelessWidget {
  final SalesOrderViewLoaded state;
  final Color accent;
  const _DetailPanel({required this.state, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(top: BorderSide(color: colour.border)),
      ),
      padding: const EdgeInsets.all(16),
      child: state.selectedDetails.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text('No items found.', style: GoogleFonts.poppins(color: colour.textSub)),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: state.selectedDetails
                  .asMap()
                  .entries
                  .map((e) => _DetailRow(index: e.key, d: e.value, accent: accent))
                  .toList(),
            ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final int index;
  final dynamic d;
  final Color accent;
  const _DetailRow({required this.index, required this.d, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colour.border),
        boxShadow: const [
          BoxShadow(color: Color(0x05000000), blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text('${index + 1}', style: GoogleFonts.poppins(color: accent, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.ProductCode.toString(), style: GoogleFonts.poppins(color: colour.brand, fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(d.ProductName.toString(), style: GoogleFonts.poppins(color: colour.textMain, fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: colour.brandLight, borderRadius: BorderRadius.circular(6)),
                child: Text('Qty: ${d.ItemQty}', style: GoogleFonts.poppins(color: colour.brandDark, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: colour.border),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('Rate: ${d.SaleRate}', style: GoogleFonts.poppins(color: colour.textSub, fontSize: 12, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 8),
                  Text('Tax: ${d.TaxAmt}', style: GoogleFonts.poppins(color: colour.textSub, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
              Text('Amt: ${d.SAmount}', style: GoogleFonts.poppins(color: colour.brandDark, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
              color: colour.brandLight,
              borderRadius: BorderRadius.circular(40)),
          child: const Icon(Icons.inbox_rounded,
              color: colour.brand, size: 40),
        ),
        const SizedBox(height: 16),
        Text('No Records Found',
            style: GoogleFonts.poppins(
                color: colour.textSub,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Adjust your filter to see results',
            style: GoogleFonts.poppins(
                color: colour.textSub.withValues(alpha: 0.6),
                fontSize: 12)),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════
// FAB
// ════════════════════════════════════════════════════════
class _FilterFab extends StatelessWidget {
  final SalesOrderViewLoaded state;
  const _FilterFab({required this.state});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _open(context),
      backgroundColor: colour.brand,
      elevation: 6,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.tune_rounded,
          color: Colors.white, size: 24),
    );
  }

  void _open(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: BlocProvider.of<SalesOrderViewBloc>(ctx),
        child: BlocBuilder<SalesOrderViewBloc, SalesOrderViewState>(
          builder: (context, state) {
            if (state is SalesOrderViewLoaded) {
              return _FilterSheet(state: state);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// Filter Sheet — auto layout mobile vs tablet
// ════════════════════════════════════════════════════════
class _FilterSheet extends StatefulWidget {
  final SalesOrderViewLoaded state;
  const _FilterSheet({required this.state});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String _from;
  late String _to;
  late String _cls;
  late String _etaVal;
  late String _etaRadio;
  late bool   _chkETA;
  late bool   _chkPickup;
  late bool   _chkLEmp;

  late final TextEditingController _jobNoCtrl;
  late final TextEditingController _loadVesselCtrl;
  late final TextEditingController _offVesselCtrl;

  @override
  void initState() {
    super.initState();
    _from      = widget.state.dtpFromDate;
    _to        = widget.state.dtpToDate;
    _cls       = widget.state.cls;
    _etaVal    = widget.state.etaVal;
    _etaRadio  = widget.state.etaRadioVal;
    _chkETA    = widget.state.checkBoxValueETA;
    _chkPickup = widget.state.checkBoxValuePickUp;
    _chkLEmp   = widget.state.checkBoxValueLEmp;

    _jobNoCtrl      = TextEditingController(text: widget.state.txtJobNo);
    _loadVesselCtrl = TextEditingController(text: widget.state.txtLoadingVessel);
    _offVesselCtrl  = TextEditingController(text: widget.state.txtOffVessel);
  }

  @override
  void dispose() {
    _jobNoCtrl.dispose();
    _loadVesselCtrl.dispose();
    _offVesselCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc  = context.read<SalesOrderViewBloc>();
    final state = widget.state;
    final screenW = MediaQuery.of(context).size.width;
    final isTab   = !_isMobile(screenW);

    return LayoutBuilder(builder: (ctx, constraints) {
      return Center(
        child: Container(
          width: isTab ? screenW * 0.55 : double.infinity,
          constraints: BoxConstraints(
              maxHeight:
              MediaQuery.of(context).size.height * 0.88),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: isTab
                ? BorderRadius.circular(24)
                : const BorderRadius.vertical(
                top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
              bottom:
              MediaQuery.of(context).viewInsets.bottom),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle (mobile only)
                if (!isTab)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: colour.border,
                        borderRadius:
                        BorderRadius.circular(2)),
                  ),
                // Title bar
                Container(
                  margin: const EdgeInsets.fromLTRB(
                      16, 12, 16, 0),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [colour.brand, colour.brandMid]),
                    borderRadius:
                    BorderRadius.circular(14),
                  ),
                  child: Row(children: [
                    const Icon(Icons.tune_rounded,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 10),
                    Text('Filter Orders',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                    if (isTab) ...[
                      const Spacer(),
                      GestureDetector(
                        onTap: () =>
                            Navigator.of(context).pop(),
                        child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white70,
                            size: 20),
                      ),
                    ],
                  ]),
                ),
                // Scrollable body
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                        16, 14, 16, 0),
                    child: isTab
                        ? _tabGrid(context, bloc, state)
                        : _mobileList(
                        context, bloc, state),
                  ),
                ),
              ]),
        ),
      );
    });
  }

  // ── Tablet 2-col grid ─────────────────────────────────
  Widget _tabGrid(BuildContext context,
      SalesOrderViewBloc bloc, SalesOrderViewLoaded state) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _lbl('Date Range'),
          _dateRow(context),
          const SizedBox(height: 12),
          _twoCol(
            left: _fieldCol('Customer',
                _searchTile(
                    hint: 'Search customer...',
                    value: state.txtCustomer,
                    onSearch: () =>
                        _pickCustomer(context, bloc),
                    onClear: () =>
                        bloc.add(ViewCustomerCleared()))),
            right: _fieldCol('Employee',
                _searchTile(
                    hint: 'Search employee...',
                    value: state.txtEmployee,
                    enabled: !_chkLEmp,
                    onSearch: () =>
                        _pickEmployee(context, bloc),
                    onClear: () =>
                        bloc.add(ViewEmployeeCleared()))),
          ),
          const SizedBox(height: 12),
          _twoCol(
            left: _fieldCol('Status',
                _searchTile(
                    hint: 'Select status...',
                    value: state.txtStatus,
                    onSearch: () =>
                        _pickStatus(context, bloc),
                    onClear: () =>
                        bloc.add(ViewStatusCleared()))),
            right: _fieldCol('Job No',
                _textTile(
                    hint: 'Job number',
                    controller: _jobNoCtrl,
                    onChanged: (v) => bloc.add(
                        ViewUpdateTextField(
                            'txtJobNo', v)))),
          ),
          const SizedBox(height: 12),
          _twoCol(
            left: _fieldCol('Loading Vessel',
                _textTile(
                    hint: 'Loading vessel',
                    controller: _loadVesselCtrl,
                    onChanged: (v) => bloc.add(
                        ViewUpdateTextField(
                            'txtLoadingVessel', v)))),
            right: _fieldCol('Off Vessel',
                _textTile(
                    hint: 'Off vessel',
                    controller: _offVesselCtrl,
                    onChanged: (v) => bloc.add(
                        ViewUpdateTextField(
                            'txtOffVessel', v)))),
          ),
          const SizedBox(height: 12),
          _twoCol(
            left: _fieldCol('Clearance',
                _chips(
                    items: const ['All', 'With', 'Without'],
                    vals: const ['3', '1', '2'],
                    cur: _cls,
                    onTap: (v) =>
                        setState(() => _cls = v))),
            right: _fieldCol('ETA Filter',
                _chips(
                    items: const [
                      'OETA', 'LETA', 'All', 'None'
                    ],
                    vals: const ['1', '2', '3', '0'],
                    cur: _etaVal,
                    onTap: (v) => setState(() {
                      _etaVal   = v;
                      _chkETA   = v != '0';
                      _etaRadio = v == '0' ? 'O' : v;
                    }))),
          ),
          const SizedBox(height: 12),
          _lbl('Options'),
          _checkboxRow(bloc),
          const SizedBox(height: 20),
          _buttons(context, bloc),
          const SizedBox(height: 20),
        ]);
  }

  // ── Mobile single-col ─────────────────────────────────
  Widget _mobileList(BuildContext context,
      SalesOrderViewBloc bloc, SalesOrderViewLoaded state) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _lbl('Date Range'),
          _dateRow(context),
          const SizedBox(height: 12),
          _lbl('Customer'),
          _searchTile(
              hint: 'Search customer...',
              value: state.txtCustomer,
              onSearch: () => _pickCustomer(context, bloc),
              onClear: () => bloc.add(ViewCustomerCleared())),
          const SizedBox(height: 12),
          _lbl('Employee'),
          _searchTile(
              hint: 'Search employee...',
              value: state.txtEmployee,
              enabled: !_chkLEmp,
              onSearch: () => _pickEmployee(context, bloc),
              onClear: () => bloc.add(ViewEmployeeCleared())),
          const SizedBox(height: 12),
          _lbl('Status'),
          _searchTile(
              hint: 'Select status...',
              value: state.txtStatus,
              onSearch: () => _pickStatus(context, bloc),
              onClear: () => bloc.add(ViewStatusCleared())),
          const SizedBox(height: 12),
          _lbl('Job No'),
          _textTile(
              hint: 'Job number',
              controller: _jobNoCtrl,
              onChanged: (v) =>
                  bloc.add(ViewUpdateTextField('txtJobNo', v))),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
                child: _textTile(
                    hint: 'Loading vessel',
                    controller: _loadVesselCtrl,
                    onChanged: (v) => bloc.add(
                        ViewUpdateTextField(
                            'txtLoadingVessel', v)))),
            const SizedBox(width: 8),
            Expanded(
                child: _textTile(
                    hint: 'Off vessel',
                    controller: _offVesselCtrl,
                    onChanged: (v) => bloc.add(
                        ViewUpdateTextField(
                            'txtOffVessel', v)))),
          ]),
          const SizedBox(height: 12),
          _lbl('Options'),
          _checkboxRow(bloc),
          const SizedBox(height: 12),
          _lbl('Clearance'),
          _chips(
              items: const ['All', 'With', 'Without'],
              vals: const ['3', '1', '2'],
              cur: _cls,
              onTap: (v) => setState(() => _cls = v)),
          const SizedBox(height: 12),
          _lbl('ETA Filter'),
          _chips(
              items: const ['OETA', 'LETA', 'All', 'None'],
              vals: const ['1', '2', '3', '0'],
              cur: _etaVal,
              onTap: (v) => setState(() {
                _etaVal   = v;
                _chkETA   = v != '0';
                _etaRadio = v == '0' ? 'O' : v;
              })),
          const SizedBox(height: 20),
          _buttons(context, bloc),
          const SizedBox(height: 20),
        ]);
  }

  // ── Search actions ────────────────────────────────────
  Future<void> _pickCustomer(
      BuildContext context, SalesOrderViewBloc bloc) async {
    final r = await Navigator.push(context,
        MaterialPageRoute(
            builder: (_) =>
            const Customer(Searchby: 1, SearchId: 0))); if (r != null) { AppGlobals.SelectCustomerList = r; }
    if (r != null) {
      bloc.add(ViewCustomerSelected(
          AppGlobals.SelectCustomerList.AccountName,
          AppGlobals.SelectCustomerList.Id));
      AppGlobals.SelectCustomerList = CustomerModel.Empty();
    }
  }

  Future<void> _pickEmployee(
      BuildContext context, SalesOrderViewBloc bloc) async {
    AppGlobals.EmployeeList = (await sl<SalesOrderViewRepository>().selectEmployee('sales', 'admin')).map<EmployeeModel>((e) => EmployeeModel.fromJson(e)).toList(); if (!context.mounted) return;final r = await Navigator.push(context,
        MaterialPageRoute(
            builder: (_) =>
            const Employee(Searchby: 1, SearchId: 0))); if (r != null) { AppGlobals.SelectEmployeeList = r; }
    if (r != null) {
      bloc.add(ViewEmployeeSelected(
          AppGlobals.SelectEmployeeList.AccountName,
          AppGlobals.SelectEmployeeList.Id));
      AppGlobals.SelectEmployeeList = EmployeeModel.Empty();
    }
  }

  Future<void> _pickStatus(
      BuildContext context, SalesOrderViewBloc bloc) async {
    final r = await Navigator.push(context,
        MaterialPageRoute(
            builder: (_) =>
            const JobStatus(Searchby: 1, SearchId: 0))); if (r != null) { AppGlobals.SelectJobStatusList = r; }
    if (r != null) {
      bloc.add(ViewStatusSelected(
          AppGlobals.SelectJobStatusList.Name,
          AppGlobals.SelectJobStatusList.Id));
      AppGlobals.SelectJobStatusList = JobStatusModel.Empty();
    }
  }

  // ── Layout helpers ────────────────────────────────────
  Widget _twoCol({required Widget left, required Widget right}) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: left),
          const SizedBox(width: 12),
          Expanded(child: right),
        ],
      );

  Widget _fieldCol(String label, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [_lbl(label), child],
  );

  Widget _dateRow(BuildContext context) => Row(children: [
    Expanded(
        child: _dateTile(
          DateFormat('dd-MM-yyyy')
              .format(DateTime.parse(_from)),
              () async {
            final p = await _pickDate(context);
            if (p != null) {
              setState(() =>
              _from = DateFormat('yyyy-MM-dd').format(p));
            }
          },
        )),
    const SizedBox(width: 10),
    Expanded(
        child: _dateTile(
          DateFormat('dd-MM-yyyy')
              .format(DateTime.parse(_to)),
              () async {
            final p = await _pickDate(context);
            if (p != null) {
              setState(() =>
              _to = DateFormat('yyyy-MM-dd').format(p));
            }
          },
        )),
  ]);

  Widget _checkboxRow(SalesOrderViewBloc bloc) => Row(children: [
    _chkChip('PickUp', _chkPickup, (v) {
      setState(() => _chkPickup = v);
      bloc.add(
          ViewUpdateCheckbox('checkBoxValuePickUp', v));
    }),
    const SizedBox(width: 8),
    _chkChip('L.Employee', _chkLEmp, (v) {
      setState(() => _chkLEmp = v);
      bloc.add(ViewUpdateCheckbox('checkBoxValueLEmp', v));
    }),
  ]);

  Widget _buttons(
      BuildContext context, SalesOrderViewBloc bloc) =>
      Row(children: [
        Expanded(
          flex: 2,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colour.brand,
              padding:
              const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 3,
              shadowColor: colour.brandGlow,
            ),
            onPressed: () {
              bloc
                ..add(ViewUpdateFromDate(_from))
                ..add(ViewUpdateToDate(_to))
                ..add(ViewUpdateCls(_cls))
                ..add(ViewUpdateRadio(
                    _etaVal, _etaRadio, _chkETA))
                ..add(LoadSalesOrderView());
              Navigator.of(context).pop();
            },
            child: Text('View Results',
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding:
              const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: colour.border),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close',
                style: GoogleFonts.poppins(
                    color: colour.brand,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      ]);

  // ── Small widget factories ────────────────────────────
  Widget _lbl(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(t,
        style: GoogleFonts.poppins(
            color: colour.textSub,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6)),
  );

  Widget _dateTile(String date, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          padding:
          const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: colour.brandLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colour.border),
          ),
          child: Row(children: [
            const Icon(Icons.calendar_today_rounded,
                color: colour.brand, size: 15),
            const SizedBox(width: 8),
            Flexible(
              child: Text(date,
                  style: GoogleFonts.poppins(
                      color: colour.brandDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ),
          ]),
        ),
      );

  Widget _searchTile({
    required String hint,
    required String value,
    bool enabled = true,
    required VoidCallback onSearch,
    required VoidCallback onClear,
  }) =>
      Container(
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: enabled
                  ? colour.border
                  : colour.border.withValues(alpha: 0.3)),
          color: enabled ? Colors.white : colour.surface,
        ),
        child: Row(children: [
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value.isEmpty ? hint : value,
              style: GoogleFonts.poppins(
                  color: value.isEmpty
                      ? colour.textSub.withValues(alpha: 0.45)
                      : colour.textMain,
                  fontSize: 13,
                  fontWeight: value.isEmpty
                      ? FontWeight.w400
                      : FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: enabled
                ? (value.isEmpty ? onSearch : onClear)
                : null,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                value.isEmpty
                    ? Icons.search_rounded
                    : Icons.close_rounded,
                color: enabled
                    ? colour.brand
                    : colour.textSub.withValues(alpha: 0.25),
                size: 20,
              ),
            ),
          ),
        ]),
      );

  Widget _textTile({
    required String hint,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
  }) =>
      TextField(
        controller: controller,
        onChanged: onChanged,
        textCapitalization: TextCapitalization.characters,
        style: GoogleFonts.poppins(
            color: colour.textMain,
            fontSize: 13,
            fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
              color: colour.textSub.withValues(alpha: 0.45),
              fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 12),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: colour.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
            const BorderSide(color: colour.brand, width: 1.5),
          ),
        ),
      );

  Widget _chkChip(
      String lbl, bool checked, ValueChanged<bool> cb) =>
      GestureDetector(
        onTap: () => cb(!checked),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: checked ? colour.brand : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: checked ? colour.brand : colour.border),
          ),
          child:
          Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(
              checked
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: checked ? Colors.white : colour.textSub,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(lbl,
                style: GoogleFonts.poppins(
                    color:
                    checked ? Colors.white : colour.textSub,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ]),
        ),
      );

  Widget _chips({
    required List<String> items,
    required List<String> vals,
    required String cur,
    required ValueChanged<String> onTap,
  }) =>
      Wrap(spacing: 8, runSpacing: 8, children: [
        ...List.generate(items.length, (i) {
          final active = cur == vals[i];
          return GestureDetector(
            onTap: () => onTap(vals[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: active ? colour.brand : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: active ? colour.brand : colour.border),
              ),
              child: Text(items[i],
                  style: GoogleFonts.poppins(
                      color: active
                          ? Colors.white
                          : colour.textSub,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ),
          );
        })
      ]);

  Future<DateTime?> _pickDate(BuildContext ctx) =>
      showDatePicker(
        context: ctx,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2050),
        builder: (ctx, child) => Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(
              primary: colour.brand,
              onPrimary: Colors.white,
              onSurface: colour.textMain,
            ),
          ),
          child: child!,
        ),
      );
}