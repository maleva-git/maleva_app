import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/core/models/model.dart';
import 'package:maleva/menu/menulist.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;

import '../../../../mastersearch/Port.dart';
import '../../enquiry/add/view/enquiryadd.dart';
import '../../saleorderadd/view/saleorderadd_tab.dart';
import '../bloc/custdashboard_bloc.dart';
import '../bloc/custdashboard_event.dart';
import '../bloc/custdashboard_state.dart';



// ─── Entry point ─────────────────────────────────────────────────────────────

class CustDashboard extends StatelessWidget {
  const CustDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CustDashboardBloc()..add(const CustDashboardStarted()),
      child: const _CustDashboardView(),
    );
  }
}

// ─── Main view ────────────────────────────────────────────────────────────────

class _CustDashboardView extends StatefulWidget {
  const _CustDashboardView();

  @override
  State<_CustDashboardView> createState() => _CustDashboardViewState();
}

class _CustDashboardViewState extends State<_CustDashboardView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _portCtrl = TextEditingController();
  final TextEditingController _portsTextCtrl = TextEditingController();
  final TextEditingController _fromPayCtrl = TextEditingController();
  final TextEditingController _toPayCtrl = TextEditingController();

  static const List<String> _categoryFilters = [
    'All', 'Hire Purchase', 'Vendor', 'Utility', 'Tenancy', 'Monthly Purpose'
  ];
  static const List<String> _paidFilters = [
    'All Payments', 'Paid', 'Not Paid'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 6);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;
    context
        .read<CustDashboardBloc>()
        .add(CustDashboardTabChanged(_tabController.index));
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_onTabChanged)
      ..dispose();
    _portCtrl.dispose();
    _portsTextCtrl.dispose();
    _fromPayCtrl.dispose();
    _toPayCtrl.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final result =
    await ConfirmationMsgYesNo(context, 'Are you Sure you want to Exit?');
    if (result) {
      if (Platform.isAndroid) {
        SystemNavigator.pop();
      } else if (Platform.isIOS) {
        exit(0);
      }
    }
    return result;
  }

  // ─── Font helpers (same logic as original) ────────────────────────────────

  void _applyFontSizes(double width) {
    if (width <= 370) {
      AppGlobals.FontLarge = 22;
      AppGlobals.FontMedium = 18;
      AppGlobals.FontLow = 16;
      AppGlobals.FontCardText = 12;
    } else {
      AppGlobals.FontLarge = 24;
      AppGlobals.FontMedium = 20;
      AppGlobals.FontLow = 18;
      AppGlobals.FontCardText = 14;
    }
  }

  // ─── Card colour helpers ──────────────────────────────────────────────────

  Color? _enquiryCardColor(Map enq) {
    if (enq['ForwardingDate'] == null) return null;
    final now = DateTime.now();
    final notifyDate =
    DateFormat('yyyy-MM-dd').format(DateTime.parse(enq['ForwardingDate']));
    final today = DateFormat('yyyy-MM-dd').format(now);
    final tomorrow = DateFormat('yyyy-MM-dd').format(now.add(const Duration(days: 1)));
    if (notifyDate == today ||
        DateTime.parse(enq['ForwardingDate']).isBefore(now)) {
      return Colors.redAccent.withOpacity(0.3);
    } else if (notifyDate == tomorrow) {
      return Colors.yellowAccent.withOpacity(0.3);
    }
    return null;
  }

  Color? _vesselCardColor(dynamic row) {
    final etb = row['SETB'] == '' ? null : DateTime.tryParse(row['SETB'] ?? '');
    final oetb = row['SOETB'] == '' ? null : DateTime.tryParse(row['SOETB'] ?? '');
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    if (etb != null && yesterday.isAfter(etb)) return Colors.redAccent.withOpacity(0.3);
    if (oetb != null && yesterday.isAfter(oetb)) return Colors.redAccent.withOpacity(0.3);
    return null;
  }

  // ─── Payment detail bottom sheet ─────────────────────────────────────────

  void _openPaymentDetailPopup(
      BuildContext context, PaymentPendingModel master, CustDashboardState state) {
    final related = state.getRelatedDetails(master);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 70, height: 6,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),
              Text(master.ExpenseName ?? '',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('Bank: ${master.BankName ?? ''}',
                  style: const TextStyle(color: Colors.black54)),
              const Divider(),
              related.isEmpty
                  ? const Expanded(child: Center(child: Text('No detail records')))
                  : Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: related.length,
                  itemBuilder: (_, i) {
                    final d = related[i];
                    return Card(
                      elevation: 0,
                      color: Colors.indigo.shade50,
                      child: ListTile(
                        title: Text(d.SubExpenseName ?? ''),
                        subtitle: Text('Due: ${d.DueDate}'),
                        trailing: Text(
                          'RM ${((d.Amount ?? 0)).toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.indigo),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Vessel detail dialog ─────────────────────────────────────────────────

  Future<void> _showVesselDialog(BuildContext context, Map row) async {
    final fields = [
      ['Job No', row['JobNo']],
      ['L Vessel Name', row['Loadingvesselname']],
      ['O Vessel Name', row['Offvesselname']],
      ['Job Type', row['JobName']],
      ['pkg', row['pkg']],
      ['LPort', row['SPort']],
      ['OPort', row['OPort']],
      ['Commodity', row['Commodity']],
      ['L ETA', row['SETA']],
      ['L ETB', row['SETB']],
      ['L ETD', row['SETD']],
      ['O ETA', row['SOETA']],
      ['O ETB', row['SOETB']],
      ['O ETD', row['SOETD']],
      ['O SCN', row['OSCN']],
      ['L SCN', row['LSCN']],
      ['Vessel Type', row['VesselType']],
      ['L Agent Company', row['AgentCompany']],
      ['L Agent', row['AgentName']],
      ['L Agent Phone', row['AgentPhone']],
      ['O Agent Company', row['OAgentCompany']],
      ['O Agent', row['OAgentName']],
      ['O Agent Phone', row['OAgentPhone']],
      ['Employee Name', row['EmployeeName']],
    ];
    await _showDetailDialog(context, fields, height: 550);
  }

  Future<void> _showTransportDialog(BuildContext context, Map row) async {
    final fields = [
      ['Job No', row['JobNo']],
      ['Vessel Name', row['VesselName']],
      ['Job Type', row['JobName']],
      ['Origin', row['Origin']],
      ['Destination', row['Destination']],
      ['pkg', row['pkg']],
      ['LPort', row['SPort']],
      ['OPort', row['OPort']],
      ['Truck Size', row['truckSize']],
      ['Truck Name', row['TruckName']],
      ['Employee Name', row['EmployeeName']],
    ];
    await _showDetailDialog(context, fields, height: 450);
  }

  Future<void> _showDetailDialog(
      BuildContext context, List<List<dynamic>> fields,
      {double height = 450}) async {
    await showDialog(
      barrierDismissible: true,
      context: context,
      builder: (_) => Dialog(
        elevation: 40,
        child: SizedBox(
          width: 200,
          height: height,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: ListView(
              shrinkWrap: true,
              children: [
                Center(
                  child: Text('DETAILS',
                      style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colour.commonColorred))),
                ),
                const SizedBox(height: 15),
                ...fields.map((f) => Text(
                  '${f[0]} : ${f[1]}',
                  style: GoogleFonts.lato(
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colour.commonColor)),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showEnquiryDialog(BuildContext context, Map enq) async {
    String collectionDate = '';
    String etaDate = '';
    String oEtaDate = '';
    if (enq['SPickupDate'] != '') {
      collectionDate = DateFormat('dd-MM-yyyy HH:mm')
          .format(DateTime.parse(enq['PickupDate']));
    }
    if (enq['SETA'] != '') {
      etaDate = DateFormat('dd-MM-yyyy HH:mm')
          .format(DateTime.parse(enq['ETA']));
    }
    if (enq['SOETA'] != '') {
      oEtaDate = DateFormat('dd-MM-yyyy HH:mm')
          .format(DateTime.parse(enq['OETA']));
    }
    final fields = [
      ['Customer Name', enq['CustomerName']],
      ['Job Type', enq['JobType']],
      ['Notify Date', enq['SForwardingDate']],
      ['Collection Date', collectionDate],
      ['L Vessel', enq['Loadingvesselname']],
      ['O Vessel', enq['Offvesselname']],
      ['ETA', etaDate],
      ['OETA', oEtaDate],
      ['LPort', enq['SPort']],
      ['OPort', enq['OPort']],
    ];
    await _showDetailDialog(context, fields, height: 450);
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    _applyFontSizes(MediaQuery.of(context).size.width);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        drawer: const Menulist(),
        appBar: _buildAppBar(context),
        body: BlocConsumer<CustDashboardBloc, CustDashboardState>(
          listener: (context, state) {
            if (state.status == CustDashboardStatus.failure &&
                state.errorMessage.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage)),
              );
            }
            // Keep portsText controller in sync
            _portsTextCtrl.text = state.vesselPortsText;
          },
          builder: (context, state) {
            return Stack(
              children: [
                TabBarView(
                  controller: _tabController,
                  children: [
                    _SalesTab(state: state),
                    _VesselTab(
                      state: state,
                      portCtrl: _portCtrl,
                      portsTextCtrl: _portsTextCtrl,
                      onVesselCardTap: (row) => _showVesselDialog(context, row),
                      onPortAdd: () => context.read<CustDashboardBloc>().add(
                          CustDashboardPortAdded(_portCtrl.text)),
                      onPortClear: () {
                        _portCtrl.clear();
                        context
                            .read<CustDashboardBloc>()
                            .add(const CustDashboardPortCleared());
                      },
                      onPortSearch: () => context
                          .read<CustDashboardBloc>()
                          .add(CustDashboardLoadVessel(
                          dayOffset: state.isVesselToday ? 0 : 1,
                          portFilter: state.vesselPortsText)),
                      onPortFieldClear: () {
                        _portCtrl.clear();
                        context
                            .read<CustDashboardBloc>()
                            .add(const CustDashboardPortFilterChanged(''));
                      },
                      onVesselCardColor: _vesselCardColor,
                    ),
                    _TransportTab(
                      state: state,
                      onCardTap: (row) => _showTransportDialog(context, row),
                      onCardLongPress: (row) async {
                        await OnlineApi.EditSalesOrder(
                             row['Id'] as int, 0); if (!context.mounted) return;Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => SalesOrderAdd(
                              saleDetails: AppGlobals.SaleEditDetailList,
                              saleMaster: AppGlobals.SaleEditMasterList,
                            )));
                      },
                    ),
                    _EnquiryTab(
                      state: state,
                      onDetailsTap: (enq) =>
                          _showEnquiryDialog(context, enq),
                      cardColor: _enquiryCardColor,
                    ),
                    _FuelTab(state: state),
                    _PaymentTab(
                      state: state,
                      fromCtrl: _fromPayCtrl,
                      toCtrl: _toPayCtrl,
                      categoryFilters: _categoryFilters,
                      paidFilters: _paidFilters,
                      onDetailTap: (item) =>
                          _openPaymentDetailPopup(context, item, state),
                    ),
                  ],
                ),
                if (state.status == CustDashboardStatus.loading)
                  const _LoadingOverlay(),
              ],
            );
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('Dash Board',
          style: GoogleFonts.lato(
              textStyle: TextStyle(
                  color: colour.topAppBarColor,
                  fontWeight: FontWeight.bold,
                  fontSize: AppGlobals.FontLarge))),
      iconTheme: const IconThemeData(color: colour.topAppBarColor),
      actions: [
        IconButton(
          icon: const Icon(Icons.exit_to_app,
              size: 30, color: colour.topAppBarColor),
          onPressed: () => AppGlobals.logout(context),
        ),
      ],
      bottom: TabBar(
        isScrollable: true,
        controller: _tabController,
        onTap: (i) => context
            .read<CustDashboardBloc>()
            .add(CustDashboardTabChanged(i)),
        tabs: const [
          Tab(text: 'SALES'),
          Tab(text: 'VSL'),
          Tab(text: 'TRANSPORT'),
          Tab(text: 'ENQ'),
          Tab(text: 'Fuel View'),
          Tab(text: 'Payment View'),
        ],
      ),
    );
  }
}

// ─── Loading overlay ──────────────────────────────────────────────────────────

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: ColoredBox(
        color: Colors.black12,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

// ─── Sales Tab ────────────────────────────────────────────────────────────────

class _SalesTab extends StatelessWidget {
  const _SalesTab({required this.state});
  final CustDashboardState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
      child: ListView(
        children: [
          const SizedBox(height: 7),
          // Employee dropdown
          _EmployeeDropdown(state: state),
          const SizedBox(height: 8),
          // Counts card
          _SalesCountCard(state: state),
          const SizedBox(height: 8),
          // Status list
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.50,
            child: ListView.builder(
              itemCount: state.salesReport.length,
              itemBuilder: (_, i) {
                final row = state.salesReport[i];
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                  child: Card(
                    child: Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(
                              row['JobStatus'].toString(),
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.lato(
                                  textStyle: TextStyle(
                                      color: colour.commonColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: AppGlobals.FontCardText)),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              row['DayCount'].toString(),
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.lato(
                                  textStyle: TextStyle(
                                      color: colour.commonColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: AppGlobals.FontCardText)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmployeeDropdown extends StatelessWidget {
  const _EmployeeDropdown({required this.state});
  final CustDashboardState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: colour.commonColorLight,
          border: Border.all()),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: state.selectedEmpId.isEmpty ? null : state.selectedEmpId,
          onChanged: (value) {
            if (value != null) {
              context
                  .read<CustDashboardBloc>()
                  .add(CustDashboardEmployeeChanged(value));
            }
          },
          style: GoogleFonts.lato(
              textStyle: TextStyle(
                  color: colour.commonColor,
                  fontWeight: FontWeight.bold,
                  fontSize: AppGlobals.FontMedium)),
          items: state.rulesTypeEmployee
              .map<DropdownMenuItem<String>>((item) => DropdownMenuItem<String>(
            value: item['Id'].toString(),
            child: Text(item['AccountName']!.toString(),
                style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: colour.commonColor,
                        fontWeight: FontWeight.bold,
                        fontSize: AppGlobals.FontMedium))),
          ))
              .toList(),
        ),
      ),
    );
  }
}

class _SalesCountCard extends StatelessWidget {
  const _SalesCountCard({required this.state});
  final CustDashboardState state;

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 5),
    child: Text(text,
        style: GoogleFonts.lato(
            textStyle: TextStyle(
                color: colour.commonColor,
                fontWeight: FontWeight.bold,
                fontSize: AppGlobals.FontLow - 2))),
  );

  Widget _value(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Text(text,
        style: GoogleFonts.lato(
            textStyle: TextStyle(
                color: colour.commonColorhighlight,
                fontWeight: FontWeight.bold,
                fontSize: AppGlobals.FontLow - 2))),
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.24,
      child: Card(
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Without Invoice :'),
                  _label('Total Count :'),
                  _label('Billed :'),
                  _label('UnBilled :'),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _value(state.withoutInvoiceCount.toString()),
                  _value(state.totalCount.toString()),
                  _value(state.totalBilledCount.toString()),
                  _value(state.totalUnBilledCount.toString()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Vessel Tab ───────────────────────────────────────────────────────────────

class _VesselTab extends StatelessWidget {
  const _VesselTab({
    required this.state,
    required this.portCtrl,
    required this.portsTextCtrl,
    required this.onVesselCardTap,
    required this.onPortAdd,
    required this.onPortClear,
    required this.onPortSearch,
    required this.onPortFieldClear,
    required this.onVesselCardColor,
  });

  final CustDashboardState state;
  final TextEditingController portCtrl;
  final TextEditingController portsTextCtrl;
  final ValueChanged<Map> onVesselCardTap;
  final VoidCallback onPortAdd;
  final VoidCallback onPortClear;
  final VoidCallback onPortSearch;
  final VoidCallback onPortFieldClear;
  final Color? Function(dynamic) onVesselCardColor;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
      child: ListView(
        children: [
          const SizedBox(height: 7),
          Center(
            child: Text('VESSEL REPORT',
                style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: colour.commonColorred,
                        fontWeight: FontWeight.bold,
                        fontSize: AppGlobals.FontLarge))),
          ),
          const SizedBox(height: 4),
          // Port search row
          Row(
            children: [
              Expanded(
                flex: 5,
                child: SizedBox(
                  height: 50,
                  child: TextField(
                    controller: portCtrl,
                    readOnly: true,
                    textCapitalization: TextCapitalization.characters,
                    style: GoogleFonts.lato(
                        textStyle: TextStyle(
                            color: colour.commonColor,
                            fontWeight: FontWeight.bold,
                            fontSize: AppGlobals.FontLow)),
                    decoration: InputDecoration(
                      hintText: 'Port',
                      hintStyle: GoogleFonts.lato(
                          textStyle: TextStyle(
                              fontSize: AppGlobals.FontMedium,
                              fontWeight: FontWeight.bold,
                              color: colour.commonColorLight)),
                      suffixIcon: InkWell(
                        onTap: () {
                          if (portCtrl.text.isEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                  const Port(Searchby: 1, SearchId: 0)),
                            ).then((_navRes) {
                              portCtrl.text = AppGlobals.SelectedPortName;
                              AppGlobals.SelectedPortName = '';
                            });
                          } else {
                            onPortFieldClear();
                          }
                        },
                        child: Icon(
                          portCtrl.text.isNotEmpty
                              ? Icons.close
                              : Icons.search_rounded,
                          color: colour.commonColorred,
                        ),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: colour.commonColor),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: colour.commonColorred),
                      ),
                      contentPadding:
                      const EdgeInsets.only(left: 10, right: 20, top: 10),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_sharp,
                    size: 30, color: colour.commonColor),
                onPressed: onPortAdd,
              ),
              IconButton(
                icon: const Icon(Icons.find_replace,
                    size: 30, color: colour.commonColor),
                onPressed: onPortSearch,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 30, color: colour.commonColor),
                onPressed: onPortClear,
              ),
            ],
          ),
          SizedBox(
            height: height * 0.08,
            child: TextField(
              controller: portsTextCtrl,
              maxLines: null,
              expands: true,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.characters,
              style: GoogleFonts.lato(
                  textStyle: TextStyle(
                      color: colour.commonColor,
                      fontWeight: FontWeight.bold,
                      fontSize: AppGlobals.FontLow)),
              decoration: InputDecoration(
                hintStyle: GoogleFonts.lato(
                    textStyle: TextStyle(
                        fontSize: AppGlobals.FontMedium,
                        color: colour.commonColorLight)),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: colour.commonColor),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: colour.commonColorred),
                ),
                contentPadding:
                const EdgeInsets.only(left: 10, right: 20, top: 10),
              ),
            ),
          ),
          // Today / Tomorrow buttons
          _DayToggle(
            isToday: state.isVesselToday,
            onToday: () => context
                .read<CustDashboardBloc>()
                .add(const CustDashboardLoadVessel(dayOffset: 0)),
            onTomorrow: () => context
                .read<CustDashboardBloc>()
                .add(const CustDashboardLoadVessel(dayOffset: 1)),
          ),
          SizedBox(
            height: height * 0.68,
            child: ListView.builder(
              itemCount: state.saleCustReport.length,
              itemBuilder: (_, i) {
                final row = state.saleCustReport[i];
                return SizedBox(
                  height: height * 0.05,
                  child: InkWell(
                    onTap: () => onVesselCardTap(row as Map),
                    child: Card(
                      color: onVesselCardColor(row),
                      child: Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: Center(
                                  child: Text('${i + 1}',
                                      style: GoogleFonts.lato(
                                          textStyle: TextStyle(
                                              color: colour.commonColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: AppGlobals.FontCardText))))),
                          Expanded(
                            flex: 2,
                            child: Text(
                              row['Loadingvesselname'].toString(),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: GoogleFonts.lato(
                                  textStyle: TextStyle(
                                      color: colour.commonColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: AppGlobals.FontCardText)),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              ' - ${row['Port']}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: GoogleFonts.lato(
                                  textStyle: TextStyle(
                                      color: colour.commonColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: AppGlobals.FontCardText)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Transport Tab ────────────────────────────────────────────────────────────

class _TransportTab extends StatelessWidget {
  const _TransportTab({
    required this.state,
    required this.onCardTap,
    required this.onCardLongPress,
  });

  final CustDashboardState state;
  final ValueChanged<Map> onCardTap;
  final ValueChanged<Map> onCardLongPress;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
      child: ListView(
        children: [
          Center(
            child: Text('TRANSPORT REPORT',
                style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: colour.commonColorred,
                        fontWeight: FontWeight.bold,
                        fontSize: AppGlobals.FontLarge))),
          ),
          _DayToggle(
            isToday: state.isPlanToday,
            onToday: () => context
                .read<CustDashboardBloc>()
                .add(const CustDashboardLoadPlanning(dayOffset: 0)),
            onTomorrow: () => context
                .read<CustDashboardBloc>()
                .add(const CustDashboardLoadPlanning(dayOffset: 1)),
          ),
          SizedBox(
            height: height * 0.68,
            child: ListView.builder(
              itemCount: state.saleTransReport.length,
              itemBuilder: (_, i) {
                final row = state.saleTransReport[i];
                return SizedBox(
                  height: height * 0.05,
                  child: InkWell(
                    onTap: () => onCardTap(row as Map),
                    onLongPress: () => onCardLongPress(row as Map),
                    child: Card(
                      child: Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: Center(
                                  child: Text('${i + 1}',
                                      style: GoogleFonts.lato(
                                          textStyle: TextStyle(
                                              color: colour.commonColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: AppGlobals.FontCardText))))),
                          Expanded(
                            flex: 3,
                            child: Text(
                              row['CustomerName'].toString(),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: GoogleFonts.lato(
                                  textStyle: TextStyle(
                                      color: colour.commonColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: AppGlobals.FontCardText)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Enquiry Tab ──────────────────────────────────────────────────────────────

class _EnquiryTab extends StatelessWidget {
  const _EnquiryTab({
    required this.state,
    required this.onDetailsTap,
    required this.cardColor,
  });

  final CustDashboardState state;
  final ValueChanged<Map> onDetailsTap;
  final Color? Function(Map) cardColor;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
      child: Column(
        children: [
          // Add button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colour.commonColorLight,
                  side: const BorderSide(color: colour.commonColor),
                  elevation: 20,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AddEnquiryScreen())),
                child:
                const Icon(Icons.add, color: colour.commonColor),
              ),
            ],
          ),
          const SizedBox(height: 5),
          // Header
          SizedBox(
            height: height * 0.05,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              color: colour.commonColor,
              child: Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: Text('Customer Name',
                          style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                  color: colour.ButtonForeColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: AppGlobals.FontLow)))),
                  Expanded(
                      flex: 2,
                      child: Text('Notify Date',
                          style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                  color: colour.ButtonForeColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: AppGlobals.FontLow)))),
                ],
              ),
            ),
          ),
          // List
          Expanded(
            child: state.enquiryMasterList.isEmpty
                ? const Center(child: Text('No Record'))
                : ListView.builder(
              itemCount: state.enquiryMasterList.length,
              itemBuilder: (_, i) {
                final enq = state.enquiryMasterList[i] as Map;
                return SizedBox(
                  height: height * 0.07,
                  child: InkWell(
                    onDoubleTap: () => onDetailsTap(enq),
                    onLongPress: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          // FIXED: Cast the map to Map<String, dynamic> here
                            builder: (_) =>
                                AddEnquiryScreen(saleMaster: Map<String, dynamic>.from(enq)))),
                    child: Card(
                      color: cardColor(enq),
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                            color: colour.commonColor, width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '   ${enq['CustomerName']}',
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.lato(
                                      textStyle: TextStyle(
                                          color: colour.commonColor,
                                          fontWeight: FontWeight.bold,
                                          // FIXED: Added .toDouble()
                                          fontSize: AppGlobals.FontCardText.toDouble())),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '   ${enq['SForwardingDate']}',
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.lato(
                                      textStyle: TextStyle(
                                          color: colour.commonColor,
                                          fontWeight: FontWeight.bold,
                                          // FIXED: Added .toDouble()
                                          fontSize: AppGlobals.FontCardText.toDouble())),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: InkWell(
                                  onTap: () async {
                                    final ok = await ConfirmationMsgYesNo(
                                        context,
                                        'Do You Want to Push to SalesOrder ?');
                                    if (ok) {
                                      AppGlobals.storagenew.setString(
                                          'EnquiryOpen', 'true');
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (_) =>
                                              // Note: Ensure this matches your class name (SalesOrderAdd vs SalesOrderAddPage)
                                              SalesOrderAdd(
                                                saleDetails: null,
                                                saleMaster: [enq],
                                              )));
                                    }
                                  },
                                  child: const Icon(
                                      Icons.fast_forward_sharp,
                                      color: colour.commonColor),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: InkWell(
                                  onTap: () async {
                                    final ok = await ConfirmationMsgYesNo(
                                        context,
                                        'Do You Want to Cancel the Enquiry ?');
                                    if (ok) {
                                      context
                                          .read<CustDashboardBloc>()
                                          .add(CustDashboardCancelEnquiry(
                                          enq['Id'] as int));
                                    }
                                  },
                                  child: const Icon(Icons.cancel,
                                      color: colour.commonColor),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Fuel Tab ─────────────────────────────────────────────────────────────────

class _FuelTab extends StatelessWidget {
  const _FuelTab({required this.state});
  final CustDashboardState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Text('Fuel Different',
              style: GoogleFonts.lato(
                  fontSize: AppGlobals.FontLarge,
                  fontWeight: FontWeight.bold,
                  color: colour.commonColor)),
          // Date range
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  DateFormat('dd-MM-yy').format(DateTime.parse(state.fuelFromDate)),
                  style: GoogleFonts.lato(
                      textStyle: TextStyle(
                          color: colour.commonColor,
                          fontWeight: FontWeight.bold,
                          fontSize: AppGlobals.FontLow)),
                ),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                  icon: const Icon(Icons.calendar_month_outlined,
                      size: 35, color: colour.commonColor),
                  onPressed: () async {
                    final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2050));
                    if (picked != null) {
                      context.read<CustDashboardBloc>().add(
                          CustDashboardFuelFromDateChanged(
                              DateFormat('yyyy-MM-dd').format(picked)));
                    }
                  },
                ),
              ),
              const Expanded(flex: 1, child: SizedBox()),
              Expanded(
                flex: 4,
                child: Text(
                  DateFormat('dd-MM-yy').format(DateTime.parse(state.fuelToDate)),
                  style: GoogleFonts.lato(
                      textStyle: TextStyle(
                          color: colour.commonColor,
                          fontWeight: FontWeight.bold,
                          fontSize: AppGlobals.FontLow)),
                ),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                  icon: const Icon(Icons.calendar_month_outlined,
                      size: 35, color: colour.commonColor),
                  onPressed: () async {
                    final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2050));
                    if (picked != null) {
                      context.read<CustDashboardBloc>().add(
                          CustDashboardFuelToDateChanged(
                              DateFormat('yyyy-MM-dd').format(picked)));
                    }
                  },
                ),
              ),
              const Expanded(flex: 1, child: SizedBox()),
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: () => context.read<CustDashboardBloc>().add(
                      CustDashboardLoadFuel(
                          fromDate: state.fuelFromDate,
                          toDate: state.fuelToDate)),
                  child: Text('View',
                      style: GoogleFonts.lato(
                          textStyle: TextStyle(fontSize: AppGlobals.FontLow))),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: state.fuelRecords.length,
              itemBuilder: (_, i) {
                final rec = state.fuelRecords[i];
                final aAmount = rec.aAmount ?? 0.0;
                final gAmount = rec.gAmount ?? 0.0;
                final aliter = rec.aliter ?? 0.0;
                final gliter = rec.gliter ?? 0.0;
                final diff = gAmount - aAmount;
                final diffColor = diff > 0
                    ? Colors.green
                    : diff < 0
                    ? Colors.red
                    : Colors.grey;
                final diffIcon = diff > 0
                    ? Icons.trending_up
                    : diff < 0
                    ? Icons.trending_down
                    : Icons.remove;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.orange.shade100.withOpacity(0.6),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ],
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.orange.shade50,
                              child: const Icon(Icons.local_shipping,
                                  color: Colors.deepOrange, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(rec.driverName ?? 'Unknown',
                                      style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  Text(rec.truckName ?? 'No Truck',
                                      style: GoogleFonts.lato(
                                          fontSize: 13,
                                          color: Colors.grey[600])),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Divider(color: Colors.orange.shade100),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _infoTile('A Amount',
                                '₹${aAmount.toStringAsFixed(2)}',
                                Colors.orange.shade700),
                            _infoTile('G Amount',
                                '₹${gAmount.toStringAsFixed(2)}',
                                Colors.blue.shade700),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _infoTile('A Liter',
                                '${aliter.toStringAsFixed(2)} L',
                                Colors.orange.shade700),
                            _infoTile('G Liter',
                                '${gliter.toStringAsFixed(2)} L',
                                Colors.blue.shade700),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                              color: diffColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(diffIcon, color: diffColor, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                'Difference: ${diff >= 0 ? '+' : ''}${diff.toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                    color: diffColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: GoogleFonts.lato(fontSize: 13, color: Colors.grey[600])),
        const SizedBox(height: 2),
        Text(value,
            style: GoogleFonts.poppins(
                fontSize: 14, color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// ─── Payment Tab ──────────────────────────────────────────────────────────────

class _PaymentTab extends StatelessWidget {
  const _PaymentTab({
    required this.state,
    required this.fromCtrl,
    required this.toCtrl,
    required this.categoryFilters,
    required this.paidFilters,
    required this.onDetailTap,
  });

  final CustDashboardState state;
  final TextEditingController fromCtrl;
  final TextEditingController toCtrl;
  final List<String> categoryFilters;
  final List<String> paidFilters;
  final ValueChanged<PaymentPendingModel> onDetailTap;

  static const _categoryToSid = {
    'All': 0,
    'Hire Purchase': 1,
    'Vendor': 2,
    'Utility': 3,
    'Tenancy': 4,
    'Monthly Purpose': 5,
  };

  static const _paidToSid = {
    'All Payments': 0,
    'Paid': 1,
    'Not Paid': 2,
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(
        children: [
          // Category chips
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: categoryFilters.map((f) {
                final selected = state.selectedCategoryFilter == f;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(f, style: const TextStyle(fontSize: 13)),
                    selected: selected,
                    selectedColor: Colors.indigo,
                    labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.black87),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    onSelected: (_) {
                      context.read<CustDashboardBloc>().add(
                          CustDashboardPaymentCategoryFilterChanged(
                              filter: f,
                              sid: _categoryToSid[f] ?? 0));
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          // Paid chips
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: paidFilters.map((f) {
                final selected = state.selectedPaidFilter == f;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(f, style: const TextStyle(fontSize: 13)),
                    selected: selected,
                    selectedColor: Colors.indigo,
                    labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.black87),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    onSelected: (_) {
                      context.read<CustDashboardBloc>().add(
                          CustDashboardPaymentPaidFilterChanged(
                              filter: f,
                              pSid: _paidToSid[f] ?? 0));
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          // Date search row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: fromCtrl,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'From Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035));
                      if (picked != null) {
                        fromCtrl.text =
                            DateFormat('yyyy-MM-dd').format(picked);
                        context
                            .read<CustDashboardBloc>()
                            .add(CustDashboardPaymentFromDatePicked(picked));
                      }
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: toCtrl,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'To Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035));
                      if (picked != null) {
                        toCtrl.text =
                            DateFormat('yyyy-MM-dd').format(picked);
                        context
                            .read<CustDashboardBloc>()
                            .add(CustDashboardPaymentToDatePicked(picked));
                      }
                    },
                  ),
                ),
                const SizedBox(width: 6),
                ElevatedButton(
                  onPressed: () => context.read<CustDashboardBloc>().add(
                      CustDashboardLoadPayment(
                          isDateSearch: true,
                          fromDate: state.paymentFromDate,
                          toDate: state.paymentToDate)),
                  child: const Text('Search'),
                ),
              ],
            ),
          ),
          // Total
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Text('Total:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  'RM ${state.totalFilteredAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 17, color: Colors.indigo),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Master list
          Expanded(
            child: state.masterList.isEmpty
                ? const Center(
                child: Text('No Records Found',
                    style: TextStyle(fontSize: 16)))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: state.masterList.length,
              itemBuilder: (_, i) {
                final item = state.masterList[i];
                return GestureDetector(
                  onTap: () => onDetailTap(item),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 3))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.ExpenseName ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17)),
                        const SizedBox(height: 6),
                        Text('Bank: ${item.BankName ?? ''}',
                            style: const TextStyle(
                                color: Colors.black54)),
                        Text(item.SubExpenseName ?? ''),
                        Text('Due: ${item.ExpenceDueDate}',
                            style: const TextStyle(
                                color: Colors.black54)),
                        Text(
                          'Paiddate: ${item.Paiddate?.split('T').first ?? '-'}',
                          style:
                          const TextStyle(color: Colors.black54),
                        ),
                        Text(
                          'Paidamount: RM ${double.tryParse(item.Paiddamount ?? '0')?.toStringAsFixed(2) ?? '0.00'}',
                          style:
                          const TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                  color: Colors.indigo.shade50,
                                  borderRadius:
                                  BorderRadius.circular(12)),
                              child: Text(
                                'RM ${((item.Amount ?? 0)).toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.indigo),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared: Day Toggle ───────────────────────────────────────────────────────

class _DayToggle extends StatelessWidget {
  const _DayToggle({
    required this.isToday,
    required this.onToday,
    required this.onTomorrow,
  });

  final bool isToday;
  final VoidCallback onToday;
  final VoidCallback onTomorrow;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _btn('Today', isToday, onToday),
        const SizedBox(width: 5),
        _btn('Tomorrow', !isToday, onTomorrow),
      ],
    );
  }

  Widget _btn(String label, bool active, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: colour.commonColorLight,
        side: BorderSide(
            color: active ? colour.commonColor : colour.commonColorLight),
        elevation: active ? 15 : 0,
        padding: const EdgeInsets.all(4),
      ),
      onPressed: onTap,
      child: Text(label,
          style: GoogleFonts.lato(
              fontSize: AppGlobals.FontMedium,
              fontWeight: FontWeight.bold,
              color: colour.commonColor)),
    );
  }
}