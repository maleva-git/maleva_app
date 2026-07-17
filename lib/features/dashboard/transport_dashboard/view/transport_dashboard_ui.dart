import 'package:maleva/core/network/api_legacy_helper.dart';
import 'package:flutter/Material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import '../../../../core/bluetooth/view/Bluetooth_tab.dart';
import '../../../../core/colors/colors.dart';
import '../../../../core/models/model.dart';
import '../../../../menu/menulist.dart';
import '../../common_tabs/emailinbox/view/emailinbox_tab.dart';
import '../../common_tabs/enquiry/view/view/enquiry_tab.dart';
import '../../common_tabs/googlereview/view/googlereview_tab.dart';
import '../../common_tabs/pdo/view/pdo_tab.dart';
import '../../common_tabs/saleorderview/view/saleorderview_tab.dart';
import '../../common_tabs/transport/view/transportview_tab.dart';
import '../../common_tabs/transportsales/view/transport_sales_tab.dart';
import '../bloc/transport_bloc.dart';
import '../bloc/transport_state.dart';
import 'package:maleva/core/widgets/custom_app_bar.dart';
import 'package:maleva/features/dashboard/common_tabs/driverleave/view/admin_leave_approval_tab.dart';
import 'package:maleva/features/dashboard/common_tabs/driverleave/view/employee_leave_request_tab.dart';
import 'package:maleva/core/models/shared/barcode_print_model.dart';


class TransportMobileDashboard extends StatelessWidget {
  final TabController tabController;
  final bool isTablet;
  const TransportMobileDashboard({required this.tabController, required this.isTablet, super.key});

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
      title: 'Transport',
      isTablet: isTablet,
      actions: [
        IconButton(
          icon: Icon(Icons.directions_boat_filled,
              size: isTablet ? 28 : 25, ),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => Saleorderview())),
        ),
        IconButton(
          icon: Icon(Icons.bluetooth_audio,
              size: isTablet ? 28 : 25, ),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => BluetoothPage())),
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
            color: Colors.black.withOpacity(0.06),
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
          _tab('SALES',       isTablet),
          _tab('TRANSPORT',       isTablet),
          _tab('Enquiry',       isTablet),
          _tab('Email',           isTablet),
          _tab('GoogleReview',    isTablet),
          _tab('PDO',             isTablet),
          _tab('LeaveApproval', isTablet),
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
    return BlocListener<TransportTabBloc, TransportTabState>(
      listener: (context, tabState) {
        switch (tabState.index) {
          case 0:
            
            break;
          case 6:
            
            break;
        }
      },
      child: TabBarView(
        controller: tabController,
        children: [

          const TransportSalesTab(),
          const TransportReportPage(),
          const EnquiryScreen(),
          const EmailPage(),
          const ReviewEntryPage(),
          PDOViewPage(
            fromDate: DateFormat('yyyy-MM-dd')
                .format(DateTime.now().subtract(const Duration(days: 7))),
            toDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          ),



          const AdminLeaveApprovalTab(),
          const EmployeeLeaveRequestTab(),
        ],
      ),
    );
  }
}
