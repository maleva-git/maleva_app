import 'package:flutter/Material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/ExpenseReport/bloc/expensereport_bloc.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/ExpenseReport/bloc/expensereport_event.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/salesorder/bloc/salesorder_bloc.dart';
import '../../../common_updates/blocs/sales/sales_bloc.dart';
import '../../../common_updates/blocs/truck/truck_bloc.dart';
import '../../admin_dashboard/tabs/ExpenseReport/view/expensereport_tab.dart';
import '../../admin_dashboard/tabs/bocheck/bloc/bocheck_bloc.dart';
import '../../admin_dashboard/tabs/bocheck/bloc/bocheck_event.dart';
import '../../admin_dashboard/tabs/bocheck/view/bocheck_tab.dart';
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
import '../../admin_dashboard/tabs/forwardingreport/bloc/forwardingreport_bloc.dart';
import '../../admin_dashboard/tabs/forwardingreport/bloc/forwardingreport_event.dart';
import '../../admin_dashboard/tabs/forwardingreport/view/forwardingreport_tab.dart';
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
import '../../admin_dashboard/tabs/inventoryreport/bloc/inventoryreport_event.dart';
import '../../admin_dashboard/tabs/inventoryreport/view/inventoryview_tab.dart';
import '../../admin_dashboard/tabs/invoice/bloc/invoice_bloc.dart';
import '../../admin_dashboard/tabs/invoice/view/invoice_tab.dart';
import '../../admin_dashboard/tabs/paymentview/bloc/paymentview_bloc.dart';
import '../../admin_dashboard/tabs/paymentview/bloc/paymentview_event.dart';
import '../../admin_dashboard/tabs/paymentview/view/paymentview_tab.dart';
import '../../admin_dashboard/tabs/pdo/bloc/pdo_bloc.dart';
import '../../admin_dashboard/tabs/pdo/view/pdo_tab.dart';
import '../../admin_dashboard/tabs/pettycash/bloc/pettycash_bloc.dart';
import '../../admin_dashboard/tabs/pettycash/bloc/pettycash_event.dart';
import '../../admin_dashboard/tabs/pettycash/view/pettycash_tab.dart';
import '../../admin_dashboard/tabs/receiptview/bloc/receiptview_bloc.dart';
import '../../admin_dashboard/tabs/receiptview/bloc/receiptview_event.dart';
import '../../admin_dashboard/tabs/receiptview/view/receiptview_tab.dart';
import '../../admin_dashboard/tabs/rtiview/bloc/rtiview_bloc.dart';
import '../../admin_dashboard/tabs/rtiview/bloc/rtiview_event.dart';
import '../../admin_dashboard/tabs/rtiview/view/rtiview_tab.dart';
import '../../admin_dashboard/tabs/salesorder/view/salesorderview_tab.dart';
import '../../admin_dashboard/tabs/spareparts/bloc/spareparts_bloc.dart';
import '../../admin_dashboard/tabs/spareparts/bloc/spareparts_event.dart';
import '../../admin_dashboard/tabs/spareparts/view/sparepartsadd.dart';
import '../../admin_dashboard/tabs/speedingreport/bloc/speeding_bloc.dart';
import '../../admin_dashboard/tabs/speedingreport/bloc/speeding_event.dart';
import '../../admin_dashboard/tabs/speedingreport/view/speedingreport_view.dart';
import '../../admin_dashboard/tabs/spotsaleorder/bloc/spotsaleorder_bloc.dart';
import '../../admin_dashboard/tabs/spotsaleorder/view/spotsaleorder_add.dart';
import '../../admin_dashboard/tabs/summonentry/bloc/summonentry_bloc.dart';
import '../../admin_dashboard/tabs/summonentry/view/summonentry_tab.dart';
import '../../admin_dashboard/tabs/transport/bloc/transport_bloc.dart';
import '../../admin_dashboard/tabs/transport/bloc/transport_event.dart';
import '../../admin_dashboard/tabs/transport/view/transportview_tab.dart';
import '../../admin_dashboard/tabs/truck/bloc/truck_bloc.dart';
import '../../admin_dashboard/tabs/truck/view/truckview_tab.dart';
import '../../admin_dashboard/tabs/vesselreport/bloc/vesselreport_bloc.dart';
import '../../admin_dashboard/tabs/vesselreport/bloc/vesselreport_event.dart';
import '../../admin_dashboard/tabs/vesselreport/view/vesselreportview_tab.dart';
import '../bloc/operationadmin_dashboard_bloc.dart';
import '../bloc/operationadmin_dashboard_event.dart';
import 'operationadmin_dashboard_ui.dart';

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
    _tabController = TabController(length: 12, vsync: this);
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;
        return MultiBlocProvider(
          providers: [
            BlocProvider<OperationAdminTabBloc>(
              create: (_) => OperationAdminTabBloc(),
            ),
            BlocProvider<SalesBloc>(
              create: (_) => SalesBloc(),
            ),
            BlocProvider<TruckBloc>(
              create: (_) => TruckBloc(),
            ),

            BlocProvider(
              create: (context) => VesselBloc(
                context: context,
              )..add(const LoadVesselDataEvent(type: 0)),
              child: const VesselReportPage(),
            ),

            BlocProvider(
              create: (context) => TruckDetailsBloc(
                context: context,
              )..add(const LoadTruckDetailsEvent()),
              child: const TruckDetailsReportPage(),
            ),
            BlocProvider(
              create: (context) => DriverBloc(context)..add(const LoadDriverEvent()),
              child: const DriverDetailsView(),
            ),
            BlocProvider(
              create: (context) => SpeedingBloc(context)..add(LoadSpeedingReport()),
              child: const SpeedingScreen(),
            ),
            BlocProvider(
              create: (context) => FuelFillingBloc(context)..add(LoadFuelFillingReport()),
              child: const FuelFillingPage(),
            ),
            BlocProvider(
              create: (context) => EngineHoursBloc(context)..add(LoadEngineHoursReport()),
              child: const EngineHoursPage(),
            ),
            BlocProvider(
              create: (context) => FuelDiffBloc(context)..add(const LoadFuelDiffEvent()),
              child: const FuelDiffPage(),
            ),


            BlocProvider(
              create: (context) => SparePartsBloc.form(context)
                ..add(const LoadSparePartsTrucksEvent()),
              child: const SparePartsEntryPage(),
            ),

            BlocProvider(
              create: (context) => SpotSaleBloc.form(context),
              child: const SpotSaleEntryPage(),
            ),
            BlocProvider(
              create: (context) => InventoryBloc(context)
                ..add(const LoadInventoryListsEvent()),
              child: const InventoryPage(),
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
            BlocProvider(
              create: (context) => RTIDetailsBloc(context)
                ..add(const LoadRTIDetailsEvent()),
              child: const RTIDetailsPage(),
            ),
          ],                                    // ← ] தான் close, } இல்ல
          child: Scaffold(
            body: MobileDashboard(
              tabController: _tabController,
              isTablet: isTablet,
            ),
          ),
        );                                      // ← MultiBlocProvider close
      },                                        // ← LayoutBuilder builder close
    );                                          // ← LayoutBuilder close
  }                                             // ← build() close
}


