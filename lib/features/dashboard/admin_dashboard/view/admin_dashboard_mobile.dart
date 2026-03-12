import 'package:flutter/Material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;
import '../../../../SaleOrderView/SaleOrderView.dart';
import '../../../../core/bluetooth/bluetoothmanager.dart';
import '../../../../core/colors/colors.dart';
import '../../../../core/models/model.dart';
import '../../../../menu/menulist.dart';
import '../../../common_updates/blocs/sales/sales_bloc.dart';
import '../../../common_updates/blocs/sales/sales_event.dart';
import '../../../common_updates/blocs/truck/truck_bloc.dart';
import '../../../common_updates/blocs/truck/truck_event.dart';
import '../bloc/admin_tab_bloc.dart';
import '../bloc/admin_tab_state.dart';
import '../tabs/ExpenseReport/view/expensereport_tab.dart';
import '../tabs/bocheck/view/bocheck_tab.dart';
import '../tabs/driver/view/driverdetails_tab.dart';
import '../tabs/emailinbox/view/emailinbox_tab.dart';
import '../tabs/employeemaster/view/employeemaster_tab.dart';
import '../tabs/enginehours/view/enginehours_tab.dart';
import '../tabs/forwardingreport/view/forwardingreport_tab.dart';
import '../tabs/fuel/view/fuelreport_tab.dart';
import '../tabs/fuelfillings/view/fuelfillings_tab.dart';
import '../tabs/googlereview/view/googlereview_tab.dart';
import '../tabs/pettycash/view/pettycash_tab.dart';
import '../tabs/receiptview/view/receiptview_tab.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import '../tabs/invoice/view/invoice_tab.dart';
import '../tabs/salesorder/view/salesorderview_tab.dart';
import '../tabs/spareparts/view/sparepartsadd.dart';
import '../tabs/speedingreport/view/speedingreport_view.dart';
import '../tabs/summonentry/view/summonentry_tab.dart';
import '../tabs/transport/view/transportview_tab.dart';
import '../tabs/truck/view/truckview_tab.dart';
import '../tabs/vesselreport/view/vesselreportview_tab.dart';

class MobileDashboard extends StatelessWidget {
  final TabController tabController;

  const MobileDashboard({required this.tabController, super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery
        .of(context)
        .size
        .height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.appBarColor,
        title: SizedBox(
          height: height * 0.05,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Dash Board',
                  style: GoogleFonts.lato(textStyle: TextStyle(
                    color: colour.topAppBarColor,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Alatsi',
                    fontSize: objfun.FontLarge,
                  ))),
            ],
          ),

        ),
        iconTheme: const IconThemeData(color: colour.topAppBarColor),
        actions: <Widget>[

          // IconButton(
          //   icon: const Icon(
          //     Icons.refresh,
          //     size: 30.0,
          //     color: colour.topAppBarColor,
          //   ),
          //   onPressed: () {
          //     Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminDashboard()));
          //   },
          // ),
          IconButton(
            icon: const Icon(
              Icons.directions_boat_filled,
              size: 25.0,
              color: colour.topAppBarColor,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Saleorderview()),
              );
            },
          ),

          IconButton(
            icon: const Icon(
              Icons.bluetooth_audio,
              size: 25.0,
              color: colour.topAppBarColor,
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (
                  context) => Bluetoothpage()));
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.print,
              size: 25.0,
              color: colour.topAppBarColor,
            ),
            onPressed: ()async {

              await objfun.printdata([BarcodePrintModel(
                  "MALEVA", "SHIPNAME", "SHIPNAME", "B0005000", "2025-05-04",
                  "WESTPORT", "WESTPORT","(1/3)")
              ]);
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.exit_to_app,
              size: 30.0,
              color: colour.topAppBarColor,
            ),
            onPressed: () {
              objfun.logout(context);
            },
          ),
        ],

      ),
      drawer: const Menulist(),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: TabBar(
              controller: tabController,
              isScrollable: true,
              indicator: BoxDecoration(
                color: AppColors.appBarColor,
                borderRadius: BorderRadius.circular(25),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFF1A2E5A),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              tabs: const [
                Tab(text: 'Invoice'),
                Tab(text: 'ReceiptView'),
                Tab(text: 'SO'),
                Tab(text: 'FW'),
                Tab(text: 'EXP'),
                Tab(text: 'VSL'),
                Tab(text: 'TRANSPORT'),
                Tab(text: 'Truck'),
                Tab(text: 'Driver'),
                Tab(text: 'SpeedingReport'),
                Tab(text: 'FuelFilling'),
                Tab(text: 'EngineHours'),
                Tab(text: 'BOCheck'),
                Tab(text: 'Email'),
                Tab(text: 'GoogleReview'),
                Tab(text: 'Fuel'),
                Tab(text: 'EmployeeView'),
                Tab(text: 'PettyCash'),
                Tab(text: 'SummonEntry'),
                Tab(text: 'SparePartsEntry'),

              ],
            ),
          ),

          Expanded(
            child: BlocListener<AdminTabBloc, AdminTabState>(
              listener: (context, tabState) {
                switch (tabState.index) {
                  case 0:
                    context.read<SalesBloc>().add(LoadSales(0));
                    break;
                  case 6:
                    context.read<TruckBloc>().add(LoadTruckList());
                    break;
                }
              },
              child: TabBarView(


                controller: tabController,
                children: [
                  const InvoiceTab(),
                  const ReceiptPage(),
                  const SalesOrderTab(),
                  const ForwardingReportPage(),
                  const ExpenseReportPage(),
                  const VesselReportPage(),
                  const TransportReportPage(),
                  const TruckDetailsReportPage(),
                  const DriverDetailsView(),
                  const SpeedingScreen(),
                  const FuelFillingPage(),
                  const EngineHoursPage(),
                  const BocPage(),
                  const EmailPage(),
                  const ReviewEntryPage(),
                  const FuelDiffPage(),
                  const EmployeeViewPage(),
                  const PettyCashPage(),
                  const SummonEntryPage(),
                  const SparePartsEntryPage(),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
