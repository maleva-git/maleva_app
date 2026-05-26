import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/menu/menulist.dart';

import '../../../../../../core/di/injection.dart';
import '../bloc/saleorderdetails_bloc.dart';
import '../bloc/saleorderdetails_event.dart';
import '../bloc/saleorderdetails_state.dart';




// ── Color tokens (from palette.dart / AppTokens) ──────────────────────────────
// Using the same hex values as Palette.blue700, Palette.blueLight, etc.
// so no external import is needed in this file.

const _kPrimary        = Color(0xFF1A3A8F); // Palette.blue700   – appBar, borders
const _kPrimaryLight   = Color(0xFF5B9BD5); // Palette.blueLight – field fill
const _kDisabled       = Color(0xFFECEEF5); // Palette.grey200   – disabled fill
const _kRed            = Color(0xFFb30c0c); // Palette.redError  – focused border
const _kWhite          = Color(0xFFFFFFFF);
const _kSpinKit        = Color(0xFF0e387a); // Palette.spinKit
const _kNavBar         = Color(0xFFE8EEFF); // Palette.blue50    – bottom nav bg

// ── Layout breakpoint ─────────────────────────────────────────────────────────

bool _isTablet(BuildContext ctx) =>
    MediaQuery.of(ctx).size.width >= 600;

// ─────────────────────────────────────────────────────────────────────────────
// Entry widget
// ─────────────────────────────────────────────────────────────────────────────

class SaleOrderDetails extends StatelessWidget {
  final List<SaleEditDetailModel>? saleDetails;
  final List<dynamic>? saleMaster;

  const SaleOrderDetails({
    super.key,
    this.saleDetails,
    this.saleMaster,
  });

  @override
  Widget build(BuildContext context) {
    return
      BlocProvider(
        create: (_) {
          // 1. Retrieve the BLoC from the service locator
          final bloc = sl<SaleOrderDetailsBloc>();

          // 2. Dispatch the startup event
          bloc.add(const SaleOrderStartupEvent(billType: 'MY'));

          // 3. Dispatch master load if data exists
          if (saleMaster != null && saleMaster!.isNotEmpty) {
            bloc.add(SaleOrderLoadMasterEvent(
              saleMaster: saleMaster!,
              saleDetails: saleDetails ?? [],
            ));
          }
          return bloc;
        },
        child: const _SaleOrderDetailsView(),
      );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal view (reads BLoC)
// ─────────────────────────────────────────────────────────────────────────────

class _SaleOrderDetailsView extends StatefulWidget {
  const _SaleOrderDetailsView();

  @override
  State<_SaleOrderDetailsView> createState() => _SaleOrderDetailsViewState();
}

class _SaleOrderDetailsViewState extends State<_SaleOrderDetailsView>
    with TickerProviderStateMixin {
  late TabController _tabController;

  static const List<String> _billTypes   = ['MY', 'TR'];
  static const List<String> _forwardingNo = ['K1', 'K2', 'K3', 'K8'];
  static const List<String> _zbNo        = ['ZB1', 'ZB2'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 6);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Derived ────────────────────────────────────────────────────────────────

  double get _fontLow    => objfun.FontLow;
  double get _fontMedium => objfun.FontMedium;

  // ── Shared builders ────────────────────────────────────────────────────────

  /// Read-only outlined text field.
  Widget _field({
    required String hint,
    required String value,
    bool readOnly = true,
    bool multiLine = false,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final ctrl = TextEditingController(text: value);
    return TextField(
      controller: ctrl,
      readOnly: readOnly || !enabled,
      showCursor: !readOnly && enabled,
      maxLines: multiLine ? null : 1,
      expands: multiLine,
      keyboardType: multiLine ? TextInputType.multiline : keyboardType,
      textCapitalization: TextCapitalization.characters,
      textInputAction: multiLine ? TextInputAction.newline : TextInputAction.done,
      style: GoogleFonts.lato(
        textStyle: TextStyle(
          color: _kPrimary,
          fontWeight: FontWeight.bold,
          fontSize: _fontLow,
          letterSpacing: 0.3,
        ),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.lato(
          textStyle: TextStyle(
            fontSize: _fontMedium,
            fontWeight: FontWeight.bold,
            color: _kPrimaryLight,
          ),
        ),
        contentPadding:
        const EdgeInsets.only(left: 10, right: 20, top: 10),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kPrimary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kRed),
        ),
      ),
    );
  }

  /// Date-display row: [label] [date box + calendar icon] [checkbox]
  Widget _dateRow({
    required String label,
    required String isoDate,
    required bool checked,
    bool isTablet = false,
  }) {
    final display = DateFormat("dd-MM-yyyy HH:mm:ss")
        .format(DateTime.parse(isoDate));
    final textColor = checked ? _kPrimary : _kDisabled;
    final bgColor   = checked ? _kPrimaryLight : _kDisabled;

    return Row(
      children: [
        const SizedBox(width: 7),
        Expanded(
          flex: isTablet ? 2 : 1,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              textStyle: TextStyle(
                fontSize: _fontMedium,
                color: _kPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          flex: 4,
          child: Container(
            height: 50,
            padding:
            const EdgeInsets.only(left: 10, right: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: bgColor,
              border: Border.all(),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    display,
                    style: GoogleFonts.lato(
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: _fontMedium,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    width: 25,
                    height: 35,
                    decoration: BoxDecoration(
                      image: DecorationImage(image: objfun.calendar),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Transform.scale(
            scale: isTablet ? 1.5 : 1.3,
            child: Checkbox(
              value: checked,
              side: const BorderSide(color: _kPrimary),
              activeColor: _kRed,
              onChanged: null,
            ),
          ),
        ),
      ],
    );
  }

  /// Dropdown for bill type / forwarding / ZB.
  Widget _dropdown({
    required String? value,
    required List<String> items,
    required ValueChanged<String?>? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: _kPrimaryLight,
        border: Border.all(),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          onChanged: onChanged,
          style: GoogleFonts.lato(
            textStyle: TextStyle(
              color: _kPrimary,
              fontWeight: FontWeight.bold,
              fontSize: _fontMedium,
              letterSpacing: 0.3,
            ),
          ),
          items: items
              .map((v) => DropdownMenuItem<String>(
            value: v,
            child: Text(
              v,
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                  color: _kPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: _fontMedium,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ))
              .toList(),
        ),
      ),
    );
  }

  /// Section divider.
  Widget get _divider => const Divider(color: _kPrimaryLight, thickness: 1);

  // ── Forwarding section (FW1/FW2/FW3) ──────────────────────────────────────

  Widget _fwSection({
    required int fwIndex,       // 1, 2 or 3
    required String? ddValue,
    required bool expanded,
    required VoidCallback onToggle,
    required String smk,
    required String enRef,
    required String exRef,
    required String sealBy,
    required String breakBy,
    required bool isTablet,
    required SaleOrderDetailsState st,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 1,
              child: IconButton(
                onPressed: onToggle,
                icon: Icon(
                  expanded
                      ? Icons.arrow_drop_down
                      : Icons.arrow_right_sharp,
                  size: isTablet ? 42 : 35,
                  color: _kPrimary,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                'FW $fwIndex',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    fontSize: _fontMedium,
                    fontWeight: FontWeight.bold,
                    color: _kPrimary,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: _dropdown(
                value: ddValue,
                items: _forwardingNo,
                onChanged: null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        if (expanded) ...[
          _field(hint: 'SMK NO $fwIndex', value: smk),
          const SizedBox(height: 3),
          Row(
            children: [
              Expanded(
                  child: _field(hint: 'EN.Ref $fwIndex', value: enRef)),
              const SizedBox(width: 5),
              Expanded(
                  child: _field(hint: 'EX.Ref $fwIndex', value: exRef)),
            ],
          ),
          const SizedBox(height: 3),
          _field(hint: 'Seal By', value: sealBy),
          const SizedBox(height: 3),
          _field(hint: 'B.Seal By', value: breakBy),
          const SizedBox(height: 3),
        ],
        _divider,
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB CONTENT
  // ═══════════════════════════════════════════════════════════════════════════

  // ── Tab 0 : General ────────────────────────────────────────────────────────

  Widget _tabGeneral(SaleOrderDetailsState st, bool isTablet) {
    final w = MediaQuery.of(context).size.width;
    return ListView(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
      children: [
        // Job No + Date row
        Row(
          children: [
            const SizedBox(width: 7),
            Expanded(
              flex: 1,
              child: Text(
                'Job No :',
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    fontSize: _fontLow,
                    fontWeight: FontWeight.bold,
                    color: _kPrimary,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 50,
                child: Container(
                  padding: const EdgeInsets.only(left: 8),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: _kPrimaryLight,
                    border: Border.all(),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      st.jobNo,
                      style: GoogleFonts.lato(
                        textStyle: TextStyle(
                          color: _kPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: _fontLow - 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                height: 50,
                padding:
                const EdgeInsets.only(left: 10, right: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: _kPrimaryLight,
                  border: Border.all(),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Text(
                        w <= 370
                            ? DateFormat("dd-MM-yy").format(
                            DateTime.parse(st.dtpSaleOrderDate))
                            : DateFormat("dd-MM-yyyy").format(
                            DateTime.parse(st.dtpSaleOrderDate)),
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: _fontLow,
                            color: _kPrimary,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: objfun.calendar),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 7),
          ],
        ),
        const SizedBox(height: 7),

        // Bill type dropdown
        _dropdown(
          value: st.billType,
          items: _billTypes,
          onChanged: st.disabledBillType
              ? null
              : (v) => context.read<SaleOrderDetailsBloc>().add(
            SaleOrderBillTypeChangedEvent(billType: v!),
          ),
        ),
        const SizedBox(height: 7),

        SizedBox(
          height: isTablet ? 65 : 55,
          child: _field(hint: 'Customer Name', value: st.customerName),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: isTablet ? 65 : 55,
          child: _field(hint: 'Job Type', value: st.jobType),
        ),
        const SizedBox(height: 3),
        SizedBox(
          height: isTablet ? 65 : 55,
          child: _field(hint: 'Job Status', value: st.jobStatus),
        ),
        const SizedBox(height: 3),
        SizedBox(
          height: isTablet ? 80 : 65,
          child: _field(
              hint: 'Remarks', value: st.remarks, multiLine: true),
        ),
        const SizedBox(height: 3),
        SizedBox(
          height: isTablet ? 95 : 80,
          child: _field(
              hint: 'Do Description',
              value: st.doDescription,
              multiLine: true),
        ),
      ],
    );
  }

  // ── Tab 1 : Cargo ──────────────────────────────────────────────────────────

  Widget _tabCargo(SaleOrderDetailsState st, bool isTablet) {
    final h = isTablet ? 65.0 : 55.0;
    return ListView(
      padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
      children: [
        SizedBox(height: h, child: _field(hint: 'Commodity Type', value: st.commodityType)),
        const SizedBox(height: 3),
        SizedBox(height: h, child: _field(hint: 'Weight', value: st.weight)),
        const SizedBox(height: 3),
        SizedBox(height: h, child: _field(hint: 'Quantity', value: st.quantity)),
        const SizedBox(height: 3),
        SizedBox(height: h, child: _field(hint: 'Truck Size', value: st.truckSize)),
        const SizedBox(height: 3),
        if (st.visibility.awbNo) ...[
          SizedBox(height: h, child: _field(hint: 'AWB NO', value: st.awbNo)),
          const SizedBox(height: 3),
        ],
        if (st.visibility.blCopy) ...[
          SizedBox(height: h, child: _field(hint: 'BL Copy', value: st.blCopy)),
          const SizedBox(height: 3),
        ],
        SizedBox(height: h, child: _field(hint: 'Cargo', value: st.cargo)),
        const SizedBox(height: 3),
        SizedBox(height: h, child: _field(hint: 'PTW No', value: st.ptwNo)),
      ],
    );
  }

  // ── Tab 2 : Loading vessel ─────────────────────────────────────────────────

  Widget _tabLoadingVessel(SaleOrderDetailsState st, bool isTablet) {
    final h = isTablet ? 65.0 : 55.0;
    final v = st.visibility;
    return ListView(
      padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
      children: [
        if (v.lEta) ...[
          _dateRow(label: 'ETA', isoDate: st.dtpLEta, checked: st.checkLEta, isTablet: isTablet),
          const SizedBox(height: 5),
        ],
        if (v.lEtb) ...[
          _dateRow(label: 'ETB', isoDate: st.dtpLEtb, checked: st.checkLEtb, isTablet: isTablet),
          const SizedBox(height: 5),
        ],
        if (v.lEtd) ...[
          _dateRow(label: 'ETD', isoDate: st.dtpLEtd, checked: st.checkLEtd, isTablet: isTablet),
          const SizedBox(height: 7),
        ],
        if (v.lShippingAgent) ...[
          SizedBox(height: h, child: _field(hint: 'Shipping Agent', value: st.lAgentCompany)),
          const SizedBox(height: 5),
        ],
        if (v.lAgentName) ...[
          SizedBox(height: h, child: _field(hint: 'Agent Name', value: st.lAgentName)),
          const SizedBox(height: 5),
        ],
        if (v.lScn) ...[
          SizedBox(height: h, child: _field(hint: 'SCN', value: st.lScn)),
        ],
        if (v.loadingVessel) ...[
          const SizedBox(height: 3),
          SizedBox(height: h, child: _field(hint: 'Loading Vessel Name', value: st.loadingVessel)),
        ],
        const SizedBox(height: 5),
        if (v.lPort) ...[
          SizedBox(height: h, child: _field(hint: 'Port', value: st.lPort)),
          const SizedBox(height: 4),
        ],
        if (v.lVesselType) ...[
          SizedBox(height: h, child: _field(hint: 'Vessel Type', value: st.lVesselType)),
        ],
      ],
    );
  }

  // ── Tab 3 : Off-load vessel ────────────────────────────────────────────────

  Widget _tabOffVessel(SaleOrderDetailsState st, bool isTablet) {
    final h = isTablet ? 65.0 : 55.0;
    final v = st.visibility;
    return ListView(
      padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
      children: [
        if (v.oEta) ...[
          _dateRow(label: 'ETA', isoDate: st.dtpOEta, checked: st.checkOEta, isTablet: isTablet),
          const SizedBox(height: 5),
        ],
        if (v.oEtb) ...[
          _dateRow(label: 'ETB', isoDate: st.dtpOEtb, checked: st.checkOEtb, isTablet: isTablet),
          const SizedBox(height: 5),
        ],
        if (v.oEtd) ...[
          _dateRow(label: 'ETD', isoDate: st.dtpOEtd, checked: st.checkOEtd, isTablet: isTablet),
          const SizedBox(height: 7),
        ],
        if (v.oShippingAgent) ...[
          SizedBox(height: h, child: _field(hint: 'Shipping Agent', value: st.oAgentCompany)),
          const SizedBox(height: 5),
        ],
        if (v.oAgentName) ...[
          SizedBox(height: h, child: _field(hint: 'Agent Name', value: st.oAgentName)),
          const SizedBox(height: 5),
        ],
        if (v.oScn) ...[
          SizedBox(height: h, child: _field(hint: 'SCN', value: st.oScn)),
        ],
        if (v.offVessel) ...[
          const SizedBox(height: 3),
          SizedBox(height: h, child: _field(hint: 'Off Vessel Name', value: st.offVessel)),
        ],
        const SizedBox(height: 5),
        if (v.oPort) ...[
          SizedBox(height: h, child: _field(hint: 'Port', value: st.oPort)),
          const SizedBox(height: 4),
        ],
        if (v.oVesselType) ...[
          SizedBox(height: h, child: _field(hint: 'Vessel Type', value: st.oVesselType)),
        ],
      ],
    );
  }

  // ── Tab 4 : Schedule / Addresses ──────────────────────────────────────────

  Widget _tabSchedule(SaleOrderDetailsState st, bool isTablet) {
    final h = isTablet ? 65.0 : 55.0;
    final addrH = isTablet ? 110.0 : 90.0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
      children: [
        _dateRow(
            label: 'PickUp Date',
            isoDate: st.dtpPickUpDate,
            checked: st.checkPickUp,
            isTablet: isTablet),
        const SizedBox(height: 7),
        _dateRow(
            label: 'Delivery Date',
            isoDate: st.dtpDeliveryDate,
            checked: st.checkDelivery,
            isTablet: isTablet),
        const SizedBox(height: 7),
        _dateRow(
            label: 'WareHouse Entry Date',
            isoDate: st.dtpWhEntryDate,
            checked: st.checkWhEntry,
            isTablet: isTablet),
        const SizedBox(height: 7),
        _dateRow(
            label: 'Warehouse Exit Date',
            isoDate: st.dtpWhExitDate,
            checked: st.checkWhExit,
            isTablet: isTablet),
        const SizedBox(height: 7),
        if (st.visibility.origin) ...[
          SizedBox(height: h, child: _field(hint: 'Origin', value: st.origin)),
          const SizedBox(height: 3),
        ],
        if (st.visibility.destination) ...[
          SizedBox(height: h, child: _field(hint: 'Destination', value: st.destination)),
          const SizedBox(height: 5),
        ],
        // PickUp address + list button
        SizedBox(
          height: addrH,
          child: Row(
            children: [
              Expanded(
                flex: 6,
                child: _field(
                    hint: 'PickUp Address',
                    value: st.pickUpAddress,
                    multiLine: true),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () =>
                          _showPickUpDialog(context, st),
                      icon: Icon(Icons.list,
                          size: isTablet ? 42 : 35,
                          color: _kPrimary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        // Delivery address + list button
        SizedBox(
          height: addrH,
          child: Row(
            children: [
              Expanded(
                flex: 6,
                child: _field(
                    hint: 'Delivery Address',
                    value: st.deliveryAddress,
                    multiLine: true),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () =>
                          _showDeliveryDialog(context, st),
                      icon: Icon(Icons.list,
                          size: isTablet ? 42 : 35,
                          color: _kPrimary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 3),
        SizedBox(
          height: addrH,
          child: _field(
              hint: 'Warehouse Address',
              value: st.warehouseAddress,
              multiLine: true),
        ),
        const SizedBox(height: 3),
      ],
    );
  }

  // ── Tab 5 : Forwarding / Boarding ─────────────────────────────────────────

  Widget _tabForwarding(SaleOrderDetailsState st, bool isTablet) {
    final h = isTablet ? 65.0 : 55.0;
    final bloc = context.read<SaleOrderDetailsBloc>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
      children: [
        // ── FW 1 / 2 / 3 ────────────────────────────────────────────────────
        if (st.visibility.forwarding) ...[
          _fwSection(
            fwIndex: 1,
            ddValue: st.dropdownFW1,
            expanded: st.visibleFW1,
            onToggle: () =>
                bloc.add(const SaleOrderToggleFW1Event()),
            smk: st.smk1,
            enRef: st.enRef1,
            exRef: st.exRef1,
            sealBy: st.sealByEmp1,
            breakBy: st.breakByEmp1,
            isTablet: isTablet,
            st: st,
          ),
          _fwSection(
            fwIndex: 2,
            ddValue: st.dropdownFW2,
            expanded: st.visibleFW2,
            onToggle: () =>
                bloc.add(const SaleOrderToggleFW2Event()),
            smk: st.smk2,
            enRef: st.enRef2,
            exRef: st.exRef2,
            sealBy: st.sealByEmp2,
            breakBy: st.breakByEmp2,
            isTablet: isTablet,
            st: st,
          ),
          _fwSection(
            fwIndex: 3,
            ddValue: st.dropdownFW3,
            expanded: st.visibleFW3,
            onToggle: () =>
                bloc.add(const SaleOrderToggleFW3Event()),
            smk: st.smk3,
            enRef: st.enRef3,
            exRef: st.exRef3,
            sealBy: st.sealByEmp3,
            breakBy: st.breakByEmp3,
            isTablet: isTablet,
            st: st,
          ),
        ],

        // ── ZB 1 / 2 ─────────────────────────────────────────────────────────
        if (st.visibility.zb) ...[
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'ZB 1',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                      fontSize: _fontMedium,
                      fontWeight: FontWeight.bold,
                      color: _kPrimary,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: _dropdown(
                    value: st.dropdownZB1,
                    items: _zbNo,
                    onChanged: null),
              ),
            ],
          ),
          const SizedBox(height: 3),
          SizedBox(
              height: h,
              child: _field(hint: 'ZB Ref 1', value: st.zbRef1)),
          const SizedBox(height: 3),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'ZB 2',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                      fontSize: _fontMedium,
                      fontWeight: FontWeight.bold,
                      color: _kPrimary,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: _dropdown(
                    value: st.dropdownZB2,
                    items: _zbNo,
                    onChanged: null),
              ),
            ],
          ),
          const SizedBox(height: 3),
          SizedBox(
              height: h,
              child: _field(hint: 'ZB Ref 2', value: st.zbRef2)),
          _divider,
        ],

        // ── Boarding officer 1 ───────────────────────────────────────────────
        SizedBox(
            height: h,
            child:
            _field(hint: 'Boarding Officer 1', value: st.boardingOfficer1)),
        const SizedBox(height: 3),
        SizedBox(
          height: h,
          child: TextField(
            controller: TextEditingController(text: st.amount1),
            readOnly: st.disabledAmount1,
            showCursor: !st.disabledAmount1,
            style: GoogleFonts.lato(
              textStyle: TextStyle(
                  color: _kPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: _fontLow,
                  letterSpacing: 0.3),
            ),
            decoration: InputDecoration(
              hintText: 'Amount 1',
              hintStyle: GoogleFonts.lato(
                textStyle: TextStyle(
                    fontSize: _fontMedium,
                    fontWeight: FontWeight.bold,
                    color: _kPrimaryLight),
              ),
              contentPadding:
              const EdgeInsets.only(left: 10, right: 20, top: 10),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _kPrimary)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _kRed)),
            ),
          ),
        ),
        const SizedBox(height: 3),
        SizedBox(
            height: h,
            child: _field(
                hint: 'Port Charges Ref', value: st.portChargeRef1)),
        _divider,

        // ── Boarding officer 2 ───────────────────────────────────────────────
        SizedBox(
            height: h,
            child:
            _field(hint: 'Boarding Officer 2', value: st.boardingOfficer2)),
        const SizedBox(height: 3),
        SizedBox(
          height: h,
          child: TextField(
            controller: TextEditingController(text: st.amount2),
            readOnly: st.disabledAmount2,
            showCursor: !st.disabledAmount2,
            style: GoogleFonts.lato(
              textStyle: TextStyle(
                  color: _kPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: _fontLow,
                  letterSpacing: 0.3),
            ),
            decoration: InputDecoration(
              hintText: 'Amount 2',
              hintStyle: GoogleFonts.lato(
                textStyle: TextStyle(
                    fontSize: _fontMedium,
                    fontWeight: FontWeight.bold,
                    color: _kPrimaryLight),
              ),
              contentPadding:
              const EdgeInsets.only(left: 10, right: 20, top: 10),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _kPrimary)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _kRed)),
            ),
          ),
        ),
        const SizedBox(height: 3),
        SizedBox(
            height: h,
            child:
            _field(hint: 'Port Charges', value: st.portCharges)),
        const SizedBox(height: 10),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Dialogs
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _showPickUpDialog(
      BuildContext ctx, SaleOrderDetailsState st) async {
    final size = MediaQuery.of(ctx).size;
    final bloc = ctx.read<SaleOrderDetailsBloc>();

    await showDialog(
      barrierDismissible: false,
      context: ctx,
      builder: (_) => StatefulBuilder(
        builder: (_, setS) => Dialog(
          elevation: 40,
          child: Container(
            width: size.width * 0.65,
            height: size.height * 0.65,
            margin: const EdgeInsets.only(right: 15, left: 15, top: 7),
            child: Column(
              children: [
                // Close button
                Row(
                  children: [
                    const Spacer(),
                    FloatingActionButton(
                      mini: true,
                      backgroundColor: _kPrimary,
                      heroTag: 'btnPickupClose',
                      onPressed: () => Navigator.of(_, rootNavigator: true).pop(),
                      child: const Icon(Icons.close,
                          color: _kWhite, size: 22),
                    ),
                  ],
                ),
                // Title
                Container(
                  color: _kPrimary,
                  padding: const EdgeInsets.symmetric(
                      vertical: 8, horizontal: 12),
                  child: Text(
                    'PickUp Address List',
                    style: GoogleFonts.lato(
                      textStyle: TextStyle(
                          color: _kWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: _fontMedium),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // List
                Expanded(
                  child: st.pickUpAddressList.isEmpty
                      ? const Center(child: Text('No Record'))
                      : ListView.builder(
                    itemCount: st.pickUpAddressList.length,
                    itemBuilder: (_, i) {
                      return InkWell(
                        onLongPress: () async {
                          final confirm =
                          await objfun.ConfirmationMsgYesNo(
                              _, 'Are you sure to delete ?');
                          if (confirm) {
                            bloc.add(
                                SaleOrderDeletePickUpAddressEvent(
                                    index: i));
                            setS(() {});
                          }
                        },
                        onTap: () {
                          bloc.add(
                              SaleOrderSelectPickUpAddressEvent(
                                  address: st.pickUpAddressList[i]
                                      .toString()));
                          Navigator.of(_, rootNavigator: true).pop();
                        },
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                color: _kPrimary, width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              st.pickUpAddressList[i].toString(),
                              textAlign: TextAlign.justify,
                              style: GoogleFonts.lato(
                                textStyle: TextStyle(
                                    color: _kPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: _fontLow,
                                    letterSpacing: 0.3),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDeliveryDialog(
      BuildContext ctx, SaleOrderDetailsState st) async {
    final size = MediaQuery.of(ctx).size;
    final bloc = ctx.read<SaleOrderDetailsBloc>();

    await showDialog(
      barrierDismissible: false,
      context: ctx,
      builder: (_) => StatefulBuilder(
        builder: (_, setS) => Dialog(
          elevation: 40,
          child: Container(
            width: size.width * 0.65,
            height: size.height * 0.65,
            margin: const EdgeInsets.only(right: 15, left: 15, top: 7),
            child: Column(
              children: [
                Row(
                  children: [
                    const Spacer(),
                    FloatingActionButton(
                      mini: true,
                      backgroundColor: _kPrimary,
                      heroTag: 'btnDeliveryClose',
                      onPressed: () =>
                          Navigator.of(_, rootNavigator: true).pop(),
                      child: const Icon(Icons.close,
                          color: _kWhite, size: 22),
                    ),
                  ],
                ),
                Container(
                  color: _kPrimary,
                  padding: const EdgeInsets.symmetric(
                      vertical: 8, horizontal: 10),
                  child: Text(
                    'Delivery Address List',
                    style: GoogleFonts.lato(
                      textStyle: TextStyle(
                          color: _kWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: _fontMedium),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: st.deliveryAddressList.isEmpty
                      ? const Center(child: Text('No Record'))
                      : ListView.builder(
                    itemCount: st.deliveryAddressList.length,
                    itemBuilder: (_, i) {
                      return InkWell(
                        onLongPress: () async {
                          final confirm =
                          await objfun.ConfirmationMsgYesNo(
                              _, 'Are you sure to delete ?');
                          if (confirm) {
                            bloc.add(
                                SaleOrderDeleteDeliveryAddressEvent(
                                    index: i));
                            setS(() {});
                          }
                        },
                        onTap: () {
                          bloc.add(
                              SaleOrderSelectDeliveryAddressEvent(
                                  address: st.deliveryAddressList[i]
                                      .toString()));
                          Navigator.of(_, rootNavigator: true).pop();
                        },
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                color: _kPrimary, width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              st.deliveryAddressList[i].toString(),
                              textAlign: TextAlign.justify,
                              style: GoogleFonts.lato(
                                textStyle: TextStyle(
                                    color: _kPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: _fontLow,
                                    letterSpacing: 0.3),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Bottom nav
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _bottomNav(SaleOrderDetailsState st, bool isTablet) {
    final iconSize = isTablet ? 32.0 : 26.0;
    return Card(
      elevation: 6,
      color: _kNavBar,
      margin: EdgeInsets.zero,
      child: SalomonBottomBar(
        duration: const Duration(milliseconds: 400),
        items: [
          SalomonBottomBarItem(
            icon: Icon(Icons.info_outline, color: _kPrimary, size: iconSize),
            title: const Text(''),
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.comment_outlined, color: _kPrimary, size: iconSize),
            title: const Text(''),
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.directions_boat_filled,
                color: _kPrimary, size: iconSize),
            title: const Text(''),
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.directions_boat_filled_outlined,
                color: _kPrimary, size: iconSize),
            title: const Text(''),
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.rate_review_outlined,
                color: _kPrimary, size: iconSize),
            title: const Text(''),
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.local_shipping_sharp,
                color: _kPrimary, size: iconSize),
            title: const Text(''),
          ),
        ],
        currentIndex: st.currentTabIndex,
        onTap: (i) {
          _tabController.index = i;
          context
              .read<SaleOrderDetailsBloc>()
              .add(SaleOrderTabChangedEvent(index: i));
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Build
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);

    return BlocBuilder<SaleOrderDetailsBloc, SaleOrderDetailsState>(
      builder: (ctx, st) {
        // Keep tab controller in sync when BLoC changes tab (e.g. from external).
        if (_tabController.index != st.currentTabIndex) {
          _tabController.index = st.currentTabIndex;
        }

        return WillPopScope(
          onWillPop: () async {
            Navigator.of(ctx).pop();
            return true;
          },
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Colors.white,
            appBar: _buildAppBar(st, isTablet),
            drawer: const Menulist(),
            body: st.status == SaleOrderStatus.loading ||
                st.status == SaleOrderStatus.initial
                ? const Center(
              child: SpinKitFoldingCube(
                color: _kSpinKit,
                size: 35,
              ),
            )
                : TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _tabGeneral(st, isTablet),
                _tabCargo(st, isTablet),
                _tabLoadingVessel(st, isTablet),
                _tabOffVessel(st, isTablet),
                _tabSchedule(st, isTablet),
                _tabForwarding(st, isTablet),
              ],
            ),
            bottomNavigationBar: _bottomNav(st, isTablet),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(SaleOrderDetailsState st, bool isTablet) {
    return AppBar(
      automaticallyImplyLeading: true,
      backgroundColor: _kPrimary,
      iconTheme: const IconThemeData(color: _kWhite),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sales Order',
            style: GoogleFonts.lato(
              textStyle: TextStyle(
                color: _kWhite,
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? objfun.FontMedium : objfun.FontLow,
              ),
            ),
          ),
          Text(
            st.userName,
            style: GoogleFonts.lato(
              textStyle: TextStyle(
                color: _kPrimaryLight,
                fontWeight: FontWeight.bold,
                fontSize: isTablet
                    ? objfun.FontLow - 2
                    : objfun.FontLow - 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}