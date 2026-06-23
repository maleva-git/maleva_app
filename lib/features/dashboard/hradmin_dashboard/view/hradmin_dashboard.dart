import 'package:flutter/Material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/salesorder/bloc/salesorder_bloc.dart';
import 'package:maleva/features/dashboard/subadmin_dashboard/view/subadmin_dashboard_ui.dart';
import '../../../../core/di/injection.dart';
import '../../../common_updates/blocs/sales/sales_bloc.dart';
import '../../../common_updates/blocs/truck/truck_bloc.dart';
import '../../admin_dashboard/tabs/driver/bloc/driverdetails_bloc.dart';
import '../../admin_dashboard/tabs/driver/bloc/driverdetails_event.dart';
import '../../admin_dashboard/tabs/driver/view/driverdetails_tab.dart';
import '../../admin_dashboard/tabs/emailinbox/bloc/emailinbox_bloc.dart';
import '../../admin_dashboard/tabs/emailinbox/bloc/emailinbox_event.dart';
import '../../admin_dashboard/tabs/emailinbox/view/emailinbox_tab.dart';
import '../../admin_dashboard/tabs/employeemaster/bloc/employeemaster_bloc.dart';
import '../../admin_dashboard/tabs/employeemaster/view/employeemaster_tab.dart';
import '../../admin_dashboard/tabs/enginehours/bloc/enginehours_bloc.dart';
import '../../admin_dashboard/tabs/enginehours/bloc/enginehours_event.dart';
import '../../admin_dashboard/tabs/enginehours/view/enginehours_tab.dart';
import '../../admin_dashboard/tabs/enquiry/view/bloc/enquiry_bloc.dart';
import '../../admin_dashboard/tabs/enquiry/view/data/enquiry_repository.dart';
import '../../admin_dashboard/tabs/enquiry/view/view/enquiry_tab.dart';
import '../../admin_dashboard/tabs/fuel/bloc/fuelreport_bloc.dart';
import '../../admin_dashboard/tabs/fuel/bloc/fuelreport_event.dart';
import '../../admin_dashboard/tabs/fuel/view/fuelreport_tab.dart';
import '../../admin_dashboard/tabs/fuelfillings/bloc/fuelfillings_bloc.dart';
import '../../admin_dashboard/tabs/fuelfillings/bloc/fuelfillings_event.dart';
import '../../admin_dashboard/tabs/fuelfillings/view/fuelfillings_tab.dart';
import '../../admin_dashboard/tabs/googlereview/bloc/googlereview_bloc.dart';
import '../../admin_dashboard/tabs/googlereview/bloc/googlereview_event.dart';
import '../../admin_dashboard/tabs/googlereview/view/googlereview_tab.dart';
import '../../admin_dashboard/tabs/inventoryreport/bloc/inventoryreport_bloc.dart';
import '../../admin_dashboard/tabs/inventoryreport/data/inventoryreport_repository.dart';
import '../../admin_dashboard/tabs/inventoryreport/view/inventoryview_tab.dart';
import '../../admin_dashboard/tabs/invoice/bloc/invoice_bloc.dart';
import '../../admin_dashboard/tabs/invoice/bloc/invoice_event.dart';
import '../../admin_dashboard/tabs/invoice/data/invoice_repository.dart';
import '../../admin_dashboard/tabs/invoice/view/invoice_tab.dart';
import '../../admin_dashboard/tabs/license/bloc/license_bloc.dart';
import '../../admin_dashboard/tabs/license/bloc/license_event.dart';
import '../../admin_dashboard/tabs/salesorder/view/salesorderview_tab.dart';
import '../../admin_dashboard/tabs/spareparts/bloc/spareparts_bloc.dart';
import '../../admin_dashboard/tabs/spareparts/data/spareparts_repository.dart';
import '../../admin_dashboard/tabs/spareparts/view/sparepartsadd.dart';
import '../../admin_dashboard/tabs/speedingreport/bloc/speeding_bloc.dart';
import '../../admin_dashboard/tabs/speedingreport/bloc/speeding_event.dart';
import '../../admin_dashboard/tabs/speedingreport/view/speedingreport_view.dart';
import '../../admin_dashboard/tabs/spotsaleorder/bloc/spotsaleorder_bloc.dart';
import '../../admin_dashboard/tabs/spotsaleorder/data/spotsale_repository.dart';
import '../../admin_dashboard/tabs/spotsaleorder/view/spotsaleorder_add.dart';
import '../../admin_dashboard/tabs/subadminsale/bloc/sales_report_bloc.dart';
import '../../admin_dashboard/tabs/subadminsale/bloc/sales_report_event.dart';
import '../../admin_dashboard/tabs/subadminsale/view/sales_report_view.dart';
import '../../admin_dashboard/tabs/transport/bloc/transport_bloc.dart';
import '../../admin_dashboard/tabs/transport/bloc/transport_event.dart';
import '../../admin_dashboard/tabs/transport/view/transportview_tab.dart';
import '../../admin_dashboard/tabs/truck/bloc/truck_bloc.dart';
import '../../admin_dashboard/tabs/truck/view/truckview_tab.dart';
import '../../admin_dashboard/tabs/vesselreport/bloc/vesselreport_bloc.dart';
import '../../admin_dashboard/tabs/vesselreport/bloc/vesselreport_event.dart';
import '../../admin_dashboard/tabs/vesselreport/view/vesselreportview_tab.dart';
import '../bloc/hradmin_bloc.dart';
import '../bloc/hradmin_event.dart';
import 'hradmin_dashboard_ui.dart';


class HrAdminDashboard extends StatefulWidget{
  const HrAdminDashboard({super.key});

  @override
  State<HrAdminDashboard> createState() => _HrAdminDashboardState();
}
class _HrAdminDashboardState extends State<HrAdminDashboard> with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this);
    _tabController.addListener(_onTabChanged);

  }

  void _onTabChanged(){
    final index = _tabController.index;
    context.read<HrAdminTabBloc>().add(HrAdminTabChanged(index));
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
            BlocProvider<HrAdminTabBloc>(
              create: (_) => HrAdminTabBloc(),
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
              create: (context) => sl<DriverBloc>()..add(const LoadDriverEvent()),
              child: const DriverDetailsView(), // Remember to add a BlocListener here if you want to show errors to the user!
            ),
            BlocProvider(
              create: (context) => sl<EmployeeMasterBloc>(),
              child: const EmployeeViewPage(),
            ),
            BlocProvider(
              create: (context) => sl<TruckDetailsBloc>()..add(const LoadTruckDetailsEvent()),
              child: const TruckDetailsReportPage(), // Make sure to add a BlocListener inside here if you want to show snackbars for TruckErrorState!
            ),
            BlocProvider(
              // ✅ Removed 'context', added named 'repository', and removed the redundant ..add() cascade
              create: (_) => SparePartsBloc.form(
                repository: sl<SparePartsRepository>(),
              ),
              child: const SparePartsEntryPage(),
            ),
            BlocProvider(
              create: (context) => sl<LicenseBloc>()..add(const LoadLicenseEvent()),
              child: const LicensePage(), // Make sure to add a BlocListener inside here if you want to show snackbars for TruckErrorState!
            ),

          ],
          child: Scaffold(
            body: HrAMobileDashboard(
              tabController: _tabController,
              isTablet: isTablet,
            ),
          ),
        );
      },                                        // ← LayoutBuilder builder close
    );                                          // ← LayoutBuilder close
  }                                             // ← build() close
}


