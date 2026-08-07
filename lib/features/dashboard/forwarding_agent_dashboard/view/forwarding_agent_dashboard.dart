import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../common_tabs/driverleave/bloc/leave_bloc.dart';
import '../bloc/forwarding_agent_bloc.dart';
import '../bloc/forwarding_agent_event.dart';
import 'forwarding_agent_dashboard_ui.dart';
import '../bloc/rti_activities/rti_activities_bloc.dart';

class ForwardingAgentDashboard extends StatefulWidget{
  const ForwardingAgentDashboard({super.key});

  @override
  State<ForwardingAgentDashboard> createState() => _ForwardingAgentDashboardState();
}

class _ForwardingAgentDashboardState extends State<ForwardingAgentDashboard> with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 600;
          return Scaffold(
            body: ForwardingAgentMobileDashboard(
              tabController: _tabController,
              isTablet: isTablet,
            ),
          );
        },
      ),
    );
  }
}
