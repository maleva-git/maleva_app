import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/Transaction/Planning/PlanningView.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;

import 'package:maleva/menu/menulist.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;

import '../../MasterSearch/Employee.dart';
import '../../MasterSearch/Port.dart';

class PlanningAdd extends StatefulWidget {
  final List<SaleEditDetailModel>? SaleDetails;
  final List<dynamic>? SaleMaster;
  const PlanningAdd({super.key, this.SaleDetails, this.SaleMaster});

  @override
  _PlanningAddState createState() => _PlanningAddState();
}

class _PlanningAddState extends State<PlanningAdd> {
  bool progress = false;
  late MenuMasterModel menuControl;
  String UserName = objfun.storagenew.getString('Username') ?? "";
  int EmpId = 0;
  String dtpPlanningdate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  String dtpPickUpdate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  String dtpTodate = DateFormat("yyyy-MM-dd").format(DateTime.now());

  final txtRemarks = TextEditingController();
  final txtSearch = TextEditingController();
  final txtPlanningNo = TextEditingController();
  final txtEmployee = TextEditingController();
  final txtPort = TextEditingController();

  @override
  void initState() {
    startup();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future startup() async {
    setState(() {
      progress = true;
    });
    loaddata();
  }

  Future loaddata() async {}

  Column loadgridheader() {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Text(
                  "SNo",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: colour.ButtonForeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: objfun.FontLow,
                        letterSpacing: 0.3),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "Code",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: colour.ButtonForeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: objfun.FontLow,
                        letterSpacing: 0.3),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  "Description",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: colour.ButtonForeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: objfun.FontLow,
                        letterSpacing: 0.3),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Text(
                  "Qty",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: colour.ButtonForeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: objfun.FontLow,
                        letterSpacing: 0.3),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "SaleRate",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: colour.ButtonForeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: objfun.FontLow,
                        letterSpacing: 0.3),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  "GST",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: colour.ButtonForeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: objfun.FontLow,
                        letterSpacing: 0.3),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
            flex: 1,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: Text(
                    "Amount",
                    textAlign: TextAlign.left,
                    style: GoogleFonts.lato(
                      textStyle: TextStyle(
                          color: colour.ButtonForeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: objfun.FontLow,
                          letterSpacing: 0.3),
                    ),
                  ),
                ),
                const Expanded(flex: 2, child: Text(""))
              ],
            )),
      ],
    );
  }

  Future SaveSalesOrder() async {}

  Future<bool> _onBackPressed() async {
    bool result = await objfun.ConfirmationMsgYesNo(
        context, "Are you Sure you want to Exit?");
    if (result == true) {
      if (Platform.isAndroid) {
        Navigator.of(context).pop();
      } else if (Platform.isIOS) {
        exit(0);
      }
    } else {
      return false;
      // Navigator.of(context).pop();
    }

    return result;
  }

  Future<void> _showDialogFilter(BuildContext context) async {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    showModalBottomSheet(
      context: context,
      //isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(55.0),
        ),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
              // height: 700,
              /*padding:
              EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 10),*/
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.only(
                top: 16.0,
                left: 16.0,
                right: 16.0,
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  // mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const SizedBox(
                          width: 7,
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            "Job No :",
                            style: TextStyle(
                                fontSize: objfun.FontLow,
                                fontWeight: FontWeight.bold,
                                color: colour.commonColor),
                          ),
                        ),
                        Expanded(
                            flex: 2,
                            child: Container(
                              height: 50,
                              padding: const EdgeInsets.only(left: 8),
                              margin:
                                  const EdgeInsets.only(left: 5, right: 5.0),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: colour.commonColorLight,
                                  border: Border.all()),
                              child: TextField(
                                cursorColor: colour.commonColor,
                                controller: txtPlanningNo,
                                autofocus: true,
                                showCursor: true,
                                enabled: false,
                                textInputAction: TextInputAction.done,
                                textCapitalization:
                                    TextCapitalization.characters,
                                style: GoogleFonts.lato(
                                  textStyle: TextStyle(
                                      color: colour.commonColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: objfun.FontLow - 2,
                                      letterSpacing: 0.3),
                                ),
                              ),
                            )),
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: 50,
                            padding:
                                const EdgeInsets.only(left: 10.0, right: 5.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: colour.commonColorLight,
                                border: Border.all()),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Text(
                                    width <= 370
                                        ? DateFormat("dd-MM-yy").format(
                                            DateTime.parse(
                                                dtpPlanningdate.toString()))
                                        : DateFormat("dd-MM-yyyy").format(
                                            DateTime.parse(
                                                dtpPlanningdate.toString())),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: objfun.FontLow,
                                        color: colour.commonColor),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: InkWell(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: objfun.calendar
                                            // fit: BoxFit.fitWidth,
                                            ),
                                      ),
                                    ),
                                    onTap: () {
                                      showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(1900),
                                              lastDate: DateTime(2050))
                                          .then((value) {
                                        setState(() {
                                          var datenew =
                                              DateTime.parse(value.toString());
                                          dtpPlanningdate =
                                              DateFormat("yyyy-MM-dd")
                                                  .format(datenew);
                                        });
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 7,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            "PickUp Date:",
                            style: TextStyle(
                                fontSize: objfun.FontLow,
                                fontWeight: FontWeight.bold,
                                color: colour.commonColor),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: 50,
                            padding:
                                const EdgeInsets.only(left: 10.0, right: 5.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: colour.commonColorLight,
                                border: Border.all()),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Text(
                                    width <= 370
                                        ? DateFormat("dd-MM-yy").format(
                                            DateTime.parse(
                                                dtpPickUpdate.toString()))
                                        : DateFormat("dd-MM-yyyy").format(
                                            DateTime.parse(
                                                dtpPickUpdate.toString())),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: objfun.FontLow,
                                        color: colour.commonColor),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: InkWell(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: objfun.calendar
                                            // fit: BoxFit.fitWidth,
                                            ),
                                      ),
                                    ),
                                    onTap: () {
                                      showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(1900),
                                              lastDate: DateTime(2050))
                                          .then((value) {
                                        setState(() {
                                          var datenew =
                                              DateTime.parse(value.toString());
                                          dtpPickUpdate =
                                              DateFormat("yyyy-MM-dd")
                                                  .format(datenew);
                                        });
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            "To Date:",
                            style: TextStyle(
                                fontSize: objfun.FontLow,
                                fontWeight: FontWeight.bold,
                                color: colour.commonColor),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: 50,
                            padding:
                                const EdgeInsets.only(left: 10.0, right: 5.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: colour.commonColorLight,
                                border: Border.all()),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Text(
                                    width <= 370
                                        ? DateFormat("dd-MM-yy").format(
                                            DateTime.parse(
                                                dtpTodate.toString()))
                                        : DateFormat("dd-MM-yyyy").format(
                                            DateTime.parse(
                                                dtpTodate.toString())),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: objfun.FontLow,
                                        color: colour.commonColor),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: InkWell(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: objfun.calendar
                                            // fit: BoxFit.fitWidth,
                                            ),
                                      ),
                                    ),
                                    onTap: () {
                                      showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(1900),
                                              lastDate: DateTime(2050))
                                          .then((value) {
                                        setState(() {
                                          var datenew =
                                              DateTime.parse(value.toString());
                                          dtpTodate = DateFormat("yyyy-MM-dd")
                                              .format(datenew);
                                        });
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      width: objfun.SizeConfig.safeBlockHorizontal * 99,
                      height: objfun.SizeConfig.safeBlockVertical * 7,
                      alignment: Alignment.topCenter,
                      padding: const EdgeInsets.only(bottom: 5),
                      child: TextField(
                        textCapitalization: TextCapitalization.characters,
                        controller: txtEmployee,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.name,
                        readOnly: true,
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                              color: colour.commonColor,
                              fontWeight: FontWeight.bold,
                              fontSize: objfun.FontLow,
                              letterSpacing: 0.3),
                        ),
                        decoration: InputDecoration(
                          hintText: "Select Employee",
                          hintStyle: TextStyle(
                              fontSize: objfun.FontLow,
                              fontWeight: FontWeight.bold,
                              color: colour.commonColorLight),
                          suffixIcon: InkWell(
                              child: Icon(
                                  (txtEmployee.text.isNotEmpty)
                                      ? Icons.close
                                      : Icons.search_rounded,
                                  color: colour.commonColorred,
                                  size: 30.0),
                              onTap: () async {
                                await OnlineApi.SelectEmployee(
                                    context, 'sales', 'admin');
                                if (txtEmployee.text == "") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Employee(
                                            Searchby: 1, SearchId: 0)),
                                  ).then((dynamic value) async {
                                    setState(() {
                                      txtEmployee.text =
                                          objfun.SelectEmployeeList.AccountName;
                                      EmpId = objfun.SelectEmployeeList.Id;
                                      objfun.SelectEmployeeList =
                                          EmployeeModel.Empty();
                                    });
                                  });
                                } else {
                                  setState(() {
                                    txtEmployee.text = "";
                                    EmpId = 0;
                                    objfun.SelectEmployeeList =
                                        EmployeeModel.Empty();
                                  });
                                }
                              }),
                          fillColor: Colors.black,
                          enabledBorder: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: colour.commonColor),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(color: colour.commonColorred),
                          ),
                          contentPadding:
                              const EdgeInsets.only(left: 10, right: 20, top: 10.0),
                        ),
                      ),
                    ),
                    Container(
                      width: objfun.SizeConfig.safeBlockHorizontal * 99,
                      height: objfun.SizeConfig.safeBlockVertical * 7,
                      alignment: Alignment.topCenter,
                      padding: const EdgeInsets.only(bottom: 5),
                      child: TextField(
                        textCapitalization: TextCapitalization.characters,
                        controller: txtPort,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.name,
                        readOnly: true,
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                              color: colour.commonColor,
                              fontWeight: FontWeight.bold,
                              fontSize: objfun.FontLow,
                              letterSpacing: 0.3),
                        ),
                        decoration: InputDecoration(
                          hintText: "Port",
                          hintStyle: TextStyle(
                              fontSize: objfun.FontMedium,
                              fontWeight: FontWeight.bold,
                              color: colour.commonColorLight),
                          suffixIcon: InkWell(
                              child: Icon(
                                  (txtPort.text.isNotEmpty)
                                      ? Icons.close
                                      : Icons.search_rounded,
                                  color: colour.commonColorred,
                                  size: 30.0),
                              onTap: () {
                                setState(() {
                                  if (txtPort.text == "") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const Port(
                                              Searchby: 1, SearchId: 0)),
                                    ).then((dynamic value) async {
                                      setState(() {
                                        txtPort.text = objfun.SelectedPortName;
                                        objfun.SelectedPortName = "";
                                      });
                                    });
                                  } else {
                                    setState(() {
                                      txtPort.text = "";
                                      objfun.SelectedPortName = "";
                                    });
                                  }
                                });
                              }),
                          fillColor: Colors.black,
                          enabledBorder: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: colour.commonColor),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(color: colour.commonColorred),
                          ),
                          contentPadding: const EdgeInsets.only(
                              left: 10, right: 20, top: 10.0),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.search_outlined,
                              size: 35,
                              color: colour.commonColor,
                            )),
                        const SizedBox(
                          width: 7,
                        ),
                        IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.refresh,
                              size: 35,
                              color: colour.commonColor,
                            )),
                        const SizedBox(
                          width: 7,
                        ),
                        IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.add_box_outlined,
                              size: 35,
                              color: colour.commonColor,
                            )),
                      ],
                    ),
                    SizedBox(
                      height: height * 0.10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: TextField(
                              cursorColor: colour.commonColor,
                              controller: txtSearch,
                              maxLines: null, // Set this
                              expands: true, // and this
                              keyboardType: TextInputType.multiline,
                              autofocus: false,
                              showCursor: true,
                              decoration: InputDecoration(
                                hintText: ('Search'),
                                hintStyle: TextStyle(
                                    fontSize: objfun.FontMedium,
                                    fontWeight: FontWeight.bold,
                                    color: colour.commonColorLight),
                                fillColor: colour.commonColor,
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide:
                                      BorderSide(color: colour.commonColor),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide:
                                      BorderSide(color: colour.commonColorred),
                                ),
                                contentPadding: const EdgeInsets.only(
                                    left: 10, right: 20, top: 10.0),
                              ),

                              textInputAction: TextInputAction.done,

                              textCapitalization: TextCapitalization.characters,
                              style: GoogleFonts.lato(
                                textStyle: TextStyle(
                                    color: colour.commonColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: objfun.FontLow,
                                    letterSpacing: 0.3),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    SizedBox(
                      height: height * 0.08,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: TextField(
                              cursorColor: colour.commonColor,
                              controller: txtRemarks,
                              maxLines: null, // Set this
                              expands: true, // and this
                              keyboardType: TextInputType.text,
                              autofocus: false,
                              showCursor: true,
                              decoration: InputDecoration(
                                hintText: ('Remarks'),
                                hintStyle: TextStyle(
                                    fontSize: objfun.FontMedium,
                                    fontWeight: FontWeight.bold,
                                    color: colour.commonColorLight),
                                fillColor: colour.commonColor,
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide:
                                      BorderSide(color: colour.commonColor),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide:
                                      BorderSide(color: colour.commonColorred),
                                ),
                                contentPadding: const EdgeInsets.only(
                                    left: 10, right: 20, top: 10.0),
                              ),

                              textInputAction: TextInputAction.done,
                              textCapitalization: TextCapitalization.characters,
                              style: GoogleFonts.lato(
                                textStyle: TextStyle(
                                    color: colour.commonColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: objfun.FontLow,
                                    letterSpacing: 0.3),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              loaddata();
                            });
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'View',
                            style: TextStyle(fontSize: objfun.FontMedium),
                          ),
                        ),
                        const SizedBox(width: 7),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Close',
                            style: TextStyle(fontSize: objfun.FontMedium),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ));
        });
      },
    );
  }

  late File ff;
  bool show = false;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.white,
          appBar: AppBar(
            automaticallyImplyLeading: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Expanded(
              flex: 2,
              child: SizedBox(
                height: height * 0.05,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        flex: 1,
                        child: Text('Planning',
                            style: TextStyle(
                              color: colour.topAppBarColor,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Alatsi',
                              fontSize: objfun.FontMedium,
                            ))),
                    Expanded(
                      flex: 1,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(UserName,
                                style: TextStyle(
                                  color: colour.commonColorLight,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Alatsi',
                                  fontSize: objfun.FontLow - 2,
                                )),
                          ]),
                    ),
                  ],
                ),
              ),
            ),
            iconTheme: const IconThemeData(color: colour.topAppBarColor),
            actions: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.only(top: 7.0, bottom: 7.0, left: 7.0),
                child: SizedBox(
                  width: 70,
                  height: 25,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colour.commonColorLight,
                      side: const BorderSide(
                          color: colour.commonColor,
                          width: 1,
                          style: BorderStyle.solid),
                      textStyle: const TextStyle(color: Colors.black),
                      elevation: 20.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.all(4.0),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PlanningView()));
                    },
                    child: Text(
                      'VIEW',
                      style: GoogleFonts.karla(
                          fontSize: objfun.FontMedium,
                          // height: 1.45,
                          fontWeight: FontWeight.bold,
                          color: colour.commonColor),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(7.0),
                child: SizedBox(
                  width: 70,
                  height: 25,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colour.commonColorLight,
                      side: const BorderSide(
                          color: colour.commonColor,
                          width: 1,
                          style: BorderStyle.solid),
                      textStyle: const TextStyle(color: Colors.black),
                      elevation: 20.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.all(4.0),
                    ),
                    onPressed: () {
                      SaveSalesOrder();
                    },
                    child: Text(
                      'SAVE',
                      style: GoogleFonts.karla(
                          fontSize: objfun.FontMedium,
                          // height: 1.45,
                          fontWeight: FontWeight.bold,
                          color: colour.commonColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
          drawer: const Menulist(),
          body: progress == false
              ? const Center(
                  child: SpinKitFoldingCube(
                    color: colour.spinKitColor,
                    size: 35.0,
                  ),
                )
              : Padding(
                  padding:
                      const EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
                  child: ListView(
                    children: <Widget>[
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colour.commonColorLight,
                                side: const BorderSide(
                                    color: colour.commonColor,
                                    width: 1,
                                    style: BorderStyle.solid),
                                textStyle: const TextStyle(color: Colors.black),
                                elevation: 20.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                padding: const EdgeInsets.all(4.0),
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const PlanningView()));
                              },
                              child: Text(
                                'SORT',
                                style: GoogleFonts.karla(
                                    fontSize: objfun.FontMedium,
                                    // height: 1.45,
                                    fontWeight: FontWeight.bold,
                                    color: colour.commonColor),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 7,
                          ),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colour.commonColorLight,
                                side: const BorderSide(
                                    color: colour.commonColor,
                                    width: 1,
                                    style: BorderStyle.solid),
                                textStyle: const TextStyle(color: Colors.black),
                                elevation: 20.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                padding: const EdgeInsets.all(4.0),
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const PlanningView()));
                              },
                              child: Text(
                                'PUSH TO RTI',
                                style: GoogleFonts.karla(
                                    fontSize: objfun.FontMedium,
                                    // height: 1.45,
                                    fontWeight: FontWeight.bold,
                                    color: colour.commonColor),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _showDialogFilter(context);
            },
            tooltip: 'Open filter',
            child: const Icon(Icons.filter_alt_outlined),
          ),
        ));
  }
}
