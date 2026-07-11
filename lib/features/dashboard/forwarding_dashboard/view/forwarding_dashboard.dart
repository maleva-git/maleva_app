import 'package:flutter/Material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/features/dashboard/common_tabs/salesorder/bloc/salesorder_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../admin_dashboard/bloc/admin_tab_bloc.dart';
import '../../common_tabs/inventoryreport/bloc/inventoryreport_bloc.dart';
import '../../common_tabs/inventoryreport/data/inventoryreport_repository.dart';
import '../../common_tabs/inventoryreport/view/inventoryview_tab.dart';
import '../../common_tabs/salary/bloc/salary_bloc.dart';
import '../../common_tabs/salary/view/salary_tab.dart';
import '../../common_tabs/spotsaleorder/bloc/spotsaleorder_bloc.dart';
import '../../common_tabs/spotsaleorder/data/spotsale_repository.dart';
import '../../common_tabs/spotsaleorder/view/spotsaleorder_add.dart';
import '../../common_tabs/transport/bloc/transport_bloc.dart';
import '../../common_tabs/transport/bloc/transport_event.dart';
import '../../common_tabs/transport/view/transportview_tab.dart';
import '../../common_tabs/unrelease/bloc/unrelease_bloc.dart';
import '../../common_tabs/unrelease/view/unrelease_tab.dart';
import '../../common_tabs/unreleasesmk/bloc/unreleasesmk_bloc.dart';
import '../../common_tabs/unreleasesmk/view/unreleasesmk_tab.dart';
import '../../common_tabs/vesselreport/bloc/vesselreport_bloc.dart';
import '../../common_tabs/vesselreport/view/vesselreportview_tab.dart';
import '../bloc/forwarding_bloc.dart';
import '../bloc/forwarding_event.dart';
import 'forwarding_dashboard_ui.dart';
import 'package:maleva/features/dashboard/common_tabs/driverleave/bloc/leave_bloc.dart';


class ForwardingDashboard extends StatefulWidget{
  const ForwardingDashboard({super.key});

  @override
  State<ForwardingDashboard> createState() => _ForwardingDashboardState();
}
class _ForwardingDashboardState extends State<ForwardingDashboard> with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_onTabChanged);

  }

  void _onTabChanged(){
    final index = _tabController.index;
    context.read<ForwardingTabBloc>().add(ForwardingTabChanged(index));
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
            BlocProvider<AdminTabBloc>(
              create: (_) => AdminTabBloc(),
            ),
            BlocProvider(
              // Pass the context into sl() using param1
              create: (context) => sl<VesselBloc>(param1: context),
              child: VesselReportPage(),
            ),
            BlocProvider(
              // Pass the context into sl() using param1
              create: (context) => sl<UnReleaseBloc>(param1: context),
              child: UnReleasePage(),
            ),
            BlocProvider(
              // Pass the context into sl() using param1
              create: (context) => sl<UnReleaseSMKBloc>(param1: context),
              child: UnReleaseSMKPage(),
            ),
                  BlocProvider<LeaveBloc>(create: (_) => sl<LeaveBloc>()),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;
        return Scaffold(
            body: ForwardingMobileDashboard(
              tabController: _tabController,
              isTablet: isTablet,
            ),
          );
        },
      ),
    );                                          // ← LayoutBuilder close
  }                                             // ← build() close
}




