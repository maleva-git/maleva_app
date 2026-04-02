import 'package:flutter/Material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;
import '../../../../SaleOrderView/SaleOrderView.dart';
import '../../../../core/bluetooth/bluetoothmanager.dart';
import '../../../../core/colors/colors.dart';
import '../../../../core/models/model.dart';
import '../../../../menu/menulist.dart';
import '../../../common_updates/blocs/sales/sales_bloc.dart';
import '../../../common_updates/blocs/sales/sales_event.dart';
import '../../../common_updates/blocs/truck/truck_bloc.dart';
import '../../../common_updates/blocs/truck/truck_event.dart';
import '../../admin_dashboard/tabs/ExpenseReport/view/expensereport_tab.dart';
import '../../admin_dashboard/tabs/bocheck/view/bocheck_tab.dart';
import '../../admin_dashboard/tabs/driver/view/driverdetails_tab.dart';
import '../../admin_dashboard/tabs/emailinbox/view/emailinbox_tab.dart';
import '../../admin_dashboard/tabs/employeemaster/view/employeemaster_tab.dart';
import '../../admin_dashboard/tabs/enginehours/view/enginehours_tab.dart';
import '../../admin_dashboard/tabs/forwardingreport/view/forwardingreport_tab.dart';
import '../../admin_dashboard/tabs/fuel/view/fuelreport_tab.dart';
import '../../admin_dashboard/tabs/fuelfillings/view/fuelfillings_tab.dart';
import '../../admin_dashboard/tabs/googlereview/view/googlereview_tab.dart';
import '../../admin_dashboard/tabs/inventoryreport/view/inventoryview_tab.dart';
import '../../admin_dashboard/tabs/invoice/view/invoice_tab.dart';
import '../../admin_dashboard/tabs/paymentview/view/paymentview_tab.dart';
import '../../admin_dashboard/tabs/pdo/view/pdo_tab.dart';
import '../../admin_dashboard/tabs/pettycash/view/pettycash_tab.dart';
import '../../admin_dashboard/tabs/receiptview/view/receiptview_tab.dart';
import '../../admin_dashboard/tabs/rtiview/view/rtiview_tab.dart';
import '../../admin_dashboard/tabs/salesorder/view/salesorderview_tab.dart';
import '../../admin_dashboard/tabs/spareparts/view/sparepartsadd.dart';
import '../../admin_dashboard/tabs/speedingreport/view/speedingreport_view.dart';
import '../../admin_dashboard/tabs/spotsaleorder/view/spotsaleorder_add.dart';
import '../../admin_dashboard/tabs/summonentry/view/summonentry_tab.dart';
import '../../admin_dashboard/tabs/transport/view/transportview_tab.dart';
import '../../admin_dashboard/tabs/truck/view/truckview_tab.dart';
import '../../admin_dashboard/tabs/vesselreport/view/vesselreportview_tab.dart';
import '../bloc/operationadmin_dashboard_bloc.dart';
import '../bloc/operationadmin_dashboard_state.dart';


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
    return AppBar(
      backgroundColor: AppColors.appBarColor,
      toolbarHeight: isTablet ? 64 : 56,
      title: Text(
        'Operation Dash Board',
        style: GoogleFonts.lato(
          color: colour.topAppBarColor,
          fontWeight: FontWeight.bold,
          fontSize: isTablet ? 20 : objfun.FontLarge,
        ),
      ),
      iconTheme: const IconThemeData(color: colour.topAppBarColor),
      actions: [
        IconButton(
          icon: Icon(Icons.directions_boat_filled,
              size: isTablet ? 28 : 25, color: colour.topAppBarColor),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => Saleorderview())),
        ),
        IconButton(
          icon: Icon(Icons.bluetooth_audio,
              size: isTablet ? 28 : 25, color: colour.topAppBarColor),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => Bluetoothpage())),
        ),
        IconButton(
          icon: Icon(Icons.print,
              size: isTablet ? 28 : 25, color: colour.topAppBarColor),
          onPressed: () async {
            await objfun.printdata([
              BarcodePrintModel("MALEVA", "SHIPNAME", "SHIPNAME",
                  "B0005000", "2025-05-04", "WESTPORT", "WESTPORT", "(1/3)")
            ]);
          },
        ),
        IconButton(
          icon: Icon(Icons.exit_to_app,
              size: isTablet ? 32 : 30, color: colour.topAppBarColor),
          onPressed: () => objfun.logout(context),
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
          fontSize: isTablet ? 14 : 13,   // ← இங்கயும் மாத்து
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: isTablet ? 14 : 13,   // ← இங்கயும் மாத்து
        ),
        tabs: [

          _tab('VSL',             isTablet),


          _tab('Truck',           isTablet),
          _tab('Driver',          isTablet),
          _tab('SpeedingReport',  isTablet),
          _tab('FuelFilling',     isTablet),
          _tab('EngineHours',     isTablet),
          _tab('Fuel',            isTablet),
          _tab('SparePartsEntry', isTablet),
          _tab('SpotsSaleOrder',  isTablet),

          _tab('InventoryReport', isTablet),
          _tab('PDO',             isTablet),
          _tab('RTI',             isTablet),
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
    return BlocListener<OperationAdminTabBloc, OperationAdminTabState>(
      listener: (context, tabState) {
        switch (tabState.index) {
          case 0:
            context.read<SalesBloc>().add(LoadSales(0));
            break;
          case 6:
            context.read<TruckBloc>().add(LoadTruckList());
            break;
        }
      },
      child: TabBarView(
        controller: tabController,
        children: [

          const VesselReportPage(),
          const TruckDetailsReportPage(),
          const DriverDetailsView(),
          const SpeedingScreen(),
          const FuelFillingPage(),
          const EngineHoursPage(),
          const FuelDiffPage(),
          const SparePartsEntryPage(),
          const SpotSaleEntryPage(),
          const InventoryPage(),
          PDOViewPage(
            fromDate: DateFormat('yyyy-MM-dd')
                .format(DateTime.now().subtract(const Duration(days: 30))),
            toDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          ),
          const RTIDetailsPage(),
        ],
      ),
    );
  }
}
