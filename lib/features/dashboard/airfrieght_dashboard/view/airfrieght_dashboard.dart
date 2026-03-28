import 'package:flutter/Material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../admin_dashboard/tabs/airfreightsales/bloc/airfreightsales_bloc.dart';
import '../../admin_dashboard/tabs/airfreightsales/bloc/airfreightsales_event.dart';
import '../../admin_dashboard/tabs/airfreightsales/view/airfreightsales_tab.dart';
import '../../admin_dashboard/tabs/enquiry/view/bloc/enquiry_bloc.dart';
import '../../admin_dashboard/tabs/enquiry/view/bloc/enquiry_event.dart';
import '../../admin_dashboard/tabs/enquiry/view/view/enquiry_tab.dart';
import '../../admin_dashboard/tabs/fuel/bloc/fuelreport_bloc.dart';
import '../../admin_dashboard/tabs/fuel/bloc/fuelreport_event.dart';
import '../../admin_dashboard/tabs/fuel/view/fuelreport_tab.dart';
import '../../admin_dashboard/tabs/paymentview/bloc/paymentview_bloc.dart';
import '../../admin_dashboard/tabs/paymentview/bloc/paymentview_event.dart';
import '../../admin_dashboard/tabs/paymentview/view/paymentview_tab.dart';
import '../../admin_dashboard/tabs/transport/bloc/transport_bloc.dart';
import '../../admin_dashboard/tabs/transport/bloc/transport_event.dart';
import '../../admin_dashboard/tabs/transport/view/transportview_tab.dart';
import '../../admin_dashboard/tabs/vesselreport/bloc/vesselreport_bloc.dart';
import '../../admin_dashboard/tabs/vesselreport/bloc/vesselreport_event.dart';
import '../../admin_dashboard/tabs/vesselreport/view/vesselreportview_tab.dart';
import '../bloc/airfreight_bloc.dart';
import 'airfrieght_dashboard_ui.dart';

class SalesDashboard extends StatefulWidget {
  const SalesDashboard({super.key});

  @override
  State<SalesDashboard> createState() => _SalesDashboardState();
}

class _SalesDashboardState extends State<SalesDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6

        , vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged(){
    final index = _tabController.index;
    // context.read<SalesDashboardBloc>().add(TabChanged(index));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints){
          final isTablet = constraints.maxWidth >= 600;
          return MultiBlocProvider(
              providers: [
                BlocProvider(create: (context) => SalesDashboardBloc()),
                BlocProvider(
                  create: (_) => CustomerDashboardBloc(
                  )..add( LoadSalesDataEvent(0)),
                  child:  const CustomerDashboardScreen(),
                ),
                BlocProvider(
                    create: (context) => VesselBloc(
                        context: context,
                    )..add(const LoadVesselDataEvent(type: 0)),
                  child: const VesselReportPage(),
                ),
                BlocProvider(
                  create: (context) => TransportBloc(
                    context: context,
                  )..add(const LoadTransportDataEvent(type: 0)),
                  child: const TransportReportPage(),
                ),
                BlocProvider(
                  create: (_) => EnquiryBloc(

                  )..add( LoadEnquiryEvent()),
                  child: const EnquiryScreen(),
                ),
                BlocProvider(
                  create: (context) => FuelDiffBloc(context)..add(const LoadFuelDiffEvent()),
                  child: const FuelDiffPage(),
                ),
                BlocProvider(
                  create: (context) => PaymentPendingBloc(context)
                    ..add(const LoadPaymentPendingEvent()),
                  child: const PaymentPendingPage(),
                ),
              ],
              child: Builder(
                builder: (context) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final isTablet = constraints.maxWidth >= 600;
                      return Scaffold(
                        body: SalesDashboardView(
                            tabController: _tabController,
                            isTablet: isTablet
                        ),
                      );
                    }
                  );
                }
              )
          );
        }
    );
  }
}