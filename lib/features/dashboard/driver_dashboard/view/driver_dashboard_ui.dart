import 'package:flutter/Material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../SaleOrderView/SaleOrderView.dart';
import '../../../../core/bluetooth/bluetoothmanager.dart';
import '../../../../core/colors/colors.dart' as colour;
import '../../../../core/models/model.dart';
import '../../../../core/utils/clsfunction.dart' as objfun;
import '../../../../menu/menulist.dart';
import '../../../common_updates/blocs/sales/sales_bloc.dart';
import '../../../common_updates/blocs/sales/sales_event.dart';
import '../../admin_dashboard/tabs/drivermaintenance/view/drivermaintenance_tab.dart';
import '../../admin_dashboard/tabs/maintenance/view/maintenance_tab.dart';
import '../../admin_dashboard/tabs/pdo/view/pdo_tab.dart';
import '../../admin_dashboard/tabs/summonentry/view/summonentry_tab.dart';
import '../../admin_dashboard/tabs/transport/view/transportview_tab.dart';
import '../bloc/driver_bloc.dart';
import '../bloc/driver_state.dart';

class DriverDashboardView extends StatelessWidget {
  final TabController tabController;
  final bool isTablet;
  const DriverDashboardView ({required this.tabController, required this.isTablet, super.key});
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
    return AppBar(
      backgroundColor: colour.AppColors.appBarColor,
      toolbarHeight: isTablet ? 64 : 56,
      title: Text(
        'Driver',
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

          _tab('TRANSPORT', isTablet),
          _tab('Maintenance', isTablet),
          _tab('SummonEntry',     isTablet),
          _tab('PDO',             isTablet),

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
    return BlocListener<DriverDashboardBloc, DriverDashboardState>(
      listener: (context, tabState) {
        switch (tabState.index) {
          case 0:
            context.read<SalesBloc>().add(LoadSales(0));
            break;

        }
      },
      child: TabBarView(
        controller: tabController,
        children: [

          const TransportReportPage(),
          const TruckMaintenanceDashboardWidget(),
          const SummonEntryPage(),
          PDOViewPage(
            fromDate: DateFormat('yyyy-MM-dd')
                .format(DateTime.now().subtract(const Duration(days: 30))),
            toDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          ),

        ],
      ),
    );
  }
}