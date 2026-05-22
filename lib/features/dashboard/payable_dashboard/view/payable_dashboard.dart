import 'package:flutter/Material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/features/dashboard/payable_dashboard/view/payable_dashboard_ui.dart';
import '../../../../core/di/injection.dart';
import '../../admin_dashboard/tabs/adinvoice/bloc/forecast/forecast_bloc.dart';
import '../../admin_dashboard/tabs/adinvoice/data/repositories/sales_forecast_repository.dart';
import '../../admin_dashboard/tabs/adinvoice/presentation/widgets/ai_sales_forecast_chart.dart';
import '../../admin_dashboard/tabs/aienginehours/bloc/ai_maintenance_bloc.dart';
import '../../admin_dashboard/tabs/aienginehours/data/repositories/maintenance_ai_repository.dart';
import '../../admin_dashboard/tabs/aienginehours/presentation/widgets/ai_maintenance_health_card.dart';
import '../../admin_dashboard/tabs/billorder/bloc/billorder_bloc.dart';
import '../../admin_dashboard/tabs/billorder/view/billorder_screen.dart';
import '../../admin_dashboard/tabs/driver/bloc/driverdetails_bloc.dart';
import '../../admin_dashboard/tabs/driver/bloc/driverdetails_event.dart';
import '../../admin_dashboard/tabs/driver/view/driverdetails_tab.dart';
import '../../admin_dashboard/tabs/enginehours/bloc/enginehours_bloc.dart';
import '../../admin_dashboard/tabs/enginehours/bloc/enginehours_event.dart';
import '../../admin_dashboard/tabs/enginehours/view/enginehours_tab.dart';
import '../../admin_dashboard/tabs/fuel/bloc/fuelreport_bloc.dart';
import '../../admin_dashboard/tabs/fuel/bloc/fuelreport_event.dart';
import '../../admin_dashboard/tabs/fuel/view/fuelreport_tab.dart';
import '../../admin_dashboard/tabs/fuelfillings/bloc/fuelfillings_bloc.dart';
import '../../admin_dashboard/tabs/fuelfillings/bloc/fuelfillings_event.dart';
import '../../admin_dashboard/tabs/fuelfillings/view/fuelfillings_tab.dart';
import '../../admin_dashboard/tabs/pettycash/bloc/pettycash_bloc.dart';
import '../../admin_dashboard/tabs/pettycash/bloc/pettycash_event.dart';
import '../../admin_dashboard/tabs/pettycash/view/pettycash_tab.dart';
import '../../admin_dashboard/tabs/speedingreport/bloc/speeding_bloc.dart';
import '../../admin_dashboard/tabs/speedingreport/bloc/speeding_event.dart';
import '../../admin_dashboard/tabs/speedingreport/view/speedingreport_view.dart';
import '../../admin_dashboard/tabs/truck/bloc/truck_bloc.dart';
import '../../admin_dashboard/tabs/truck/view/truckview_tab.dart';
import '../bloc/payable_dasboard_bloc.dart';
import '../bloc/payable_dashboard_event.dart';


class PayableDashboard extends StatefulWidget{
  const PayableDashboard({super.key});

  @override
  State<PayableDashboard> createState() => _PayableDashboardState();
}

class _PayableDashboardState extends State<PayableDashboard> with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
    _tabController.addListener(_onTabChanged);

  }
  void _onTabChanged(){
    final index = _tabController.index;
    context.read<PayableTabBloc>().add(PTabChanged(index));
  }
  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;
        return MultiBlocProvider(
          providers: [

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
              create: (context) => sl<BillOrderBloc>(),
              child: const BillOrderScreen(),
            ),
            BlocProvider(
              create: (context) => sl<PettyCashBloc>()..add(const LoadPettyCashEvent()),
              child: const PettyCashPage(),
            ),
            BlocProvider(
              create: (context) => AIMaintenanceBloc(
                repository: MaintenanceAIRepository(),
              )..add(LoadAIMaintenanceRisks()),
              child: const AIMaintenanceHealthCard(),
            )
          ],                                    // ← ] தான் close, } இல்ல
          child: Scaffold(
            body: PayableMobileDashboard(
              tabController: _tabController,
              isTablet: isTablet,
            ),
          ),
        );                                      // ← MultiBlocProvider close
      },                                        // ← LayoutBuilder builder close
    );                                          // ← LayoutBuilder close
  }

}
