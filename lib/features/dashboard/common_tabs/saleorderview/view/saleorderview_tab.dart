import 'package:maleva/core/network/api_legacy_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/menu/menulist.dart';
import '../../../../../core/bluetooth/view/Bluetooth_tab.dart';
import '../../../../../core/theme/tokens.dart';
import '../../../../mastersearch/Customer.dart';
import '../../../../mastersearch/Employee.dart';
import '../../../../mastersearch/JobStatus.dart';
import '../bloc/saleorderview_bloc.dart';
import '../bloc/saleorderview_event.dart';
import '../bloc/saleorderview_state.dart';
import '../data/saleorderrepository.dart';
import 'package:maleva/core/models/shared/barcode_print_model.dart';
import 'package:maleva/core/models/shared/customer_model.dart';
import 'package:maleva/core/models/shared/employee_model.dart';
import 'package:maleva/features/transaction/salesorder/models/sale_order_master_model.dart';
import 'package:maleva/features/operations/models/job_status_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

class Saleorderview extends StatelessWidget {
  const Saleorderview({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SaleOrderBloc(
        repository: SaleOrderRepository(), // <-- Pass the repository here
      )..add(const SaleOrderStartupRequested()),
      child: const _SaleOrderView(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal view (stateful for TextEditingControllers only)
// ─────────────────────────────────────────────────────────────────────────────

class _SaleOrderView extends StatefulWidget {
  const _SaleOrderView();

  @override
  State<_SaleOrderView> createState() => _SaleOrderViewState();
}

class _SaleOrderViewState extends State<_SaleOrderView> {
  // Controllers live here (UI layer only — not in BLoC)
  final _txtJobNo         = TextEditingController();
  final _txtLoadingVessel = TextEditingController();
  final _txtOffVessel     = TextEditingController();
  final _txtCustomer      = TextEditingController();
  final _txtEmployee      = TextEditingController();
  final _txtStatus        = TextEditingController();

  // Local ETA dialog state (dialog-internal only)
  DateTime? _dlgLeta, _dlgLetb, _dlgOeta, _dlgOetb;

  @override
  void dispose() {
    _txtJobNo.dispose();
    _txtLoadingVessel.dispose();
    _txtOffVessel.dispose();
    _txtCustomer.dispose();
    _txtEmployee.dispose();
    _txtStatus.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _dispatchSearchText() {
    context.read<SaleOrderBloc>().add(SaleOrderSearchTextChanged(
      jobNo:         _txtJobNo.text,
      loadingVessel: _txtLoadingVessel.text,
      offVessel:     _txtOffVessel.text,
    ));
  }

  Future<void> _pickDate(
      BuildContext ctx,
      String initial,
      void Function(String) onPicked,
      ) async {
    final picked = await showDatePicker(
      context: ctx,
      initialDate: DateTime.tryParse(initial) ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTokens.brandPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) onPicked(DateFormat('yyyy-MM-dd').format(picked));
  }

  // ── ETA date popup ────────────────────────────────────────────────────────

  void _openETAPopup(BuildContext ctx) {
    final bloc = ctx.read<SaleOrderBloc>();
    final st   = bloc.state;
    _dlgLeta = st.leta;
    _dlgLetb = st.letb;
    _dlgOeta = st.oeta;
    _dlgOetb = st.oetb;

    showDialog(
      context: ctx,
      builder: (_) => StatefulBuilder(
        builder: (dCtx, setDlg) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Select ETA Dates',
            style: GoogleFonts.lato(
              fontWeight: FontWeight.bold,
              color: AppTokens.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _etaDateField(dCtx, 'LETA', _dlgLeta, (v) => setDlg(() => _dlgLeta = v)),
              _etaDateField(dCtx, 'LETB', _dlgLetb, (v) => setDlg(() => _dlgLetb = v)),
              _etaDateField(dCtx, 'OETA', _dlgOeta, (v) => setDlg(() => _dlgOeta = v)),
              _etaDateField(dCtx, 'OETB', _dlgOetb, (v) => setDlg(() => _dlgOetb = v)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dCtx),
              child: Text('Cancel',
                  style: GoogleFonts.lato(color: AppTokens.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTokens.brandPrimary,
                foregroundColor: Palette.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.pop(dCtx);
                bloc.add(SaleOrderETADatesSet(
                  leta: _dlgLeta,
                  letb: _dlgLetb,
                  oeta: _dlgOeta,
                  oetb: _dlgOetb,
                ));
              },
              child: Text('Confirm', style: GoogleFonts.lato()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _etaDateField(
      BuildContext ctx,
      String label,
      DateTime? value,
      void Function(DateTime) onSelect,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        readOnly: true,
        controller: TextEditingController(
          text: value == null ? '' : DateFormat('yyyy-MM-dd').format(value),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.lato(color: AppTokens.textSecondary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
            const BorderSide(color: AppTokens.brandPrimary, width: 1.5),
          ),
          suffixIcon: const Icon(Icons.calendar_today,
              size: 18, color: AppTokens.brandPrimary),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        onTap: () async {
          final picked = await showDatePicker(
            context: ctx,
            initialDate: value ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (picked != null) onSelect(picked);
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.surfacePage,
      appBar: _buildAppBar(context),
      drawer: const Menulist(),
      body: BlocConsumer<SaleOrderBloc, SaleOrderState>(
        listener: _handleListener,
        builder: (ctx, state) {
          if (state.status == SaleOrderStatus.initial ||
              state.isLoading) {
            return const Center(
              child: SpinKitFoldingCube(
                color: AppTokens.spinKit,
                size: 35.0,
              ),
            );
          }
          if (state.status == SaleOrderStatus.failure) {
            return _ErrorWidget(
              message: state.errorMessage,
              onRetry: () => ctx
                  .read<SaleOrderBloc>()
                  .add(const SaleOrderDataRequested()),
            );
          }
          return _buildBody(ctx, state);
        },
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        decoration:
        const BoxDecoration(gradient: AppTokens.headerGradient),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppTokens.appBarIcon),
      title: Text(
        'Dash Board',
        style: GoogleFonts.lato(
          textStyle: const TextStyle(
            color: AppTokens.appBarTitle,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.directions_boat_filled, size: 24),
          tooltip: 'Shipment',
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.bluetooth_audio, size: 24),
          tooltip: 'Bluetooth',
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const BluetoothPage())),
        ),
        IconButton(
          icon: const Icon(Icons.print, size: 24),
          tooltip: 'Print',
          onPressed: () async {
            await printdata([
              BarcodePrintModel(
                'MALEVA', 'SHIPNAME', 'SHIPNAME', 'B0005000',
                '2025-05-04', 'WESTPORT', 'WESTPORT', '(1/3)',
              )
            ]);
          },
        ),
        IconButton(
          icon: const Icon(Icons.exit_to_app, size: 26),
          tooltip: 'Logout',
          onPressed: () => ApiLegacyHelper.logout(context),
        ),
      ],
    );
  }

  // ── Listener ──────────────────────────────────────────────────────────────

  void _handleListener(BuildContext ctx, SaleOrderState state) {
    if (state.status == SaleOrderStatus.failure &&
        state.errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        backgroundColor: Palette.redError,
        content: Text(state.errorMessage,
            style: GoogleFonts.lato(color: Palette.white)),
        duration: const Duration(seconds: 3),
      ));
    }
    if (state.isUpdating) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        backgroundColor: AppTokens.brandPrimary,
        content: Text('Updating…',
            style: GoogleFonts.lato(color: Palette.white)),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  // ── Main body ─────────────────────────────────────────────────────────────

  Widget _buildBody(BuildContext ctx, SaleOrderState state) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final bool isTablet = constraints.maxWidth >= 600;

        return RefreshIndicator(
          color: AppTokens.brandPrimary,
          onRefresh: () async {
            ctx.read<SaleOrderBloc>().add(const SaleOrderRefreshRequested());
            await Future.delayed(const Duration(milliseconds: 600));
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 16 : 6, vertical: 6),
            child: Column(
              children: [
                // ── Date row ────────────────────────────────────────────
                _DateRow(
                  fromDate: state.fromDate,
                  toDate: state.toDate,
                  isTablet: isTablet,
                  onFromTap: () => _pickDate(
                    ctx,
                    state.fromDate,
                        (d) => ctx
                        .read<SaleOrderBloc>()
                        .add(SaleOrderFromDateChanged(d)),
                  ),
                  onToTap: () => _pickDate(
                    ctx,
                    state.toDate,
                        (d) => ctx
                        .read<SaleOrderBloc>()
                        .add(SaleOrderToDateChanged(d)),
                  ),
                ),

                const SizedBox(height: 6),

                // ── Action buttons ───────────────────────────────────────
                _ActionButtons(
                  isTablet: isTablet,
                  onView: () {
                    _dispatchSearchText();
                    ctx.read<SaleOrderBloc>().add(const SaleOrderDataRequested());
                  },
                  onFilter: () => _showFilterSheet(ctx, state, isTablet),
                  onDates: () => _openETAPopup(ctx),
                  onUpdate: () {
                    ctx.read<SaleOrderBloc>().add(const SaleOrderUpdateRequested());
                  },
                ),

                const SizedBox(height: 6),

                // ── Summary pill ─────────────────────────────────────────
                _SummaryPill(count: state.masterList.length),

                const SizedBox(height: 4),

                // ── List ─────────────────────────────────────────────────
                Expanded(
                  child: state.isEmpty
                      ? const _EmptyWidget()
                      : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: state.masterList.length,
                    itemBuilder: (_, i) => _SaleOrderCard(
                      index: i,
                      item: state.masterList[i],
                      bgColor: state.cardColor(i),
                      isExpanded: state.currentlyVisibleIndex == i,
                      isTablet: isTablet,
                      onTap: () => ctx
                          .read<SaleOrderBloc>()
                          .add(SaleOrderCardToggled(i)),
                      onChecked: (v) => ctx
                          .read<SaleOrderBloc>()
                          .add(SaleOrderItemChecked(i, v)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Filter bottom sheet ───────────────────────────────────────────────────

  void _showFilterSheet(
      BuildContext ctx, SaleOrderState state, bool isTablet) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: AppTokens.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: ctx.read<SaleOrderBloc>(),
        child: _FilterSheet(
          txtCustomer:      _txtCustomer,
          txtEmployee:      _txtEmployee,
          txtStatus:        _txtStatus,
          txtJobNo:         _txtJobNo,
          txtLoadingVessel: _txtLoadingVessel,
          txtOffVessel:     _txtOffVessel,
          onView: () {
            _dispatchSearchText();
            ctx.read<SaleOrderBloc>().add(const SaleOrderDataRequested());
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Date row widget
// ─────────────────────────────────────────────────────────────────────────────

class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.fromDate,
    required this.toDate,
    required this.isTablet,
    required this.onFromTap,
    required this.onToTap,
  });

  final String fromDate;
  final String toDate;
  final bool isTablet;
  final VoidCallback onFromTap;
  final VoidCallback onToTap;

  @override
  Widget build(BuildContext context) {
    final double fs = isTablet ? 14 : 12;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTokens.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Palette.brandGlow.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Palette.grey200.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildDateSelector('From', fromDate, onFromTap, fs),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTokens.brandPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.arrow_forward_rounded, size: 16, color: AppTokens.brandPrimary),
          ),
          _buildDateSelector('To', toDate, onToTap, fs),
        ],
      ),
    );
  }

  Widget _buildDateSelector(String label, String dateStr, VoidCallback onTap, double fs) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: GoogleFonts.lato(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppTokens.textMuted,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_month_rounded, size: 16, color: AppTokens.brandPrimary),
                const SizedBox(width: 6),
                Text(
                  DateFormat('dd MMM yyyy').format(DateTime.parse(dateStr)),
                  style: GoogleFonts.lato(
                    fontSize: fs,
                    fontWeight: FontWeight.w700,
                    color: AppTokens.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Action buttons row
// ─────────────────────────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.isTablet,
    required this.onView,
    required this.onFilter,
    required this.onDates,
    required this.onUpdate,
  });

  final bool isTablet;
  final VoidCallback onView;
  final VoidCallback onFilter;
  final VoidCallback onDates;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    final double fs = isTablet ? 14 : 12;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _btn('View',   Icons.search_rounded,       onView,   AppTokens.brandPrimary, fs),
          const SizedBox(width: 8),
          _btn('Filter', Icons.filter_alt_rounded,   onFilter, AppTokens.planCobalt,  fs),
          const SizedBox(width: 8),
          _btn('Dates',  Icons.calendar_today_rounded, onDates,  AppTokens.statusWarning, fs),
          const SizedBox(width: 8),
          _btn('Update', Icons.save_rounded,         onUpdate, AppTokens.statusSuccess, fs),
        ],
      ),
    );
  }

  Widget _btn(String label, IconData icon, VoidCallback onPressed,
      Color color, double fs) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Palette.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        shadowColor: color.withValues(alpha: 0.4),
      ).copyWith(
        elevation: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) return 2;
          if (states.contains(WidgetState.hovered)) return 4;
          return 0; // Flat design by default, elevates on hover
        }),
      ),
      icon: Icon(icon, size: 16),
      label: Text(label, style: GoogleFonts.lato(fontSize: fs, fontWeight: FontWeight.bold)),
      onPressed: onPressed,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary pill
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTokens.surfaceCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Palette.grey200),
        boxShadow: [
          BoxShadow(
            color: Palette.brandGlow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.analytics_rounded, size: 16, color: AppTokens.brandPrimary),
          const SizedBox(width: 8),
          Text(
            'Total Orders: ',
            style: GoogleFonts.lato(
              color: AppTokens.textSecondary,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          Text(
            '$count',
            style: GoogleFonts.lato(
              color: AppTokens.brandPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sale Order Card
// ─────────────────────────────────────────────────────────────────────────────

class _SaleOrderCard extends StatelessWidget {
  const _SaleOrderCard({
    required this.index,
    required this.item,
    required this.bgColor,
    required this.isExpanded,
    required this.isTablet,
    required this.onTap,
    required this.onChecked,
  });

  final int index;
  final SaleOrderMasterModel item;
  final Color? bgColor;
  final bool isExpanded;
  final bool isTablet;
  final VoidCallback onTap;
  final void Function(bool) onChecked;

  @override
  Widget build(BuildContext context) {
    final double fs = isTablet ? 13.5 : 12;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      decoration: BoxDecoration(
        color: bgColor ?? AppTokens.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Palette.brandGlow.withValues(alpha: isExpanded ? 0.15 : 0.05),
            blurRadius: isExpanded ? 12 : 6,
            offset: Offset(0, isExpanded ? 4 : 2),
          ),
        ],
        border: Border.all(color: Palette.grey200.withValues(alpha: 0.6), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: _getStatusColor(item.JobStatus),
                    width: 5,
                  ),
                ),
              ),
              padding: EdgeInsets.all(isTablet ? 16 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Header row ─────────────────────────────────────
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: item.isETASelected,
                          activeColor: AppTokens.brandPrimary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                          onChanged: (v) => onChecked(v ?? false),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.BillNoDisplay,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.lato(
                            fontSize: fs + 2,
                            fontWeight: FontWeight.w800,
                            color: AppTokens.textPrimary,
                          ),
                        ),
                      ),
                      _StatusChip(label: item.JobStatus, fontSize: fs - 1),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppTokens.textSecondary,
                          size: 22,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // ── Vessel row ─────────────────────────────────────
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTokens.brandPrimary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.directions_boat_rounded,
                            size: 14, color: AppTokens.brandPrimary),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.lato(
                              fontSize: fs,
                              color: AppTokens.textSecondary,
                            ),
                            children: [
                              TextSpan(
                                text: item.Loadingvesselname,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              const TextSpan(text: '  ➔  '),
                              TextSpan(
                                text: item.Offvesselname,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // ── Expanded Content ───────────────────────────────
                  AnimatedCrossFade(
                    firstChild: const SizedBox(width: double.infinity, height: 0),
                    secondChild: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),

                        // ── Employee ───────────────────────────────────
                        Row(
                          children: [
                            const Icon(Icons.person_pin_circle_rounded,
                                size: 16, color: AppTokens.textSecondary),
                            const SizedBox(width: 6),
                            Text(
                              item.EmployeeName,
                              style: GoogleFonts.lato(
                                  fontSize: fs,
                                  fontWeight: FontWeight.w600,
                                  color: AppTokens.textPrimary),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // ── Route ──────────────────────────────────────
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Palette.grey200.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.alt_route_rounded,
                                  size: 16, color: AppTokens.brandPrimary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${item.Origin}  ➔  ${item.Destination}',
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.lato(
                                      fontSize: fs,
                                      fontWeight: FontWeight.w600,
                                      color: AppTokens.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ── ETA chips ──────────────────────────────────
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _ETAChip(label: 'SETA',  value: item.SETA,  fs: fs - 2),
                            _ETAChip(label: 'SETB',  value: item.SETB,  fs: fs - 2),
                            _ETAChip(label: 'SOETA', value: item.SOETA, fs: fs - 2),
                            _ETAChip(label: 'SOETB', value: item.SOETB, fs: fs - 2),
                          ],
                        ),
                      ],
                    ),
                    crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 250),
                    sizeCurve: Curves.easeOutCubic,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status.toLowerCase().contains('cancel')) return Palette.redError;
    if (status.toLowerCase().contains('complete')) return AppTokens.statusSuccess;
    if (status.toLowerCase().contains('progress')) return AppTokens.statusWarning;
    return AppTokens.brandPrimary;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Micro widgets
// ─────────────────────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.fontSize});
  final String label;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    // Dynamic color based on status text
    Color chipColor = AppTokens.brandPrimary;
    if (label.toLowerCase().contains('cancel')) chipColor = Palette.redError;
    if (label.toLowerCase().contains('complete')) chipColor = AppTokens.statusSuccess;
    if (label.toLowerCase().contains('progress')) chipColor = AppTokens.statusWarning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipColor.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Text(
        label,
        style: GoogleFonts.lato(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          color: chipColor,
        ),
      ),
    );
  }
}

class _ETAChip extends StatelessWidget {
  const _ETAChip(
      {required this.label, required this.value, required this.fs});
  final String label;
  final String value;
  final double fs;

  @override
  Widget build(BuildContext context) {
    final bool hasValue = value.isNotEmpty && value != 'null';
    const Color successText = Color(0xFF047857); // Deep Emerald Green
    final Color successBg = const Color(0xFF059669).withValues(alpha: 0.12); // Soft Emerald
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: hasValue ? successBg : Palette.grey200.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasValue ? successText.withValues(alpha: 0.3) : Palette.grey200.withValues(alpha: 0.8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasValue ? Icons.check_circle_outline_rounded : Icons.access_time_rounded,
            size: fs + 2,
            color: hasValue ? successText : AppTokens.textMuted,
          ),
          const SizedBox(width: 4),
          Text(
            '$label: ${hasValue ? value.split(' ')[0] : '–'}',
            style: GoogleFonts.lato(
              fontSize: fs,
              fontWeight: FontWeight.w700,
              color: hasValue ? successText : AppTokens.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _FilterSheet extends StatelessWidget {
  const _FilterSheet({
    required this.txtCustomer,
    required this.txtEmployee,
    required this.txtStatus,
    required this.txtJobNo,
    required this.txtLoadingVessel,
    required this.txtOffVessel,
    required this.onView,
  });

  final TextEditingController txtCustomer;
  final TextEditingController txtEmployee;
  final TextEditingController txtStatus;
  final TextEditingController txtJobNo;
  final TextEditingController txtLoadingVessel;
  final TextEditingController txtOffVessel;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SaleOrderBloc, SaleOrderState>(
      builder: (ctx, state) {
        final bool isTablet = MediaQuery.of(ctx).size.width >= 600;
        final double fs = isTablet ? 13.5 : 12;

        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollCtrl) => Container(
            decoration: const BoxDecoration(
              color: AppTokens.surfaceCard,
              borderRadius:
              BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: ListView(
              controller: scrollCtrl,
              padding: EdgeInsets.fromLTRB(
                  16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Palette.grey200,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  'Filter Orders',
                  style: GoogleFonts.lato(
                    fontSize: isTablet ? 17 : 15,
                    fontWeight: FontWeight.bold,
                    color: AppTokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),

                // ── Customer ──────────────────────────────────────
                _searchField(
                  ctx: ctx,
                  controller: txtCustomer,
                  hint: 'Customer Name',
                  fs: fs,
                  onSearch: () => Navigator.push(
                    ctx,
                    MaterialPageRoute(
                        builder: (_) =>
                        const Customer(Searchby: 1, SearchId: 0)),
                  ).then((navRes) { if (navRes != null) { AppGlobals.SelectCustomerList = navRes; }
                    txtCustomer.text =
                        AppGlobals.SelectCustomerList.AccountName;
                    if (!context.mounted) return;
                    ctx.read<SaleOrderBloc>().add(SaleOrderCustomerChanged(
                      AppGlobals.SelectCustomerList.Id,
                      AppGlobals.SelectCustomerList.AccountName,
                    ));
                    AppGlobals.SelectCustomerList = CustomerModel.Empty();
                  }),
                  onClear: () {
                    txtCustomer.clear();
                    ctx.read<SaleOrderBloc>().add(
                        const SaleOrderCustomerChanged(0, ''));
                  },
                ),
                const SizedBox(height: 10),

                // ── Employee ──────────────────────────────────────
                _searchField(
                  ctx: ctx,
                  controller: txtEmployee,
                  hint: 'Select Employee',
                  fs: fs,
                  enabled: !state.checkBoxValueLEmp,
                  onSearch: () => Navigator.push(
                    ctx,
                    MaterialPageRoute(
                        builder: (_) =>
                        const Employee(Searchby: 1, SearchId: 0)),
                  ).then((navRes) { if (navRes != null) { AppGlobals.SelectEmployeeList = navRes; }
                    txtEmployee.text =
                        AppGlobals.SelectEmployeeList.AccountName;
                    if (!context.mounted) return;
                    ctx.read<SaleOrderBloc>().add(SaleOrderEmployeeChanged(
                      AppGlobals.SelectEmployeeList.Id,
                      AppGlobals.SelectEmployeeList.AccountName,
                    ));
                    AppGlobals.SelectEmployeeList = EmployeeModel.Empty();
                  }),
                  onClear: () {
                    txtEmployee.clear();
                    ctx.read<SaleOrderBloc>().add(
                        const SaleOrderEmployeeChanged(0, ''));
                  },
                ),
                const SizedBox(height: 10),

                // ── Status ────────────────────────────────────────
                _searchField(
                  ctx: ctx,
                  controller: txtStatus,
                  hint: 'Select Status',
                  fs: fs,
                  onSearch: () => Navigator.push(
                    ctx,
                    MaterialPageRoute(
                        builder: (_) =>
                        const JobStatus(Searchby: 1, SearchId: 0)),
                  ).then((navRes) { if (navRes != null) { AppGlobals.SelectJobStatusList = navRes; }
                    txtStatus.text = AppGlobals.SelectJobStatusList.Name;
                    if (!context.mounted) return;
                    ctx.read<SaleOrderBloc>().add(SaleOrderStatusChanged(
                      AppGlobals.SelectJobStatusList.Id,
                      AppGlobals.SelectJobStatusList.Name,
                    ));
                    AppGlobals.SelectJobStatusList = JobStatusModel.Empty();
                  }),
                  onClear: () {
                    txtStatus.clear();
                    ctx.read<SaleOrderBloc>().add(
                        const SaleOrderStatusChanged(0, ''));
                  },
                ),
                const SizedBox(height: 10),

                // ── Free-text fields ──────────────────────────────
                _plainField(txtJobNo,         'Job No',         fs),
                const SizedBox(height: 10),
                _plainField(txtLoadingVessel, 'Loading Vessel', fs),
                const SizedBox(height: 10),
                _plainField(txtOffVessel,     'Off Vessel',     fs),
                const SizedBox(height: 14),

                // ── Checkboxes ────────────────────────────────────
                Row(
                  children: [
                    _labeledCheckbox(
                      ctx,
                      'PickUp',
                      state.checkBoxValuePickUp,
                          (v) => ctx.read<SaleOrderBloc>().add(SaleOrderPickUpToggled(v)),
                      fs,
                    ),
                    const SizedBox(width: 16),
                    _labeledCheckbox(
                      ctx,
                      'L.Emp',
                      state.checkBoxValueLEmp,
                          (v) => ctx.read<SaleOrderBloc>().add(SaleOrderLEmpToggled(v)),
                      fs,
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // ── Cls radio ─────────────────────────────────────
                _SectionLabel('Order Type', fs),
                Row(
                  children: [
                    _radioOption(ctx, state.cls, '3', 'All',     fs),
                    _radioOption(ctx, state.cls, '2', 'Without', fs),
                    _radioOption(ctx, state.cls, '1', 'With',    fs),
                  ],
                ),
                const SizedBox(height: 6),

                // ── ETA radio ─────────────────────────────────────
                _SectionLabel('ETA Filter', fs),
                Wrap(
                  children: [
                    _etaRadioOption(ctx, state, '1', 'O', true,  'OETA', fs),
                    _etaRadioOption(ctx, state, '2', '2', true,  'LETA', fs),
                    _etaRadioOption(ctx, state, '3', 'O', true,  'All',  fs),
                    _etaRadioOption(ctx, state, '0', 'O', false, 'None', fs),
                  ],
                ),
                const SizedBox(height: 18),

                // ── Buttons ───────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTokens.brandPrimary,
                        foregroundColor: Palette.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      icon: const Icon(Icons.search, size: 16),
                      label: Text('View', style: GoogleFonts.lato(fontSize: fs)),
                      onPressed: () {
                        Navigator.pop(ctx);
                        onView();
                      },
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTokens.brandPrimary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('Close',
                          style: GoogleFonts.lato(
                              fontSize: fs,
                              color: AppTokens.brandPrimary)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Filter field builders ─────────────────────────────────────────────────

  Widget _searchField({
    required BuildContext ctx,
    required TextEditingController controller,
    required String hint,
    required double fs,
    required VoidCallback onSearch,
    required VoidCallback onClear,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      style: GoogleFonts.lato(
          fontSize: fs,
          fontWeight: FontWeight.w600,
          color: AppTokens.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.lato(
            fontSize: fs, color: AppTokens.textSecondary),
        suffixIcon: InkWell(
          onTap: controller.text.isEmpty ? onSearch : onClear,
          child: Icon(
            controller.text.isNotEmpty ? Icons.close : Icons.search_rounded,
            color: enabled ? AppTokens.brandPrimary : AppTokens.textMuted,
          ),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTokens.surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
          const BorderSide(color: AppTokens.brandPrimary, width: 1.5),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  Widget _plainField(
      TextEditingController ctrl, String hint, double fs) {
    return TextField(
      controller: ctrl,
      textCapitalization: TextCapitalization.characters,
      style: GoogleFonts.lato(
          fontSize: fs,
          fontWeight: FontWeight.w600,
          color: AppTokens.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
        GoogleFonts.lato(fontSize: fs, color: AppTokens.textSecondary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTokens.surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
          const BorderSide(color: AppTokens.brandPrimary, width: 1.5),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  Widget _labeledCheckbox(
      BuildContext ctx,
      String label,
      bool value,
      void Function(bool) onChanged,
      double fs,
      ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          activeColor: AppTokens.brandPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onChanged: (v) => onChanged(v ?? false),
        ),
        Text(label,
            style: GoogleFonts.lato(
                fontSize: fs,
                fontWeight: FontWeight.bold,
                color: AppTokens.textPrimary)),
      ],
    );
  }

  Widget _radioOption(
      BuildContext ctx, String groupVal, String val, String label, double fs) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: val,
          groupValue: groupVal,
          activeColor: AppTokens.brandPrimary,
          onChanged: (v) => ctx
              .read<SaleOrderBloc>()
              .add(SaleOrderClsChanged(v ?? '3')),
        ),
        Text(label,
            style: GoogleFonts.lato(
                fontSize: fs, color: AppTokens.textPrimary)),
      ],
    );
  }

  Widget _etaRadioOption(
      BuildContext ctx,
      SaleOrderState state,
      String etaVal,
      String radioVal,
      bool etaEnabled,
      String label,
      double fs,
      ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: etaVal,
          groupValue: state.etaVal,
          activeColor: AppTokens.brandPrimary,
          onChanged: (v) => ctx.read<SaleOrderBloc>().add(
              SaleOrderETARadioChanged(v ?? '0', radioVal, etaEnabled)),
        ),
        Text(label,
            style: GoogleFonts.lato(
                fontSize: fs, color: AppTokens.textPrimary)),
        const SizedBox(width: 4),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label, this.fs);
  final String label;
  final double fs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        label,
        style: GoogleFonts.lato(
          fontSize: fs - 1,
          fontWeight: FontWeight.bold,
          color: AppTokens.textSecondary,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty / Error widgets
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyWidget extends StatelessWidget {
  const _EmptyWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_rounded,
              size: 64, color: Palette.grey400.withValues(alpha: 0.6)),
          const SizedBox(height: 12),
          Text('No orders found',
              style: GoogleFonts.lato(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTokens.textSecondary)),
          const SizedBox(height: 4),
          Text('Adjust filters and tap View',
              style: GoogleFonts.lato(
                  fontSize: 12, color: AppTokens.textMuted)),
        ],
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  const _ErrorWidget({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 56, color: Palette.redError),
            const SizedBox(height: 12),
            Text('Failed to load data',
                style: GoogleFonts.lato(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTokens.textPrimary)),
            const SizedBox(height: 6),
            Text(message,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lato(
                    fontSize: 12, color: AppTokens.textMuted)),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTokens.brandPrimary,
                foregroundColor: Palette.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text('Retry',
                  style:
                  GoogleFonts.lato(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}