import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/models/model.dart';
import 'package:maleva/menu/menulist.dart';
import 'package:maleva/MasterSearch/Customer.dart';
import 'package:maleva/Transaction/SaleOrder/SalesOrderAdd.dart';
import 'package:maleva/DashBoard/Admin/AdminDashboard.dart';
import 'package:maleva/DashBoard/AirFrieght/AirFrieghtDashboard.dart';
import 'package:maleva/DashBoard/Boarding/BoardingDashboard.dart';
import 'package:maleva/DashBoard/CustomerService/CustDashboard.dart';
import 'package:maleva/DashBoard/Forwarding/ForwardingDashboard.dart';
import 'package:maleva/DashBoard/OperationAdmin/OperationAdminDashboard.dart';
import 'package:maleva/DashBoard/TransportDB/TransportDashboard.dart';
import 'package:maleva/DashBoard/User/UserDashboard.dart';
import '../../../../MasterSearch/JobType.dart';
import '../../../../MasterSearch/Port.dart';
import '../bloc/prealertview_bloc.dart';
import '../bloc/prealertview_event.dart';
import '../bloc/prealertview_state.dart';


// ─── Design Tokens (same as VesselPlanningView) ───────────────────────────────
const kHeaderGradStart = Color(0xFF1A3A8F);
const kHeaderGradEnd   = Color(0xFF4A6FD4);
const kCardBorder      = Color(0xFFC5D0EE);
const kCardBg          = Color(0xFFFFFFFF);
const kPageBg          = Color(0xFFF4F6FB);
const kTextDark        = Color(0xFF1E2D5E);
const kTextMid         = Color(0xFF4A5A8A);
const kTextMuted       = Color(0xFF8A96BF);
const kDetailBg        = Color(0xFFF0F4FF);
const kChipBg          = Color(0xFFEEF2FF);

const kGradient = LinearGradient(
  colors: [kHeaderGradStart, kHeaderGradEnd],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// ─── Root ─────────────────────────────────────────────────────────────────────
class PreAlertReport extends StatelessWidget {
  const PreAlertReport({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PreAlertBloc()..add(PreAlertStarted()),
      child: const _PreAlertPage(),
    );
  }
}

// ─── Page ─────────────────────────────────────────────────────────────────────
class _PreAlertPage extends StatelessWidget {
  const _PreAlertPage();

  @override
  Widget build(BuildContext context) {
    final isTablet = objfun.MalevaScreen != 1;
    final userName = objfun.storagenew.getString('Username') ?? '';

    return BlocListener<PreAlertBloc, PreAlertState>(
      listener: (context, state) async {
        if (state is PreAlertNavigateToEdit) {
          await OnlineApi.EditSalesOrder(context, state.id, state.saleOrderNo);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SalesOrderAdd(
                SaleDetails: objfun.SaleEditDetailList,
                SaleMaster: objfun.SaleEditMasterList,
              ),
            ),
          );
        }
        if (state is PreAlertError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message,
                  style: GoogleFonts.lato(color: Colors.white)),
              backgroundColor: const Color(0xFFB33040),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      },
      child: WillPopScope(
        onWillPop: () async {
          _navigateBack(context);
          return false;
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: kPageBg,
          appBar: _buildAppBar(context, userName, isTablet),
          drawer: const Menulist(),
          body: BlocBuilder<PreAlertBloc, PreAlertState>(
            builder: (context, state) {
              if (state is PreAlertInitial || state is PreAlertLoading) {
                return const Center(
                  child: SpinKitFoldingCube(color: kHeaderGradEnd, size: 35),
                );
              }
              if (state is PreAlertLoaded) {
                return _PreAlertBody(state: state, isTablet: isTablet);
              }
              return const SizedBox.shrink();
            },
          ),
          floatingActionButton: _PAFab(
            onPressed: () {
              final state = context.read<PreAlertBloc>().state;
              if (state is PreAlertLoaded) {
                _showFilterSheet(context, state);
              }
            },
          ),
        ),
      ),
    );
  }

  void _navigateBack(BuildContext context) {
    final role = objfun.storagenew.getString('RulesType') ?? '';
    Widget dest;
    switch (role) {
      case 'ADMIN':
        dest = const AdminDashboard();
        break;
      case 'SALES':
        dest = const CustDashboard();
        break;
      case 'TRANSPORTATION':
        dest = const TransportDashboard();
        break;
      case 'OPERATIONADMIN':
        dest = const OperationAdminDashboard();
        break;
      case 'AIR FRIEGHT':
        dest = const AirFrieghtDashboard();
        break;
      case 'BOARDING':
      case 'OPERATION':
        dest = const BoardingDashboard();
        break;
      case 'FORWARDING':
        dest = const ForwardingDashboard();
        break;
      default:
        dest = const Homemobile();
    }
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => dest));
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, String userName, bool isTablet) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      toolbarHeight: isTablet ? 70 : 62,
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: kGradient),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        color: Colors.white,
        onPressed: () => _navigateBack(context),
      ),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pre Alert Report',
            style: GoogleFonts.lato(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: isTablet ? objfun.FontMedium + 2 : objfun.FontMedium,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            userName,
            style: GoogleFonts.lato(
              color: Colors.white.withOpacity(0.65),
              fontWeight: FontWeight.w500,
              fontSize: isTablet ? objfun.FontLow : objfun.FontLow - 1,
            ),
          ),
        ],
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  // ─── Filter Bottom Sheet ───────────────────────────────────────────────────
  void _showFilterSheet(BuildContext pageContext, PreAlertLoaded current) {
    showModalBottomSheet(
      context: pageContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: pageContext.read<PreAlertBloc>(),
        child: _FilterSheet(current: current),
      ),
    );
  }
}

// ─── Filter Sheet (StatefulWidget for local pickers) ─────────────────────────
class _FilterSheet extends StatefulWidget {
  final PreAlertLoaded current;
  const _FilterSheet({required this.current});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late PreAlertLoaded _local;

  @override
  void initState() {
    super.initState();
    _local = widget.current;
  }

  void _emit(PreAlertEvent event) =>
      context.read<PreAlertBloc>().add(event);

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2050),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: kHeaderGradStart,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: kTextDark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    final formatted = DateFormat('yyyy-MM-dd').format(picked);
    setState(() {
      if (isFrom) {
        _local = _local.copyWith(fromDate: formatted);
        _emit(PreAlertFromDateChanged(formatted));
      } else {
        _local = _local.copyWith(toDate: formatted);
        _emit(PreAlertToDateChanged(formatted));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = objfun.MalevaScreen != 1;

    final labelStyle = GoogleFonts.lato(
      color: kTextDark,
      fontWeight: FontWeight.w600,
      fontSize: isTablet ? objfun.FontLow + 1 : objfun.FontLow,
    );

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 0,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 18),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: kCardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Text(
              'Filter',
              style: GoogleFonts.lato(
                color: kHeaderGradStart,
                fontWeight: FontWeight.w700,
                fontSize: isTablet ? 16 : 15,
              ),
            ),
            const SizedBox(height: 16),

            // ── Date row ───────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _SheetDateTile(
                    label: 'From',
                    date: _local.fromDate,
                    onTap: () => _pickDate(true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SheetDateTile(
                    label: 'To',
                    date: _local.toDate,
                    onTap: () => _pickDate(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Customer ───────────────────────────────────────────────
            _PASearchField(
              hint: 'Customer Name',
              value: _local.custName,
              onSearch: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                      const Customer(Searchby: 1, SearchId: 0)),
                ).then((_) {
                  final sel = objfun.SelectCustomerList;
                  if (sel.Id != 0) {
                    _emit(PreAlertCustomerChanged(
                        custId: sel.Id, custName: sel.AccountName));
                    setState(() => _local = _local.copyWith(
                        custId: sel.Id, custName: sel.AccountName));
                    objfun.SelectCustomerList = CustomerModel.Empty();
                  }
                });
              },
              onClear: () {
                _emit(PreAlertCustomerCleared());
                setState(() => _local = _local.copyWith(custId: 0, custName: ''));
              },
            ),
            const SizedBox(height: 10),

            // ── Job Type ───────────────────────────────────────────────
            _PASearchField(
              hint: 'Select Job Type',
              value: _local.jobName,
              disabled: _local.checkLEmp,
              onSearch: () async {
                await OnlineApi.SelectJobType(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                      const JobType(Searchby: 1, SearchId: 0)),
                ).then((_) {
                  final sel = objfun.SelectJobTypeList;
                  if (sel.Id != 0) {
                    _emit(PreAlertJobTypeChanged(
                        jobId: sel.Id, jobName: sel.Name));
                    setState(() => _local =
                        _local.copyWith(jobId: sel.Id, jobName: sel.Name));
                    objfun.SelectJobTypeList = JobTypeModel.Empty();
                  }
                });
              },
              onClear: () {
                _emit(PreAlertJobTypeCleared());
                setState(
                        () => _local = _local.copyWith(jobId: 0, jobName: ''));
              },
            ),
            const SizedBox(height: 10),

            // ── Port ───────────────────────────────────────────────────
            _PASearchField(
              hint: 'Select Port',
              value: _local.portName,
              onSearch: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const Port(Searchby: 1, SearchId: 0)),
                ).then((_) {
                  final portName = objfun.SelectedPortName;
                  final portId = objfun.SelectJobStatusList.Id;
                  if (portId != 0) {
                    _emit(PreAlertPortChanged(
                        portId: portId, portName: portName));
                    setState(() => _local = _local.copyWith(
                        portId: portId, portName: portName));
                    objfun.SelectJobStatusList = JobStatusModel.Empty();
                  }
                });
              },
              onClear: () {
                _emit(PreAlertPortCleared());
                setState(
                        () => _local = _local.copyWith(portId: 0, portName: ''));
              },
            ),
            const SizedBox(height: 10),

            // ── Vessel ─────────────────────────────────────────────────
            _PATextField(
              hint: 'Vessel',
              value: _local.vessel,
              onChanged: (v) {
                _emit(PreAlertVesselChanged(v));
                setState(() => _local = _local.copyWith(vessel: v));
              },
            ),
            const SizedBox(height: 14),

            // ── Checkboxes grid ────────────────────────────────────────
            _CheckboxGrid(local: _local, onChanged: (field, val) {
              setState(() {
                switch (field) {
                  case 'pickup':
                    _local = _local.copyWith(checkPickUp: val);
                    break;
                  case 'port':
                    _local = _local.copyWith(checkPort: val);
                    break;
                  case 'vesselName':
                    _local = _local.copyWith(checkVesselName: val);
                    break;
                  case 'consolidated':
                    _local = _local.copyWith(checkConsolidated: val);
                    break;
                  case 'delivery':
                    _local = _local.copyWith(checkDelivery: val);
                    break;
                  case 'lEmp':
                    _local = _local.copyWith(checkLEmp: val);
                    break;
                }
                _emit(PreAlertCheckboxChanged(field: field, value: val));
              });
            }),
            const SizedBox(height: 14),

            // ── ETA Radio row ──────────────────────────────────────────
            _ETARadioRow(
              etaVal: _local.etaVal,
              onChanged: (val, radio, enabled) {
                setState(() {
                  _local = _local.copyWith(
                      etaVal: val, etaRadioVal: radio, etaEnabled: enabled);
                });
                _emit(PreAlertETAChanged(
                    etaVal: val, etaRadio: radio, etaEnabled: enabled));
              },
            ),
            const SizedBox(height: 20),

            // ── Buttons ────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _GradientButton(
                  label: 'View',
                  onPressed: () {
                    _emit(PreAlertViewRequested());
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 12),
                _OutlineButton(
                  label: 'Close',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────
class _PreAlertBody extends StatelessWidget {
  final PreAlertLoaded state;
  final bool isTablet;

  const _PreAlertBody({required this.state, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width  = MediaQuery.of(context).size.width;

    return Column(
      children: [
        // ── Grid Header ────────────────────────────────────────────────
        Container(
          height: isTablet ? height * 0.08 : height * 0.07,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kHeaderGradStart, Color(0xFF2D56C8)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: _GridHeader(isTablet: isTablet),
        ),

        // ── List ───────────────────────────────────────────────────────
        Expanded(
          child: state.masterList.isEmpty
              ? _EmptyState()
              : ListView.builder(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 10),
            itemCount: state.masterList.length,
            itemBuilder: (ctx, index) {
              final item = state.masterList[index]
              as SaleOrderMasterModel;
              return _SaleOrderCard(
                item: item,
                index: index,
                isExpanded: state.expandedIndex == index,
                isTablet: isTablet,
                height: height,
                width: width,
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Grid Header ──────────────────────────────────────────────────────────────
class _GridHeader extends StatelessWidget {
  final bool isTablet;
  const _GridHeader({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.lato(
      color: Colors.white.withOpacity(0.85),
      fontWeight: FontWeight.w600,
      fontSize: isTablet ? 11 : 10,
      letterSpacing: 0.5,
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(children: [
          Expanded(flex: 3, child: Text('JOB NO', style: style)),
          Expanded(flex: 3, child: Text('CUSTOMER', style: style)),
          Expanded(flex: 2, child: Text('STATUS', style: style)),
        ]),
        Row(children: [
          Expanded(flex: 3, child: Text('VESSEL', style: style)),
          Expanded(flex: 3, child: Text('ETA', style: style)),
          Expanded(flex: 2, child: Text('PICKUP', style: style)),
        ]),
      ],
    );
  }
}

// ─── Sale Order Card ──────────────────────────────────────────────────────────
class _SaleOrderCard extends StatelessWidget {
  final SaleOrderMasterModel item;
  final int index;
  final bool isExpanded;
  final bool isTablet;
  final double height;
  final double width;

  const _SaleOrderCard({
    required this.item,
    required this.index,
    required this.isExpanded,
    required this.isTablet,
    required this.height,
    required this.width,
  });

  Color _statusColor() {
    final hasPickup = item.SPickupDate.toString().isNotEmpty;
    final hasETA = item.SETA.toString().isNotEmpty ||
        item.SOETA.toString().isNotEmpty;

    if (!hasPickup && !hasETA) return const Color(0xFFFFCDD2); // red tint
    if (!hasPickup) return const Color(0xFFFFF9C4);            // yellow tint
    if (item.JobMasterRefId == 10) return kDetailBg;           // neutral
    return const Color(0xFFDCEDC8);                            // green tint
  }

  Color _statusDotColor() {
    final hasPickup = item.SPickupDate.toString().isNotEmpty;
    final hasETA = item.SETA.toString().isNotEmpty ||
        item.SOETA.toString().isNotEmpty;

    if (!hasPickup && !hasETA) return const Color(0xFFE53935);
    if (!hasPickup) return const Color(0xFFF9A825);
    if (item.JobMasterRefId == 10) return kTextMuted;
    return const Color(0xFF388E3C);
  }

  @override
  Widget build(BuildContext context) {
    final valStyle = GoogleFonts.lato(
      color: kTextDark,
      fontWeight: FontWeight.w600,
      fontSize: isTablet ? objfun.FontCardText + 1 : objfun.FontCardText,
    );
    final labelStyle = GoogleFonts.lato(
      color: kTextMuted,
      fontWeight: FontWeight.w600,
      fontSize: isTablet ? 10 : 9,
      letterSpacing: 0.4,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onLongPress: () => _showPasswordDialog(context),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: _statusColor(),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kCardBorder, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: kHeaderGradStart.withOpacity(0.07),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Accent bar
                Container(
                  height: 3,
                  decoration: const BoxDecoration(gradient: kGradient),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: Job No + Customer + Status dot
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('JOB NO', style: labelStyle),
                                const SizedBox(height: 2),
                                Text(item.BillNoDisplay.toString(),
                                    style: valStyle,
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('CUSTOMER', style: labelStyle),
                                const SizedBox(height: 2),
                                Text(item.CustomerName ?? '',
                                    style: valStyle,
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _statusDotColor(),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Row 2: Vessel + ETA + Pickup
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('VESSEL', style: labelStyle),
                                const SizedBox(height: 2),
                                Text(item.Offvesselname ?? '-',
                                    style: valStyle.copyWith(color: kTextMid),
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ETA', style: labelStyle),
                                const SizedBox(height: 2),
                                Text(item.SETA?.toString() ?? '-',
                                    style: valStyle.copyWith(color: kTextMid),
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('PICKUP', style: labelStyle),
                                const SizedBox(height: 2),
                                Text(item.SPickupDate?.toString() ?? '-',
                                    style: valStyle.copyWith(color: kTextMid),
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Action row ──────────────────────────────────────────
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    children: [
                      _CardActionChip(
                        icon: isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        label: isExpanded ? 'Collapse' : 'Details',
                        onTap: () => context
                            .read<PreAlertBloc>()
                            .add(PreAlertRowToggled(index)),
                      ),
                      const SizedBox(width: 8),
                      _CardActionChip(
                        icon: Icons.picture_as_pdf_outlined,
                        label: 'Pre Alert',
                        onTap: () => _shareReport(context),
                      ),
                    ],
                  ),
                ),

                // ── Expanded details ────────────────────────────────────
                if (isExpanded) _DetailsSection(item: item, isTablet: isTablet),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _shareReport(BuildContext context) async {
    final bloc = context.read<PreAlertBloc>();
    if (bloc.state is! PreAlertLoaded) return;
    final s = bloc.state as PreAlertLoaded;

    const reportName = 'PreAlertReport';
    final master = {
      'SoId':                0,
      'Comid':               objfun.storagenew.getInt('Comid') ?? 0,
      'Fromdate':            s.fromDate,
      'Todate':              s.toDate,
      'CustomerId':          s.custId,
      'DId':                 0,
      'TId':                 0,
      'Jobid':               s.jobId,
      'SPort':               s.portId,
      'completestatusnotshow': s.completeStatusNotShow,
      'Search':              s.vessel.isNotEmpty ? s.vessel : null,
      'Remarks':             '3',
      'DeliveryDone':        s.checkDelivery,
      'ETA':                 s.etaEnabled,
      'ETAType':             s.etaRadioVal,
      'Pickupdate':          s.checkPickUp,
      'Cons':                s.checkConsolidated,
    };
    final header = {'Content-Type': 'application/json; charset=UTF-8'};
    final resultData = await objfun.apiAllinoneSelectArray(
        '${objfun.apiPreAlertReport}$reportName', master, header, context);
    if (resultData != '') {
      final value = ResponseViewModel.fromJson(resultData);
      if (value.IsSuccess == true) objfun.launchInBrowser(value.data1);
    }
  }

  void _showPasswordDialog(BuildContext context) {
    final txtPassword = TextEditingController();
    final bloc = context.read<PreAlertBloc>();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          width: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: kHeaderGradStart.withOpacity(0.18),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  gradient: kGradient,
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Edit Password',
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      height: 90,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image:
                        DecorationImage(image: objfun.lockimg),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Password field
                    TextField(
                      controller: txtPassword,
                      cursorColor: kHeaderGradStart,
                      textCapitalization: TextCapitalization.characters,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.lato(
                        color: kTextDark,
                        fontWeight: FontWeight.w600,
                        fontSize: objfun.FontLow,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter password',
                        hintStyle: GoogleFonts.lato(
                            color: kTextMuted, fontSize: objfun.FontLow),
                        filled: true,
                        fillColor: kDetailBg,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: kHeaderGradEnd, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: _GradientButton(
                        label: 'Confirm',
                        onPressed: () async {
                          if (txtPassword.text.isEmpty) {
                            objfun.ConfirmationOK(
                                'Enter Password !!', dialogCtx);
                            return;
                          }
                          final result = await objfun
                              .apiAllinoneSelectArray(
                            '${objfun.apiEditPassword}${txtPassword.text}&type=EditPassword&Comid=${objfun.Comid}',
                            null,
                            null,
                            dialogCtx,
                          );
                          if (result.length != 0 &&
                              result['IsSuccess'] == true) {
                            txtPassword.text = '';
                            Navigator.pop(dialogCtx);
                            bloc.add(PreAlertEditRequested(

                              Id: item.Id,
                              SaleOrderNo: item.BillNo,
                            ));
                          } else {
                            txtPassword.text = '';
                            objfun.ConfirmationOK(
                                'Invalid Password !!!', dialogCtx);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Details Section ──────────────────────────────────────────────────────────
class _DetailsSection extends StatelessWidget {
  final SaleOrderMasterModel item;
  final bool isTablet;

  const _DetailsSection({required this.item, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    // Pull matching details from global list
    final details = objfun.SaleOrderDetailList
        .where((d) => d.SaleOrderMasterRefId == item.Id)
        .toList();

    final headerStyle = GoogleFonts.lato(
      color: Colors.white.withOpacity(0.85),
      fontWeight: FontWeight.w600,
      fontSize: isTablet ? 10 : 9,
      letterSpacing: 0.5,
    );
    final rowStyle = GoogleFonts.lato(
      color: kTextDark,
      fontWeight: FontWeight.w500,
      fontSize: isTablet ? objfun.FontCardText : objfun.FontCardText - 1,
    );

    final rowHeight = isTablet ? 42.0 : 38.0;
    final headerHeight = isTablet ? 34.0 : 30.0;
    final listHeight = details.isEmpty
        ? rowHeight
        : (details.length * rowHeight).clamp(0, rowHeight * 5).toDouble();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Detail header strip
        Container(
          height: headerHeight,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kHeaderGradStart, Color(0xFF2D56C8)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Expanded(flex: 2, child: Text('ITEM', style: headerStyle)),
              Expanded(flex: 3, child: Text('DESCRIPTION', style: headerStyle)),
              Expanded(flex: 2, child: Text('QTY', style: headerStyle)),
            ],
          ),
        ),

        SizedBox(
          height: listHeight,
          child: details.isEmpty
              ? Center(
            child: Text('No details',
                style: GoogleFonts.lato(
                    fontSize: objfun.FontLow, color: kTextMuted)),
          )
              : ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: details.length,
            itemBuilder: (ctx, i) {
              return Container(
                height: rowHeight,
                color: i % 2 == 0 ? Colors.white : kDetailBg,
                padding:
                const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        details[i].ItemName ?? '',
                        style: rowStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        details[i].Description ?? '',
                        style: rowStyle.copyWith(color: kTextMid),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        details[i].Qty?.toString() ?? '',
                        style: rowStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
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
              color: kChipBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.description_outlined,
                size: 32, color: kHeaderGradEnd),
          ),
          const SizedBox(height: 14),
          Text(
            'No Records Found',
            style: GoogleFonts.lato(
                color: kTextDark, fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            'Use the filter to load data',
            style: GoogleFonts.lato(color: kTextMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ─── FAB ──────────────────────────────────────────────────────────────────────
class _PAFab extends StatelessWidget {
  final VoidCallback onPressed;
  const _PAFab({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: kGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kHeaderGradStart.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: const Icon(Icons.filter_alt_outlined,
              color: Colors.white, size: 24),
        ),
      ),
    );
  }
}

// ─── Checkbox Grid ────────────────────────────────────────────────────────────
class _CheckboxGrid extends StatelessWidget {
  final PreAlertLoaded local;
  final void Function(String field, bool value) onChanged;

  const _CheckboxGrid({required this.local, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isTablet = objfun.MalevaScreen != 1;
    final items = [
      ('pickup',       'PickUp',      local.checkPickUp),
      ('port',         'Port',        local.checkPort),
      ('vesselName',   'Vessel Name', local.checkVesselName),
      ('consolidated', 'Consolidated',local.checkConsolidated),
      ('delivery',     'Delivery Done', local.checkDelivery),
      ('lEmp',         'L.Emp',       local.checkLEmp),
    ];

    return Wrap(
      spacing: 0,
      runSpacing: 4,
      children: items.map((item) {
        return SizedBox(
          width: MediaQuery.of(context).size.width * (isTablet ? 0.27 : 0.42),
          child: InkWell(
            onTap: () => onChanged(item.$1, !item.$3),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      gradient: item.$3 ? kGradient : null,
                      border: item.$3
                          ? null
                          : Border.all(color: kCardBorder, width: 1.5),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: item.$3
                        ? const Icon(Icons.check_rounded,
                        size: 12, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.$2,
                    style: GoogleFonts.lato(
                      color: kTextDark,
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet
                          ? objfun.FontLow + 1
                          : objfun.FontLow,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── ETA Radio Row ────────────────────────────────────────────────────────────
class _ETARadioRow extends StatelessWidget {
  final String etaVal;
  final void Function(String val, String radio, bool enabled) onChanged;

  const _ETARadioRow({required this.etaVal, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isTablet = objfun.MalevaScreen != 1;
    final style = GoogleFonts.lato(
      color: kTextDark,
      fontWeight: FontWeight.w600,
      fontSize: isTablet ? objfun.FontLow + 1 : objfun.FontLow,
    );
    final options = [
      ('1', 'OETA',  '1', true),
      ('2', 'LETA',  '1', true),
      ('3', 'All',   '2', true),
      ('0', 'None',  'O', false),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: kDetailBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kCardBorder, width: 0.5),
      ),
      child: Row(
        children: options.map((opt) {
          final selected = etaVal == opt.$1;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(opt.$1, opt.$3, opt.$4),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? kHeaderGradEnd : kCardBorder,
                          width: 1.5,
                        ),
                        gradient: selected ? kGradient : null,
                      ),
                      child: selected
                          ? const Icon(Icons.circle,
                          size: 8, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(opt.$2,
                          style: style, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Shared Reusable Widgets ──────────────────────────────────────────────────

class _SheetDateTile extends StatelessWidget {
  final String label;
  final String date;
  final VoidCallback onTap;

  const _SheetDateTile(
      {required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final displayDate =
    DateFormat('dd-MM-yy').format(DateTime.parse(date));
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: kDetailBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kCardBorder, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: GoogleFonts.lato(
                color: kTextMuted,
                fontWeight: FontWeight.w700,
                fontSize: 9,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(displayDate,
                    style: GoogleFonts.lato(
                        color: kTextDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
                const Icon(Icons.calendar_month_outlined,
                    size: 18, color: kHeaderGradEnd),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PASearchField extends StatelessWidget {
  final String hint;
  final String value;
  final bool disabled;
  final VoidCallback onSearch;
  final VoidCallback onClear;

  const _PASearchField({
    required this.hint,
    required this.value,
    this.disabled = false,
    required this.onSearch,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: disabled ? null : (value.isEmpty ? onSearch : onClear),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: disabled ? const Color(0xFFF5F5F5) : kDetailBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kCardBorder, width: 0.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value.isEmpty ? hint : value,
                style: GoogleFonts.lato(
                  color: value.isEmpty ? kTextMuted : kTextDark,
                  fontWeight: value.isEmpty ? FontWeight.w500 : FontWeight.w600,
                  fontSize: objfun.FontLow,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              value.isNotEmpty ? Icons.close_rounded : Icons.search_rounded,
              size: 20,
              color: disabled ? kTextMuted : kHeaderGradEnd,
            ),
          ],
        ),
      ),
    );
  }
}

class _PATextField extends StatelessWidget {
  final String hint;
  final String value;
  final void Function(String) onChanged;

  const _PATextField(
      {required this.hint, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController(text: value)
        ..selection =
        TextSelection.collapsed(offset: value.length),
      textCapitalization: TextCapitalization.characters,
      textInputAction: TextInputAction.done,
      onChanged: onChanged,
      style: GoogleFonts.lato(
        color: kTextDark,
        fontWeight: FontWeight.w600,
        fontSize: objfun.FontLow,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.lato(color: kTextMuted, fontSize: objfun.FontLow),
        filled: true,
        fillColor: kDetailBg,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kCardBorder, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kHeaderGradEnd, width: 1.5),
        ),
      ),
    );
  }
}

class _CardActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CardActionChip(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: kChipBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kCardBorder, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: kHeaderGradStart),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.lato(
                color: kHeaderGradStart,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _GradientButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: kGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: kHeaderGradStart.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 28, vertical: 11),
            child: Text(
              label,
              style: GoogleFonts.lato(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: objfun.FontMedium,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _OutlineButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kChipBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kCardBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 28, vertical: 11),
            child: Text(
              label,
              style: GoogleFonts.lato(
                color: kHeaderGradStart,
                fontWeight: FontWeight.w700,
                fontSize: objfun.FontMedium,
              ),
            ),
          ),
        ),
      ),
    );
  }
}