
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:flutter_spinkit/flutter_spinkit.dart";
import 'package:intl/intl.dart';
import 'package:maleva/DashBoard/OperationAdmin/OperationAdminDashboard.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/core/models/model.dart';
import '../DashBoard/Admin/AdminDashboard.dart';
import '../DashBoard/AirFrieght/AirFrieghtDashboard.dart';
import '../DashBoard/Boarding/BoardingDashboard.dart';
import '../DashBoard/CustomerService/CustDashboard.dart';
import '../DashBoard/Driver/DriverDashboard.dart';
import '../DashBoard/Forwarding/ForwardingDashboard.dart';
import '../DashBoard/HR/HrDashboard.dart';
import '../DashBoard/Maintenance/MaintenanceDashboard.dart';
import '../DashBoard/Payable/PayableDashbord.dart';
import '../DashBoard/Receivable/ReceivableDashboard.dart';
import '../DashBoard/TransportDB/TransportDashboard.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/pages/login_page.dart.dart';
import '../DashBoard/User/UserDashboard.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;

import '../features/dashboard/admin_dashboard/bloc/admin_tab_bloc.dart';
import '../features/dashboard/admin_dashboard/view/admin_dashboard_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double width = 0;
  double height = 0;
  String dtpDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  int progress = 1;
  String loginstatus = "0";
  String url = "";
  int daysscount = 0;
  @override
  void initState() {
    startup();
    super.initState();
  }

  Future startup() async {
    await objfun.localstoragecall();
    await Future.delayed(const Duration(seconds: 3));
    await objfun.getDeviceToken();
    // String blueToothlist = objfun.storagenew.getString('BlueTooth') ?? "";
    // if(blueToothlist!="") {
    //   try {
    //     objfun.bluetoothdeviceList.add(
    //         BluetoothModel.fromJson(jsonDecode(blueToothlist)));
    //    await objfun.printerinit();
    //   }
    //   catch (ex) {
    //     if (kDebugMode) {
    //       print(ex);
    //     }
    //   }
    // }
    String UserName = objfun.storagenew.getString('Username') ?? "";
    String Password = objfun.storagenew.getString('Password') ?? "";
    String OldUserName = objfun.storagenew.getString('OldUsername') ?? "";
    objfun.MalevaScreen= objfun.storagenew.getInt('DeviceView') ?? 1;
    objfun.DriverLogin=objfun.storagenew.getInt('DriverId') ?? 0;
    if (UserName != "" && Password != "") {
      if (await OnlineApi.Login(UserName, Password, OldUserName,objfun.DriverLogin, context) ==
          true) {

        if(objfun.DriverLogin == 1)
        {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const DriverDashboard()));
        }
        else if(objfun.storagenew.getString('RulesType') == "ADMIN")
        {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => AdminTabBloc(),
                child: const NewAdminDashboard(),
              ),
            ),
          );
        }
        else if(objfun.storagenew.getString('RulesType') == "SALES")
        {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CustDashboard()));
        }
        else if(objfun.storagenew.getString('RulesType') == "TRANSPORTATION")
        {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const TransportDashboard()));
        }
        else if(objfun.storagenew.getString('RulesType') == "OPERATIONADMIN")
        {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const OperationAdminDashboard()));
        }
        else if(objfun.storagenew.getString('RulesType') == "AIR FRIEGHT")
        {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AirFrieghtDashboard()));
        }
        else if(objfun.storagenew.getString('RulesType') == "BOARDING" || objfun.storagenew.getString('RulesType') == "OPERATION")
        {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const BoardingDashboard()));
        }
        else if( objfun.storagenew.getString('RulesType') == "FORWARDING" )
        {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ForwardingDashboard()));
        }
        else if( objfun.storagenew.getString('RulesType') == "HRADMIN")
        {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const HrDashboard()));
        }
        else if(objfun.storagenew.getString('RulesType') == "HR")
        {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const MaintenanceDashboard()));
        }
        else if( objfun.storagenew.getString('RulesType') == "RECEIVABLE" )
        {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ReceivableDashboard()));
        }
        else if( objfun.storagenew.getString('RulesType') == "ACCOUNTS")
        {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const PayableDashbord()));
        }
        else
        {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const Homemobile()));
        }
      }
      else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => LoginBloc(),
              child: const Appuserloginmobile(),
            ),
          ),
        );

      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => LoginBloc(),
            child: const Appuserloginmobile(),
          ),
        ),
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[

              Expanded(
                flex: 1,
                child: Container(),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    image: DecorationImage(
                      image: objfun.splashlogo,
                      // fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              const Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SpinKitRotatingCircle(
                      color: colour.spinKitColor,
                      size: 35.0,
                    ),
                    SizedBox(height: 20.0),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
