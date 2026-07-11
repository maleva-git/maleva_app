import 'package:flutter/Material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/features/dashboard/payable_dashboard/view/payable_dashboard_ui.dart';
import '../../../../core/di/injection.dart';
import '../../common_tabs/billorder/bloc/billorder_bloc.dart';
import '../../common_tabs/billorder/view/billorder_screen.dart';
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
import '../../common_tabs/pettycash/bloc/pettycash_bloc.dart';
import '../../common_tabs/pettycash/bloc/pettycash_event.dart';
import '../../common_tabs/pettycash/view/pettycash_tab.dart';
import '../../common_tabs/speedingreport/bloc/speeding_bloc.dart';
import '../../common_tabs/speedingreport/bloc/speeding_event.dart';
import '../../common_tabs/speedingreport/view/speedingreport_view.dart';
import '../../common_tabs/truck/bloc/truck_bloc.dart';
import '../../common_tabs/truck/view/truckview_tab.dart';
import '../bloc/payable_dasboard_bloc.dart';
import '../bloc/payable_dashboard_event.dart';
import 'package:maleva/features/dashboard/common_tabs/driverleave/bloc/leave_bloc.dart';


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
    _tabController = TabController(length: 10, vsync: this);
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
    return MultiBlocProvider(
      providers: [

            BlocProvider(
              create: (context) => sl<TruckDetailsBloc>()..add(const LoadTruckDetailsEvent()),
              child: const TruckDetailsReportPage(),
            ),
              BlocProvider(
              create: (context) => sl<DriverBloc>()..add(const LoadDriverEvent()),
              child: const DriverDetailsView(),
              ),
            BlocProvider(
              create: (context) => sl<SpeedingBloc>()..add(LoadSpeedingReport()),
              child: const SpeedingScreen(),
            ),
            BlocProvider(
              create: (context) => sl<FuelFillingBloc>()..add(LoadFuelFillingReport()),
              child: const FuelFillingPage(),
            ),
            BlocProvider(
              create: (context) => sl<EngineHoursBloc>()..add(LoadEngineHoursReport()),
              child: const EngineHoursPage(),
            ),

            BlocProvider(
              create: (context) => sl<FuelDiffBloc>()..add(const LoadFuelDiffEvent()),
              child: const FuelDiffPage(),
            ),
            BlocProvider(
              create: (context) => sl<BillOrderBloc>(),
              child: const BillOrderScreen(),
            ),
            BlocProvider(
              create: (context) => sl<PettyCashBloc>()..add(const LoadPettyCashEvent()),
              child: const PettyCashPage(),
            ),

                  BlocProvider<LeaveBloc>(create: (_) => sl<LeaveBloc>()),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;
        return Scaffold(
            body: PayableMobileDashboard(
              tabController: _tabController,
              isTablet: isTablet,
            ),
          );
        },
      ),
    );
  }

}
