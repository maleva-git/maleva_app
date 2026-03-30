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
import '../../MasterSearch/Employee.dart';
import 'VesselPlanningDetails.dart';
part 'package:maleva/Transaction/VesselPlanning/mobileVesselPlanningView.dart';
part 'package:maleva/Transaction/VesselPlanning/tabletVesselPlanningView.dart';
class VesselPlanningView extends StatefulWidget {
  const VesselPlanningView({super.key});

  @override
  VesselPlanningViewState createState() => VesselPlanningViewState();
}

class VesselPlanningViewState extends State<VesselPlanningView> {
  bool progress = false;

  int EmpId = 0;
  int EditId = 0;
  int _currentlyVisibleIndex = -1;
  bool checkBoxValueLEmp = true;
  bool completestatusnotshow = false;
  late List<bool> VisiblePlanningDetails;
  String dtpToDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  String dtpFromDate = DateFormat("yyyy-MM-dd").format(DateTime.now());

  final txtPlanningNo = TextEditingController();
  final txtEmployee = TextEditingController();
  final txtPassword = TextEditingController();
  List<dynamic> VesselPlanningDetailedList = [];
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
      LEmpRefId = EmpId;
    }
    Map<String, dynamic> master = {
      "Comid": objfun.storagenew.getInt('Comid') ?? 0,
      "Fromdate": dtpFromDate,
      "Todate": dtpToDate,
      "Employeeid": LEmpRefId,
      "Search": txtPlanningNo.text
    };

    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    await objfun
        .apiAllinoneSelectArray(
        objfun.apiSelectVesselPlanning, master, header, context)
        .then((resultData) async {
      if (resultData != "") {
        setState(() {
          progress = true;
        });
        if (resultData.length != 0) {
          objfun.VesselPlanningMasterList = resultData[0]["salemaster"]
              .map((element) => VesselPlanningMasterModel.fromJson(element))
              .toList();
          objfun.VesselPlanningDetailsList = resultData[0]["saledetails"].toList();
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

  Future _shareVesselPlanning( int Id ,String VesselPlanningNo) async {

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
        "${objfun.apiViewVesselPlanningPdf}$VesselPlanningNo",
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
                                      await OnlineApi.EditVesselPlanning(
                                          context, Id, PlanningNo);
                                      Navigator.push(
                                          context, MaterialPageRoute(builder: (context) => const VesselPlanningDetailsView()));
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
