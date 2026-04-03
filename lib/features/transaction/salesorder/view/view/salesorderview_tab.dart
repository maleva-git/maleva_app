import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/menu/menulist.dart';
import 'package:maleva/MasterSearch/Customer.dart';
import 'package:maleva/MasterSearch/Employee.dart';
import 'package:maleva/MasterSearch/JobStatus.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import '../../add/view/salesorderadd_tab.dart';
import '../bloc/salesorderview_bloc.dart';
import '../bloc/salesorderview_event.dart';
import '../bloc/salesorderview_state.dart';




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
      SalesOrderViewBloc(ctx)..add(StartupSalesOrderView()),
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

        return WillPopScope(
          onWillPop: () async {
            Navigator.pop(context);
            return false;
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
          Text(objfun.storagenew.getString('Username') ?? '',
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
      _MobileColHeader(),
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

// ── Mobile Column Header ──────────────────────────────────
class _MobileColHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: colour.brandDeep,
      padding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      child: Column(children: [
        Row(children: [
          _h('#',        flex: 1),
          _h('Status',   flex: 3),
          _h('Employee', flex: 4),
        ]),
        const SizedBox(height: 4),
        Row(children: [
          _h('L.Vessel', flex: 3),
          _h('ETA',      flex: 4),
          _h('ETB',      flex: 3),
        ]),
        const SizedBox(height: 4),
        Row(children: [
          _h('Port',     flex: 3),
          _h('Customer', flex: 5),
          _h('Order No', flex: 3),
        ]),
      ]),
    );
  }

  Widget _h(String t, {int flex = 1}) => Expanded(
    flex: flex,
    child: Text(t,
        style: GoogleFonts.poppins(
            color: Colors.white54,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8)),
  );
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

  // Status strip color logic
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colour.border, width: 1),
        boxShadow: [
          BoxShadow(
              color: strip.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 4)),
          const BoxShadow(
              color: Color(0x08000000),
              blurRadius: 6,
              offset: Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onLongPress: () =>
              _showPasswordDialog(context, 1, model.Id, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top accent bar ────────────────────────
              Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [strip, strip.withOpacity(0.6)],
                  ),
                ),
              ),

              // ── Header: SNo + Status + Employee ──────
              Padding(
                padding:
                const EdgeInsets.fromLTRB(14, 12, 14, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Serial no circle
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            strip.withOpacity(0.15),
                            strip.withOpacity(0.08)
                          ],
                        ),
                        borderRadius:
                        BorderRadius.circular(16),
                        border: Border.all(
                            color: strip.withOpacity(0.3),
                            width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Text('${index + 1}',
                          style: GoogleFonts.poppins(
                              color: strip,
                              fontSize: 12,
                              fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 10),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: strip.withOpacity(0.1),
                        borderRadius:
                        BorderRadius.circular(20),
                        border: Border.all(
                            color: strip.withOpacity(0.3),
                            width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: strip,
                              borderRadius:
                              BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            model.JobStatus.toString()
                                .toUpperCase(),
                            style: GoogleFonts.poppins(
                                color: strip,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Employee
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_outline_rounded,
                              size: 13, color: colour.textSub),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              model.EmployeeName.toString(),
                              style: GoogleFonts.poppins(
                                  color: colour.textSub,
                                  fontSize: 11,
                                  fontWeight:
                                  FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Divider ───────────────────────────────
              Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 14),
                  color: colour.brandLight),

              // ── Vessel / ETA info grid ────────────────
              Padding(
                padding:
                const EdgeInsets.fromLTRB(14, 12, 14, 4),
                child: Column(children: [
                  // Row 1: L.Vessel, ETA, ETB
                  Row(children: [
                    _infoCell('L.Vessel',
                        model.Loadingvesselname.toString(),
                        flex: 3),
                    _infoCell('ETA',
                        model.SETA.toString(),
                        flex: 4),
                    _infoCell('ETB',
                        model.SETB.toString(),
                        flex: 3),
                  ]),
                  const SizedBox(height: 8),
                  // Row 2: O.Vessel, OETA, OETB
                  Row(children: [
                    _infoCell('O.Vessel',
                        model.Offvesselname.toString(),
                        flex: 3),
                    _infoCell('OETA',
                        model.SOETA.toString(),
                        flex: 4),
                    _infoCell('OETB',
                        model.SOETB.toString(),
                        flex: 3),
                  ]),
                ]),
              ),

              // ── Customer chip ─────────────────────────
              Container(
                margin:
                const EdgeInsets.fromLTRB(14, 8, 14, 0),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFEEF2FF),
                      Color(0xFFE8EFFE)
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colour.border),
                ),
                child: Row(children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: colour.brand.withOpacity(0.12),
                      borderRadius:
                      BorderRadius.circular(8),
                    ),
                    child: const Icon(
                        Icons.business_rounded,
                        color: colour.brand,
                        size: 16),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      model.CustomerName.toString(),
                      style: GoogleFonts.poppins(
                          color: colour.brandDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(8),
                      border: Border.all(
                          color: colour.brand.withOpacity(0.25)),
                    ),
                    child: Text(
                      model.BillNoDisplay.toString(),
                      style: GoogleFonts.poppins(
                          color: colour.brand,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3),
                    ),
                  ),
                ]),
              ),

              // ── Port + Flight row ─────────────────────
              if (model.SPort.toString().isNotEmpty ||
                  model.FlighTime.toString().isNotEmpty)
                Padding(
                  padding:
                  const EdgeInsets.fromLTRB(14, 8, 14, 0),
                  child: Row(children: [
                    if (model.SPort.toString().isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: colour.brandLight,
                          borderRadius:
                          BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.anchor_rounded,
                                color: colour.brandMid, size: 12),
                            const SizedBox(width: 4),
                            Text(model.SPort.toString(),
                                style: GoogleFonts.poppins(
                                    color: colour.brandDark,
                                    fontSize: 10,
                                    fontWeight:
                                    FontWeight.w700)),
                          ],
                        ),
                      ),
                    ],
                    if (model.FlighTime.toString()
                        .isNotEmpty) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.flight_rounded,
                          color: colour.brandMid, size: 12),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          model.FlighTime.toString(),
                          style: GoogleFonts.poppins(
                              color: colour.textSub,
                              fontSize: 10,
                              fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ]),
                ),

              // ── Action Buttons ────────────────────────
              Padding(
                padding:
                const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Row(children: [
                  // Details expand button
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          bloc.add(ExpandRow(index)),
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                          BorderRadius.circular(10),
                          border:
                          Border.all(color: colour.border),
                        ),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            Icon(
                              _expanded
                                  ? Icons
                                  .keyboard_arrow_up_rounded
                                  : Icons
                                  .keyboard_arrow_down_rounded,
                              size: 18,
                              color: colour.brand,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _expanded ? 'Close' : 'Details',
                              style: GoogleFonts.poppins(
                                  color: colour.brand,
                                  fontSize: 12,
                                  fontWeight:
                                  FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // DO button
                  Expanded(
                    child: GestureDetector(
                      onTap: () => bloc.add(
                          ShareDO(model.Id, model.BillNo)),
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              strip,
                              strip.withOpacity(0.8)
                            ],
                          ),
                          borderRadius:
                          BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color:
                              strip.withOpacity(0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            const Icon(
                                Icons.picture_as_pdf_rounded,
                                size: 15,
                                color: Colors.white),
                            const SizedBox(width: 5),
                            Text('DO',
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight:
                                    FontWeight.w800,
                                    letterSpacing: 0.5)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ]),
              ),

              // ── Expanded Detail Panel ─────────────────
              if (_expanded)
                _DetailPanel(state: state, accent: strip),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCell(String label, String val, {int flex = 1}) =>
      Expanded(
        flex: flex,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.poppins(
                    color: colour.textSub,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5)),
            const SizedBox(height: 2),
            Text(
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
              maxLines: 1,
            ),
          ],
        ),
      );

  Future<void> _showPasswordDialog(BuildContext context,
      int type, int id, int saleNo) async {
    final ctrl    = TextEditingController();
    final pwdType = type == 1 ? 'EditPassword' : 'AdminPower';
    final title   = type == 1 ? 'Edit Password' : 'Admin Pwd';

    await showDialog(
      barrierDismissible: true,
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child:
          Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  color: colour.brandLight,
                  borderRadius: BorderRadius.circular(30)),
              child: const Icon(Icons.lock_rounded,
                  color: colour.brand, size: 28),
            ),
            const SizedBox(height: 14),
            Text(title,
                style: GoogleFonts.poppins(
                    color: colour.textMain,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Enter password',
                hintStyle: GoogleFonts.poppins(
                    color: colour.textSub, fontSize: 13),
                filled: true,
                fillColor: colour.brandLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: colour.brand, width: 1.5),
                ),
                prefixIcon: const Icon(Icons.vpn_key_rounded,
                    color: colour.brand),
              ),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: colour.border),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12),
                  ),
                  child: Text('Cancel',
                      style: GoogleFonts.poppins(
                          color: colour.textSub,
                          fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colour.brand,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    if (ctrl.text.isEmpty) {
                      objfun.ConfirmationOK(
                          'Enter Password !!', context);
                      return;
                    }
                    final result =
                    await objfun.apiAllinoneSelectArray(
                      '${objfun.apiEditPassword}${ctrl.text}&type=$pwdType&Comid=${objfun.Comid}',
                      null, null, context,
                    );
                    if (result != null &&
                        result['IsSuccess'] == true) {
                      ctrl.clear();
                      await OnlineApi.EditSalesOrder(
                          context, id, saleNo);
                      Navigator.of(ctx).pop();
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                        builder: (_) => SalesOrdersAdd(
                          SaleDetails:
                          objfun.SaleEditDetailList,
                          SaleMaster:
                          objfun.SaleEditMasterList,
                        ),
                      ));
                    } else {
                      ctrl.clear();
                      objfun.ConfirmationOK(
                          'Invalid Password !!!', context);
                    }
                  },
                  child: Text('Confirm',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
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
    return Column(children: [
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
    ]);
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
            _showPasswordDialog(context, 1, model.Id, 0),
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
                    color: strip.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: strip.withOpacity(0.3)),
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
                    color: strip.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: strip.withOpacity(0.25)),
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
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 17),
        ),
      );

  Future<void> _showPasswordDialog(BuildContext context,
      int type, int id, int saleNo) async {
    final ctrl    = TextEditingController();
    final pwdType = type == 1 ? 'EditPassword' : 'AdminPower';
    final title   = type == 1 ? 'Edit Password' : 'Admin Pwd';

    await showDialog(
      barrierDismissible: true,
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        child: SizedBox(
          width: 420,
          child: Padding(
            padding: const EdgeInsets.all(28),
            child:
            Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                    color: colour.brandLight,
                    borderRadius: BorderRadius.circular(32)),
                child: const Icon(Icons.lock_rounded,
                    color: colour.brand, size: 30),
              ),
              const SizedBox(height: 16),
              Text(title,
                  style: GoogleFonts.poppins(
                      color: colour.textMain,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Enter password',
                  filled: true,
                  fillColor: colour.brandLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: colour.brand, width: 1.5),
                  ),
                  prefixIcon: const Icon(
                      Icons.vpn_key_rounded,
                      color: colour.brand),
                ),
              ),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: colour.border),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 14),
                    ),
                    child: Text('Cancel',
                        style: GoogleFonts.poppins(
                            color: colour.textSub,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colour.brand,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 14),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      if (ctrl.text.isEmpty) {
                        objfun.ConfirmationOK(
                            'Enter Password !!', context);
                        return;
                      }
                      final result =
                      await objfun.apiAllinoneSelectArray(
                        '${objfun.apiEditPassword}${ctrl.text}&type=$pwdType&Comid=${objfun.Comid}',
                        null, null, context,
                      );
                      if (result != null &&
                          result['IsSuccess'] == true) {
                        ctrl.clear();
                        await OnlineApi.EditSalesOrder(
                            context, id, saleNo);
                        Navigator.of(ctx).pop();
                        Navigator.of(context)
                            .push(MaterialPageRoute(
                          builder: (_) => SalesOrdersAdd(
                            SaleDetails:
                            objfun.SaleEditDetailList,
                            SaleMaster:
                            objfun.SaleEditMasterList,
                          ),
                        ));
                      } else {
                        ctrl.clear();
                        objfun.ConfirmationOK(
                            'Invalid Password !!!', context);
                      }
                    },
                    child: Text('Confirm',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14)),
                  ),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// Shared — Detail Panel
// ════════════════════════════════════════════════════════
class _DetailPanel extends StatelessWidget {
  final SalesOrderViewLoaded state;
  final Color accent;
  const _DetailPanel(
      {required this.state, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colour.surface,
        border: Border(top: BorderSide(color: colour.border)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header bar
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                accent,
                accent.withOpacity(0.75)
              ]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(children: [
              _dh('S',           flex: 1),
              _dh('Code',        flex: 3),
              _dh('Description', flex: 5),
              _dh('Qty',         flex: 2),
              _dh('Rate',        flex: 3),
              _dh('GST',         flex: 2),
              _dh('Amount',      flex: 3,
                  align: TextAlign.right),
            ]),
          ),
          const SizedBox(height: 8),
          if (state.selectedDetails.isEmpty)
            Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text('No items',
                    style: GoogleFonts.poppins(
                        color: colour.textSub, fontSize: 13)),
              ),
            )
          else
            ...state.selectedDetails
                .asMap()
                .entries
                .map((e) => _DetailRow(
                index: e.key,
                d: e.value,
                accent: accent))
                .toList(),
        ],
      ),
    );
  }

  Widget _dh(String t,
      {int flex = 1,
        TextAlign align = TextAlign.left}) =>
      Expanded(
        flex: flex,
        child: Text(t,
            textAlign: align,
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5)),
      );
}

class _DetailRow extends StatelessWidget {
  final int index;
  final dynamic d;
  final Color accent;
  const _DetailRow(
      {required this.index,
        required this.d,
        required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colour.border),
      ),
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 10),
      child: Row(children: [
        Expanded(
            flex: 1,
            child: Text('${index + 1}',
                style: GoogleFonts.poppins(
                    color: accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w800))),
        Expanded(
            flex: 3,
            child: Text(d.ProductCode.toString(),
                style: GoogleFonts.poppins(
                    color: colour.brand,
                    fontSize: 11,
                    fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis)),
        Expanded(
            flex: 5,
            child: Text(d.ProductName.toString(),
                style: GoogleFonts.poppins(
                    color: colour.textMain,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis)),
        Expanded(
            flex: 2,
            child: Text('×${d.ItemQty}',
                style: GoogleFonts.poppins(
                    color: colour.textSub,
                    fontSize: 11,
                    fontWeight: FontWeight.w600))),
        Expanded(
            flex: 3,
            child: Text('${d.SaleRate}',
                style: GoogleFonts.poppins(
                    color: colour.textSub, fontSize: 11),
                overflow: TextOverflow.ellipsis)),
        Expanded(
            flex: 2,
            child: Text('${d.TaxPercent}%',
                style: GoogleFonts.poppins(
                    color: colour.textSub, fontSize: 11))),
        Expanded(
          flex: 3,
          child: Text('₹${d.SAmount}',
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                  color: accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w800)),
        ),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════
// Empty State
// ════════════════════════════════════════════════════════
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
                color: colour.textSub.withOpacity(0.6),
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
        child: _FilterSheet(state: state),
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
                    value: state.txtJobNo,
                    onChanged: (v) => bloc.add(
                        ViewUpdateTextField(
                            'txtJobNo', v)))),
          ),
          const SizedBox(height: 12),
          _twoCol(
            left: _fieldCol('Loading Vessel',
                _textTile(
                    hint: 'Loading vessel',
                    value: state.txtLoadingVessel,
                    onChanged: (v) => bloc.add(
                        ViewUpdateTextField(
                            'txtLoadingVessel', v)))),
            right: _fieldCol('Off Vessel',
                _textTile(
                    hint: 'Off vessel',
                    value: state.txtOffVessel,
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
              value: state.txtJobNo,
              onChanged: (v) =>
                  bloc.add(ViewUpdateTextField('txtJobNo', v))),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
                child: _textTile(
                    hint: 'Loading vessel',
                    value: state.txtLoadingVessel,
                    onChanged: (v) => bloc.add(
                        ViewUpdateTextField(
                            'txtLoadingVessel', v)))),
            const SizedBox(width: 8),
            Expanded(
                child: _textTile(
                    hint: 'Off vessel',
                    value: state.txtOffVessel,
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
            const Customer(Searchby: 1, SearchId: 0)));
    if (r != null) {
      bloc.add(ViewCustomerSelected(
          objfun.SelectCustomerList.AccountName,
          objfun.SelectCustomerList.Id));
      objfun.SelectCustomerList = CustomerModel.Empty();
    }
  }

  Future<void> _pickEmployee(
      BuildContext context, SalesOrderViewBloc bloc) async {
    await OnlineApi.SelectEmployee(context, 'sales', 'admin');
    final r = await Navigator.push(context,
        MaterialPageRoute(
            builder: (_) =>
            const Employee(Searchby: 1, SearchId: 0)));
    if (r != null) {
      bloc.add(ViewEmployeeSelected(
          objfun.SelectEmployeeList.AccountName,
          objfun.SelectEmployeeList.Id));
      objfun.SelectEmployeeList = EmployeeModel.Empty();
    }
  }

  Future<void> _pickStatus(
      BuildContext context, SalesOrderViewBloc bloc) async {
    final r = await Navigator.push(context,
        MaterialPageRoute(
            builder: (_) =>
            const JobStatus(Searchby: 1, SearchId: 0)));
    if (r != null) {
      bloc.add(ViewStatusSelected(
          objfun.SelectJobStatusList.Name,
          objfun.SelectJobStatusList.Id));
      objfun.SelectJobStatusList = JobStatusModel.Empty();
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
            if (p != null)
              setState(() =>
              _from = DateFormat('yyyy-MM-dd').format(p));
          },
        )),
    const SizedBox(width: 10),
    Expanded(
        child: _dateTile(
          DateFormat('dd-MM-yyyy')
              .format(DateTime.parse(_to)),
              () async {
            final p = await _pickDate(context);
            if (p != null)
              setState(() =>
              _to = DateFormat('yyyy-MM-dd').format(p));
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
                  : colour.border.withOpacity(0.3)),
          color: enabled ? Colors.white : colour.surface,
        ),
        child: Row(children: [
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value.isEmpty ? hint : value,
              style: GoogleFonts.poppins(
                  color: value.isEmpty
                      ? colour.textSub.withOpacity(0.45)
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
                    : colour.textSub.withOpacity(0.25),
                size: 20,
              ),
            ),
          ),
        ]),
      );

  Widget _textTile({
    required String hint,
    required String value,
    required ValueChanged<String> onChanged,
  }) =>
      TextField(
        controller: TextEditingController(text: value),
        onChanged: onChanged,
        textCapitalization: TextCapitalization.characters,
        style: GoogleFonts.poppins(
            color: colour.textMain,
            fontSize: 13,
            fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
              color: colour.textSub.withOpacity(0.45),
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