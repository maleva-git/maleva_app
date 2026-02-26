import 'dart:async';
import 'dart:io';

import 'package:maleva/DashBoard/OperationAdmin/OperationAdminDashboard.dart';
import 'package:maleva/MasterSearch/Customer.dart';
import 'package:maleva/MasterSearch/JobStatus.dart';
import 'package:maleva/DashBoard/User/UserDashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/menu/menulist.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/Transaction/SaleOrder/SalesOrderAdd.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;

import '../../DashBoard/Admin/AdminDashboard.dart';
import '../../DashBoard/AirFrieght/AirFrieghtDashboard.dart';
import '../../DashBoard/Boarding/BoardingDashboard.dart';
import '../../DashBoard/CustomerService/CustDashboard.dart';
import '../../DashBoard/Forwarding/ForwardingDashboard.dart';
import '../../DashBoard/TransportDB/TransportDashboard.dart';
import '../../MasterSearch/Employee.dart';
import '../MasterSearch/JobType.dart';
import '../MasterSearch/Port.dart';
part 'package:maleva/PreAlertReport/mobilePreAlertView.dart';
part 'package:maleva/PreAlertReport/tabletPreAlertView.dart';

class PreAlertreport extends StatefulWidget {
  const PreAlertreport({super.key});
  @override
  PreAlertreportState createState() => PreAlertreportState();
}

class PreAlertreportState extends State<PreAlertreport> {
  bool progress = false;
  String cls = "3";
  String ETAVal = "0";
  int CustId = 0;
  int Jobid = 0;
  int EmpId = 0;

  int PortId = 0;
  int EditId = 0;
  int StatusId = 0;
  String ETARadioVal = "0";
  bool checkBoxValueETA = false;
  bool checkBoxValuePickUp = false;
  bool checkBoxValueVesselName = false;
  bool checkBoxValueDelivery = false;
  bool checkBoxValueConsolidated = false;
  bool checkBoxValuePort = false;
  bool checkBoxValueLEmp = objfun.storagenew.getString('RulesType') == "ADMIN" ? false : true;
  bool completestatusnotshow = false;

  String dtpToDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  String dtpFromDate = DateFormat("yyyy-MM-dd").format(DateTime.now());

  final txtLoadingVessel = TextEditingController();
  final txtOffVessal = TextEditingController();
  final txtVessel = TextEditingController();
  final txtJobNo = TextEditingController();
  final txtStatus = TextEditingController();
  final txtCustomer = TextEditingController();
  final txtJobType = TextEditingController();
  final txtPort = TextEditingController();
  final txtPassword = TextEditingController();
  List<dynamic> SaleDetailsList = [];
  String UserName = objfun.storagenew.getString('Username') ?? "";
  List<bool> VisibleSaleDetails = List<bool>.filled(objfun.SaleOrderMasterList.length, false);
  int daysscount = 0;
  late Timer _timer1;
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
    txtVessel.dispose();
    txtCustomer.dispose();
    txtJobType.dispose();
    txtPort.dispose();
    txtPassword.dispose();
    super.dispose();
  }

  Future startup() async {
    await OnlineApi.SelectCustomer(context);
    await OnlineApi.SelectJobStatus(context);
    await OnlineApi.SelectEmployee(context,'Sales','');
    await OnlineApi.loadComboS1(
        context, 0);
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
      LEmpRefId = Jobid;
    }
    Map<String, dynamic> master = {};
    master = {
      'SoId': 0,
      'Comid': objfun.storagenew.getInt('Comid') ?? 0,
      'Fromdate': dtpFromDate,
      'Todate': dtpToDate,
      'Id': CustId,
      'DId': 0,
      'TId': 0,
      'Employeeid': LEmpRefId,
      'Statusid': PortId,
      'completestatusnotshow': completestatusnotshow,
      'Search':
      txtVessel.text.toString() != "" ? txtVessel.text.toString() : null,
      'Offvesselname': txtOffVessal.text.toString() != ""
          ? txtOffVessal.text.toString()
          : null,
      'Loadingvesselname': txtLoadingVessel.text.toString() != ""
          ? txtLoadingVessel.text.toString()
          : null,
      'Remarks': cls,
      'ETA': checkBoxValueETA,
      'ETAType': ETARadioVal,
      'Pickup': checkBoxValuePickUp,
    };
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    await objfun
        .apiAllinoneSelectArray(
        objfun.apiSelectSalesOrder, master, header, context)
        .then((resultData) async {
      if (resultData != "") {
        setState(() {
          progress = true;
        });
        if (resultData.length != 0) {
          objfun.SaleOrderMasterList = resultData[0]["salemaster"]
              .map((element) => SaleOrderMasterModel.fromJson(element))
              .toList();
          objfun.SaleOrderDetailList = resultData[0]["saledetails"]
              .map((element) => SaleOrderDetailModel.fromJson(element))
              .toList();
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
    VisibleSaleDetails = List<bool>.filled(objfun.SaleOrderMasterList.length, false);
    setState(() {
      progress = true;
    });
  }
  Future _sharePreAlertReport(  ) async {
   var ReportName = "PreAlertReport";
    Map<String?, dynamic> master = {};
    master =
    {
      'SoId': 0,
      'Comid': objfun.storagenew.getInt('Comid') ?? 0,
      'Fromdate': dtpFromDate,
      'Todate': dtpToDate,
      'CustomerId': CustId,
      'DId': 0,
      'TId': 0,
      'Jobid': Jobid,
      'SPort': PortId,
      'completestatusnotshow': completestatusnotshow,
      'Search':
      txtVessel.text.toString() != "" ? txtVessel.text.toString() : null,
      'Remarks': cls,
      'DeliveryDone': checkBoxValueDelivery,
      'ETA': checkBoxValueETA,
      'ETAType': ETARadioVal,
      'Pickupdate': checkBoxValuePickUp,
      'Cons': checkBoxValueConsolidated,
    };
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    await objfun
        .apiAllinoneSelectArray(
        "${objfun.apiPreAlertReport}$ReportName",
        master,
        header,
        context)
        .then((resultData) async {
      if (resultData != "") {
        ResponseViewModel? value = ResponseViewModel.fromJson(resultData);
        if (value.IsSuccess == true) {
          objfun.launchInBrowser(value.data1);
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

  Color? _CardColor(int index) {
    if (objfun.SaleOrderMasterList[index].SPickupDate.toString() != '' &&
        (objfun.SaleOrderMasterList[index].SETA.toString() != '' ||
            objfun.SaleOrderMasterList[index].SOETA.toString() != '')) {
      return null;
    } else if (objfun.SaleOrderMasterList[index].SPickupDate.toString() == '' &&
        objfun.SaleOrderMasterList[index].SETA.toString() == '' &&
        objfun.SaleOrderMasterList[index].SOETA.toString() == '') {
      return Colors.redAccent.withOpacity(0.3);
    } else if (objfun.SaleOrderMasterList[index].SPickupDate.toString() == '') {
      return Colors.yellowAccent.withOpacity(0.3);
    } else {
      if (objfun.SaleOrderMasterList[index].JobMasterRefId == 10) {
        return null;
      } else {
        return Colors.greenAccent.withOpacity(0.3);
      }
    }
  }

  Future<void> _showDialogPassword(int type, int Id, int SaleOrderNo) async {
    var titlenew = "";
    var passwordType = "";
    txtPassword.text = "";
    if (type == 1) {
      titlenew = "Edit Password";
      passwordType = "EditPassword";
    } else if (type == 0) {
      titlenew = "Form Pwd";
      passwordType = "FormConfig";
    } else if (type == 2) {
      titlenew = "Admin Pwd";
      passwordType = "AdminPower";
    }

    await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              elevation: 40.0,
              child: Container(
                  width: 200,
                  height: 220,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(
                    right: 5.0,
                    left: 5.0,
                  ),
                  child: Column(children: [
                    ListView(shrinkWrap: true, children: <Widget>[
                      Container(
                          width: 350, // Set desired width
                          height: 150,
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                image: objfun.lockimg,
                              )),
                          child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 85, left: 35, right: 35, bottom: 25),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                  const BorderRadius.all(Radius.circular(10.0)),
                                  color:
                                  colour.commonColorLight.withOpacity(1.0),
                                ),
                                child: TextField(
                                  cursorColor: colour.commonColor,
                                  controller: txtPassword,
                                  autofocus: false,
                                  showCursor: true,
                                  expands: true,
                                  maxLines: null,
                                  decoration: InputDecoration(
                                    hintText: titlenew,
                                    hintStyle: GoogleFonts.lato(
                                        textStyle:TextStyle(
                                            fontSize: objfun.FontMedium,
                                            fontWeight: FontWeight.bold,
                                            color: colour.commonColor
                                                .withOpacity(0.6))),
                                    fillColor: colour.commonColor,
                                    enabledBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      borderSide:
                                      BorderSide(color: colour.commonColor),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                    ),
                                    contentPadding: const EdgeInsets.only(
                                        left: 10, right: 20, top: 10.0),
                                  ),
                                  textInputAction: TextInputAction.done,
                                  textCapitalization:
                                  TextCapitalization.characters,
                                  keyboardType: TextInputType.number,
                                  style: GoogleFonts.lato(
                                    textStyle: TextStyle(
                                        color: colour.commonColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: objfun.FontLow,
                                        letterSpacing: 0.3),
                                  ),
                                ),
                              ))),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              if (txtPassword.text != "") {
                                await objfun
                                    .apiAllinoneSelectArray(
                                    "${objfun.apiEditPassword}${txtPassword.text}&type=$passwordType&Comid=${objfun.Comid}",
                                    null,
                                    null,
                                    context)
                                    .then((resultData) async {
                                  if (resultData.length != 0) {
                                    if (resultData["IsSuccess"] == true) {
                                      //Navigator.of(context).pop();
                                      txtPassword.text = "";
                                      await OnlineApi.EditSalesOrder(
                                          context, Id, SaleOrderNo);
                                      List<SaleEditDetailModel>
                                      SaleDetailsList =
                                          objfun.SaleEditDetailList;
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SalesOrderAdd(
                                                    SaleDetails: objfun
                                                        .SaleEditDetailList,
                                                    SaleMaster: objfun
                                                        .SaleEditMasterList,
                                                  )));
                                    } else {

                                      txtPassword.text = "";
                                      objfun.ConfirmationOK(
                                          "Invalid Password !!!", context);
                                    }
                                  } else {

                                    txtPassword.text = "";
                                    objfun.ConfirmationOK(
                                        "Invalid Password !!!", context);
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
                              } else {
                                objfun.ConfirmationOK(
                                    "Enter Password !!", context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: colour.commonColor),
                            child: Text(
                              'Ok',
                              style: GoogleFonts.lato(
                                  textStyle:TextStyle(
                                      fontSize: objfun.FontMedium,
                                      color: colour.commonColorLight)),
                            ),
                          ),
                        ],
                      ),
                    ]),
                  ])));
        });
  }

  late File ff;
  bool show = false;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return objfun.MalevaScreen == 1
        ? mobiledesign(this, context)
        : tabletdesign(this, context);
  }
}
