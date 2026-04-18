import 'package:flutter/Material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/ExpenseReport/bloc/expensereport_bloc.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/ExpenseReport/bloc/expensereport_event.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/salesorder/bloc/salesorder_bloc.dart';
import '../../../common_updates/blocs/sales/sales_bloc.dart';
import '../../../common_updates/blocs/truck/truck_bloc.dart';
import '../bloc/admin_tab_bloc.dart';
import '../bloc/admin_tab_event.dart';
import '../tabs/ExpenseReport/view/expensereport_tab.dart';
import '../tabs/adinvoice/bloc/forecast/forecast_bloc.dart';
import '../tabs/adinvoice/data/repositories/sales_forecast_repository.dart';
import '../tabs/adinvoice/presentation/widgets/ai_sales_forecast_chart.dart';
import '../tabs/aienginehours/bloc/ai_maintenance_bloc.dart';
import '../tabs/aienginehours/data/repositories/maintenance_ai_repository.dart';
import '../tabs/aienginehours/presentation/widgets/ai_maintenance_health_card.dart';
import '../tabs/bocheck/bloc/bocheck_bloc.dart';
import '../tabs/bocheck/bloc/bocheck_event.dart';
import '../tabs/bocheck/view/bocheck_tab.dart';
import '../tabs/driver/bloc/driverdetails_bloc.dart';
import '../tabs/driver/bloc/driverdetails_event.dart';
import '../tabs/driver/view/driverdetails_tab.dart';
import '../tabs/emailinbox/bloc/emailinbox_bloc.dart';
import '../tabs/emailinbox/bloc/emailinbox_event.dart';
import '../tabs/emailinbox/view/emailinbox_tab.dart';
import '../tabs/employeemaster/bloc/employeemaster_bloc.dart';
import '../tabs/employeemaster/view/employeemaster_tab.dart';
import '../tabs/enginehours/bloc/enginehours_bloc.dart';
import '../tabs/enginehours/bloc/enginehours_event.dart';
import '../tabs/enginehours/view/enginehours_tab.dart';
import '../tabs/forwardingreport/bloc/forwardingreport_bloc.dart';
import '../tabs/forwardingreport/bloc/forwardingreport_event.dart';
import '../tabs/forwardingreport/view/forwardingreport_tab.dart';
import '../tabs/fuel/bloc/fuelreport_bloc.dart';
import '../tabs/fuel/bloc/fuelreport_event.dart';
import '../tabs/fuel/view/fuelreport_tab.dart';
import '../tabs/fuelfillings/bloc/fuelfillings_bloc.dart';
import '../tabs/fuelfillings/bloc/fuelfillings_event.dart';
import '../tabs/fuelfillings/view/fuelfillings_tab.dart';
import '../tabs/googlereview/bloc/googlereview_bloc.dart';
import '../tabs/googlereview/bloc/googlereview_event.dart';
import '../tabs/googlereview/view/googlereview_tab.dart';
import '../tabs/inventoryreport/bloc/inventoryreport_bloc.dart';
import '../tabs/inventoryreport/bloc/inventoryreport_event.dart';
import '../tabs/inventoryreport/view/inventoryview_tab.dart';
import '../tabs/invoice/bloc/invoice_bloc.dart';
import '../tabs/invoice/view/invoice_tab.dart';
import '../tabs/paymentview/bloc/paymentview_bloc.dart';
import '../tabs/paymentview/bloc/paymentview_event.dart';
import '../tabs/paymentview/view/paymentview_tab.dart';
import '../tabs/pdo/bloc/pdo_bloc.dart';
import '../tabs/pdo/view/pdo_tab.dart';
import '../tabs/pettycash/bloc/pettycash_bloc.dart';
import '../tabs/pettycash/bloc/pettycash_event.dart';
import '../tabs/pettycash/view/pettycash_tab.dart';
import '../tabs/receiptview/bloc/receiptview_bloc.dart';
import '../tabs/receiptview/bloc/receiptview_event.dart';
import '../tabs/receiptview/view/receiptview_tab.dart';
import '../tabs/rtiview/bloc/rtiview_bloc.dart';
import '../tabs/rtiview/bloc/rtiview_event.dart';
import '../tabs/rtiview/view/rtiview_tab.dart';
import '../tabs/salesorder/view/salesorderview_tab.dart';
import '../tabs/spareparts/bloc/spareparts_bloc.dart';
import '../tabs/spareparts/bloc/spareparts_event.dart';
import '../tabs/spareparts/view/sparepartsadd.dart';
import '../tabs/speedingreport/bloc/speeding_bloc.dart';
import '../tabs/speedingreport/bloc/speeding_event.dart';
import '../tabs/speedingreport/view/speedingreport_view.dart';
import '../tabs/spotsaleorder/bloc/spotsaleorder_bloc.dart';
import '../tabs/spotsaleorder/view/spotsaleorder_add.dart';
import '../tabs/summonentry/bloc/summonentry_bloc.dart';
import '../tabs/summonentry/view/summonentry_tab.dart';
import '../tabs/transport/bloc/transport_bloc.dart';
import '../tabs/transport/bloc/transport_event.dart';
import '../tabs/transport/view/transportview_tab.dart';
import '../tabs/truck/bloc/truck_bloc.dart';
import '../tabs/truck/view/truckview_tab.dart';
import '../tabs/vesselreport/bloc/vesselreport_bloc.dart';
import '../tabs/vesselreport/bloc/vesselreport_event.dart';
import '../tabs/vesselreport/view/vesselreportview_tab.dart';
import 'admin_dashboard_ui.dart';

class NewAdminDashboard extends StatefulWidget{
  const NewAdminDashboard({super.key});

  @override
  State<NewAdminDashboard> createState() => _AdminDashboardState();
}
class _AdminDashboardState extends State<NewAdminDashboard> with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 27, vsync: this);
    _tabController.addListener(_onTabChanged);

  }

  void _onTabChanged(){
    final index = _tabController.index;
    context.read<AdminTabBloc>().add(TabChanged(index));
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
              create: (_) => InvoiceBloc(),
              child: const InvoiceTab(),
            ),
            BlocProvider(
              create: (_) => SalesOrderBloc(),
              child: const SalesOrderTab(),
            ),
            BlocProvider(
              create: (_) => ReceiptBloc(
              )..add(LoadReceiptEvent()),
              child: const ReceiptPage(),
            ),
            BlocProvider(
              create: (context) => ForwardingReportBloc(context)
                ..add(LoadFWDataEvent(
                  fromDate: DateFormat("yyyy-MM-dd").format(DateTime.now()),
                  toDate: DateFormat("yyyy-MM-dd").format(DateTime.now()),
                )),
              child: const ForwardingReportView(),
            ),
            BlocProvider(
              create: (context) => ExpenseReportBloc(context)
                ..add(LoadExpReportEvent(
                  fromDate: DateFormat("yyyy-MM-dd")
                      .format(DateTime.now().subtract(const Duration(days: 30))),
                  toDate: DateFormat("yyyy-MM-dd").format(DateTime.now()),
                )),
              child: const ExpenseReportView(),
            ),
            BlocProvider(
              create: (context) => VesselBloc(
                context: context,
              )..add(const LoadVesselDataEvent(type: 0)),
              child: const VesselReportPage(),
            ),
            BlocProvider(
              create: (context) => TransportBloc(
                context: context,
              )..add(const LoadTransportDataEvent(type: 0)),
              child: const TransportReportPage(),
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
              create: (context) => BocBloc(context)..add(LoadBocReport()),
              child: const BocPage(),
            ),
            BlocProvider(
              create: (context) => EmailBloc(context)..add(const LoadEmployeesEvent()),
              child: const EmailPage(),
            ),
            BlocProvider(
              create: (context) => ReviewBloc(context)..add(const LoadReviewsEvent()),
              child: const ReviewEntryPage(),
            ),
            BlocProvider(
              create: (context) => FuelDiffBloc(context)..add(const LoadFuelDiffEvent()),
              child: const FuelDiffPage(),
            ),
            BlocProvider(
              create: (context) => EmployeeMasterBloc.list(context),
              child: const EmployeeViewPage(),
            ),
            BlocProvider(
              create: (context) => PettyCashBloc(context)..add(const LoadPettyCashEvent()),
              child: const PettyCashPage(),
            ),
            BlocProvider(
              create: (context) => SummonBloc.form(context),
              child: const SummonEntryPage(),
            ),
            BlocProvider(
              create: (context) => SparePartsBloc.form(context)
                ..add(const LoadSparePartsTrucksEvent()),
              child: const SparePartsEntryPage(),
            ),
            BlocProvider(
              create: (context) => PaymentPendingBloc(context)
                ..add(const LoadPaymentPendingEvent()),
              child: const PaymentPendingPage(),
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
            BlocProvider(
              create: (context) => ForecastBloc(
                repository: SalesForecastRepository(),
              )..add(LoadSalesForecast(0)), // 0 means default type
              child: const AISalesForecastWidget(),
            ),
            BlocProvider(
              create: (context) => AIMaintenanceBloc(
                repository: MaintenanceAIRepository(),
              )..add(LoadAIMaintenanceRisks()),
              child: const AIMaintenanceHealthCard(),
            )
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


