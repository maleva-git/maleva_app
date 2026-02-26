import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import '../core/bluetooth/bluetoothmanager.dart';
import '../MasterSearch/Customer.dart';
import '../MasterSearch/Employee.dart';
import '../MasterSearch/JobStatus.dart';
import '../Transaction/SaleOrder/SalesOrderAdd.dart';
import '../menu/menulist.dart';
import '../core/models/model.dart';

class Saleorderview extends StatefulWidget {
  const Saleorderview({super.key});

  @override
  State<Saleorderview> createState() => _SaleorderviewState();
}

class _SaleorderviewState extends State<Saleorderview> {
  List<bool> VisibleSaleDetails = List<bool>.filled(objfun.SaleOrderMasterList.length, false);
  bool checkBoxValueLEmp = objfun.storagenew.getString('RulesType') == "ADMIN" ? false : true;
  int CustId = 0;
  int EmpId = 0;
  int StatusId = 0;
  int EditId = 0;
  bool isSelected = false;

  final txtJobNo = TextEditingController();
  bool completestatusnotshow = false;
  String dtpToDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  String dtpFromDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  final txtLoadingVessel = TextEditingController();
  final txtOffVessal = TextEditingController();
  String ETAVal = "0";
  final txtCustomer = TextEditingController();
  final txtEmployee = TextEditingController();
  final txtStatus = TextEditingController();
  final txtPassword = TextEditingController();
  int _currentlyVisibleIndex = -1;
  List<dynamic> SaleDetailsList = [];
  String cls = "3";
  bool checkBoxValueETA = false;
  String ETARadioVal = "0";
  bool checkBoxValuePickUp = false;
  final double width =
      WidgetsBinding.instance.window.physicalSize.width /
          WidgetsBinding.instance.window.devicePixelRatio;

  final double height =
      WidgetsBinding.instance.window.physicalSize.height /
          WidgetsBinding.instance.window.devicePixelRatio;
  DateTime? fromDate;
  DateTime? toDate;
  bool progress = false;
  DateTime? LETA, LETB, OETA, OETB;
  @override
  void initState() {

    startup();
    super.initState();
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
      LEmpRefId = EmpId;
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
      'Statusid': StatusId,
      'completestatusnotshow': completestatusnotshow,
      'Search':
      txtJobNo.text.toString() != "" ? txtJobNo.text.toString() : null,
      'Offvesselname': txtOffVessal.text.toString() != ""
          ? txtOffVessal.text.toString()
          : null,
      'Loadingvesselname': txtLoadingVessel.text.toString() != ""
          ? txtLoadingVessel.text.toString()
          : null,
      'Remarks': cls,
      'Westport': 0,
      'ETA': checkBoxValueETA,
      'ETAType': ETARadioVal,
      'Pickup': checkBoxValuePickUp,
    };
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    await objfun
        .apiAllinoneSelectArray(
        objfun.apiSelectTVSaleOrder, master, header, context)
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


  Future<void> pickDate(Function(DateTime) onSelect) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onSelect(picked);
    }
  }
  void openPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Select Dates"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dateField("LETA", LETA, (v) {
                    setDialogState(() => LETA = v);
                  }),
                  _dateField("LETB", LETB, (v) {
                    setDialogState(() => LETB = v);
                  }),
                  _dateField("OETA", OETA, (v) {
                    setDialogState(() => OETA = v);
                  }),
                  _dateField("OETB", OETB, (v) {
                    setDialogState(() => OETB = v);
                  }),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // close dialog first
                    updateFunction();
                  },
                  child: const Text("Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _dateField(
      String label,
      DateTime? value,
      Function(DateTime) onSelect,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        controller: TextEditingController(
          text: value == null ? '' : value.toString().split(' ')[0],
        ),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: value ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            onSelect(picked);
          }
        },
      ),
    );
  }
  String formatDateTime(DateTime d) {
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} "
        "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}:00";
  }


  Future<void> updateFunction() async {
     final confirm = await objfun.ConfirmationMsgYesNo(
         context, 'Do you want to Update'
     );
     if (!confirm) return;
     final toSave = objfun.SaleOrderMasterList.where((e) => e.isETASelected).toList();
     
     if (toSave.isEmpty){
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text("Please Check any of the CheckBox"))
       );
       return;
     }

     for (int i = 0; i < toSave.length; i++) {
       toSave[i].SETA  = LETA  != null ? formatDateTime(LETA!)  : null;
       toSave[i].SETB  = LETB  != null ? formatDateTime(LETB!)  : null;
       toSave[i].SOETA = OETA  != null ? formatDateTime(OETA!) : null;
       toSave[i].SOETB = OETB  != null ? formatDateTime(OETB!) : null;
     }

     setState(() => progress = true);

     try {
       final header = {
         'Content-Type': 'application/json; charset=UTF-8',
         'Comid': (objfun.storagenew.getInt('Comid') ?? 0).toString(),
       };

       final payload = toSave.toList();
       final result = await objfun.apiAllinoneMapSelect(
         objfun.apiUpdateSaleOrderMaster,
         payload,
         header,
         context,
       );

       if (result != null && result['IsSuccess'] == true){
         await objfun.ConfirmationOK('Updated Successfully:\n$result', context);

       }
       else{
         objfun.msgshow(
           "Failed to save emails",
           '',
           Colors.white,
           Colors.red,
           null,
           18.0 - objfun.reducesize,
           objfun.tll,
           objfun.tgc,
           context,
           2,
         );
       }
     }
     catch (e,stack){
       objfun.msgshow(
         e.toString(),
         stack.toString(),
         Colors.white,
         Colors.red,
         null,
         18.0 - objfun.reducesize,
         objfun.tll,
         objfun.tgc,
         context,
         2,
       );
     }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: height * 0.05,
          child: Center(
            child: Text(
              'Dash Board',
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                  color: colour.topAppBarColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Alatsi',
                  fontSize: objfun.FontLarge,
                ),
              ),
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: colour.topAppBarColor),
        actions: <Widget>[

          /// Shipment
          IconButton(
            icon: const Icon(
              Icons.directions_boat_filled,
              size: 25.0,
              color: colour.topAppBarColor,
            ),
            onPressed: () {
              // already in Saleorderview → no need push again
            },
          ),

          /// Bluetooth
          IconButton(
            icon: const Icon(
              Icons.bluetooth_audio,
              size: 25.0,
              color: colour.topAppBarColor,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => Bluetoothpage()),
              );
            },
          ),

          /// Print
          IconButton(
            icon: const Icon(
              Icons.print,
              size: 25.0,
              color: colour.topAppBarColor,
            ),
            onPressed: () async {
              await objfun.printdata([
                BarcodePrintModel(
                  "MALEVA",
                  "SHIPNAME",
                  "SHIPNAME",
                  "B0005000",
                  "2025-05-04",
                  "WESTPORT",
                  "WESTPORT",
                  "(1/3)",
                )
              ]);
            },
          ),

          /// Logout
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

      /// REQUIRED body
      body: progress == false
          ? Center(
        child: SpinKitFoldingCube(
          color: colour.spinKitColor,
          size: 35.0,
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            /// 🔹 Top Date Selection Row
            Row(
              children: [
                // From Date
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3.0),
                    child: Text(
                      DateFormat("dd-MM-yy")
                          .format(DateTime.parse(dtpFromDate.toString())),
                      style: GoogleFonts.lato(
                        textStyle: TextStyle(
                            color: colour.commonColor,
                            fontWeight: FontWeight.bold,
                            fontSize: objfun.FontLow,
                            letterSpacing: 0.3),
                      ),
                    ),
                  ),
                ),
                // From Date Picker Button
                Expanded(
                  flex: 1,
                  child: IconButton(
                    icon: const Icon(
                      Icons.calendar_month_outlined,
                      size: 35,
                      color: colour.commonColor,
                    ),
                    onPressed: () async {
                      DateTime? value = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2050),
                      );
                      if (value != null) {
                        setState(() {
                          dtpFromDate =
                              DateFormat("yyyy-MM-dd").format(value);
                        });
                      }
                    },
                  ),
                ),

                const SizedBox(width: 5),

                // To Date
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3.0),
                    child: Text(
                      DateFormat("dd-MM-yy")
                          .format(DateTime.parse(dtpToDate.toString())),
                      style: GoogleFonts.lato(
                        textStyle: TextStyle(
                            color: colour.commonColor,
                            fontWeight: FontWeight.bold,
                            fontSize: objfun.FontLow,
                            letterSpacing: 0.3),
                      ),
                    ),
                  ),
                ),
                // To Date Picker Button
                Expanded(
                  flex: 1,
                  child: IconButton(
                    icon: const Icon(
                      Icons.calendar_month_outlined,
                      size: 35,
                      color: colour.commonColor,
                    ),
                    onPressed: () async {
                      DateTime? value = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2050),
                      );
                      if (value != null) {
                        setState(() {
                          dtpToDate =
                              DateFormat("yyyy-MM-dd").format(value);
                        });
                      }
                    },
                  ),
                ),

              ],
            ),
            const SizedBox(height: 8),
            /// 🔹 Action Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      loaddata();
                    });
                   /* Navigator.of(context).pop();*/
                  },
                  child: Text(
                    'View',
                    style: GoogleFonts.lato(
                        textStyle:
                        TextStyle(fontSize: objfun.FontMedium)),
                  ),
                ),
                const SizedBox(width: 7),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Close',
                    style: GoogleFonts.lato(
                        textStyle:
                        TextStyle(fontSize: objfun.FontMedium)),
                  ),
                ),
                const SizedBox(width: 7),
                ElevatedButton(
                  onPressed: () {
                    openPopup();
                  },
                  child: Text(
                    'Dates',
                    style: GoogleFonts.lato(
                        textStyle:
                        TextStyle(fontSize: objfun.FontMedium)),
                  ),
                ),
                const SizedBox(width: 7),
                ElevatedButton(
                  onPressed: () {
                    updateFunction();
                  },
                  child: Text(
                    'Update',
                    style: GoogleFonts.lato(
                        textStyle:
                        TextStyle(fontSize: objfun.FontMedium)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            /// 🔹 List of SaleOrder Cards
            Expanded(
              child: ListView.builder(
                itemCount: objfun.SaleOrderMasterList.length,
                itemBuilder: (context, index) {
                  return saleOrderCard(index);
                },
              ),
            ),
          ],
        ),
      ),


      /*  floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialogFilter(context);
        },
        tooltip: 'Open filter',
        child: const Icon(Icons.filter_alt_outlined),
      ),*/
    );
  }
  Future<void> showDialogFilter(BuildContext context) async {
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
                  height: 700,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding:
                                const EdgeInsets.only(left: 3.0, right: 3.0),
                                child: Text(
                                  "",
                                  style: GoogleFonts.lato(
                                    textStyle: const TextStyle(
                                        color: colour.commonColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.0,
                                        letterSpacing: 0.3),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding:
                                const EdgeInsets.only(left: 3.0, right: 3.0),
                                child: Text(
                                  DateFormat("dd-MM-yy").format(
                                      DateTime.parse(dtpFromDate.toString())),
                                  style: GoogleFonts.lato(
                                    textStyle: TextStyle(
                                        color: colour.commonColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: objfun.FontLow,
                                        letterSpacing: 0.3),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                  child: IconButton(
                                      icon: const Icon(
                                        Icons.calendar_month_outlined,
                                        size: 35,
                                        color: colour.commonColor,
                                      ),
                                      onPressed: () async {
                                        showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(1900),
                                            lastDate: DateTime(2050))
                                            .then((value) {
                                          value ??= DateTime.now();
                                          var datenew =
                                          DateTime.parse(value.toString());
                                          setState(() {
                                            dtpFromDate = DateFormat("yyyy-MM-dd")
                                                .format(datenew);
                                          });
                                        });
                                      })),
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding:
                                const EdgeInsets.only(left: 3.0, right: 3.0),
                                child: Text(
                                  "",
                                  style: GoogleFonts.lato(
                                    textStyle: const TextStyle(
                                        color: colour.commonColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.0,
                                        letterSpacing: 0.3),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding:
                                const EdgeInsets.only(left: 3.0, right: 3.0),
                                child: Text(
                                  DateFormat("dd-MM-yy")
                                      .format(DateTime.parse( dtpToDate.toString())),
                                  style: GoogleFonts.lato(
                                    textStyle: TextStyle(
                                        color: colour.commonColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: objfun.FontLow,
                                        letterSpacing: 0.3),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                  child: IconButton(
                                      icon: const Icon(
                                        Icons.calendar_month_outlined,
                                        size: 35,
                                        color: colour.commonColor,
                                      ),
                                      onPressed: () async {
                                        showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(1900),
                                            lastDate: DateTime(2050))
                                            .then((value) {
                                          value ??= DateTime.now();
                                          var datenew =
                                          DateTime.parse(value.toString());
                                          setState(() {
                                            dtpToDate = DateFormat("yyyy-MM-dd")
                                                .format(datenew);
                                          });
                                        });
                                      })),
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding:
                                const EdgeInsets.only(left: 3.0, right: 3.0),
                                child: Text(
                                  "",
                                  style: GoogleFonts.lato(
                                    textStyle: const TextStyle(
                                        color: colour.commonColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.0,
                                        letterSpacing: 0.3),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: objfun.SizeConfig.safeBlockHorizontal * 99,
                          height: objfun.SizeConfig.safeBlockVertical * 5,
                          alignment: Alignment.topCenter,
                          margin: const EdgeInsets.only(right: 5.0, left: 5.0),
                          padding: const EdgeInsets.only(bottom: 5),
                          child: TextField(
                            textCapitalization: TextCapitalization.characters,
                            controller:  txtCustomer,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.name,
                            readOnly: true,
                            maxLines: null,
                            expands: true,
                            style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                  color: colour.commonColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: objfun.FontLow,
                                  letterSpacing: 0.3),
                            ),
                            decoration: InputDecoration(
                              hintText: "Customer Name",
                              hintStyle:GoogleFonts.lato(
                                  textStyle: TextStyle(
                                      fontSize: objfun.FontLow,
                                      fontWeight: FontWeight.bold,
                                      color: colour.commonColorLight)),
                              suffixIcon: InkWell(
                                  child: Icon(
                                      ( txtCustomer.text.isNotEmpty)
                                          ? Icons.close
                                          : Icons.search_rounded,
                                      color: colour.commonColorred,
                                      size: 30.0),
                                  onTap: () {
                                    if ( txtCustomer.text == "") {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const Customer(
                                                Searchby: 1, SearchId: 0)),
                                      ).then((dynamic value) async {
                                        setState(() {
                                          txtCustomer.text =
                                              objfun.SelectCustomerList.AccountName;
                                          CustId = objfun.SelectCustomerList.Id;
                                          objfun.SelectCustomerList =
                                              CustomerModel.Empty();
                                        });
                                      });
                                    } else {
                                      setState(() {
                                        txtCustomer.text = "";
                                        CustId = 0;
                                        objfun.SelectCustomerList =
                                            CustomerModel.Empty();
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
                          height: objfun.SizeConfig.safeBlockVertical * 5,
                          alignment: Alignment.topCenter,
                          margin: const EdgeInsets.only(right: 5.0, left: 5.0),
                          padding: const EdgeInsets.only(bottom: 5),
                          child: TextField(
                            textCapitalization: TextCapitalization.characters,
                            controller:  txtEmployee,
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
                              hintStyle:GoogleFonts.lato(
                                  textStyle: TextStyle(
                                      fontSize: objfun.FontLow,
                                      fontWeight: FontWeight.bold,
                                      color: colour.commonColorLight)),
                              suffixIcon: InkWell(
                                  child: Icon(
                                      ( txtEmployee.text.isNotEmpty)
                                          ? Icons.close
                                          : Icons.search_rounded,
                                      color:  checkBoxValueLEmp
                                          ? colour.commonColorDisabled
                                          : colour.commonColorred,
                                      size: 30.0),
                                  onTap: () async {
                                    await OnlineApi.SelectEmployee(
                                        context, 'sales', 'admin');
                                    if ( txtEmployee.text == "" &&
                                        checkBoxValueLEmp != true) {
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
                          height: objfun.SizeConfig.safeBlockVertical * 5,
                          alignment: Alignment.topCenter,
                          margin: const EdgeInsets.only(right: 5.0, left: 5.0),
                          padding: const EdgeInsets.only(bottom: 5),
                          child: TextField(
                            textCapitalization: TextCapitalization.characters,
                            controller:  txtStatus,
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
                              hintText: "Select Status",
                              hintStyle:GoogleFonts.lato(
                                  textStyle: TextStyle(
                                      fontSize: objfun.FontLow,
                                      fontWeight: FontWeight.bold,
                                      color: colour.commonColorLight)),
                              suffixIcon: InkWell(
                                  child: Icon(
                                      ( txtStatus.text.isNotEmpty)
                                          ? Icons.close
                                          : Icons.search_rounded,
                                      color: colour.commonColorred,
                                      size: 30.0),
                                  onTap: () {
                                    if ( txtStatus.text == "") {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const JobStatus(
                                                Searchby: 1, SearchId: 0)),
                                      ).then((dynamic value) async {
                                        setState(() {
                                          txtStatus.text =
                                              objfun.SelectJobStatusList.Name;
                                          StatusId = objfun.SelectJobStatusList.Id;
                                          objfun.SelectJobStatusList =
                                              JobStatusModel.Empty();
                                        });
                                      });
                                    } else {
                                      setState(() {
                                        txtStatus.text = "";
                                        StatusId = 0;
                                        objfun.SelectJobStatusList =
                                            JobStatusModel.Empty();
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
                          height: objfun.SizeConfig.safeBlockVertical * 5,
                          alignment: Alignment.topCenter,
                          margin: const EdgeInsets.only(right: 5.0, left: 5.0),
                          padding: const EdgeInsets.only(bottom: 5),
                          child: TextField(
                            cursorColor: colour.commonColor,
                            controller:  txtJobNo,
                            autofocus: false,
                            showCursor: true,
                            decoration: InputDecoration(
                              hintText: ('Job No'),
                              hintStyle:GoogleFonts.lato(
                                  textStyle: TextStyle(
                                      fontSize: objfun.FontLow,
                                      fontWeight: FontWeight.bold,
                                      color: colour.commonColorLight)),
                              fillColor: colour.commonColor,
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
                        Container(
                          width: objfun.SizeConfig.safeBlockHorizontal * 99,
                          height: objfun.SizeConfig.safeBlockVertical * 5,
                          alignment: Alignment.topCenter,
                          margin: const EdgeInsets.only(right: 5.0, left: 5.0),
                          padding: const EdgeInsets.only(bottom: 5),
                          child: TextField(
                            cursorColor: colour.commonColor,
                            controller:  txtLoadingVessel,
                            autofocus: false,
                            showCursor: true,
                            decoration: InputDecoration(
                              hintText: ('Loading Vessel'),
                              hintStyle:GoogleFonts.lato(
                                  textStyle: TextStyle(
                                      fontSize: objfun.FontLow,
                                      fontWeight: FontWeight.bold,
                                      color: colour.commonColorLight)),
                              fillColor: colour.commonColor,
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
                        Container(
                          width: objfun.SizeConfig.safeBlockHorizontal * 99,
                          height: objfun.SizeConfig.safeBlockVertical * 5,
                          alignment: Alignment.topCenter,
                          margin: const EdgeInsets.only(right: 5.0, left: 5.0),
                          padding: const EdgeInsets.only(bottom: 5),
                          child: TextField(
                            cursorColor: colour.commonColor,
                            controller:  txtOffVessal,
                            autofocus: false,
                            showCursor: true,
                            decoration: InputDecoration(
                              hintText: ('Off Vessel'),
                              hintStyle: GoogleFonts.lato(
                                  textStyle:TextStyle(
                                      fontSize: objfun.FontLow,
                                      fontWeight: FontWeight.bold,
                                      color: colour.commonColorLight)),
                              fillColor: colour.commonColor,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Checkbox(
                                value:  checkBoxValuePickUp,
                                activeColor: colour.commonColorred,
                                onChanged: (bool? value) {
                                  setState(() {
                                    checkBoxValuePickUp = value!;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                  width: 120,
                                  // flex: 1,
                                  child: Text(
                                    'PickUp',
                                    style: GoogleFonts.lato(
                                      textStyle: TextStyle(
                                          color: colour.commonColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: objfun.FontMedium,
                                          letterSpacing: 0.3),
                                    ),
                                  )),
                            ),
                            Expanded(
                              flex: 1,
                              child: Checkbox(
                                value:  checkBoxValueLEmp,
                                activeColor: colour.commonColorred,
                                onChanged: (bool? value) {
                                  setState(() {
                                    checkBoxValueLEmp = value!;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                  width: 120,
                                  // flex: 1,
                                  child: Text(
                                    'L.Emp',
                                    style: GoogleFonts.lato(
                                      textStyle: TextStyle(
                                          color: colour.commonColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: objfun.FontMedium,
                                          letterSpacing: 0.3),
                                    ),
                                  )),
                            ),
                          ],
                        ),
                        Row(children: [
                          Expanded(
                            // width: 250,
                            flex: 1,
                            child: Radio(
                              value: "3",
                              groupValue:  cls,
                              onChanged: (value) {
                                setState(() {
                                  cls = value.toString();
                                });
                              },
                            ),
                          ),
                          Expanded(
                            // width: 250,
                            flex: 1,
                            child: Text(
                              "All",
                              style: GoogleFonts.lato(
                                  textStyle:TextStyle(
                                      color: colour.commonColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: objfun.FontMedium,
                                      letterSpacing: 0.3)),
                            ),
                          ),
                          Expanded(
                            // width: 250,
                            flex: 1,
                            child: Radio(
                              value: "2",
                              groupValue:  cls,
                              onChanged: (value) {
                                setState(() {
                                  cls = value.toString();
                                });
                              },
                            ),
                          ),
                          Expanded(
                            // width: 250,
                            flex: 2,
                            child: Text(
                              "WithOut",
                              style: GoogleFonts.lato(
                                  textStyle:TextStyle(
                                      color: colour.commonColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: objfun.FontMedium,
                                      letterSpacing: 0.3)),
                            ),
                          ),
                          Expanded(
                            // width: 250,
                            flex: 1,
                            child: Radio(
                              value: "1",
                              groupValue:  cls,
                              onChanged: (value) {
                                setState(() {
                                  cls = value.toString();
                                });
                              },
                            ),
                          ),
                          Expanded(
                            // width: 250,
                            flex: 1,
                            child: Text(
                              "With",
                              style: GoogleFonts.lato(
                                  textStyle:TextStyle(
                                      color: colour.commonColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: objfun.FontMedium,
                                      letterSpacing: 0.3)),
                            ),
                          ),
                        ]),
                        Row(children: [
                          Expanded(
                            // width: 250,
                            flex: 1,
                            child: Radio(
                              value: "1",
                              groupValue:  ETAVal,
                              onChanged: (value) {
                                setState(() {
                                  checkBoxValueETA = true;
                                  ETARadioVal = "1";
                                  ETAVal = value!;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            // width: 250,
                            flex: 1,
                            child: Text(
                              "OETA",
                              style:GoogleFonts.lato(
                                  textStyle: TextStyle(
                                      color: colour.commonColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: objfun.FontLow,
                                      letterSpacing: 0.3)),
                            ),
                          ),
                          Expanded(
                            // width: 250,
                            flex: 1,
                            child: Radio(
                              value: "2",
                              groupValue:  ETAVal,
                              onChanged: (value) {
                                setState(() {
                                  checkBoxValueETA = true;
                                  ETARadioVal = "2";
                                  ETAVal = value!;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            // width: 250,
                            flex: 1,
                            child: Text(
                              "LETA",
                              style: GoogleFonts.lato(
                                  textStyle:TextStyle(
                                      color: colour.commonColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: objfun.FontLow,
                                      letterSpacing: 0.3)),
                            ),
                          ),
                          Expanded(
                            // width: 250,
                            flex: 1,
                            child: Radio(
                              value: "3",
                              groupValue:  ETAVal,
                              onChanged: (value) {
                                setState(() {
                                  checkBoxValueETA = true;
                                  ETARadioVal = "O";
                                  ETAVal = value!;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            // width: 250,
                            flex: 1,
                            child: Text(
                              "All",
                              style:GoogleFonts.lato(
                                  textStyle: TextStyle(
                                      color: colour.commonColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: objfun.FontLow,
                                      letterSpacing: 0.3)),
                            ),
                          ),
                          Expanded(
                            // width: 250,
                            flex: 1,
                            child: Radio(
                              value: "0",
                              groupValue:  ETAVal,
                              onChanged: (value) {
                                setState(() {
                                  checkBoxValueETA = false;
                                  ETARadioVal = "O";
                                  ETAVal = value!;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            // width: 250,
                            flex: 1,
                            child: Text(
                              "None",
                              style: GoogleFonts.lato(
                                  textStyle:TextStyle(
                                      color: colour.commonColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: objfun.FontMedium,
                                      letterSpacing: 0.3)),
                            ),
                          ),
                        ]),
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
                                style:GoogleFonts.lato(
                                    textStyle: TextStyle(fontSize: objfun.FontMedium)),
                              ),
                            ),
                            const SizedBox(width: 7),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'Close',
                                style: GoogleFonts.lato(
                                    textStyle:TextStyle(fontSize: objfun.FontMedium)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ));
            });
      },
    );
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
  Widget saleOrderCard(int index) {
    final item = objfun.SaleOrderMasterList[index];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      padding: const EdgeInsets.all(4.0),
      height: _currentlyVisibleIndex == index ? height * 0.48 : height * 0.26,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            _currentlyVisibleIndex =
            _currentlyVisibleIndex == index ? -1 : index;
          });
        },
        onLongPress: () {
          setState(() {
            EditId = item.Id; // Option1: set EditId
          });
        },
        child: Card(
          elevation: 6,
          color: _CardColor(index),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: colour.commonColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView( // ✅ Scrollable content prevents overflow
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔹 Header: BillNo + JobStatus
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Checkbox(
                        value: item.isETASelected, // bool variable
                        onChanged: (value) {
                          setState(() {
                            item.isETASelected = value!;
                          });
                        },
                      ),

                      Expanded(
                        child: Text(
                          item.BillNoDisplay,
                          style: _titleStyle(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Chip(
                        label: Text(item.JobStatus),
                        backgroundColor:
                        colour.commonColor.withOpacity(0.15),
                        labelStyle: _chipStyle(),
                      )
                    ],
                  ),

                  const SizedBox(height: 6),

                  /// 🔹 Vessel
                  Text(
                    "${item.Loadingvesselname} → ${item.Offvesselname}",
                    style: _subTitleStyle(),
                  ),

                  const Divider(),

                  /// 🔹 Employee
                  Text(
                    "Employee: ${item.EmployeeName}",
                    style: _normalStyle(),
                  ),

                  const SizedBox(height: 6),

                  /// 🔹 SET Info
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      _infoChip("SETA", item.SETA),
                      _infoChip("SETB", item.SETB),
                      _infoChip("SOETA", item.SOETA),
                      _infoChip("SOETB", item.SOETB),
                    ],
                  ),

                  const SizedBox(height: 6),

                  /// 🔹 Route (always visible at bottom)
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          "${item.Origin} → ${item.Destination}",
                          style: _normalStyle(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),


                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  TextStyle _titleStyle() => GoogleFonts.lato(
    fontSize: objfun.FontCardText + 2,
    fontWeight: FontWeight.bold,
    color: colour.commonColor,
  );
  TextStyle _subTitleStyle() => GoogleFonts.lato(
    fontSize: objfun.FontCardText,
    fontWeight: FontWeight.w600,
  );
  TextStyle _normalStyle() => GoogleFonts.lato(
    fontSize: objfun.FontLow,
    fontWeight: FontWeight.w500,
  );
  TextStyle _chipStyle() => GoogleFonts.lato(
    fontSize: objfun.FontLow,
    fontWeight: FontWeight.bold,
    color: colour.commonColor,
  );
  Widget _infoChip(String label, String value) {
    return Chip(
      label: Text("$label: $value"),
      backgroundColor: Colors.grey.shade200,
    );
  }

}
