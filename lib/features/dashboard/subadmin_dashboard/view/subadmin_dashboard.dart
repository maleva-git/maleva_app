import 'package:flutter/Material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/salesorder/bloc/salesorder_bloc.dart';
import 'package:maleva/features/dashboard/subadmin_dashboard/view/subadmin_dashboard_ui.dart';
import '../../../common_updates/blocs/sales/sales_bloc.dart';
import '../../../common_updates/blocs/truck/truck_bloc.dart';
import '../../admin_dashboard/tabs/emailinbox/bloc/emailinbox_bloc.dart';
import '../../admin_dashboard/tabs/emailinbox/bloc/emailinbox_event.dart';
import '../../admin_dashboard/tabs/emailinbox/view/emailinbox_tab.dart';
import '../../admin_dashboard/tabs/employeemaster/bloc/employeemaster_bloc.dart';
import '../../admin_dashboard/tabs/employeemaster/view/employeemaster_tab.dart';
import '../../admin_dashboard/tabs/enquiry/view/bloc/enquiry_bloc.dart';
import '../../admin_dashboard/tabs/enquiry/view/bloc/enquiry_event.dart';
import '../../admin_dashboard/tabs/enquiry/view/view/enquiry_tab.dart';
import '../../admin_dashboard/tabs/googlereview/bloc/googlereview_bloc.dart';
import '../../admin_dashboard/tabs/googlereview/bloc/googlereview_event.dart';
import '../../admin_dashboard/tabs/googlereview/view/googlereview_tab.dart';
import '../../admin_dashboard/tabs/inventoryreport/bloc/inventoryreport_bloc.dart';
import '../../admin_dashboard/tabs/inventoryreport/bloc/inventoryreport_event.dart';
import '../../admin_dashboard/tabs/inventoryreport/view/inventoryview_tab.dart';
import '../../admin_dashboard/tabs/invoice/bloc/invoice_bloc.dart';
import '../../admin_dashboard/tabs/invoice/bloc/invoice_event.dart';
import '../../admin_dashboard/tabs/invoice/data/invoice_repository.dart';
import '../../admin_dashboard/tabs/invoice/view/invoice_tab.dart';
import '../../admin_dashboard/tabs/salesorder/view/salesorderview_tab.dart';
import '../../admin_dashboard/tabs/spotsaleorder/bloc/spotsaleorder_bloc.dart';
import '../../admin_dashboard/tabs/spotsaleorder/view/spotsaleorder_add.dart';
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
    _tabController = TabController(length: 10, vsync: this);
    _tabController.addListener(_onTabChanged);

  }

  void _onTabChanged(){
    final index = _tabController.index;
    context.read<SubAdminTabBloc>().add(TabChanged(index));
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
              create: (context) => SalesOrderBloc(),
              child: const SalesOrderTab(),
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
              create: (_) => EnquiryBloc(

              )..add( LoadEnquiryEvent()),
              child: const EnquiryScreen(),
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
              create: (context) => EmployeeMasterBloc.list(context),
              child: const EmployeeViewPage(),
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


