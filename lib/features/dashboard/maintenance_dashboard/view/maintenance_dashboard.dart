import 'package:flutter/Material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/salesorder/bloc/salesorder_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../common_updates/blocs/sales/sales_bloc.dart';
import '../../../common_updates/blocs/truck/truck_bloc.dart';
import '../../admin_dashboard/bloc/admin_tab_bloc.dart';
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
import '../../admin_dashboard/tabs/expenseReport/bloc/expensereport_bloc.dart';
import '../../admin_dashboard/tabs/expenseReport/bloc/expensereport_event.dart';
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
import '../../admin_dashboard/tabs/inventoryreport/data/inventoryreport_repository.dart';
import '../../admin_dashboard/tabs/inventoryreport/view/inventoryview_tab.dart';
import '../../admin_dashboard/tabs/invoice/bloc/invoice_bloc.dart';
import '../../admin_dashboard/tabs/invoice/bloc/invoice_event.dart';
import '../../admin_dashboard/tabs/invoice/data/invoice_repository.dart';
import '../../admin_dashboard/tabs/invoice/view/invoice_tab.dart';
import '../../admin_dashboard/tabs/maintenance/bloc/maintenance_bloc.dart';
import '../../admin_dashboard/tabs/maintenance/bloc/maintenance_event.dart';
import '../../admin_dashboard/tabs/maintenance/view/maintenance_tab.dart';
import '../../admin_dashboard/tabs/paymentview/bloc/paymentview_bloc.dart';
import '../../admin_dashboard/tabs/paymentview/view/paymentview_tab.dart';
import '../../admin_dashboard/tabs/pdo/bloc/pdo_bloc.dart';
import '../../admin_dashboard/tabs/pdo/data/pdo_repository.dart';
import '../../admin_dashboard/tabs/pdo/view/pdo_tab.dart';
import '../../admin_dashboard/tabs/pettycash/bloc/pettycash_bloc.dart';
import '../../admin_dashboard/tabs/pettycash/bloc/pettycash_event.dart';
import '../../admin_dashboard/tabs/pettycash/view/pettycash_tab.dart';
import '../../admin_dashboard/tabs/receiptview/bloc/receiptview_bloc.dart';
import '../../admin_dashboard/tabs/receiptview/bloc/receiptview_event.dart';
import '../../admin_dashboard/tabs/receiptview/view/receiptview_tab.dart';
import '../../admin_dashboard/tabs/rtiview/bloc/rtiview_bloc.dart';
import '../../admin_dashboard/tabs/rtiview/view/rtiview_tab.dart';
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
import '../../admin_dashboard/tabs/summonentry/bloc/summonentry_bloc.dart';
import '../../admin_dashboard/tabs/summonentry/data/summonentry_repository.dart';
import '../../admin_dashboard/tabs/summonentry/view/summonentry_tab.dart';
import '../../admin_dashboard/tabs/transport/bloc/transport_bloc.dart';
import '../../admin_dashboard/tabs/transport/bloc/transport_event.dart';
import '../../admin_dashboard/tabs/transport/view/transportview_tab.dart';
import '../../admin_dashboard/tabs/truck/bloc/truck_bloc.dart';
import '../../admin_dashboard/tabs/truck/view/truckview_tab.dart';
import '../../admin_dashboard/tabs/vesselreport/bloc/vesselreport_bloc.dart';
import '../../admin_dashboard/tabs/vesselreport/view/vesselreportview_tab.dart';
import '../../admin_dashboard/view/admin_dashboard_ui.dart';
import '../bloc/maintenance_bloc.dart';
import '../bloc/maintenance_event.dart';
import 'maintenance_dashboard_ui.dart';


class MaintenanceDashboard extends StatefulWidget{
  const MaintenanceDashboard({super.key});

  @override
  State<MaintenanceDashboard> createState() => _AdminDashboardState();
}
class _AdminDashboardState extends State<MaintenanceDashboard> with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 10, vsync: this);
    _tabController.addListener(_onTabChanged);

  }

  void _onTabChanged(){
    final index = _tabController.index;
    context.read<MaintenanceTabBloc>().add(MaintenanceTabChanged(index));
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
            BlocProvider<AdminTabBloc>(
              create: (_) => AdminTabBloc(),
            ),
            BlocProvider<SalesBloc>(
              create: (_) => SalesBloc(),
            ),
            BlocProvider<TruckBloc>(
              create: (_) => TruckBloc(),
            ),
            BlocProvider(
              create: (_) => InvoiceBloc(
                invoiceRepo: InvoiceRepositoryImpl(),
              )..add( LoadInvoiceByType(0)),
              child: const InvoiceTab(),
            ),
            BlocProvider(
              create: (_) =>sl<SalesOrderBloc>(),
              child: const SalesOrderTab(),
            ),
            BlocProvider(
              create: (_) => sl<ReceiptBloc>()..add(LoadReceiptEvent()),
              child: const ReceiptPage(),
            ),

            BlocProvider(
              // Use sl (GetIt) to create the Bloc. It automatically injects the required repository.
              create: (_) => sl<ForwardingReportBloc>()
                ..add(const LoadForwardingReportEvent()),
              child: const ForwardingReportView(),
            ),
            BlocProvider(
              create: (_) => sl<ExpenseReportBloc>()
                ..add(const LoadExpenseReportEvent()),
              child: const ExpenseReportView(),
            ),
            BlocProvider(
              // Pass the context into sl() using param1
              create: (context) => sl<VesselBloc>(param1: context),
              child: VesselReportPage(),
            ),
            BlocProvider(
              create: (context) => sl<TransportBloc>()
                ..add(const LoadTransportDataEvent(type: 0)),
              child: const TransportReportPage(),
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
              create: (context) => sl<BocBloc>()..add(LoadBocReport()),
              child: const BocPage(), // Remember to add a BlocListener here to show SnackBars for BocError if needed!
            ),
            BlocProvider(
              create: (context) => sl<EmailBloc>()..add(const LoadEmployeesEvent()),
              child: const EmailPage(), // Remember to add BlocListener here if you want SnackBars for EmailError or EmailSaveSuccess!
            ),
            BlocProvider(
              create: (context) => sl<ReviewBloc>()..add(const LoadEmployeeEvent()),
              child: const ReviewEntryPage(), // Add BlocListener here to listen for ReviewSaveSuccess and ReviewError!
            ),

            BlocProvider(
              create: (context) => sl<FuelDiffBloc>()..add(const LoadFuelDiffEvent()),
              child: const FuelDiffPage(), // Remember to add BlocListener here if you want to show SnackBars for FuelDiffError!
            ),
            BlocProvider(
              create: (context) => sl<EmployeeMasterBloc>(),
              child: const EmployeeViewPage(),
            ),
            BlocProvider(
              create: (context) => sl<PettyCashBloc>()..add(const LoadPettyCashEvent()),
              child: const PettyCashPage(),
            ),
            BlocProvider(
              // ✅ Removed 'context', added named 'repository' parameter
              create: (_) => SummonBloc.form(
                repository: sl<SummonRepository>(),
              ),
              child: const SummonEntryPage(),
            ),
            BlocProvider(
              // ✅ Removed 'context', added named 'repository', and removed the redundant ..add() cascade
              create: (_) => SparePartsBloc.form(
                repository: sl<SparePartsRepository>(),
              ),
              child: const SparePartsEntryPage(),
            ),
            BlocProvider(
              create: (_) => sl<PaymentPendingBloc>(),
              child: const PaymentPendingPage(),
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
                repository: sl<PDORepository>(),
                fromDate: DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 30))),
                toDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
              ),
              child: PDOViewPage(
                fromDate: DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 30))),
                toDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
              ),
            ),
            BlocProvider(
              // ✅ Removed 'context', removed the redundant ..add(), and used our Service Locator!
              create: (_) => sl<RTIDetailsBloc>(),
              child: const RTIDetailsPage(),
            ),


            BlocProvider(
              create: (_) => MaintenanceBloc()..add( MaintenanceStarted()),
              child: const MaintenanceDashboardWidget(),
            ),

          ],                                    // ← ] தான் close, } இல்ல
          child: Scaffold(
            body: MaintenanceMobileDashboard(
              tabController: _tabController,
              isTablet: isTablet,
            ),
          ),
        );                                      // ← MultiBlocProvider close
      },                                        // ← LayoutBuilder builder close
    );                                          // ← LayoutBuilder close
  }                                             // ← build() close
}




