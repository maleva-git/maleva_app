import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../common_tabs/driverlicense/bloc/driverlicense_bloc.dart';
import '../../common_tabs/driverlicense/bloc/driverlicense_event.dart';
import '../../common_tabs/driverlicense/view/driverlicense_tab.dart';
import '../../common_tabs/drivermaintenance/bloc/drivermaintenance_bloc.dart';
import '../../common_tabs/drivermaintenance/bloc/drivermaintenance_event.dart';
import '../../common_tabs/drivermaintenance/view/drivermaintenance_tab.dart';
import '../../common_tabs/driversalary/bloc/driversalary_bloc.dart';
import '../../common_tabs/driversalary/bloc/driversalary_event.dart';
import '../../common_tabs/driversalary/view/driversalary_tab.dart';
import 'driver_dashboard_ui.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // owner 2026-10-28: Today, Fuel, Maintenance, Truck License, Salary, Driver Leave (Transport, Summons, PDO removed)
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
                BlocProvider(
                  create: (context) => sl<TruckMaintDashBloc>()
                    ..add(TruckMaintDashStarted()),
                  child: const TruckMaintDashView(),
                ),
                BlocProvider(
                  create: (context) => sl<DriverLicenseExpiryBloc>()
                    ..add(DriverLicenseExpiryStarted()),
                  child: const DriverLicenseExpiryWidget(),
                ),
                BlocProvider(
                  create: (context) => sl<DriverSalaryBloc>()
                    ..add(DriverSalaryStarted()),
                  child: const DriverSalaryWidget(),
                ),
              ],
      child: LayoutBuilder(
        builder: (context, constraints){
        return Builder(
                  builder: (context) {
                    return LayoutBuilder(
                        builder: (context, constraints) {
                          final isTablet = constraints.maxWidth >= 600;
                          return Scaffold(
                            body: DriverDashboardView(
                                tabController: _tabController,
                                isTablet: isTablet
                            ),
                          );
                        }
                    );
                  }
              );
        },
      ),
    );
  }
}