import 'package:flutter/material.dart';
import 'package:maleva/features/notifications/notification_bell.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import '../../../../core/bluetooth/view/Bluetooth_tab.dart';
import '../../../../core/colors/colors.dart';
import '../../../../core/models/model.dart';
import '../../../../menu/menulist.dart';
import '../../common_tabs/driver/view/driverdetails_tab.dart';
import '../../common_tabs/enginehours/view/enginehours_tab.dart';
import '../../common_tabs/fuel/view/fuelreport_tab.dart';
import '../../common_tabs/fuelfillings/view/fuelfillings_tab.dart';
import '../../common_tabs/pettycash/view/pettycash_tab.dart';
import '../../common_tabs/saleorderview/view/saleorderview_tab.dart';
import '../../common_tabs/speedingreport/view/speedingreport_view.dart';
import '../../common_tabs/truck/view/truckview_tab.dart';
import '../../common_tabs/driversalary/view/driversalary_tab.dart';
import '../expenses/expense_report_tab.dart';
import '../../common_tabs/paymentview/view/paymentview_tab.dart';
import '../today/view/payable_today_tab.dart';
import '../completed/completed_tab.dart';
import '../reminders/view/reminders_view.dart';
import '../records/view/records_tab.dart';
import 'payable_spend_tab.dart';
import 'payable_tabs.dart';
import 'package:maleva/core/widgets/custom_app_bar.dart';
import 'package:maleva/features/dashboard/common_tabs/driverleave/view/employee_leave_request_tab.dart';
import 'package:maleva/core/models/shared/barcode_print_model.dart';
import 'package:maleva/core/utils/auth_helper.dart';
import 'package:maleva/features/ir_report/presentation/pages/ir_report_tab.dart';

class PayableMobileDashboard extends StatelessWidget {
  final TabController tabController;
  final bool isTablet;
  const PayableMobileDashboard({required this.tabController, required this.isTablet, super.key});

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

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isTablet) {
    return CustomGradientAppBar(
      title: 'Payable',
      isTablet: isTablet,
      actions: [
        // the bell: unread notices and open vessel alerts (vessel-master-and-ptp-schedule)
        NotificationBellButton(isTablet: isTablet),
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
        tabs: [for (final t in PayableTab.values) _tab(t.label, isTablet)],
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
    return TabBarView(
      controller: tabController,
      children: [for (final t in PayableTab.values) _page(t)],
    );
  }

  /// The page of each tab (order and names in [PayableTab]; change `payable-desk-today`).
  Widget _page(PayableTab t) => switch (t) {
        PayableTab.today => PayableTodayTab(onOpen: (tab) => tabController.animateTo(tab.index)),
        PayableTab.reminders => const RemindersView(),
        PayableTab.spend => const PayableSpendTab(),
        PayableTab.records => const RecordsTab(),
        PayableTab.completed => const CompletedTab(),
        PayableTab.payments => const PaymentPendingPage(),
        PayableTab.pettyCash => const PettyCashPage(),
        PayableTab.expenses => const ExpenseReportTab(),
        PayableTab.driverSalary => const DriverSalaryWidget(),
        PayableTab.irReport => const IrReportTab(),
        PayableTab.empLeave => const EmployeeLeaveRequestTab(),
        PayableTab.fuelFilling => const FuelFillingPage(),
        PayableTab.speeding => const SpeedingScreen(),
        PayableTab.engineHours => const EngineHoursPage(),
        PayableTab.fuel => const FuelDiffPage(),
        PayableTab.driver => const DriverDetailsView(),
        PayableTab.truck => const TruckDetailsReportPage(),
      };
}
