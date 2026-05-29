import 'package:flutter/Material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/salesorder/bloc/salesorder_bloc.dart';
import 'package:maleva/features/dashboard/subadmin_dashboard/view/subadmin_dashboard_ui.dart';
import '../../../../core/di/injection.dart';
import '../../../common_updates/blocs/sales/sales_bloc.dart';
import '../../../common_updates/blocs/truck/truck_bloc.dart';
import '../../admin_dashboard/tabs/emailinbox/bloc/emailinbox_bloc.dart';
import '../../admin_dashboard/tabs/emailinbox/bloc/emailinbox_event.dart';
import '../../admin_dashboard/tabs/emailinbox/view/emailinbox_tab.dart';
import '../../admin_dashboard/tabs/employeemaster/bloc/employeemaster_bloc.dart';
import '../../admin_dashboard/tabs/employeemaster/view/employeemaster_tab.dart';
import '../../admin_dashboard/tabs/enquiry/view/bloc/enquiry_bloc.dart';
import '../../admin_dashboard/tabs/enquiry/view/bloc/enquiry_event.dart';
import '../../admin_dashboard/tabs/enquiry/view/data/enquiry_repository.dart';
import '../../admin_dashboard/tabs/enquiry/view/view/enquiry_tab.dart';
import '../../admin_dashboard/tabs/googlereview/bloc/googlereview_bloc.dart';
import '../../admin_dashboard/tabs/googlereview/bloc/googlereview_event.dart';
import '../../admin_dashboard/tabs/googlereview/view/googlereview_tab.dart';
import '../../admin_dashboard/tabs/inventoryreport/bloc/inventoryreport_bloc.dart';
import '../../admin_dashboard/tabs/inventoryreport/bloc/inventoryreport_event.dart';
import '../../admin_dashboard/tabs/inventoryreport/data/inventoryreport_repository.dart';
import '../../admin_dashboard/tabs/inventoryreport/view/inventoryview_tab.dart';
import '../../admin_dashboard/tabs/invoice/bloc/invoice_bloc.dart';
import '../../admin_dashboard/tabs/invoice/bloc/invoice_event.dart';
import '../../admin_dashboard/tabs/invoice/data/invoice_repository.dart';
import '../../admin_dashboard/tabs/invoice/view/invoice_tab.dart';
import '../../admin_dashboard/tabs/salesorder/bloc/salesorder_event.dart';
import '../../admin_dashboard/tabs/salesorder/view/salesorderview_tab.dart';
import '../../admin_dashboard/tabs/spotsaleorder/bloc/spotsaleorder_bloc.dart';
import '../../admin_dashboard/tabs/spotsaleorder/data/spotsale_repository.dart';
import '../../admin_dashboard/tabs/spotsaleorder/view/spotsaleorder_add.dart';
import '../../admin_dashboard/tabs/subadminsale/bloc/salesreport bloc.dart';
import '../../admin_dashboard/tabs/subadminsale/bloc/salesreport event.dart';
import '../../admin_dashboard/tabs/subadminsale/view/salesreport view.dart';
import '../../admin_dashboard/tabs/transport/bloc/transport_bloc.dart';
import '../../admin_dashboard/tabs/transport/bloc/transport_event.dart';
import '../../admin_dashboard/tabs/transport/view/transportview_tab.dart';
import '../../admin_dashboard/tabs/vesselreport/bloc/vesselreport_bloc.dart';
import '../../admin_dashboard/tabs/vesselreport/bloc/vesselreport_event.dart';
import '../../admin_dashboard/tabs/vesselreport/view/vesselreportview_tab.dart';
import '../bloc/subadmin_dashboard_bloc.dart';
import '../bloc/subadmin_dashboard_event.dart';

class SubAdminDashboard extends StatefulWidget{
  const SubAdminDashboard({super.key});

  @override
  State<SubAdminDashboard> createState() => _AdminDashboardState();
}
class _AdminDashboardState extends State<SubAdminDashboard> with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 11, vsync: this);
    _tabController.addListener(_onTabChanged);

  }

  void _onTabChanged(){
    final index = _tabController.index;
    context.read<SubAdminTabBloc>().add(SATabChanged(index));
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
            BlocProvider<SubAdminTabBloc>(
              create: (_) => SubAdminTabBloc(),
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
              create: (_) => sl<SalesOrderBloc>()
                ..add(LoadInvoiceByTypes(1)), // ✅ fires on page open
              child: const SalesOrderTab(),
            ),
            BlocProvider(
              create: (context) => sl<VesselBloc>()
                ..add(const LoadVesselDataEvent(type: 0)),
              child: const VesselReportPage(),
            ),
            BlocProvider(
              create: (context) => sl<TransportBloc>()
                ..add(const LoadTransportDataEvent(type: 0)),
              child: const TransportReportPage(),
            ),
            BlocProvider(
              create: (_) => EnquiryBloc(
                repository: sl<EnquiryRepository>(),
              ),
              child: const EnquiryScreen(),
            ),
            BlocProvider(
              create: (context) => sl<EmailBloc>()..add(const LoadEmployeesEvent()),
              child: const EmailPage(), // Remember to add BlocListener here if you want SnackBars for EmailError or EmailSaveSuccess!
            ),
            BlocProvider(
              create: (context) => sl<SalesReportBloc>()..add(const LoadSalesReportEvent()),
              child: const SalesReportPage(), // Remember to add BlocListener here if you want SnackBars for EmailError or EmailSaveSuccess!
            ),

            BlocProvider(
              create: (context) => sl<ReviewBloc>()..add(const LoadEmployeeEvent()),
              child: const ReviewEntryPage(), // Add BlocListener here to listen for ReviewSaveSuccess and ReviewError!
            ),
            // BlocProvider(
            //   create: (context) => EmployeeMasterBloc.list(context),
            //   child: const EmployeeViewPage(),
            // ),

            BlocProvider(
              create: (context) => sl<EmployeeMasterBloc>(),
              child: const EmployeeViewPage(),
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


          ],
          child: Scaffold(
            body: MobileDashboard(
              tabController: _tabController,
              isTablet: isTablet,
            ),
          ),
        );
        },                                        // ← LayoutBuilder builder close
    );                                          // ← LayoutBuilder close
  }                                             // ← build() close
}


