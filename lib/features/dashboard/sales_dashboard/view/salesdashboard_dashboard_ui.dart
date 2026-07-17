import 'package:maleva/core/network/api_legacy_helper.dart';
import 'package:flutter/material.dart';
import 'package:maleva/core/widgets/custom_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/menu/menulist.dart';
import '../../../../core/bluetooth/view/Bluetooth_tab.dart';
import '../../../../core/models/model.dart';
import 'package:maleva/core/utils/app_globals.dart';
import '../../common_tabs/airfreightsales/view/airfreightsales_tab.dart';
import '../../common_tabs/enquiry/view/view/enquiry_tab.dart';
import '../../common_tabs/fuel/view/fuelreport_tab.dart';
import '../../common_tabs/paymentview/view/paymentview_tab.dart';
import '../../common_tabs/saleorderview/view/saleorderview_tab.dart';
import '../../common_tabs/transport/view/transportview_tab.dart';
import '../../common_tabs/vesselreport/view/vesselreportview_tab.dart';
import '../../common_tabs/driverleave/view/admin_leave_approval_tab.dart';
import '../bloc/sales_bloc.dart';
import '../bloc/sales_state.dart';
import 'package:maleva/features/dashboard/common_tabs/driverleave/view/employee_leave_request_tab.dart';
import 'package:maleva/core/models/shared/barcode_print_model.dart';
class SalesDashboardView extends StatelessWidget {
  final TabController tabController;
  final bool isTablet;
  const SalesDashboardView ({required this.tabController, required this.isTablet, super.key});

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

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isTablet){
    return CustomGradientAppBar(
      title: 'Sales',
      isTablet: isTablet,
      actions: [
        IconButton(
          icon: Icon(Icons.directions_boat_filled,
              size: isTablet ? 28 : 25),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => Saleorderview())),
        ),
        IconButton(
          icon: Icon(Icons.bluetooth_audio,
              size: isTablet ? 28 : 25),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => BluetoothPage())),
        ),
        IconButton(
          icon: Icon(Icons.print,
              size: isTablet ? 28 : 25),
          onPressed: () async {
            await printdata([
              BarcodePrintModel("MALEVA", "SHIPNAME", "SHIPNAME",
                  "B0005000", "2025-05-04", "WESTPORT", "WESTPORT", "(1/3)")
            ]);
          },
        ),
        IconButton(
          icon: Icon(Icons.exit_to_app,
              size: isTablet ? 32 : 30),
          onPressed: () => ApiLegacyHelper.logout(context),
        ),
        if (isTablet) const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTabBar(bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? 20 : 12,
        vertical: isTablet ? 12 : 10,
      ),
      padding: EdgeInsets.all(isTablet ? 0 : 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 36 : 30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: isTablet ? 12 : 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
          controller: tabController,
          isScrollable: true,
          indicator: BoxDecoration(
            color: colour.AppColors.appBarColor,
            borderRadius: BorderRadius.circular(isTablet ? 20 : 25),
          ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: colour.kNavy,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: isTablet ? 14 : 13,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: isTablet ? 14 : 13,
        ),
        tabs: [
          _tab('SALES', isTablet),
          _tab('VSL', isTablet),
          _tab('TRANSPORT', isTablet),
          _tab('ENQUIRY', isTablet),
          _tab('FUEL VIEW', isTablet),
          _tab('PaymentView', isTablet),
          _tab('Leave', isTablet),
          _tab('EmpLeave', isTablet),
        ],
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
    return BlocListener<SalesDashboardBloc, SalesDashboardState>(
        listener: (context, tabState) {
        switch (tabState.index) {
          case 0:
            // AirfreightSales bloc auto-loads in constructor, so do nothing.
            break;
        }
      },
        child: TabBarView(
          controller: tabController,
          children: [
            const AirfreightSales(),
            const VesselReportPage(),
            const TransportReportPage(),
            const EnquiryScreen(),
            const FuelDiffPage(),
            const PaymentPendingPage(),
            const AdminLeaveApprovalTab(),
          const EmployeeLeaveRequestTab(),
          ],
        ),
    );
  }

}