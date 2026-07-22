import 'package:maleva/core/network/api_legacy_helper.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/menu/menulist.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import '../../../../../core/di/injection.dart';
import '../../../../transaction/enquirytrmaster/add/view/enquirytradd_tab.dart';
import '../../saleorderadd/view/saleorderadd_tab.dart';
import '../../spotsaleorder/view/spotsaleorder_view.dart';
import '../bloc/transportdb_bloc.dart';
import '../bloc/transportdb_event.dart';
import '../bloc/transportdb_state.dart';
import 'package:maleva/core/models/shared/review.dart';
import 'package:maleva/core/models/shared/employee_model.dart';



class TransportDashboard extends StatelessWidget {
  final Review? existingReview;
  final int initialTabIndex;

  const TransportDashboard({
    super.key,
    this.existingReview,
    this.initialTabIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return
      BlocProvider(
        create: (_) => sl<TransportDashboardBloc>()
          ..add(TransportDashboardInitialized(
            initialTabIndex: initialTabIndex,
            existingReview: existingReview,
          )),
        child: _TransportDashboardView(
          existingReview: existingReview,
          initialTabIndex: initialTabIndex,
        ),
      );
  }
}

class _TransportDashboardView extends StatefulWidget {
  final Review? existingReview;
  final int initialTabIndex;

  const _TransportDashboardView({
    required this.existingReview,
    required this.initialTabIndex,
  });

  @override
  State<_TransportDashboardView> createState() =>
      _TransportDashboardViewState();
}

class _TransportDashboardViewState extends State<_TransportDashboardView>
    with TickerProviderStateMixin {
  late TabController _tabMainController;
  late TabController _tabSubController;
  final TextEditingController _shopCtrl = TextEditingController();
  final TextEditingController _mobileCtrl = TextEditingController();
  final TextEditingController _reviewMsgCtrl = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabMainController = TabController(
      length: 6,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _tabSubController = TabController(length: 3, vsync: this);

    _tabMainController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabMainController.indexIsChanging) return;
    final bloc = context.read<TransportDashboardBloc>();
    final idx = _tabMainController.index;

    if (idx == 0) bloc.add(LoadSalesDataRequested(empId: AppGlobals.EmpRefId));
    if (idx == 1) bloc.add(const LoadPlanningDataRequested(type: 0));
    if (idx == 2) bloc.add(const LoadEnquiryDataRequested());
    if (idx == 3) bloc.add(const LoadEmployeesRequested());
    if (idx == 4) {
      bloc.add(const LoadEmployeesRequested());
      if (widget.existingReview != null) {
        bloc.add(ReviewFormInitialized(existingReview: widget.existingReview));
      }
    }
  }

  @override
  void dispose() {
    _tabMainController.dispose();
    _tabSubController.dispose();
    _shopCtrl.dispose();
    _mobileCtrl.dispose();
    _reviewMsgCtrl.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final result =
    await ConfirmationMsgYesNo(context, 'Are you Sure you want to Exit?');
    if (result) {
      if (Platform.isAndroid) SystemNavigator.pop();
      if (Platform.isIOS) exit(0);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    // Determine if tablet or mobile from objfun flag
    final isTablet = AppGlobals.MalevaScreen != 1;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        bool pop = await _onWillPop();
        if (pop) Navigator.pop(context);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        drawer: const Menulist(),
        appBar: _buildAppBar(context, isTablet),
        body: TabBarView(
          controller: _tabMainController,
          children: [
            _SalesTab(isTablet: isTablet),
            _TransportTab(isTablet: isTablet),
            _EnquiryTab(isTablet: isTablet),
            _EmailInboxTab(isTablet: isTablet),
            _GoogleReviewTab(
              isTablet: isTablet,
              shopCtrl: _shopCtrl,
              mobileCtrl: _mobileCtrl,
              reviewMsgCtrl: _reviewMsgCtrl,
              formKey: _formKey,
            ),
            _PDOTab(
              isTablet: isTablet,
              searchController: _searchController,
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, bool isTablet) {
    final titleSize = isTablet ? 28.0 : AppGlobals.FontLarge.toDouble();

    return AppBar(
      title: Text(
        'Dash Board',
        style: GoogleFonts.lato(
          color: colour.topAppBarColor,
          fontWeight: FontWeight.bold,
          fontSize: titleSize,
        ),
      ),
      iconTheme: const IconThemeData(color: colour.topAppBarColor),
      actions: [
        IconButton(
          icon: const Icon(Icons.exit_to_app, size: 30, color: colour.topAppBarColor),
          onPressed: () => ApiLegacyHelper.logout(context),
        ),
      ],
      bottom: TabBar(
        controller: _tabMainController,
        isScrollable: true,
        tabs: const [
          Tab(text: 'SALES'),
          Tab(text: 'TRANSPORT'),
          Tab(text: 'ENQ'),
          Tab(text: 'EmailInbox'),
          Tab(text: 'GoogleReview'),
          Tab(text: 'PDO'),
        ],
      ),
    );
  }
}

class _SalesTab extends StatelessWidget {
  final bool isTablet;
  const _SalesTab({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocBuilder<TransportDashboardBloc, TransportDashboardState>(
      builder: (context, state) {
        final bloc = context.read<TransportDashboardBloc>();

        return Padding(
          padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
          child: ListView(
            children: [
              const SizedBox(height: 7),

              // Employee dropdown
              Container(
                padding: const EdgeInsets.only(left: 10, right: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: colour.commonColorLight,
                  border: Border.all(),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: state.rulesTypeEmployee
                        .any((e) => e['Id'].toString() == state.dropdownValueEmp)
                        ? state.dropdownValueEmp
                        : null,
                    hint: const Text('Select Employee'),
                    onChanged: (value) {
                      bloc.add(EmployeeFilterChanged(
                        dropdownValueEmp: value,
                        empId: int.tryParse(value ?? '0') ?? 0,
                      ));
                    },
                    items: state.rulesTypeEmployee
                        .map<DropdownMenuItem<String>>((item) =>
                        DropdownMenuItem<String>(
                          value: item['Id'].toString(),
                          child: Text(item['AccountName'] ?? ''),
                        ))
                        .toList(),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Summary card
              SizedBox(
                height: isTablet ? size.height * 0.20 : size.height * 0.24,
                child: Card(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _summaryLabel('Without Invoice :', isTablet),
                            _summaryLabel('Total Count :', isTablet),
                            _summaryLabel('Billed :', isTablet),
                            _summaryLabel('UnBilled :', isTablet),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            _summaryValue(state.withoutInvoiceCount.toString(), isTablet),
                            _summaryValue(state.totalCount.toString(), isTablet),
                            _summaryValue(state.totalBilledCount.toString(), isTablet),
                            _summaryValue(state.totalUnBilledCount.toString(), isTablet),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Sales report list
              SizedBox(
                height: isTablet ? size.height * 0.60 : size.height * 0.50,
                child: ListView.builder(
                  itemCount: state.salesReport.length,
                  itemBuilder: (context, index) {
                    final item = state.salesReport[index];
                    return SizedBox(
                      height: isTablet ? size.height * 0.06 : size.height * 0.05,
                      child: Card(
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _centeredText(
                                  item['JobStatus']?.toString() ?? '', isTablet),
                            ),
                            Expanded(
                              flex: 2,
                              child: _centeredText(
                                  item['DayCount']?.toString() ?? '', isTablet),
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
      },
    );
  }

  Widget _summaryLabel(String text, bool isTablet) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 5),
    child: Text(
      text,
      style: GoogleFonts.lato(
        color: colour.commonColor,
        fontWeight: FontWeight.bold,
        fontSize: isTablet ? AppGlobals.FontLow : AppGlobals.FontLow - 2,
      ),
    ),
  );

  Widget _summaryValue(String text, bool isTablet) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 5),
    child: Text(
      text,
      style: GoogleFonts.lato(
        color: colour.commonColorhighlight,
        fontWeight: FontWeight.bold,
        fontSize: isTablet ? AppGlobals.FontLow : AppGlobals.FontLow - 2,
      ),
    ),
  );

  Widget _centeredText(String text, bool isTablet) => Container(
    padding: const EdgeInsets.all(5),
    child: Text(
      text,
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: GoogleFonts.lato(
        color: colour.commonColor,
        fontWeight: FontWeight.bold,
        fontSize: isTablet ? AppGlobals.FontCardText + 2 : AppGlobals.FontCardText,
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 2: TRANSPORT
// ─────────────────────────────────────────────────────────────────────────────

class _TransportTab extends StatelessWidget {
  final bool isTablet;
  const _TransportTab({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocBuilder<TransportDashboardBloc, TransportDashboardState>(
      builder: (context, state) {
        final bloc = context.read<TransportDashboardBloc>();

        return Padding(
          padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
          child: ListView(
            children: [
              const SizedBox(height: 7),
              Center(
                child: Text(
                  'TRANSPORT REPORT',
                  style: GoogleFonts.lato(
                    color: colour.commonColorred,
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? AppGlobals.FontLarge + 4 : AppGlobals.FontLarge,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Today / Tomorrow buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _planButton(
                    context,
                    label: 'Today',
                    isActive: state.isPlanToday,
                    onPressed: () => bloc.add(const LoadPlanningDataRequested(type: 0)),
                    isTablet: isTablet,
                  ),
                  const SizedBox(width: 5),
                  _planButton(
                    context,
                    label: 'Tomorrow',
                    isActive: !state.isPlanToday,
                    onPressed: () => bloc.add(const LoadPlanningDataRequested(type: 1)),
                    isTablet: isTablet,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              SizedBox(
                height: isTablet ? size.height * 0.72 : size.height * 0.68,
                child: ListView.builder(
                  itemCount: state.saleTransReport.length,
                  itemBuilder: (context, index) {
                    final item = state.saleTransReport[index];
                    return SizedBox(
                      height: isTablet ? size.height * 0.06 : size.height * 0.05,
                      child: InkWell(
                        onTap: () => _showDetailsDialog(context, item),
                        onLongPress: () async {
                          await OnlineApi.EditSalesOrder(
                               item['Id'], 0); if (!context.mounted) return;Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SalesOrderAdd(
                                saleDetails: AppGlobals.SaleEditDetailList,
                                saleMaster: AppGlobals.SaleEditMasterList,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: _cellText(
                                    (index + 1).toString(), TextAlign.center, isTablet),
                              ),
                              Expanded(
                                flex: 3,
                                child: _cellText(
                                    item['CustomerName']?.toString() ?? '',
                                    TextAlign.left,
                                    isTablet),
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
      },
    );
  }

  Widget _planButton(
      BuildContext context, {
        required String label,
        required bool isActive,
        required VoidCallback onPressed,
        required bool isTablet,
      }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: colour.commonColorLight,
        side: BorderSide(
          color: isActive ? colour.commonColor : colour.commonColorLight,
          width: 1,
        ),
        elevation: isActive ? 15 : 0,
        padding: const EdgeInsets.all(4),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: GoogleFonts.lato(
          fontSize: isTablet ? AppGlobals.FontMedium + 2 : AppGlobals.FontMedium,
          fontWeight: FontWeight.bold,
          color: colour.commonColor,
        ),
      ),
    );
  }

  Widget _cellText(String text, TextAlign align, bool isTablet) => Container(
    padding: const EdgeInsets.all(5),
    child: Text(
      text,
      textAlign: align,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: GoogleFonts.lato(
        color: colour.commonColor,
        fontWeight: FontWeight.bold,
        fontSize: isTablet ? AppGlobals.FontCardText + 2 : AppGlobals.FontCardText,
      ),
    ),
  );

  void _showDetailsDialog(BuildContext context, Map item) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (_) => Dialog(
        elevation: 40,
        child: SizedBox(
          width: 220,
          height: 460,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: ListView(
              shrinkWrap: true,
              children: [
                Center(
                  child: Text('DETAILS',
                      style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          color: colour.commonColorred)),
                ),
                const SizedBox(height: 15),
                ...[
                  'Job No : ${item["JobNo"]}',
                  'Vessel Name : ${item["VesselName"]}',
                  'Job Type : ${item["JobName"]}',
                  'Origin : ${item["Origin"]}',
                  'Destination : ${item["Destination"]}',
                  'Pkg : ${item["pkg"]}',
                  'LPort : ${item["SPort"]}',
                  'OPort : ${item["OPort"]}',
                  'Truck Size : ${item["truckSize"]}',
                  'Truck Name : ${item["TruckName"]}',
                  'Employee : ${item["EmployeeName"]}',
                ].map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(t,
                      style: GoogleFonts.lato(
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
}
class _EnquiryTab extends StatelessWidget {
  final bool isTablet;
  const _EnquiryTab({required this.isTablet});

  Color? _cardColor(Map item) {
    if (item['ForwardingDate'] == null) return null;
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final nowStr = DateFormat('yyyy-MM-dd').format(now);
    final tomorrowStr = DateFormat('yyyy-MM-dd').format(tomorrow);
    final notifyDate =
    DateFormat('yyyy-MM-dd').format(DateTime.parse(item['ForwardingDate']));
    if (notifyDate == nowStr ||
        DateTime.parse(item['ForwardingDate']).isBefore(now)) {
      return Colors.redAccent.withValues(alpha: 0.3);
    } else if (notifyDate == tomorrowStr) {
      return Colors.yellowAccent.withValues(alpha: 0.3);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocBuilder<TransportDashboardBloc, TransportDashboardState>(
      builder: (context, state) {
        final bloc = context.read<TransportDashboardBloc>();

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
                      side: const BorderSide(color: colour.commonColor, width: 1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AddEnquiryTR()),
                    ),
                    child: const Icon(Icons.add, color: colour.commonColor),
                  ),
                ],
              ),

              const SizedBox(height: 5),

              // Header row
              Container(
                height: isTablet ? size.height * 0.055 : size.height * 0.05,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                color: colour.commonColor,
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text('Customer Name',
                          style: GoogleFonts.lato(
                              color: colour.ButtonForeColor,
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet
                                  ? AppGlobals.FontLow + 2
                                  : AppGlobals.FontLow)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('Notify Date',
                          style: GoogleFonts.lato(
                              color: colour.ButtonForeColor,
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet
                                  ? AppGlobals.FontLow + 2
                                  : AppGlobals.FontLow)),
                    ),
                  ],
                ),
              ),

              // List
              Expanded(
                child: state.enquiryMasterList.isEmpty
                    ? const Center(child: Text('No Record'))
                    : ListView.builder(
                  itemCount: state.enquiryMasterList.length,
                  itemBuilder: (context, index) {
                    final item = state.enquiryMasterList[index];
                    return SizedBox(
                      height: isTablet
                          ? size.height * 0.09
                          : size.height * 0.07,
                      child: InkWell(
                        onDoubleTap: () =>
                            _showEnqDetailsDialog(context, item),
                        onLongPress: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AddEnquiryTR(SaleMaster: item),
                          ),
                        ),
                        child: Card(
                          color: _cardColor(item),
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                color: colour.commonColor, width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(1),
                                      child: Text(
                                        '   ${item["CustomerName"]}',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: GoogleFonts.lato(
                                          color: colour.commonColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: isTablet
                                              ? AppGlobals.FontCardText + 2
                                              : AppGlobals.FontCardText,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(1),
                                      child: Text(
                                        '   ${item["SForwardingDate"]}',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: GoogleFonts.lato(
                                          color: colour.commonColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: isTablet
                                              ? AppGlobals.FontCardText + 2
                                              : AppGlobals.FontCardText,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  // Push to SalesOrder
                                  Expanded(
                                    flex: 2,
                                    child: InkWell(
                                      onTap: () async {
                                        final confirm =
                                        await ConfirmationMsgYesNo(
                                            context,
                                            'Do You Want to Push to SalesOrder ?');
                                        if (confirm) {
                                          AppGlobals.storagenew.setString(
                                              'EnquiryOpen', 'true');
                                          if (!context.mounted) return;
Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  SalesOrderAdd(
                                                    saleDetails: null,
                                                    saleMaster: [item],
                                                  ),
                                            ),
                                          );
                                        }
                                      },
                                      child: const Icon(
                                        Icons.fast_forward_sharp,
                                        color: colour.commonColor,
                                      ),
                                    ),
                                  ),
                                  // Cancel
                                  Expanded(
                                    flex: 2,
                                    child: InkWell(
                                      onTap: () async {
                                        final confirm =
                                        await ConfirmationMsgYesNo(
                                            context,
                                            'Do You Want to Cancel the Enquiry ?');
                                        if (confirm) {
                                          bloc.add(CancelEnquiryRequested(
                                              id: item['Id']));
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
      },
    );
  }

  void _showEnqDetailsDialog(BuildContext context, Map item) {
    var collectionDate = '';
    var deliveryDate = '';
    if (item['SPickupDate'] != '' && item['PickupDate'] != null) {
      collectionDate = DateFormat('dd-MM-yyyy HH:mm')
          .format(DateTime.parse(item['PickupDate']));
    }
    if (item['SDeliveryDate'] != '' && item['DeliveryDate'] != null) {
      deliveryDate = DateFormat('dd-MM-yyyy HH:mm')
          .format(DateTime.parse(item['DeliveryDate']));
    }

    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (_) => Dialog(
        elevation: 40,
        child: SizedBox(
          width: 220,
          height: 460,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: ListView(
              shrinkWrap: true,
              children: [
                Center(
                  child: Text('DETAILS',
                      style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          color: colour.commonColorred)),
                ),
                const SizedBox(height: 15),
                ...[
                  'Customer : ${item["CustomerName"]}',
                  'Job Type : ${item["JobType"]}',
                  'Notify Date : ${item["SForwardingDate"]}',
                  'Collection Date : $collectionDate',
                  'Delivery Date : $deliveryDate',
                  'Origin : ${item["Origin"]}',
                  'Destination : ${item["Destination"]}',
                  'Quantity : ${item["Quantity"]}',
                  'Weight : ${item["TotalWeight"]}',
                ].map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(t,
                      style: GoogleFonts.lato(
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
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 4: EMAIL INBOX
// ─────────────────────────────────────────────────────────────────────────────

class _EmailInboxTab extends StatelessWidget {
  final bool isTablet;
  const _EmailInboxTab({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransportDashboardBloc, TransportDashboardState>(
      builder: (context, state) {
        final bloc = context.read<TransportDashboardBloc>();

        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              DropdownButtonFormField<EmployeeModel>(
                isExpanded: true,
                initialValue: state.selectedEmployee,
                decoration: InputDecoration(
                  labelText: 'Select Employee',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: state.employees
                    .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e.AccountName,
                      overflow: TextOverflow.ellipsis),
                ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    bloc.add(EmployeeSelectedForEmail(employee: value));
                  }
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: state.emails.length,
                  itemBuilder: (context, index) {
                    final email = state.emails[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(email.name,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: isTablet ? 18.0 : 16.0)),
                                Text(
                                  email.receivedDate
                                      .toLocal()
                                      .toString()
                                      .split('.')
                                      .first,
                                  style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: isTablet ? 14.0 : 12.0),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(email.subject,
                                style: TextStyle(
                                    fontSize: isTablet ? 17.0 : 15.0,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text('From: ${email.sender}',
                                style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: isTablet ? 16.0 : 14.0)),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 4,
                              children: [
                                _checkRow(
                                  label: 'Active',
                                  value: email.isActive,
                                  onChanged: (v) => bloc.add(
                                      EmailActiveToggled(
                                          index: index, value: v ?? false)),
                                ),
                                _checkRow(
                                  label: 'Read',
                                  value: email.isUnread,
                                  onChanged: (v) => bloc.add(
                                      EmailUnreadToggled(
                                          index: index, value: v ?? false)),
                                ),
                                _checkRow(
                                  label: 'Replied',
                                  value: email.isReplied,
                                  onChanged: (v) => bloc.add(
                                      EmailRepliedToggled(
                                          index: index, value: v ?? false)),
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
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: state.isSavingEmails
                      ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save),
                  label: const Text('Save Emails'),
                  onPressed: state.isSavingEmails
                      ? null
                      : () async {
                    final confirm =
                    await ConfirmationMsgYesNo(
                        context, 'Do You Want to Update?');
                    if (confirm) {
                      bloc.add(const SaveEmailsRequested());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _checkRow({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(value: value, onChanged: onChanged),
        Text(label),
      ],
    );
  }
}
class _GoogleReviewTab extends StatelessWidget {
  final bool isTablet;
  final TextEditingController shopCtrl;
  final TextEditingController mobileCtrl;
  final TextEditingController reviewMsgCtrl;
  final GlobalKey<FormState> formKey;

  const _GoogleReviewTab({
    required this.isTablet,
    required this.shopCtrl,
    required this.mobileCtrl,
    required this.reviewMsgCtrl,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransportDashboardBloc, TransportDashboardState>(
      listener: (context, state) {
        // Reset form after successful save
        if (state.status == TransportDashboardStatus.success &&
            !state.isSavingReview) {
          shopCtrl.clear();
          mobileCtrl.clear();
          reviewMsgCtrl.clear();
        }
      },
      builder: (context, state) {
        final bloc = context.read<TransportDashboardBloc>();

        return Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: shopCtrl,
                      decoration:
                      const InputDecoration(labelText: 'Company Name'),
                      validator: (v) =>
                      v!.isEmpty ? 'Enter Company Name' : null,
                    ),
                    const SizedBox(height: 10),

                    DropdownButtonFormField<int>(
                      initialValue: state.selectedReview >= 1 &&
                          state.selectedReview <= 5
                          ? state.selectedReview
                          : 1,
                      isExpanded: true,
                      items: List.generate(5, (i) => i + 1)
                          .map((v) => DropdownMenuItem<int>(
                        value: v,
                        child: Text(v.toString()),
                      ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          bloc.add(ReviewStarChanged(star: v));
                        }
                      },
                      decoration:
                      const InputDecoration(labelText: 'Google Review'),
                      validator: (v) => v == null ? 'Select Review' : null,
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: reviewMsgCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Google Review Message'),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<int>(
                      initialValue: state.employees
                          .any((e) => e.Id == state.selectedEmpId)
                          ? state.selectedEmpId
                          : null,
                      isExpanded: true,
                      items: state.employees
                          .map((e) => DropdownMenuItem<int>(
                        value: e.Id,
                        child: Text(e.AccountName),
                      ))
                          .toList(),
                      onChanged: (v) =>
                          bloc.add(ReviewEmployeeChanged(empId: v)),
                      decoration:
                      const InputDecoration(labelText: 'Employee'),
                      validator: (v) =>
                      v == null ? 'Select Employee' : null,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Date: ${DateFormat('yyyy-MM-dd').format(state.selectedDate)}',
                            style: TextStyle(
                                fontSize:
                                isTablet ? 16.0 : 14.0),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.date_range),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: state.selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              bloc.add(ReviewDateChanged(date: picked));
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: state.isSavingReview
                                ? null
                                : () {
                              if (formKey.currentState!.validate()) {
                                bloc.add(SaveReviewRequested(
                                  shopName: shopCtrl.text,
                                  mobileNo: mobileCtrl.text,
                                  reviewMsg: reviewMsgCtrl.text,
                                ));
                              }
                            },
                            child: state.isSavingReview
                                ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2))
                                : const Text('Save'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                    const SpotSaleViewPage()),
                              );
                              if (result == true) {
                                bloc.add(const LoadEmployeesRequested());
                              }
                            },
                            child: const Text('View'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PDOTab extends StatelessWidget {
  final bool isTablet;
  final TextEditingController searchController;

  const _PDOTab({required this.isTablet, required this.searchController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransportDashboardBloc, TransportDashboardState>(
      builder: (context, state) {
        final bloc = context.read<TransportDashboardBloc>();

        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('RTI Details',
                  style: TextStyle(
                      fontSize: isTablet ? 22.0 : 18.0,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search RTI No / Driver / Truck',
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 12),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onChanged: (v) =>
                    bloc.add(RTISearchQueryChanged(query: v)),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: state.status == TransportDashboardStatus.loading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  itemCount: state.filteredRTIMasterList.length,
                  itemBuilder: (context, index) {
                    final m = state.filteredRTIMasterList[index];
                    final details = state.rtiDetailList
                        .where((d) => d.RTIMasterRefId == m.Id)
                        .toList();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.all(12),
                        childrenPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(m.RTINoDisplay,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text('RM${m.Amount}',
                                    style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(m.RTIDate,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey)),
                          ],
                        ),
                        children: [
                          // Master info
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                _infoRow('Driver', m.DriverName),
                                _infoRow('Truck', m.TruckName),
                                _infoRow('Remarks', m.Remarks),
                              ],
                            ),
                          ),

                          // Detail rows
                          ...details.map((d) => Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey.shade300),
                              borderRadius:
                              BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(d.JobNo,
                                    style: const TextStyle(
                                        fontWeight:
                                        FontWeight.bold)),
                                const SizedBox(height: 6),
                                _infoRow('Customer', d.CustomerName),
                                Checkbox(
                                  value: d.isChecked,
                                  onChanged: (v) => bloc.add(
                                      RTIDetailCheckToggled(
                                        detailId: d.Id,
                                        isChecked: v ?? false,
                                      )),
                                ),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () => bloc.add(
                                          RTIImagePicked(
                                              detailId: d.Id,
                                              fromCamera: true)),
                                      icon: const Icon(
                                          Icons.camera_alt),
                                      label:
                                      const Text('Camera'),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () => bloc.add(
                                          RTIImagePicked(
                                              detailId: d.Id,
                                              fromCamera: false)),
                                      icon: const Icon(
                                          Icons.photo_library),
                                      label: const Text('Gallery'),
                                    ),
                                    _buildImageWidget(
                                        d.imagePath, context),
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: state.isSavingRTI
                                      ? null
                                      : () => bloc.add(
                                      SaveRTIDataRequested(
                                          masterId: m.Id)),
                                  child: state.isSavingRTI
                                      ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child:
                                      CircularProgressIndicator(
                                          strokeWidth: 2))
                                      : const Text('Save'),
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text('$label :',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ),
      ],
    ),
  );

  Widget _buildImageWidget(String? path, BuildContext context) {
    if (path == null || path.isEmpty) return const SizedBox.shrink();

    Widget imageWidget;
    if (path.startsWith('http')) {
      imageWidget = Image.network(path, fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
          const Icon(Icons.broken_image, color: Colors.red));
    } else if (path.startsWith('/data/')) {
      imageWidget = Image.file(File(path), fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
          const Icon(Icons.broken_image, color: Colors.red));
    } else if (path.startsWith('/')) {
      final fullUrl = ApiConstants.port + path;
      imageWidget = Image.network(fullUrl, fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
          const Icon(Icons.broken_image, color: Colors.red));
    } else {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () => _showImagePopup(context, imageWidget),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(width: 100, height: 100, child: imageWidget),
      ),
    );
  }

  void _showImagePopup(BuildContext context, Widget imageWidget) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          children: [
            InteractiveViewer(child: Center(child: imageWidget)),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}