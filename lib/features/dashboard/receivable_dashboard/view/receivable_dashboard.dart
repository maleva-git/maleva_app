import 'package:flutter/Material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/salesorder/bloc/salesorder_bloc.dart';
import 'package:maleva/features/dashboard/receivable_dashboard/view/receivable_dashboard_ui.dart';
import '../../../../core/di/injection.dart';
import '../../admin_dashboard/tabs/invoice/bloc/invoice_bloc.dart';
import '../../admin_dashboard/tabs/invoice/bloc/invoice_event.dart';
import '../../admin_dashboard/tabs/invoice/data/invoice_repository.dart';
import '../../admin_dashboard/tabs/invoice/view/invoice_tab.dart';
import '../../admin_dashboard/tabs/salesorder/view/salesorderview_tab.dart';
import '../bloc/receivable_bloc.dart';
import '../bloc/receivable_event.dart';

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
    _tabController = TabController(length: 2, vsync: this);
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;
        return MultiBlocProvider(
          providers: [

            BlocProvider(
              create: (_) => InvoiceBloc(
                invoiceRepo: InvoiceRepositoryImpl(),
              )..add( LoadInvoiceByType(0)),
              child: const InvoiceTab(),
            ),
            BlocProvider(
              create: (_) => sl<SalesOrderBloc>(),
              child: const SalesOrderTab(),
            ),

          ],                                    // ← ] தான் close, } இல்ல
          child: Scaffold(
            body: ReceivableMobileDashboard(
              tabController: _tabController,
              isTablet: isTablet,
            ),
          ),
        );                                      // ← MultiBlocProvider close
      },                                        // ← LayoutBuilder builder close
    );                                          // ← LayoutBuilder close
  }                                             // ← build() close
}


