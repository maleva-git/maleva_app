import 'package:flutter/material.dart';
import 'package:maleva/core/widgets/custom_app_bar.dart';
import 'package:maleva/features/auth/presentation/mode_switch_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/bluetooth/view/Bluetooth_tab.dart';
import '../../../../menu/menulist.dart';
import '../../common_tabs/driverlicense/view/driverlicense_tab.dart';
import '../../common_tabs/drivermaintenance/view/drivermaintenance_tab.dart';
import '../../common_tabs/driversalary/view/driversalary_tab.dart';
import '../../common_tabs/driverleave/view/driver_leave_request_tab.dart';
import '../../common_tabs/fuelentry/view/driver_fuel_tab.dart';
import '../../../today_trips/today_trips_tab.dart';
import '../bloc/driver_bloc.dart';
import '../bloc/driver_state.dart';
import 'package:maleva/core/utils/auth_helper.dart';
import 'package:maleva/core/ui/premium.dart';

class DriverDashboardView extends StatelessWidget {
  final TabController tabController;
  final bool isTablet;
  const DriverDashboardView ({required this.tabController, required this.isTablet, super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Px.page,
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
      title: 'Driver Dashboard',
      isTablet: isTablet,
      actions: [
        // Driver mode -> Office mode for a driver who is also an employee
        ModeSwitchButton(isTablet: isTablet),

        IconButton(
          icon: Icon(Icons.bluetooth_audio,
              size: isTablet ? 28 : 25),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const BluetoothPage())),
        ),

        IconButton(
          icon: Icon(Icons.exit_to_app,
              size: isTablet ? 32 : 30),
          onPressed: () => AuthHelper.logout(context),
        ),
        if (isTablet) const SizedBox(width: 8),
      ],
    );
  }
  /// Pill tabs (owner 2026-10-29 premium look): a white track, the open tab a navy pill, the others quiet grey.
  /// Order (owner 2026-10-28): Today, Fuel, Maintenance, Truck License, Salary, Driver Leave.
  Widget _buildTabBar(bool isTablet) {
    const tabs = [
      (Icons.today_rounded, 'Today'),
      (Icons.local_gas_station_rounded, 'Fuel'),
      (Icons.build_circle_outlined, 'Maintenance'),
      (Icons.badge_outlined, 'Truck License'),
      (Icons.account_balance_wallet_outlined, 'Salary'),
      (Icons.event_available_outlined, 'Driver Leave'),
    ];
    return Container(
      margin: EdgeInsets.fromLTRB(isTablet ? 20 : 12, isTablet ? 14 : 12, isTablet ? 20 : 12, 4),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Px.card,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Px.line),
        boxShadow: Px.shadow,
      ),
      child: TabBar(
        controller: tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        dividerColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        indicator: BoxDecoration(
          color: Px.brand,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [BoxShadow(color: Px.brand.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: Px.sub,
        labelStyle: Px.t(isTablet ? 14 : 13, weight: FontWeight.w700),
        unselectedLabelStyle: Px.t(isTablet ? 14 : 13, weight: FontWeight.w600),
        tabs: [
          for (final (icon, text) in tabs)
            Tab(
              height: isTablet ? 44 : 40,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(icon, size: 17),
                  const SizedBox(width: 6),
                  Text(text),
                ]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabBarView(BuildContext context) {
    return BlocListener<DriverDashboardBloc, DriverDashboardState>(
      listener: (context, tabState) {
        switch (tabState.index) {
          case 0:
            
            break;

        }
      },
      child: TabBarView(
        controller: tabController,
        children: const [
          TodayTripsTab(),
          DriverFuelTab(),
          TruckMaintenanceDashboardWidget(),
          DriverLicenseExpiryWidget(),
          DriverSalaryWidget(),
          DriverLeaveRequestTab(),
        ],
      ),
    );
  }
}