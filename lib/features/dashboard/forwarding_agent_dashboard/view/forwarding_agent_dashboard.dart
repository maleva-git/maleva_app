import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../common_tabs/driverleave/bloc/leave_bloc.dart';
import '../bloc/forwarding_agent_bloc.dart';
import '../bloc/forwarding_agent_event.dart';
import 'forwarding_agent_dashboard_ui.dart';
import '../../../../core/session/work_jobs.dart';
import '../../admin_dashboard/bloc/admin_tab_bloc.dart';
import '../../common_tabs/inventoryreport/bloc/inventoryreport_bloc.dart';
import '../../common_tabs/inventoryreport/data/inventoryreport_repository.dart';
import '../../common_tabs/spotsaleorder/bloc/spotsaleorder_bloc.dart';
import '../../common_tabs/spotsaleorder/data/spotsale_repository.dart';
import '../../common_tabs/vesselreport/bloc/vesselreport_bloc.dart';
import '../../common_tabs/vesselreport/bloc/vesselreport_event.dart';
import '../../work_tabs/work_tabs.dart';
import '../bloc/rti_activities/rti_activities_bloc.dart';

class ForwardingAgentDashboard extends StatefulWidget{
  const ForwardingAgentDashboard({super.key});

  @override
  State<ForwardingAgentDashboard> createState() => _ForwardingAgentDashboardState();
}

class _ForwardingAgentDashboardState extends State<ForwardingAgentDashboard> with SingleTickerProviderStateMixin {

  late TabController _tabController;

  /// Today's tabs plus the boarding tabs of an extra boarding job (employee-extra-jobs-and-driver-mode).
  late final List<WorkTab> _tabs = workTabsFor(WorkDashboard.forwardingAgent, WorkJobs.current());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged(){
    final index = _tabController.index;
    context.read<ForwardingAgentTabBloc>().add(ForwardingAgentTabChanged(index));
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
        BlocProvider<LeaveBloc>(create: (_) => sl<LeaveBloc>()),
        BlocProvider<RtiActivitiesBloc>(create: (_) => RtiActivitiesBloc()),
        // Boarding tabs (created only when such a tab is shown; BlocProvider is lazy)
        BlocProvider<AdminTabBloc>(create: (_) => AdminTabBloc()),
        BlocProvider(create: (_) => sl<VesselBloc>()..add(const LoadVesselDataEvent(type: 0))),
        BlocProvider(create: (_) => InventoryBloc(repository: sl<InventoryReportRepository>())),
        BlocProvider(create: (_) => SpotSaleBloc.form(repository: sl<SpotSaleRepository>())),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 600;
          return Scaffold(
            body: ForwardingAgentMobileDashboard(
              tabController: _tabController,
              tabs: _tabs,
              isTablet: isTablet,
            ),
          );
        },
      ),
    );
  }
}
