import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/Transaction/EnquiryTR/AddEnquiryTR.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/menu/menulist.dart';
import 'package:maleva/core/models/model.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;

import '../../core/bluetooth/bluetoothmanager.dart';
import '../../Boarding/BoardingOfficerUpdate/BoardOfficerUpdate.dart';
import '../../MasterSearch/Port.dart';
import '../../Transaction/SaleOrder/SalesOrderAdd.dart';
import '../../Transaction/SaleOrderDetails.dart';
import '../../Transaction/Stock/StockUpdate.dart';
part 'package:maleva/DashBoard/Forwarding/mobileForwardingDashboard.dart';
part 'package:maleva/DashBoard/Forwarding/tabletForwardingDashboard.dart';

class ForwardingDashboard extends StatefulWidget {
  const ForwardingDashboard({super.key});

  @override
  ForwardingDashboardState createState() => ForwardingDashboardState();
}

class ForwardingDashboardState extends State<ForwardingDashboard> with TickerProviderStateMixin {
  bool progress = false;
  late MenuMasterModel menuControl;
  bool Is6Months = true;
  bool IsToday = true;
  bool IsPlanToday = true;
  bool Is6Months2 = true;
  bool Is6Months3 = true;
  bool Invoicewiseview = true;
  bool FWReportview = false;
  DateTime now = DateTime.now();
  int monthIndex = 0;
  int withoutInvoiceCount = 0;
  int TotalCount = 0;
  int TotalBilledCount = 0;
  int TotalUnBilledCount = 0;
  int EmpId = 0;

  static const List<String> DashBoardList = <String>['INV', 'SO', 'FW'];
  String? dropdownValueFW;


   // Months are 1-indexed

  List <dynamic> SaleCustReport=[];
  List <dynamic> UnReleaseList =[];



  late TabController _tabmainController;
  final txtEmployee = TextEditingController();
  final txtPort = TextEditingController();
  final txtRemarks = TextEditingController();
  String? dropdownValueEMp;
  @override
  void initState() {

    _tabmainController = TabController(vsync: this, length: 3);

    EmpId = objfun.EmpRefId;
    startup();
    super.initState();

  }

  Future startup() async {

    loadVesseldata(0);
    setState(() {
      progress = true;
    });
  }

  Future loadVesseldata(int type) async {
    setState(() {
      progress = false;
    });
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };


    var eid;
    DateTime now = DateTime.now();
    DateTime newDate = now.add(Duration(days: type));
    String FromDate = DateFormat('yyyy-MM-dd').format(newDate);
    String ToDate = DateFormat('yyyy-MM-dd').format(newDate);

    if (type == 0) {
      //FromDate = "2025-02-01";
      FromDate = "2024-10-01";
    }
    Map<String, dynamic> master = {};

    master = {

      'Comid': objfun.storagenew.getInt('Comid') ?? 0,
      'Fromdate': FromDate,
      'Todate': ToDate,
      'Search': txtRemarks.text,
      'Employeeid': eid,
      'ETAType' : 0

    };
    await objfun
        .apiAllinoneSelectArray(
        objfun.VESSELPLANINGDB, master, header, context)
        .then((resultData) async {
      if (resultData != "") {
        setState(() {
          progress = true;
        });
        if (resultData.length != 0) {
          SaleCustReport=resultData;
          SaleCustReport.sort((a, b) {
            String nameA = a['Port']?.toLowerCase() ?? '';
            String nameB = b['Port']?.toLowerCase() ?? '';
            return nameA.compareTo(nameB);
          });

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
  Future loadUnreleasedata(int type) async {
    setState(() {
      progress = false;
    });
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    var URL = objfun.LoadUnReleaseNo;
    if (type == 1) {
       URL = objfun.LoadK8UnReleaseNo;
    }
    Map<String, dynamic> master = {};

    master = {

      'Comid': objfun.storagenew.getInt('Comid') ?? 0,

    };
    await objfun
        .apiAllinoneSelectArray(
        URL, master, header, context)
        .then((resultData) async {
      if (resultData != "") {
        setState(() {
          progress = true;
        });
        if (resultData.length != 0) {
          UnReleaseList=resultData;


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
  Future<void> _showDialogDetails(Map detailsList) async {

    await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              elevation: 40.0,
              child: Container(
                  width: 200,
                  height: 550,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(
                    right: 5.0,
                    left: 5.0,
                  ),
                  child: Column(children: [
                    Padding(padding: const EdgeInsets.all(15),
                    child: ListView(shrinkWrap: true, children: <Widget>[
                     Center(
                       child:  Text("DETAILS",style:GoogleFonts
                        .lato(
                      textStyle: const TextStyle(
                           fontWeight: FontWeight.bold,
                         color: colour
                             .commonColorred,
                       )),),
                     ),
                      const SizedBox(height: 15,),
                      Text("Job No : ${detailsList["JobNo"]}",style:GoogleFonts
                          .lato(
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colour
                            .commonColor,
                      )),),
                      Text("L Vessel Name : ${detailsList["Loadingvesselname"]}",style:GoogleFonts
                          .lato(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colour
                                .commonColor,
                          )),),
                      Text("O Vessel Name : ${detailsList["Offvesselname"]}",style:GoogleFonts
                          .lato(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colour
                                .commonColor,
                          )),),
                      Text("Job Type : ${detailsList["JobName"]}",style:GoogleFonts
                          .lato(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colour
                                .commonColor,
                          )),),
                      Text("pkg : ${detailsList["pkg"]}",style:GoogleFonts
                          .lato(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colour
                                .commonColor,
                          )),),
                      Text("LPort : ${detailsList["SPort"]}",style:GoogleFonts
                          .lato(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colour
                                .commonColor,
                          )),),
                      Text("OPort : ${detailsList["OPort"]}",style:GoogleFonts
                          .lato(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colour
                                .commonColor,
                          )),),
                      Text("Commodity : ${detailsList["Commodity"]}",style:GoogleFonts
                          .lato(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colour
                                .commonColor,
                          )),),
                      Text("L ETA : ${detailsList["SETA"]}",style:GoogleFonts
                          .lato(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colour
                                .commonColor,
                          )),),
                      Text("L ETB : ${detailsList["SETB"]}",style:GoogleFonts
                          .lato(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colour
                                .commonColor,
                          )),),
                      Text("L ETD : ${detailsList["SETD"]}",style:GoogleFonts
                          .lato(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colour
                                .commonColor,
                          )),),
                      Text("O ETA : ${detailsList["SOETA"]}",style:GoogleFonts
                          .lato(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colour
                                .commonColor,
                          )),),
                      Text("O ETB : ${detailsList["SOETB"]}",style:GoogleFonts
                          .lato(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colour
                                .commonColor,
                          )),),
                      Text("O ETD : ${detailsList["SOETD"]}",style:GoogleFonts
                          .lato(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colour
                                .commonColor,
                          )),),
                      Text("O SCN : ${detailsList["OSCN"]}",style:GoogleFonts
                          .lato(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colour
                                .commonColor,
                          )),),
                      Text("L SCN : ${detailsList["LSCN"]}",style:GoogleFonts
                          .lato(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colour
                                .commonColor,
                          )),),
                      Text("Vessel Type : ${detailsList["VesselType"]}",style:GoogleFonts
                          .lato(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colour
                                .commonColor,
                          )),),
                      Text("L Agent Company: ${detailsList["AgentCompany"]}",style:GoogleFonts
                          .lato(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colour
                                .commonColor,
                          )),),
                      Text("L Agent : ${detailsList["AgentName"]}",style:GoogleFonts
                          .lato(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colour
                                .commonColor,
                          )),),
                      Text("L Agent Phone: ${detailsList["AgentPhone"]}",style:GoogleFonts
                          .lato(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colour
                                .commonColor,
                          )),),
                      Text("O Agent Company: ${detailsList["OAgentCompany"]}",style:GoogleFonts
                          .lato(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colour
                                .commonColor,
                          )),),
                      Text("O Agent : ${detailsList["OAgentName"]}",style:GoogleFonts
                          .lato(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colour
                                .commonColor,
                          )),),

                      Text("O Agent Phone : ${detailsList["OAgentPhone"]}",style:GoogleFonts
                          .lato(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colour
                                .commonColor,
                          )),),

                      Text("Employee Name : ${detailsList["EmployeeName"]}",style:GoogleFonts
                          .lato(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colour
                                .commonColor,
                          )),),
                    ]),
                    )

                  ])));
        });
  }

  Future<bool> _onBackPressed() async {
    bool result = await objfun.ConfirmationMsgYesNo(
        context, "Are you Sure you want to Exit?");
    if (result == true) {
      if (Platform.isAndroid) {
        SystemNavigator.pop();
      } else if (Platform.isIOS) {
        exit(0);
      }
    } else {
      return false;
      // Navigator.of(context).pop();
    }
    return result;
  }
  Color? _CardColor(int index) {

    DateTime? targetETA = SaleCustReport[index]["SETB"] == "" ? null : DateTime.parse(SaleCustReport[index]["SETB"]);
    DateTime? targetOETA = SaleCustReport[index]["SOETB"] == "" ?null : DateTime.parse(SaleCustReport[index]["SOETB"]);
    DateTime now = DateTime.now();
    DateTime yesterday = now.subtract(Duration(days: 1));
    if (targetETA != null && yesterday.isAfter(targetETA)  ) {
      return Colors.redAccent.withOpacity(0.3);
    }
    else if (targetOETA != null && yesterday.isAfter(targetOETA)  ) {
     return Colors.redAccent.withOpacity(0.3);
    }
    else {
      return null;
    }
  }
  Color? _CardUnReleaseColor(int index) {

    if (UnReleaseList[index]["DayCount"] >= 10){
      return Colors.redAccent.withOpacity(0.3);
    }
    else {
      return null;
    }
  }
  late File ff;
  bool show = false;

  @override
  Widget build(BuildContext context) {
    return objfun.MalevaScreen == 1
        ? mobiledesign(this, context)
        : tabletdesign(this, context);

  }
}
