import 'package:flutter/Material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;
import '../../../../core/bluetooth/view/Bluetooth_tab.dart';
import '../../../../core/colors/colors.dart';
import '../../../../core/models/model.dart';
import '../../../../menu/menulist.dart';
import '../../../common_updates/blocs/sales/sales_bloc.dart';
import '../../../common_updates/blocs/sales/sales_event.dart';
import '../../../common_updates/blocs/truck/truck_bloc.dart';
import '../../../common_updates/blocs/truck/truck_event.dart';
import '../../admin_dashboard/tabs/invoice/view/invoice_tab.dart';
import '../../admin_dashboard/tabs/saleorderview/view/saleorderview_tab.dart';
import '../../admin_dashboard/tabs/salesorder/view/salesorderview_tab.dart';
import '../bloc/receivable_bloc.dart';
import '../bloc/receivable_state.dart';
import 'package:maleva/core/widgets/custom_app_bar.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/driverleave/view/admin_leave_approval_tab.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/driverleave/view/employee_leave_request_tab.dart';


class ReceivableMobileDashboard extends StatelessWidget {
  final TabController tabController;
  final bool isTablet;
  const ReceivableMobileDashboard({required this.tabController, required this.isTablet, super.key});

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
      title: 'Receivable',
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
            await objfun.printdata([
              BarcodePrintModel("MALEVA", "SHIPNAME", "SHIPNAME",
                  "B0005000", "2025-05-04", "WESTPORT", "WESTPORT", "(1/3)")
            ],
    );
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
          fontSize: isTablet ? 14 : 13,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: isTablet ? 14 : 13,
        ),
        tabs: [
          _tab('Invoice',         isTablet),
          _tab('SO',              isTablet),

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
    return BlocListener<ReceivableTabBloc, ReceivableTabState>(
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
          const InvoiceTab(),
          const SalesOrderTab(),

          const AdminLeaveApprovalTab(),
          const EmployeeLeaveRequestTab(),
        ],
      ),
    );
  }
}
