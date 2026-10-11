import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import '../../../../core/bluetooth/view/Bluetooth_tab.dart';
import '../../../../core/colors/colors.dart';
import '../../../../core/models/model.dart';
import '../../../../menu/menulist.dart';
import '../bloc/admin_tab_bloc.dart';
import '../bloc/admin_tab_state.dart';
import '../../common_tabs/ExpenseReport/view/expensereport_tab.dart';
import '../../common_tabs/bocheck/view/bocheck_tab.dart';
import '../../common_tabs/driver/view/driverdetails_tab.dart';
import '../../common_tabs/emailinbox/view/emailinbox_tab.dart';
import '../../common_tabs/employeemaster/view/employeemaster_tab.dart';
import '../../common_tabs/enginehours/view/enginehours_tab.dart';
import '../../common_tabs/forwardingreport/view/forwardingreport_tab.dart';
import '../../common_tabs/fuel/view/fuelreport_tab.dart';
import '../../common_tabs/fuelfillings/view/fuelfillings_tab.dart';
import '../../common_tabs/googlereview/view/googlereview_tab.dart';
import '../../common_tabs/inventoryreport/view/inventoryview_tab.dart';
import '../../common_tabs/paymentview/view/paymentview_tab.dart';
import '../../common_tabs/pdo/view/pdo_tab.dart';
import '../../common_tabs/pettycash/view/pettycash_tab.dart';
import '../../common_tabs/receiptview/view/receiptview_tab.dart';
import '../../common_tabs/invoice/view/invoice_tab.dart';
import 'package:maleva/features/rti/list/view/rti_list_page.dart';
import '../../common_tabs/saleorderview/view/saleorderview_tab.dart';
import '../../common_tabs/salesorder/view/salesorderview_tab.dart';
import '../../common_tabs/spareparts/view/sparepartsadd.dart';
import '../../common_tabs/speedingreport/view/speedingreport_view.dart';
import '../../common_tabs/spotsaleorder/view/spotsaleorder_add.dart';
import '../../common_tabs/summonentry/view/summonentry_tab.dart';
import '../../common_tabs/transport/view/transportview_tab.dart';
import '../../common_tabs/truck/view/truckview_tab.dart';
import '../../common_tabs/vesselreport/view/vesselreportview_tab.dart';
import '../../common_tabs/driverleave/view/admin_leave_approval_tab.dart';
import 'package:maleva/core/widgets/custom_app_bar.dart';
import 'package:maleva/features/dashboard/common_tabs/driverleave/view/employee_leave_request_tab.dart';
import 'package:maleva/features/dashboard/common_tabs/driverleave/view/employee_leave_approval_tab.dart';
import '../../common_tabs/salary/view/salary_tab.dart';
import 'package:maleva/core/models/shared/barcode_print_model.dart';
import 'package:maleva/core/utils/auth_helper.dart';
import '../../common_tabs/top_customers/view/admin_top_customers_tab.dart';
import '../../common_tabs/job_orders/view/job_orders_tab.dart';
import 'package:maleva/features/ir_report/presentation/pages/ir_report_tab.dart';
import 'package:maleva/features/mail_monitor/view/mail_monitor_tab.dart';
import 'package:maleva/features/mail_monitor/report/mail_response_tab.dart';
import '../overview/view/admin_overview_tab.dart';

typedef AdminTab = ({String label, Widget page});

/// Every admin dashboard tab in order: the tab bar, the pages and the controller's length all come
/// from this one list. The Super Admin (role 100) gets Overview first and Mailbox Monitor and Mail
/// Response after Invoice (changes `super-admin-overview-tab`, `mail-response-report-tab`); [openTab] lets Overview switch to a tab by label.
List<AdminTab> adminTabs({required bool superAdmin, required void Function(String label) openTab}) => [
      if (superAdmin) (label: 'Overview', page: AdminOverviewTab(onOpenTab: openTab)),
      (label: 'SO', page: const SalesOrderTab()),
      (label: 'JobOrders', page: const JobOrdersTab()),
      (label: 'Invoice', page: const InvoiceTab()),
      if (superAdmin) (label: 'Mailbox Monitor', page: const MailMonitorTab()),
      if (superAdmin) (label: 'Mail Response', page: const MailResponseTab()),
      (label: 'IR Report', page: const IrReportTab()),
      (label: 'EXP', page: const ExpenseReportPage()),
      (label: 'VSL', page: const VesselReportPage()),
      (label: 'TRANSPORT', page: const TransportReportPage()),
      (label: 'ReceiptView', page: const ReceiptPage()),
      (label: 'FW', page: const ForwardingReportPage()),
      (label: 'Truck', page: const TruckDetailsReportPage()),
      (label: 'Driver', page: const DriverDetailsView()),
      (label: 'Salary', page: const SalaryTab()),
      (label: 'SpeedingReport', page: const SpeedingScreen()),
      (label: 'FuelFilling', page: const FuelFillingPage()),
      (label: 'EngineHours', page: const EngineHoursPage()),
      (label: 'BOCheck', page: const BocPage()),
      (label: 'Email', page: const EmailPage()),
      (label: 'GoogleReview', page: const ReviewEntryPage()),
      (label: 'Fuel', page: const FuelDiffPage()),
      (label: 'EmployeeView', page: const EmployeeViewPage()),
      (label: 'PettyCash', page: const PettyCashPage()),
      (label: 'SummonEntry', page: const SummonEntryPage()),
      (label: 'SparePartsEntry', page: const SparePartsEntryPage()),
      (label: 'PaymentView', page: const PaymentPendingPage()),
      (label: 'SpotsSaleOrder', page: const SpotSaleEntryPage()),
      (label: 'InventoryReport', page: const InventoryPage()),
      (
        label: 'PDO',
        page: PDOViewPage(
          fromDate: DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 7))),
          toDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        ),
      ),
      (label: 'RTI', page: const RtiListPage()),
      (label: 'DriverApproval', page: const AdminLeaveApprovalTab()),
      (label: 'EmpApproval', page: const EmployeeLeaveApprovalTab()),
      (label: 'EmpLeave', page: const EmployeeLeaveRequestTab(isAdminOrSubadmin: true)),
      (
        label: 'TopCustomers',
        page: AdminTopCustomersTab(
          comid: AppGlobals.Comid,
          fromDate: DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 30))),
          toDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        ),
      ),
    ];

class MobileDashboard extends StatelessWidget {
  final TabController tabController;
  final bool isTablet;

  /// The Super Admin's tabs: Overview first, Mailbox Monitor after Invoice.
  final bool superAdmin;
  const MobileDashboard({required this.tabController, required this.isTablet, this.superAdmin = false, super.key});

  List<AdminTab> get _tabs => adminTabs(superAdmin: superAdmin, openTab: _openTab);

  void _openTab(String label) {
    final index = _tabs.indexWhere((t) => t.label == label);
    if (index >= 0) tabController.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context, isTablet),
      drawer: const Menulist(),
      body: Column(
        children: [
          _buildTabBar(isTablet),
          Expanded(child: _buildTabBarView(context)),
        ],
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context, bool isTablet) {
    return CustomGradientAppBar(
      title: 'ADMIN',
      isTablet: isTablet,
      actions: [
        IconButton(
          icon: Icon(Icons.directions_boat_filled,
              size: isTablet ? 28 : 25, ),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const Saleorderview())),
        ),
        IconButton(
          icon: Icon(Icons.bluetooth_audio,
              size: isTablet ? 28 : 25, ),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const BluetoothPage())),
        ),
        IconButton(
          icon: Icon(Icons.print,
              size: isTablet ? 28 : 25, ),
          onPressed: () async {
            await printdata([
              BarcodePrintModel("MALEVA", "SHIPNAME", "SHIPNAME",
                  "B0005000", "2025-05-04", "WESTPORT", "WESTPORT", "(1/3)")
            ],
    );
  },
        ),
        IconButton(
          icon: Icon(Icons.exit_to_app,
              size: isTablet ? 32 : 30, color: colour.topAppBarColor),
          onPressed: () => AuthHelper.logout(context),
        ),
        if (isTablet) const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTabBar(bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? 20 : 12,
        vertical:   isTablet ? 12 : 10,
      ),
      padding: EdgeInsets.all(isTablet ? 8 : 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 36 : 30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: isTablet ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: tabController,
        isScrollable: true,
        indicator: BoxDecoration(
          color: AppColors.appBarColor,
          borderRadius: BorderRadius.circular(isTablet ? 28 : 25),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF1A2E5A),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: isTablet ? 14 : 13,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: isTablet ? 14 : 13,
        ),
        tabs: [for (final t in _tabs) _tab(t.label, isTablet)],
      ),
    );
  }

  Tab _tab(String text, bool isTablet) => Tab(
    height: isTablet ? 42 : null,
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 6 : 2,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isTablet ? 14 : 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
  Widget _buildTabBarView(BuildContext context) {
    return BlocListener<AdminTabBloc, AdminTabState>(
      listener: (context, tabState) {
      },
      child: TabBarView(
        controller: tabController,
        children: [for (final t in _tabs) t.page],
      ),
    );
  }
}
