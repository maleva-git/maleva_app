import 'package:flutter/Material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../common_tabs/driver/bloc/driverdetails_bloc.dart';
import '../../common_tabs/driver/bloc/driverdetails_event.dart';
import '../../common_tabs/driver/view/driverdetails_tab.dart';
import '../../common_tabs/enginehours/bloc/enginehours_bloc.dart';
import '../../common_tabs/enginehours/bloc/enginehours_event.dart';
import '../../common_tabs/enginehours/view/enginehours_tab.dart';
import '../../common_tabs/fuel/bloc/fuelreport_bloc.dart';
import '../../common_tabs/fuel/bloc/fuelreport_event.dart';
import '../../common_tabs/fuel/view/fuelreport_tab.dart';
import '../../common_tabs/fuelfillings/bloc/fuelfillings_bloc.dart';
import '../../common_tabs/fuelfillings/bloc/fuelfillings_event.dart';
import '../../common_tabs/fuelfillings/view/fuelfillings_tab.dart';
import '../../common_tabs/inventoryreport/bloc/inventoryreport_bloc.dart';
import '../../common_tabs/inventoryreport/bloc/inventoryreport_event.dart';
import '../../common_tabs/inventoryreport/data/inventoryreport_repository.dart';
import '../../common_tabs/inventoryreport/view/inventoryview_tab.dart';
import '../../common_tabs/maintenance/bloc/maintenance_bloc.dart';
import '../../common_tabs/maintenance/bloc/maintenance_event.dart';
import '../../common_tabs/maintenance/view/maintenance_tab.dart';
import '../../common_tabs/pdo/bloc/pdo_bloc.dart';
import '../../common_tabs/pdo/data/pdo_repository.dart';
import '../../common_tabs/pdo/view/pdo_tab.dart';
import '../../common_tabs/rtiview/bloc/rtiview_bloc.dart';
import '../../common_tabs/rtiview/bloc/rtiview_event.dart';
import '../../common_tabs/rtiview/view/rtiview_tab.dart';
import '../../common_tabs/spareparts/bloc/spareparts_bloc.dart';
import '../../common_tabs/spareparts/bloc/spareparts_event.dart';
import '../../common_tabs/spareparts/data/spareparts_repository.dart';
import '../../common_tabs/spareparts/view/sparepartsadd.dart';
import '../../common_tabs/speedingreport/bloc/speeding_bloc.dart';
import '../../common_tabs/speedingreport/bloc/speeding_event.dart';
import '../../common_tabs/speedingreport/view/speedingreport_view.dart';
import '../../common_tabs/spotsaleorder/bloc/spotsaleorder_bloc.dart';
import '../../common_tabs/spotsaleorder/data/spotsale_repository.dart';
import '../../common_tabs/spotsaleorder/view/spotsaleorder_add.dart';
import '../../common_tabs/truck/bloc/truck_bloc.dart';
import '../../common_tabs/truck/view/truckview_tab.dart';
import '../../common_tabs/vesselreport/bloc/vesselreport_bloc.dart';
import '../../common_tabs/vesselreport/bloc/vesselreport_event.dart';
import '../../common_tabs/vesselreport/view/vesselreportview_tab.dart';
import '../bloc/operationadmin_dashboard_bloc.dart';
import '../bloc/operationadmin_dashboard_event.dart';
import 'operationadmin_dashboard_ui.dart';
import 'package:maleva/features/dashboard/common_tabs/driverleave/bloc/leave_bloc.dart';

class OperationAdminDashboard extends StatefulWidget{
  const OperationAdminDashboard({super.key});

  @override
  State<OperationAdminDashboard> createState() => _AdminDashboardState();
}
class _AdminDashboardState extends State<OperationAdminDashboard> with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 16, vsync: this);
    _tabController.addListener(_onTabChanged);

  }

  void _onTabChanged(){
    final index = _tabController.index;
    context.read<OperationAdminTabBloc>().add(TabChanged(index));
  }
  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
            BlocProvider<OperationAdminTabBloc>(
              create: (_) => OperationAdminTabBloc(),
            ),

            BlocProvider(
              create: (_) => sl<MaintenanceBloc>()..add(MaintenanceStarted()),
              child: const MaintenanceDashboardWidget(),
            ),
            BlocProvider(
              create: (context) => sl<VesselBloc>()
                ..add(const LoadVesselDataEvent(type: 0)),
              child: const VesselReportPage(),
            ),

            BlocProvider(
              create: (context) => sl<TruckDetailsBloc>()..add(const LoadTruckDetailsEvent()),
              child: const TruckDetailsReportPage(), // Make sure to add a BlocListener inside here if you want to show snackbars for TruckErrorState!
            ),
            BlocProvider(
            create: (context) => sl<DriverBloc>()..add(const LoadDriverEvent()),
            child: const DriverDetailsView(), // Remember to add a BlocListener here if you want to show errors to the user!
            ),
            BlocProvider(
              create: (context) => sl<SpeedingBloc>()..add(LoadSpeedingReport()),
              child: const SpeedingScreen(), // Add a BlocListener here to show SnackBars for SpeedingError if needed!
            ),
            BlocProvider(
              create: (context) => sl<FuelFillingBloc>()..add(LoadFuelFillingReport()),
              child: const FuelFillingPage(), // Add a BlocListener here to show SnackBars for FuelFillingError if needed!
            ),
            BlocProvider(
              create: (context) => sl<EngineHoursBloc>()..add(LoadEngineHoursReport()),
              child: const EngineHoursPage(), // Add a BlocListener here to show SnackBars for EngineHoursError if needed!
            ),

            BlocProvider(
              create: (context) => sl<FuelDiffBloc>()..add(const LoadFuelDiffEvent()),
              child: const FuelDiffPage(), // Remember to add BlocListener here if you want to show SnackBars for FuelDiffError!
            ),
            BlocProvider(
              // ✅ Removed 'context', added named 'repository', and removed the redundant ..add() cascade
              create: (_) => SparePartsBloc.form(
                repository: sl<SparePartsRepository>(),
              ),
              child: const SparePartsEntryPage(),
            ),
            BlocProvider(
              // ✅ Removed 'context', added named 'repository' parameter
              create: (_) => SpotSaleBloc.form(
                repository: sl<SpotSaleRepository>(),
              ),
              child: const SpotSaleEntryPage(),
            ),
            BlocProvider(
              // ✅ Removed 'context', added named 'repository', and removed the redundant ..add() cascade
              create: (_) => InventoryBloc(
                repository: sl<InventoryReportRepository>(),
              ),
              child: const InventoryPage(),
            ),
            BlocProvider(
              create: (_) => PDOBloc(
                repository: sl<PDORepository>(), // ✅ Repository injected here!
                fromDate: DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 7))),
                toDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
              ),
              child: PDOViewPage(
                fromDate: DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 7))),
                toDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
              ),
            ),
            BlocProvider(
              create: (_) => sl<RTIDetailsBloc>(),
              child: const RTIDetailsPage(),
            ),
        BlocProvider<LeaveBloc>(create: (_) => sl<LeaveBloc>()),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;
        return Scaffold(
            body: MobileDashboard(
              tabController: _tabController,
              isTablet: isTablet,
            ),
          );
        },
      ),
    );                                          // ← LayoutBuilder close
  }                                             // ← build() close
}


