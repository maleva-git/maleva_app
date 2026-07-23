import 'package:maleva/core/network/api_legacy_helper.dart';
import 'package:flutter/Material.dart';
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
import '../../common_tabs/rtiview/view/rtiview_tab.dart';
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
import 'package:maleva/core/models/shared/barcode_print_model.dart';

class MobileDashboard extends StatelessWidget {
  final TabController tabController;
  final bool isTablet;
  const MobileDashboard({required this.tabController, required this.isTablet, super.key});

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
          onPressed: () => ApiLegacyHelper.logout(context),
        ),
        if (isTablet) const SizedBox(width: 8),
      ],
    );
  }

  // ── TabBar ────────────────────────────────────────────────────────────
// ✅ Step 2: _buildTabBar() method-ல container size மாத்து
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
        tabs: [
          _tab('Invoice',         isTablet),
          _tab('ReceiptView',     isTablet),
          _tab('SO',              isTablet),
          _tab('FW',              isTablet),
          _tab('EXP',             isTablet),
          _tab('VSL',             isTablet),
          _tab('TRANSPORT',       isTablet),
          _tab('Truck',           isTablet),
          _tab('Driver',          isTablet),
          _tab('SpeedingReport',  isTablet),
          _tab('FuelFilling',     isTablet),
          _tab('EngineHours',     isTablet),
          _tab('BOCheck',         isTablet),
          _tab('Email',           isTablet),
          _tab('GoogleReview',    isTablet),
          _tab('Fuel',            isTablet),
          _tab('EmployeeView',    isTablet),
          _tab('PettyCash',       isTablet),
          _tab('SummonEntry',     isTablet),
          _tab('SparePartsEntry', isTablet),
          _tab('PaymentView',     isTablet),
          _tab('SpotsSaleOrder',  isTablet),
          _tab('InventoryReport', isTablet),
          _tab('PDO',             isTablet),
          _tab('RTI',             isTablet),
          _tab('LeaveApproval',   isTablet),

          _tab('EmpApproval', isTablet),
          _tab('EmpLeave', isTablet),
        ],
      ),
    );
  }

  // ── Tab item ──────────────────────────────────────────────────────────
// ✅ Step 1: _tab() method-ல isTablet add பண்ணு
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
  // ── TabBarView ────────────────────────────────────────────────────────
  Widget _buildTabBarView(BuildContext context) {
    return BlocListener<AdminTabBloc, AdminTabState>(
      listener: (context, tabState) {
        // No longer dispatching to SalesBloc or TruckBloc as they were removed

      },
      child: TabBarView(
        controller: tabController,
        children: [
          const InvoiceTab(),
          const ReceiptPage(),
          const SalesOrderTab(),
          const ForwardingReportPage(),
          const ExpenseReportPage(),
          const VesselReportPage(),
          const TransportReportPage(),
          const TruckDetailsReportPage(),
          const DriverDetailsView(),
          const SpeedingScreen(),
          const FuelFillingPage(),
          const EngineHoursPage(),
          const BocPage(),
          const EmailPage(),
          const ReviewEntryPage(),
          const FuelDiffPage(),
          const EmployeeViewPage(),
          const PettyCashPage(),
          const SummonEntryPage(),
          const SparePartsEntryPage(),
          const PaymentPendingPage(),
          const SpotSaleEntryPage(),
          const InventoryPage(),
          PDOViewPage(
            fromDate: DateFormat('yyyy-MM-dd')
                .format(DateTime.now().subtract(const Duration(days: 7))),
            toDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          ),
          const RTIDetailsPage(),
          const AdminLeaveApprovalTab(),
          const EmployeeLeaveApprovalTab(),
          const EmployeeLeaveRequestTab(isAdminOrSubadmin: true),
        ],
      ),
    );
  }
}
