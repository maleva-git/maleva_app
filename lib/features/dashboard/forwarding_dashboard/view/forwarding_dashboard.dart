import 'package:flutter/Material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/salesorder/bloc/salesorder_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../common_updates/blocs/sales/sales_bloc.dart';
import '../../../common_updates/blocs/truck/truck_bloc.dart';
import '../../admin_dashboard/bloc/admin_tab_bloc.dart';
import '../../admin_dashboard/tabs/inventoryreport/bloc/inventoryreport_bloc.dart';
import '../../admin_dashboard/tabs/inventoryreport/data/inventoryreport_repository.dart';
import '../../admin_dashboard/tabs/inventoryreport/view/inventoryview_tab.dart';
import '../../admin_dashboard/tabs/salary/bloc/salary_bloc.dart';
import '../../admin_dashboard/tabs/salary/view/salary_tab.dart';
import '../../admin_dashboard/tabs/spotsaleorder/bloc/spotsaleorder_bloc.dart';
import '../../admin_dashboard/tabs/spotsaleorder/data/spotsale_repository.dart';
import '../../admin_dashboard/tabs/spotsaleorder/view/spotsaleorder_add.dart';
import '../../admin_dashboard/tabs/transport/bloc/transport_bloc.dart';
import '../../admin_dashboard/tabs/transport/bloc/transport_event.dart';
import '../../admin_dashboard/tabs/transport/view/transportview_tab.dart';
import '../../admin_dashboard/tabs/unrelease/bloc/unrelease_bloc.dart';
import '../../admin_dashboard/tabs/unrelease/view/unrelease_tab.dart';
import '../../admin_dashboard/tabs/unreleasesmk/bloc/unreleasesmk_bloc.dart';
import '../../admin_dashboard/tabs/unreleasesmk/view/unreleasesmk_tab.dart';
import '../../admin_dashboard/tabs/vesselreport/bloc/vesselreport_bloc.dart';
import '../../admin_dashboard/tabs/vesselreport/view/vesselreportview_tab.dart';
import '../bloc/forwarding_bloc.dart';
import '../bloc/forwarding_event.dart';
import 'forwarding_dashboard_ui.dart';


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
          ],
          child: Scaffold(
            body: ForwardingMobileDashboard(
              tabController: _tabController,
              isTablet: isTablet,
            ),
          ),
        );                                      // ← MultiBlocProvider close
      },                                        // ← LayoutBuilder builder close
    );                                          // ← LayoutBuilder close
  }                                             // ← build() close
}




