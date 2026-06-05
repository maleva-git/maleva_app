import 'package:flutter/Material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../admin_dashboard/tabs/driverlicense/bloc/driverlicense_bloc.dart';
import '../../admin_dashboard/tabs/driverlicense/bloc/driverlicense_event.dart';
import '../../admin_dashboard/tabs/driverlicense/view/driverlicense_tab.dart';
import '../../admin_dashboard/tabs/drivermaintenance/bloc/drivermaintenance_bloc.dart';
import '../../admin_dashboard/tabs/drivermaintenance/bloc/drivermaintenance_event.dart';
import '../../admin_dashboard/tabs/drivermaintenance/view/drivermaintenance_tab.dart';
import '../../admin_dashboard/tabs/driversalary/bloc/driversalary_bloc.dart';
import '../../admin_dashboard/tabs/driversalary/bloc/driversalary_event.dart';
import '../../admin_dashboard/tabs/driversalary/view/driversalary_tab.dart';
import '../../admin_dashboard/tabs/pdo/bloc/pdo_bloc.dart';
import '../../admin_dashboard/tabs/pdo/data/pdo_repository.dart';
import '../../admin_dashboard/tabs/pdo/view/pdo_tab.dart';
import '../../admin_dashboard/tabs/summonentry/bloc/summonentry_bloc.dart';
import '../../admin_dashboard/tabs/summonentry/data/summonentry_repository.dart';
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
    _tabController = TabController(length: 6, vsync: this);
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
                  create: (context) => sl<TransportBloc>()
                    ..add(const LoadTransportDataEvent(type: 0)),
                  child: const TransportReportPage(),
                ),
                BlocProvider(
                  create: (_) => SummonBloc.form(
                    repository: sl<SummonRepository>(),
                  ),
                  child: const SummonEntryPage(),
                ),
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
                BlocProvider(
                  create: (_) => PDOBloc(
                    repository: sl<PDORepository>(), // ✅ Repository injected here!
                    fromDate: DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 30))),
                    toDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                  ),
                  child: PDOViewPage(
                    fromDate: DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 30))),
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