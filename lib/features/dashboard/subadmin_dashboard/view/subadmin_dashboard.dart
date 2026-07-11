import 'package:flutter/Material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/features/dashboard/common_tabs/salesorder/bloc/salesorder_bloc.dart';
import 'package:maleva/features/dashboard/subadmin_dashboard/view/subadmin_dashboard_ui.dart';
import '../../../../core/di/injection.dart';
import '../../common_tabs/emailinbox/bloc/emailinbox_bloc.dart';
import '../../common_tabs/emailinbox/bloc/emailinbox_event.dart';
import '../../common_tabs/emailinbox/view/emailinbox_tab.dart';
import '../../common_tabs/employeemaster/bloc/employeemaster_bloc.dart';
import '../../common_tabs/employeemaster/view/employeemaster_tab.dart';
import '../../common_tabs/enquiry/view/bloc/enquiry_bloc.dart';
import '../../common_tabs/enquiry/view/bloc/enquiry_event.dart';
import '../../common_tabs/enquiry/view/data/enquiry_repository.dart';
import '../../common_tabs/enquiry/view/view/enquiry_tab.dart';
import '../../common_tabs/googlereview/bloc/googlereview_bloc.dart';
import '../../common_tabs/googlereview/bloc/googlereview_event.dart';
import '../../common_tabs/googlereview/view/googlereview_tab.dart';
import '../../common_tabs/inventoryreport/bloc/inventoryreport_bloc.dart';
import '../../common_tabs/inventoryreport/bloc/inventoryreport_event.dart';
import '../../common_tabs/inventoryreport/data/inventoryreport_repository.dart';
import '../../common_tabs/inventoryreport/view/inventoryview_tab.dart';
import '../../common_tabs/invoice/bloc/invoice_bloc.dart';
import '../../common_tabs/invoice/bloc/invoice_event.dart';
import '../../common_tabs/invoice/data/invoice_repository.dart';
import '../../common_tabs/invoice/view/invoice_tab.dart';
import '../../common_tabs/salesorder/bloc/salesorder_event.dart';
import '../../common_tabs/salesorder/view/salesorderview_tab.dart';
import '../../common_tabs/spotsaleorder/bloc/spotsaleorder_bloc.dart';
import '../../common_tabs/spotsaleorder/data/spotsale_repository.dart';
import '../../common_tabs/spotsaleorder/view/spotsaleorder_add.dart';
import '../../common_tabs/subadminsale/bloc/sales_report_bloc.dart';
import '../../common_tabs/subadminsale/bloc/sales_report_event.dart';
import '../../common_tabs/subadminsale/view/sales_report_view.dart';
import '../../common_tabs/transport/bloc/transport_bloc.dart';
import '../../common_tabs/transport/bloc/transport_event.dart';
import '../../common_tabs/transport/view/transportview_tab.dart';
import '../../common_tabs/vesselreport/bloc/vesselreport_bloc.dart';
import '../../common_tabs/vesselreport/bloc/vesselreport_event.dart';
import '../../common_tabs/vesselreport/view/vesselreportview_tab.dart';
import '../bloc/subadmin_dashboard_bloc.dart';
import '../bloc/subadmin_dashboard_event.dart';
import 'package:maleva/features/dashboard/common_tabs/driverleave/bloc/leave_bloc.dart';

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
    _tabController = TabController(length: 14, vsync: this);
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
    return MultiBlocProvider(
      providers: [
            BlocProvider<SubAdminTabBloc>(
              create: (_) => SubAdminTabBloc(),
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


