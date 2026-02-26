import 'dart:async';
import 'dart:io';

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
import '../../DashBoard/Admin/AdminDashboard.dart';
import '../../DashBoard/CustomerService/CustDashboard.dart';
import '../../DashBoard/OperationAdmin/OperationAdminDashboard.dart';
import '../../DashBoard/TransportDB/TransportDashboard.dart';
import '../../MasterSearch/Customer.dart';
import '../../MasterSearch/Employee.dart';
import '../../MasterSearch/JobType.dart';
import '../SaleOrder/SalesOrderAdd.dart';
import 'AddEnquiryTR.dart';


part 'package:maleva/Transaction/EnquiryTR/mobileEnquiryTRView.dart';
part 'package:maleva/Transaction/EnquiryTR/tabletEnquiryTRView.dart';

class EnquiryTRView extends StatefulWidget {
  const EnquiryTRView({super.key});

  @override
  EnquiryTRViewState createState() => EnquiryTRViewState();
}

class EnquiryTRViewState extends State<EnquiryTRView> {
  bool progress = false;

  int EmpId = 0;
  int CustId = 0;
  int JobId = 0;
  int EditId = 0;
  int _currentlyVisibleIndex = -1;
  bool checkBoxValueLEmp = true;
  bool checkBoxValueEnq = false;
  bool completestatusnotshow = false;
  late List<bool> VisiblePlanningDetails;
  String dtpToDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  String dtpFromDate = DateFormat("yyyy-MM-dd").format(DateTime.now());

  final txtPlanningNo = TextEditingController();
  final txtEmployee = TextEditingController();
  final txtPassword = TextEditingController();
  final txtCustomer = TextEditingController();
  final txtJobType = TextEditingController();

  List<dynamic> PlanningDetailedList = [];
  String UserName = objfun.storagenew.getString('Username') ?? "";

  @override
  void initState() {
    VisiblePlanningDetails = List<bool>.filled(10, false);
    startup();
    super.initState();
  }

  @override
  void dispose() {
    txtPlanningNo.dispose();
    txtEmployee.dispose();
    txtPassword.dispose();
    txtCustomer.dispose();
    txtJobType.dispose();
    super.dispose();
  }

  Future startup() async {
    await OnlineApi.SelectEmployee(context, 'Sales', '');
    await OnlineApi.SelectCustomer(context);
    loaddata(false);
    setState(() {
      progress = true;
    });
  }

  Future loaddata(bool val) async {
    setState(() {
      progress = false;
    });
    var LEmpRefId = 0;
    if(checkBoxValueLEmp){
      LEmpRefId = objfun.EmpRefId;
    }
    else{
      LEmpRefId = EmpId;
    }
    Map<String, dynamic> master = {
      "Comid": objfun.storagenew.getInt('Comid') ?? 0,
      "Fromdate": val ? dtpFromDate : null,
      "Todate":val ?  dtpToDate : null,
      "Employeeid": LEmpRefId,
      "Invoice": checkBoxValueEnq,
      "Id": CustId,
      "JId": JobId,
     // "DashboardStatus": type,
    };

    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    await objfun
        .apiAllinoneSelectArray(
            objfun.apiSelectEnquiryMaster, master, header, context)
        .then((resultData) async {
      if (resultData != "") {
        setState(() {
          progress = true;
        });
        if (resultData.length != 0) {
          objfun.EnquiryMasterList = resultData;
          for(var i = 0;i<objfun.EnquiryMasterList.length;i++){
            if(objfun.EnquiryMasterList[i]["ForwardingDate"] == null){
              objfun.EnquiryMasterList[i]["SForwardingDate"] = "";
            }
            else{
              objfun.EnquiryMasterList[i]["SForwardingDate"] = DateFormat(
                  'dd-MM-yyyy HH:mm')
                  .format(DateTime.parse(
                  objfun.EnquiryMasterList[i]
                  ["ForwardingDate"]));
            }
          }
          //objfun.PlanningDetailsList = resultData[0]["saledetails"].toList();
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
  Future<void> _showDialogEnqDetails(Map detailsList) async {
    var CollectionDate = "";
    var DeliveryDate = "";

    if(detailsList["SPickupDate"] != ""){
      CollectionDate = DateFormat('dd-MM-yyyy HH:mm').format(DateTime.parse(detailsList["PickupDate"])).toString();
    }
    if(detailsList["SDeliveryDate"] != ""){
      DeliveryDate = DateFormat('dd-MM-yyyy HH:mm').format(DateTime.parse(detailsList["DeliveryDate"])).toString();
    }

    await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              elevation: 40.0,
              child: Container(
                  width: 200,
                  height: 450,
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
                        Text("Customer Name : ${detailsList["CustomerName"]}",style:GoogleFonts
                            .lato(
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colour
                                  .commonColor,
                            )),),
                        Text("Job Type : ${detailsList["JobType"]}",style:GoogleFonts
                            .lato(
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colour
                                  .commonColor,
                            )),),
                        Text("Notify Date : ${detailsList["SForwardingDate"]}",style:GoogleFonts
                            .lato(
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colour
                                  .commonColor,
                            )),),
                        Text("Collection Date : $CollectionDate",
                            style:GoogleFonts.lato(
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colour
                                      .commonColor,
                                ))),
                        Text("Delivery Date : $DeliveryDate",
                            style:GoogleFonts.lato(
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colour
                                      .commonColor,
                                ))),
                        Text("Origin : ${detailsList["Origin"]}",style:GoogleFonts
                            .lato(
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colour
                                  .commonColor,
                            )),),
                        Text("Destination : ${detailsList["Destination"]}",style:GoogleFonts
                            .lato(
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colour
                                  .commonColor,
                            )),),

                        Text("Quantity : ${detailsList["Quantity"]}",style:GoogleFonts
                            .lato(
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colour
                                  .commonColor,
                            )),),
                        Text("Weight : ${detailsList["TotalWeight"]}",style:GoogleFonts
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
  Future CancelEnquiry(int Id) async {
    setState(() {
      progress = false;
    });


    var Comid = objfun.storagenew.getInt('Comid') ?? 0;
    var Status = "CANCEL";
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    await objfun
        .apiAllinoneSelectArray(
        "${objfun.apiUpdateEnquiryMaster}$Id&Comid=$Comid&StatusName=$Status", null, header, context)
        .then((resultData) async {
      if (resultData != "") {
        loaddata(false);
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
  Future _sharePlanning( int Id ,String PlanningNo) async {

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
        "${objfun.apiViewPlanningPdf}$PlanningNo",
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
  Color? _CardColor(int index) {

    if(objfun.EnquiryMasterList[index]["ForwardingDate"] == null){
      return null;
    }
    DateTime currentDate = DateTime.now();
    DateTime nextDay = currentDate.add(const Duration(days: 1));
    String formattedDate1 = DateFormat('yyyy-MM-dd').format(currentDate);
    String formattedDate2 = DateFormat('yyyy-MM-dd').format(nextDay);
    var notifyDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(objfun.EnquiryMasterList[index]["ForwardingDate"]));
    if (notifyDate == formattedDate1 || DateTime.parse(objfun.EnquiryMasterList[index]["ForwardingDate"]).isBefore(currentDate) ) {
      return Colors.redAccent.withOpacity(0.3);
    }
    else if (notifyDate == formattedDate2) {
      return Colors.yellowAccent.withOpacity(0.3);
    }
    else {
      return null;
    }
  }

  Future<void> _showDialogPassword(int type, int Id, int PlanningNo) async {
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
                                    hintStyle:GoogleFonts
                                        .lato(
                                      textStyle: TextStyle(
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
                                      txtPassword.text = "";
                                      await OnlineApi.EditPlanning(
                                           context, Id, PlanningNo);
                                      // Navigator.push(
                                      //     context, MaterialPageRoute(builder: (context) => PlanningDetailsView()));
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
                              style: GoogleFonts
                                  .lato(
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
