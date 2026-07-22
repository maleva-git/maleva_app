import 'package:flutter/Material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/features/dashboard/transport_dashboard/view/transport_dashboard_ui.dart';
import '../../../../core/di/injection.dart';
import '../../common_tabs/emailinbox/bloc/emailinbox_bloc.dart';
import '../../common_tabs/emailinbox/bloc/emailinbox_event.dart';
import '../../common_tabs/emailinbox/view/emailinbox_tab.dart';
import '../../common_tabs/enquiry/view/bloc/enquiry_bloc.dart';
import '../../common_tabs/enquiry/view/data/enquiry_repository.dart';
import '../../common_tabs/enquiry/view/view/enquiry_tab.dart';
import '../../common_tabs/googlereview/bloc/googlereview_bloc.dart';
import '../../common_tabs/googlereview/bloc/googlereview_event.dart';
import '../../common_tabs/googlereview/view/googlereview_tab.dart';
import '../../common_tabs/pdo/bloc/pdo_bloc.dart';
import '../../common_tabs/pdo/data/pdo_repository.dart';
import '../../common_tabs/pdo/view/pdo_tab.dart';
import '../../common_tabs/transport/bloc/transport_bloc.dart';
import '../../common_tabs/transport/bloc/transport_event.dart';
import '../../common_tabs/transport/view/transportview_tab.dart';
import '../../common_tabs/transportsales/bloc/transport_sales_bloc.dart';
import '../../common_tabs/transportsales/data/transport_sales_repository.dart';
import '../../common_tabs/transportsales/view/transport_sales_tab.dart';
import '../bloc/transport_bloc.dart';
import '../bloc/transport_event.dart';
import 'package:maleva/features/dashboard/common_tabs/driverleave/bloc/leave_bloc.dart';

class TransportDashboard extends StatefulWidget{
  const TransportDashboard({super.key});

  @override
  State<TransportDashboard> createState() => _TransportDashboardState();
}

class _TransportDashboardState extends State<TransportDashboard> with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
    _tabController.addListener(_onTabChanged);

  }
  void _onTabChanged(){
    final index = _tabController.index;
    context.read<TransportTabBloc>().add(TransportTabEvents(index));
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
              create: (context) => sl<TransportBloc>()
                ..add(const LoadTransportDataEvent(type: 0)),
              child: const TransportReportPage(),
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
              create: (_) => EnquiryBloc(
                repository: sl<EnquiryRepository>(),
              ),
              child: const EnquiryScreen(),
            ),
            BlocProvider(
              create: (_) => TransportSalesBloc(
                repository: sl<TransportSalesRepository>(),
              ),
              child: const TransportSalesTab(),
            ),
            BlocProvider(
              create: (_) => PDOBloc(
                repository: sl<PDORepository>(),
                fromDate: DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 7))),
                toDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
              ),
              child: PDOViewPage(
                fromDate: DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 7))),
                toDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
              ),
            ),

                  BlocProvider<LeaveBloc>(create: (_) => sl<LeaveBloc>()),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;
        return Scaffold(
            body: TransportMobileDashboard(
              tabController: _tabController,
              isTablet: isTablet,
            ),
          );
        },
      ),
    );                                          // ← LayoutBuilder close
  }
}