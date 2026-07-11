import 'package:flutter/Material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/features/dashboard/common_tabs/salesorder/bloc/salesorder_bloc.dart';
import 'package:maleva/features/dashboard/receivable_dashboard/view/receivable_dashboard_ui.dart';
import '../../../../core/di/injection.dart';
import '../../common_tabs/invoice/bloc/invoice_bloc.dart';
import '../../common_tabs/invoice/bloc/invoice_event.dart';
import '../../common_tabs/invoice/data/invoice_repository.dart';
import '../../common_tabs/invoice/view/invoice_tab.dart';
import '../../common_tabs/salesorder/bloc/salesorder_event.dart';
import '../../common_tabs/salesorder/view/salesorderview_tab.dart';
import '../bloc/receivable_bloc.dart';
import '../bloc/receivable_event.dart';
import 'package:maleva/features/dashboard/common_tabs/driverleave/bloc/leave_bloc.dart';

class ReceivableDashboard extends StatefulWidget{
  const ReceivableDashboard({super.key});

  @override
  State<ReceivableDashboard> createState() => _AdminDashboardState();
}
class _AdminDashboardState extends State<ReceivableDashboard> with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);

  }

  void _onTabChanged(){
    final index = _tabController.index;
    context.read<ReceivableTabBloc>().add(ReceivableTabChanged(index));
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
              create: (_) => InvoiceBloc(
                invoiceRepo: InvoiceRepositoryImpl(),
              )..add( LoadInvoiceByType(0)),
              child: const InvoiceTab(),
            ),
            BlocProvider(
              create: (_) => sl<SalesOrderBloc>()
                ..add(LoadInvoiceByTypes(1)),
              child: const SalesOrderTab(),
            ),
                  BlocProvider<LeaveBloc>(create: (_) => sl<LeaveBloc>()),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;
        return Scaffold(
            body: ReceivableMobileDashboard(
              tabController: _tabController,
              isTablet: isTablet,
            ),
          );
        },
      ),
    );                                          // ← LayoutBuilder close
  }                                             // ← build() close
}


