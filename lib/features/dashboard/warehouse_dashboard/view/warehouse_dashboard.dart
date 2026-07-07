import 'package:flutter/Material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/features/dashboard/warehouse_dashboard/view/warehouse_dashboard_ui.dart';
import '../../../../core/di/injection.dart';
import '../../admin_dashboard/tabs/inventoryreport/bloc/inventoryreport_bloc.dart';
import '../../admin_dashboard/tabs/inventoryreport/bloc/inventoryreport_event.dart';
import '../../admin_dashboard/tabs/inventoryreport/data/inventoryreport_repository.dart';
import '../../admin_dashboard/tabs/inventoryreport/view/inventoryview_tab.dart';
import '../../admin_dashboard/tabs/spotsaleorder/bloc/spotsaleorder_bloc.dart';
import '../../admin_dashboard/tabs/spotsaleorder/data/spotsale_repository.dart';
import '../../admin_dashboard/tabs/spotsaleorder/view/spotsaleorder_add.dart';
import '../bloc/warehouse_bloc.dart';
import '../bloc/warehouse_event.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/driverleave/bloc/leave_bloc.dart';


class WareHouseDashboard extends StatefulWidget{
  const WareHouseDashboard({super.key});

  @override
  State<WareHouseDashboard> createState() => _WareHouseDashboardState();
}
class _WareHouseDashboardState extends State<WareHouseDashboard> with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);

  }

  void _onTabChanged(){
    final index = _tabController.index;
    context.read<WareHouseTabBloc>().add(WarehouseTabChanged(index));
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
          child: Scaffold(
            body: WareHouseMobileDashboard(
              tabController: _tabController,
              isTablet: isTablet,
            ),
          ),
        );                                      // ← MultiBlocProvider close
      },                                        // ← LayoutBuilder builder close
    );                                          // ← LayoutBuilder close
  }                                             // ← build() close
}


