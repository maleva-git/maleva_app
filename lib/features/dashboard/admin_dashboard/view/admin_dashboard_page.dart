import 'package:flutter/Material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/features/dashboard/admin_dashboard/tabs/ExpenseReport/bloc/expensereport_bloc.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/ExpenseReport/bloc/expensereport_event.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/salesorder/bloc/salesorder_bloc.dart';
import '../../../common_updates/blocs/sales/sales_bloc.dart';
import '../../../common_updates/blocs/truck/truck_bloc.dart';
import '../bloc/admin_tab_bloc.dart';
import '../bloc/admin_tab_event.dart';
import '../tabs/ExpenseReport/view/expensereport_tab.dart';
import '../tabs/forwardingreport/bloc/forwardingreport_bloc.dart';
import '../tabs/forwardingreport/bloc/forwardingreport_event.dart';
import '../tabs/forwardingreport/view/forwardingreport_tab.dart';
import '../tabs/invoice/bloc/invoice_bloc.dart';
import '../tabs/invoice/view/invoice_tab.dart';
import '../tabs/receiptview/bloc/receiptview_bloc.dart';
import '../tabs/receiptview/bloc/receiptview_event.dart';
import '../tabs/receiptview/view/receiptview_tab.dart';
import '../tabs/salesorder/view/salesorderview_tab.dart';
import 'admin_dashboard_mobile.dart';

class NewAdminDashboard extends StatefulWidget{
  const NewAdminDashboard({super.key});

  @override
  State<NewAdminDashboard> createState() => _AdminDashboardState();
}
class _AdminDashboardState extends State<NewAdminDashboard> with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(_onTabChanged);

  }

  void _onTabChanged(){
    final index = _tabController.index;
    context.read<AdminTabBloc>().add(TabChanged(index));
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
        BlocProvider<SalesBloc>(
          create: (_) => SalesBloc(),
        ),
        BlocProvider<TruckBloc>(
          create: (_) => TruckBloc(),
        ),
        BlocProvider(
        create: (context) => InvoiceBloc(context),
        child: const InvoiceTab(),
        ),
        BlocProvider(
          create: (context) => SalesOrderBloc(context),
          child: const SalesOrderTab(),
        ),
        BlocProvider(
          create: (context) => ReceiptBloc(
            context: context,
          )..add(LoadReceiptEvent()),
          child: const ReceiptPage(),
        ),
        BlocProvider(
          create: (context) => ForwardingReportBloc(context)
            ..add(LoadFWDataEvent(
              fromDate: DateFormat("yyyy-MM-dd").format(DateTime.now()),
              toDate: DateFormat("yyyy-MM-dd").format(DateTime.now()),
            )),
          child: const ForwardingReportView(),
        ),
        BlocProvider(
          create: (context) => ExpenseReportBloc(context)
            ..add(LoadExpReportEvent(
              fromDate: DateFormat("yyyy-MM-dd").format(DateTime.now()),
              toDate: DateFormat("yyyy-MM-dd").format(DateTime.now()),
            )),
          child: const ExpenseReportView(),
        ),
      ],
      child: Scaffold(
        body: MobileDashboard(
          tabController: _tabController,
        ),
      ),
    );
  }
}



class Tab2Content extends StatelessWidget {
  const Tab2Content({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Tab 2 Content'));
  }
}

class Tab3Content extends StatelessWidget {
  const Tab3Content({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Tab 3 Content'));
  }
}

class Tab4Content extends StatelessWidget {
  const Tab4Content({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Tab 4 Content'));
  }
}

class Tab5Content extends StatelessWidget {
  const Tab5Content({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Tab 5 Content'));
  }
}

class Tab6Content extends StatelessWidget {
  const Tab6Content({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Tab 6 Content'));
  }
}

class TruckTab extends StatelessWidget {
  const TruckTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Truck Tab Content'));
  }
}
