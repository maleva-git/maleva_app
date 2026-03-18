import 'dart:async';
import 'dart:io';

import 'package:maleva/DashBoard/OperationAdmin/OperationAdminDashboard.dart';
import 'package:maleva/DashBoard/User/UserDashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/menu/menulist.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../DashBoard/Admin/AdminDashboard.dart';
import '../../DashBoard/AirFrieght/AirFrieghtDashboard.dart';
import '../../DashBoard/Boarding/BoardingDashboard.dart';
import '../../DashBoard/Driver/DriverDashboard.dart';
import '../../DashBoard/Forwarding/ForwardingDashboard.dart';
import '../../DashBoard/TransportDB/TransportDashboard.dart';
import '../../MasterSearch/Driver.dart';
import '../../MasterSearch/Truck.dart';

import '../../features/dashboard/admin_dashboard/view/admin_dashboard.dart';
import 'UpdateRTIStatus.dart';
part 'package:maleva/Transport/RTI/mobileUpdateRTIDetails.dart';
part 'package:maleva/Transport/RTI/tabletUpdateRTIDetails.dart';

class UpdateRTI extends StatefulWidget {
  const UpdateRTI({super.key});

  @override
  UpdateRTIState createState() => UpdateRTIState();
}

class UpdateRTIState extends State<UpdateRTI> {
  bool progress = false;
  String cls = "3";
  String ETAVal = "0";
  int DriverId = 0;
  int TruckId = 0;
  int StatusId = 0;
  int EditId = 0;
  int Employeeid = 0;
  String ETARadioVal = "0";
  bool checkBoxValueETA = false;
  bool checkBoxValuePickUp = false;
  bool checkBoxValueLEmp = true;
  bool completestatusnotshow = false;
  bool VisibleDriverTruck = objfun.DriverLogin == 1 ? false : true;
  String dtpToDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  String dtpFromDate = DateFormat("yyyy-MM-dd").format(DateTime.now());

  final txtLoadingVessel = TextEditingController();
  final txtOffVessal = TextEditingController();
  final txtRTINo = TextEditingController();
  final txtDriver = TextEditingController();
  final txtTruckNo = TextEditingController();
  final txtStatus = TextEditingController();
  final txtPassword = TextEditingController();
  List<dynamic> RTIDetailsList = [];
  String UserName = objfun.storagenew.getString('Username') ?? "";
  List<bool> VisibleRTIDetails = List<bool>.filled(objfun.RTIViewMasterList.length, false);
  int daysscount = 0;
  int _currentlyVisibleIndex = -1;

  @override
  void initState() {
    startup();
    super.initState();

  }

  @override
  void dispose() {
    txtLoadingVessel.dispose();
    txtOffVessal.dispose();
    txtRTINo.dispose();
    txtDriver.dispose();
    txtTruckNo.dispose();
    txtStatus.dispose();
    txtPassword.dispose();
    super.dispose();
  }

  Future startup() async {

    await OnlineApi.SelectEmployee(context, 'Sales', '');
    loaddata();
    setState(() {
      progress = true;
    });
  }

  Future loaddata() async {
    setState(() {
      progress = false;
    });
    var LEmpRefId = 0;
    if(checkBoxValueLEmp){
      LEmpRefId = objfun.EmpRefId;
    }
    else{

    }
    if(objfun.DriverLogin == 1){
      DriverId = objfun.EmpRefId;
    }
    await OnlineApi.SelectRTIViewList(context, dtpFromDate, dtpToDate, DriverId, TruckId, Employeeid, txtRTINo.text);
    VisibleRTIDetails = List<bool>.filled(objfun.RTIViewMasterList.length, false);
    setState(() {
      progress = true;
    });
  }

  Future<bool> _onBackPressed() async {
    if(objfun.DriverLogin == 1)
    {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const DriverDashboard()));
    }
    else if(objfun.storagenew.getString('RulesType') == "ADMIN")
    {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const NewAdminDashboard()));
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
    else if(objfun.storagenew.getString('RulesType') == "BOARDING"  || objfun.storagenew.getString('RulesType') == "OPERATION")
    {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const BoardingDashboard()));
    }
    else if( objfun.storagenew.getString('RulesType') == "FORWARDING" )
    {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ForwardingDashboard()));
    }
    else
    {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const Homemobile()));
    }   return true;
  }



  Future<void> _openPdf(String url) async {
    try {
      // Download PDF
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Save PDF to temporary directory
        final Directory tempDir = await getTemporaryDirectory();
        final File file = File('${tempDir.path}/temp.pdf');
        await file.writeAsBytes(response.bodyBytes);

        // Open the PDF
        // final result = await OpenFile.open(file.path);
        // if (result.type != ResultType.done) {
        //   throw 'Failed to open the PDF file.';
        // }
      } else {
        throw 'Failed to download PDF';
      }
    } catch (e) {
      print('Error: $e');
      // Optionally, show an error message to the user
    }
  }
  Future _shareRTI( int Id ,String RTINo) async {

    Map<String?, dynamic> master = {};
    master =
    {
      'SoId': Id,
      'Comid': objfun.Comid,
    };
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    await objfun
        .apiAllinoneSelectArray(
        "${objfun.apiViewRTIPdf}$RTINo",
        master,
        header,
        context)
        .then((resultData) async {
      if (resultData != "") {
        ResponseViewModel? value = ResponseViewModel.fromJson(resultData);
        if (value.IsSuccess == true) {
            objfun
            .launchInBrowser(value.data1);

        }

      }
    }).onError((error, stackTrace) {

      objfun.msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - objfun.reducesize,
          objfun.tll,
          objfun.tgc,
          context,
          2);
    });
setState(() {
  progress = true;
});

  }

  late File ff;
  bool show = false;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return width < 768
        ? mobiledesign(this, context)
        : tabletdesign(this, context);
  }


}
