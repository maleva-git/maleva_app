import 'package:flutter/Material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/features/dashboard/common_tabs/salesorder/bloc/salesorder_bloc.dart';
import 'package:maleva/features/dashboard/common_tabs/salesorder/bloc/salesorder_event.dart';
import '../../../../core/di/injection.dart';
import '../bloc/admin_tab_bloc.dart';
import '../bloc/admin_tab_event.dart';
import '../../common_tabs/bocheck/bloc/bocheck_bloc.dart';
import '../../common_tabs/bocheck/bloc/bocheck_event.dart';
import '../../common_tabs/driver/bloc/driverdetails_bloc.dart';
import '../../common_tabs/driver/bloc/driverdetails_event.dart';
import '../../common_tabs/emailinbox/bloc/emailinbox_bloc.dart';
import '../../common_tabs/emailinbox/bloc/emailinbox_event.dart';
import '../../common_tabs/employeemaster/bloc/employeemaster_bloc.dart';
import '../../common_tabs/enginehours/bloc/enginehours_bloc.dart';
import '../../common_tabs/enginehours/bloc/enginehours_event.dart';
import '../../common_tabs/expenseReport/bloc/expensereport_bloc.dart';
import '../../common_tabs/expenseReport/bloc/expensereport_event.dart';
import '../../common_tabs/forwardingreport/bloc/forwardingreport_bloc.dart';
import '../../common_tabs/forwardingreport/bloc/forwardingreport_event.dart';
import '../../common_tabs/fuel/bloc/fuelreport_bloc.dart';
import '../../common_tabs/fuel/bloc/fuelreport_event.dart';
import '../../common_tabs/fuelfillings/bloc/fuelfillings_bloc.dart';
import '../../common_tabs/fuelfillings/bloc/fuelfillings_event.dart';
import '../../common_tabs/googlereview/bloc/googlereview_bloc.dart';
import '../../common_tabs/googlereview/bloc/googlereview_event.dart';
import '../../common_tabs/inventoryreport/bloc/inventoryreport_bloc.dart';
import '../../common_tabs/inventoryreport/data/inventoryreport_repository.dart';
import '../../common_tabs/invoice/bloc/invoice_bloc.dart';
import '../../common_tabs/invoice/bloc/invoice_event.dart';
import '../../common_tabs/invoice/data/invoice_repository.dart';
import '../../common_tabs/paymentview/bloc/paymentview_bloc.dart';
import '../../common_tabs/pdo/bloc/pdo_bloc.dart';
import '../../common_tabs/pdo/data/pdo_repository.dart';
import '../../common_tabs/pettycash/bloc/pettycash_bloc.dart';
import '../../common_tabs/pettycash/bloc/pettycash_event.dart';
import '../../common_tabs/receiptview/bloc/receiptview_bloc.dart';
import '../../common_tabs/receiptview/bloc/receiptview_event.dart';
import '../../common_tabs/rtiview/bloc/rtiview_bloc.dart';
import '../../common_tabs/spareparts/bloc/spareparts_bloc.dart';
import '../../common_tabs/spareparts/data/spareparts_repository.dart';
import '../../common_tabs/speedingreport/bloc/speeding_bloc.dart';
import '../../common_tabs/speedingreport/bloc/speeding_event.dart';
import '../../common_tabs/spotsaleorder/bloc/spotsaleorder_bloc.dart';
import '../../common_tabs/spotsaleorder/data/spotsale_repository.dart';
import '../../common_tabs/summonentry/bloc/summonentry_bloc.dart';
import '../../common_tabs/summonentry/data/summonentry_repository.dart';
import '../../common_tabs/transport/bloc/transport_bloc.dart';
import '../../common_tabs/transport/bloc/transport_event.dart';
import '../../common_tabs/truck/bloc/truck_bloc.dart';
import '../../common_tabs/vesselreport/bloc/vesselreport_bloc.dart';
import '../../common_tabs/vesselreport/bloc/vesselreport_event.dart';
import 'package:maleva/features/dashboard/common_tabs/driverleave/bloc/leave_bloc.dart';
import 'admin_dashboard_ui.dart';

class NewAdminDashboard extends StatefulWidget{
  const NewAdminDashboard({super.key});

  @override
  State<NewAdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<NewAdminDashboard> with SingleTickerProviderStateMixin {

  late TabController _tabController;
  late AdminTabBloc _adminTabBloc;

  @override
  void initState() {
    super.initState();
    _adminTabBloc = AdminTabBloc();
    _tabController = TabController(length: 28, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged(){
    final index = _tabController.index;
    _adminTabBloc.add(AdminTabChanged(index));
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _adminTabBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return MultiBlocProvider(
      providers: [

        BlocProvider<AdminTabBloc>.value(value: _adminTabBloc),

        BlocProvider<InvoiceBloc>(
          create: (_) => InvoiceBloc(invoiceRepo: InvoiceRepositoryImpl())..add(LoadInvoiceByType(0)),
        ),
        BlocProvider<SalesOrderBloc>(create: (_) => sl<SalesOrderBloc>()..add(LoadInvoiceByTypes(1))),
        BlocProvider<ReceiptBloc>(create: (_) => sl<ReceiptBloc>()..add(LoadReceiptEvent())),
        BlocProvider<ForwardingReportBloc>(create: (_) => sl<ForwardingReportBloc>()..add(const LoadForwardingReportEvent())),
        BlocProvider<ExpenseReportBloc>(create: (_) => sl<ExpenseReportBloc>()..add(const LoadExpenseReportEvent())),
        BlocProvider<VesselBloc>(create: (context) => sl<VesselBloc>()..add(const LoadVesselDataEvent(type: 0))),
        BlocProvider<TransportBloc>(create: (context) => sl<TransportBloc>()..add(const LoadTransportDataEvent(type: 0))),
        BlocProvider<TruckDetailsBloc>(create: (context) => sl<TruckDetailsBloc>()..add(const LoadTruckDetailsEvent())),
        BlocProvider<DriverBloc>(create: (context) => sl<DriverBloc>()..add(const LoadDriverEvent())),
        BlocProvider<SpeedingBloc>(create: (context) => sl<SpeedingBloc>()..add(LoadSpeedingReport())),
        BlocProvider<FuelFillingBloc>(create: (context) => sl<FuelFillingBloc>()..add(LoadFuelFillingReport())),
        BlocProvider<EngineHoursBloc>(create: (context) => sl<EngineHoursBloc>()..add(LoadEngineHoursReport())),
        BlocProvider<BocBloc>(create: (context) => sl<BocBloc>()..add(LoadBocReport())),
        BlocProvider<EmailBloc>(create: (context) => sl<EmailBloc>()..add(const LoadEmployeesEvent())),
        BlocProvider<ReviewBloc>(create: (context) => sl<ReviewBloc>()..add(const LoadEmployeeEvent())),
        BlocProvider<FuelDiffBloc>(create: (context) => sl<FuelDiffBloc>()..add(const LoadFuelDiffEvent())),
        BlocProvider<EmployeeMasterBloc>(create: (context) => sl<EmployeeMasterBloc>()),
        BlocProvider<PettyCashBloc>(create: (context) => sl<PettyCashBloc>()..add(const LoadPettyCashEvent())),
        BlocProvider<SummonBloc>(create: (_) => SummonBloc.form(repository: sl<SummonRepository>())),
        BlocProvider<SparePartsBloc>(create: (_) => SparePartsBloc.form(repository: sl<SparePartsRepository>())),
        BlocProvider<PaymentPendingBloc>(create: (_) => sl<PaymentPendingBloc>()),
        BlocProvider<SpotSaleBloc>(create: (_) => SpotSaleBloc.form(repository: sl<SpotSaleRepository>())),
        BlocProvider<InventoryBloc>(create: (_) => InventoryBloc(repository: sl<InventoryReportRepository>())),
        BlocProvider<PDOBloc>(
          create: (_) => PDOBloc(
            repository: sl<PDORepository>(),
            fromDate: DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 7))),
            toDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          ),
        ),
        BlocProvider<RTIDetailsBloc>(create: (_) => sl<RTIDetailsBloc>()),
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
    );
  }
}