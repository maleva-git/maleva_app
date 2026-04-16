import 'package:flutter/Material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../admin_dashboard/tabs/driverlicense/bloc/driverlicense_bloc.dart';
import '../../admin_dashboard/tabs/driverlicense/view/driverlicense_tab.dart';
import '../../admin_dashboard/tabs/drivermaintenance/bloc/drivermaintenance_bloc.dart';
import '../../admin_dashboard/tabs/drivermaintenance/view/drivermaintenance_tab.dart';
import '../../admin_dashboard/tabs/pdo/bloc/pdo_bloc.dart';
import '../../admin_dashboard/tabs/pdo/view/pdo_tab.dart';
import '../../admin_dashboard/tabs/summonentry/bloc/summonentry_bloc.dart';
import '../../admin_dashboard/tabs/summonentry/view/summonentry_tab.dart';
import '../../admin_dashboard/tabs/transport/bloc/transport_bloc.dart';
import '../../admin_dashboard/tabs/transport/bloc/transport_event.dart';
import '../../admin_dashboard/tabs/transport/view/transportview_tab.dart';
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
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_onTabChanged);
  }
  void _onTabChanged(){
    final index = _tabController.index;
    // context.read<SalesDashboardBloc>().add(TabChanged(index));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints){
          final isTablet = constraints.maxWidth >= 600;
          return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => TransportBloc(
                    context: context,
                  )..add(const LoadTransportDataEvent(type: 0)),
                  child: const TransportReportPage(),
                ),
                BlocProvider(
                  create: (context) => SummonBloc.form(context),
                  child: const SummonEntryPage(),
                ),

                BlocProvider(
                  create: (context) => TruckMaintDashBloc(),
                  child: const TruckMaintenanceDashboardWidget(),
                ),
                BlocProvider(
                  create: (context) => DriverLicenseExpiryBloc(),
                  child: const DriverLicenseExpiryWidget(),
                ),

                BlocProvider(
                  create: (context) => PDOBloc(
                    context,
                    fromDate: DateFormat('yyyy-MM-dd')
                        .format(DateTime.now().subtract(const Duration(days: 30))),
                    toDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                  ),
                  child: PDOViewPage(
                    fromDate: DateFormat('yyyy-MM-dd')
                        .format(DateTime.now().subtract(const Duration(days: 30))),
                    toDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                  ),
                ),
              ],
              child: Builder(
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
              )
          );
        }
    );
  }
}