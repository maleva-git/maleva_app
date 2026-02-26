import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/menu/menulist.dart';
import 'package:maleva/core/models/model.dart';
import '../../core/bluetooth/bluetoothmanager.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:http/http.dart' as http;
import '../../SparePartsEntry/SparePartsViewPage.dart';
import '../../SummonEntry/SummonViewPage.dart';

part 'package:maleva/DashBoard/Driver/mobileDriverDashboard.dart';
part 'package:maleva/DashBoard/Driver/tabletDriverDashboard.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  DriverDashboardState createState() => DriverDashboardState();
}

class DriverDashboardState extends State<DriverDashboard> with TickerProviderStateMixin {
  bool progress = false;
  late MenuMasterModel menuControl;
  bool Is6Months = true;
  bool IsToday = true;
  bool IsPlanToday = true;
  bool Is6Months2 = true;
  bool Is6Months3 = true;
  bool FWReportview = false;
  DateTime now = DateTime.now();
  int monthIndex = 0;
  int withoutInvoiceCount = 0;
  int TotalCount = 0;
  int TotalBilledCount = 0;
  int TotalUnBilledCount = 0;
  int EmpId = 0;
  double SalaryAmount = 0.0;
  int DriverId = 0;
  int EditId = 0;
  static const List<String> DashBoardList = <String>['INV', 'SO', 'FW'];
  String? dropdownValueFW;

  String dtpToDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  String dtpFromDate = DateFormat("yyyy-MM-dd").format(DateTime.now());

  String RdtpToDate = DateFormat("yyyy-MM-dd").format(DateTime.now());

   // Months are 1-indexed
  String RdtpFromDate = DateFormat("yyyy-MM-dd")
      .format(DateTime.now().subtract(Duration(days: 1)));


  List <dynamic> SaleCustReport=[];
  List <dynamic> SaleTransReport=[];


  List<dynamic> DriverExpiryList = [];
  List<dynamic> DriverSalaryList = [];

  late TabController _tabmainController;

  final txtEmployee = TextEditingController();
  final txtPort = TextEditingController();
  final txtRemarks = TextEditingController();
  String? dropdownValueEMp;
  int TruckId = objfun.DriverTruckRefId ;
  var ExpDate = "";
  var ExpApadBonam = "";
  var ExpServiceAligmentGreece="";
  bool ischecked = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  List<dynamic> selectedDetails = [];
  final TextEditingController driverController = TextEditingController();
  final TextEditingController SummonTypeController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController PortPassController = TextEditingController();
  final TextEditingController TruckLcnMntController = TextEditingController();
  final TextEditingController LevyController = TextEditingController();
  final TextEditingController FuelController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final txtRTINo = TextEditingController();
  File? _pickedImage;
  File? _pickedPDF;
  List<RTIMasterViewModel> allRTIMasterList = [];
  List<RTIMasterViewModel> filteredRTIMasterList = [];

  final ImagePicker _picker = ImagePicker();
  String? selectedTruck; // Truck Id
  DateTime? selectedDate; // Selected Date

  // Calculate first & last day of current month
  DateTime? fromDate;
  DateTime? toDate;
  bool _isLoading = false;
  String selectedCountry = "Malaysia";
  String? selectedSummon;

  List<String> malaysiaList = ["MAJLIS", "JPJ", "PDRM (traffic)"];
  List<String> singaporeList = ["LTA", "POLICE", "URA"];

  @override
  void initState() {

    _tabmainController = TabController(vsync: this, length: 6);

    EmpId = objfun.EmpRefId;
    startup();
    super.initState();

  }

  Future startup() async {

    loadPlanningdata(0);
    setState(() {
      progress = true;
    });
  }


  Future loaddata() async {
    setState(() {
      progress = false;
    });
    var Employeeid = 0;

    if(objfun.DriverLogin == 1){
      DriverId = objfun.EmpRefId;
    }

    await OnlineApi.SelectRTIViewList(context, RdtpFromDate, RdtpToDate, DriverId, TruckId, Employeeid, txtRTINo.text);
    allRTIMasterList = List.from(objfun.RTIViewMasterList);
    filteredRTIMasterList = List.from(allRTIMasterList);

    setState(() {
      progress = true;
    });
  }
  void searchRTI(String query) {
    if (query.isEmpty) {
      filteredRTIMasterList = allRTIMasterList;
    } else {
      filteredRTIMasterList = allRTIMasterList.where((item) {
        return item.RTINoDisplay
            .toLowerCase()
            .contains(query.toLowerCase()) ||
            item.DriverName
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            item.TruckName
                .toLowerCase()
                .contains(query.toLowerCase());
      }).toList();
    }

    setState(() {});
  }
  Future loadPlanningdata(int type) async {
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

    Map<String, dynamic> master = {};

    master = {

      'Comid': objfun.storagenew.getInt('Comid') ?? 0,
      'Fromdate': FromDate,
      'Todate': ToDate,
      'Search': '',
      'Employeeid': objfun.EmpRefId,
      'ETAType' : 0

    };
    await objfun
        .apiAllinoneSelectArray(
        objfun.PLANINGDriverSearch, master, header, context)
        .then((resultData) async {
      if (resultData != "") {
        setState(() {
          progress = true;
        });
        if (resultData.length != 0) {
          SaleTransReport=resultData;
        }

        else{
          SaleTransReport=[];
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
  Future<void> submitData(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      var Comid = objfun.storagenew.getInt('Comid') ?? 0;

      // Prepare JSON part
      List<Map<String, dynamic>> sparePartsList = [
        {
          "Comid": Comid,
          "Id": 0,
          "TruckName": selectedTruck, // Send truck Id as string
          "DriverName": driverController.text.trim(),
          "Summon": selectedSummon,
          "PortPass": PortPassController.text.trim(),
          "TruckLcnMnt": TruckLcnMntController.text.trim(),
          "Levy": LevyController.text.trim(),
          "Fuel": FuelController.text.trim(),
          "Country": selectedCountry,
          "EntryDate": selectedDate == null
              ? DateFormat('yyyy-MM-dd').format(DateTime.now())
              : DateFormat('yyyy-MM-dd').format(selectedDate!),

          "Amount": amountController.text.trim(),
          "DocumentPath": ""
        }
      ];

      // API URL
      var uri = Uri.parse("${objfun.apiInsertSummonParts}?Comid=$Comid");

      // Create Multipart Request
      var request = http.MultipartRequest("POST", uri);

      // JSON → string
      request.fields["details"] = jsonEncode(sparePartsList);
      request.fields["Comid"] = Comid.toString();

      // Attach Image / PDF
      if (_pickedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath("Files", _pickedImage!.path),
        );
      }
      if (_pickedPDF != null) {
        request.files.add(
          await http.MultipartFile.fromPath("Files", _pickedPDF!.path),
        );
      }

      // Send request
      var response = await request.send();

      if (response.statusCode == 200) {
        var respStr = await response.stream.bytesToString();
        print("SUCCESS: $respStr");

        // Clear form
        setState(() {
          selectedTruck = null;
          selectedDate = null;
          selectedSummon = null;
          driverController.clear();
          SummonTypeController.clear();
          amountController.clear();
          dateController.clear();
          PortPassController.clear();
          TruckLcnMntController.clear();
          LevyController.clear();
          FuelController.clear();

          _pickedImage = null;
          _pickedPDF = null;
          _isLoading = false;
        });
      } else {
        print("FAILED: ${response.statusCode}");
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      setState(() {
        _isLoading = false;
      });
      objfun.msgshow(
        e.toString(),
        stackTrace.toString(),
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
  Future<void> loadTruckList() async {
    await OnlineApi.SelectTruckList(context, null);
    print("Truck Count: ${objfun.GetTruckList.length}");
    setState(() {}); // Refresh UI after list load
  }
  Future loadTruckdata() async {

    ExpDate = objfun.currentdate(objfun.commonexpirydays);
    ExpApadBonam = objfun.currentdate(objfun.apadbonamexpirydays);
    ExpServiceAligmentGreece = objfun.currentdate(objfun.ExpServiceAligmentGreecedays);
    Map<String, dynamic> master = {};
    master = {
      // 'Expdate':ExpDate,
      'Expdate':null,
      'ExpApadBonam':ExpApadBonam,
      'ExpServiceAligmentGreece': ExpServiceAligmentGreece,
      'Id':TruckId,
      'SFromDate':null,
      'Comid':objfun.Comid,
    };
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    await objfun
        .apiAllinoneSelectArray(
        objfun.apiSelectTruckDetails, master, header, context)
        .then((resultData) async {
      if (resultData != "") {
        if (resultData.length != 0) {
          objfun.TruckDetailsList = resultData
              .map((element) => TruckDetailsModel.fromJson(element))
              .toList().cast<TruckDetailsModel>();
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
  Future loadDriverdata() async {

    ExpDate = objfun.currentdate(objfun.commonexpirydays);

    Map<String, dynamic> master = {};

    master = {

      'ExpDate':"",
      'Id':objfun.EmpRefId,
      'SFromDate':null,
      'Comid':objfun.Comid,
    };
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    await objfun
        .apiAllinoneSelectArray(
        objfun.apiSelectDriverDetails, master, header, context)
        .then((resultData) async {
      if (resultData != "") {
        if (resultData.length != 0) {

          DriverExpiryList = resultData;

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
  Future loadSalaryData() async {


    Map<String, dynamic> master = {};

    master = {
      'Comid': objfun.Comid,
      'DriverId': objfun.EmpRefId,
      'TruckId': 0,
      'FromDate': dtpFromDate,
      'ToDate': dtpToDate,
      'DriverName': '',
      'TruckName': '',
    };
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    await objfun
        .apiAllinoneSelectArrayWithOutAuth(
        objfun.apiSelectDriverSalary, master, header, context)
        .then((resultData) async {
      if (resultData != "")
      {
        ResponseViewModel? value = ResponseViewModel.fromJson(resultData);
        if (value.IsSuccess == true && value.data1 != null && value.data1.length != 0 ) {

          DriverSalaryList = value.data1;
          var salarySum = 0.0;
          for(var i = 0 ; i < DriverSalaryList.length ; i++){
            salarySum = salarySum + DriverSalaryList[i]["Amount"];
          }
        SalaryAmount = salarySum;
        }
        else{
          DriverSalaryList = [];
          SalaryAmount = 0.0;
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
  Color _ExpColor(String LicenseDate ) {
    DateFormat dateFormat = DateFormat("yyyy/MM/dd");
    DateFormat dateFormat2 = DateFormat("yyyy-MM-dd");
    if(ExpDate == "" || LicenseDate == "null"){
      return colour.commonColor;
    }
    DateTime FormatlicenseDate = dateFormat.parse(LicenseDate);
    DateTime FormatExpDate = dateFormat2.parse(ExpDate);
    if (FormatlicenseDate.isBefore(FormatExpDate) || FormatlicenseDate.isAtSameMomentAs(FormatExpDate) ) {
      return colour.commonColorred;
    }  else {
      return colour.commonColor;
    }
  }
  Color _ExpServiceAligmentGreece(String LicenseDate ) {
    DateFormat dateFormat = DateFormat("yyyy/MM/dd");
    DateFormat dateFormat2 = DateFormat("yyyy-MM-dd");
    if( ExpServiceAligmentGreece == "" || LicenseDate == "null"){
      return colour.commonColor;
    }
    DateTime FormatlicenseDate = dateFormat.parse(LicenseDate);
    DateTime FormatExpDate = dateFormat2.parse( ExpServiceAligmentGreece);
    if (FormatlicenseDate.isBefore(FormatExpDate) || FormatlicenseDate.isAtSameMomentAs(FormatExpDate) ) {
      return colour.commonColorred;
    }  else {
      return colour.commonColor;
    }
  }
  Color _ExpApadBonamColor(String LicenseDate ) {
    DateFormat dateFormat = DateFormat("yyyy/MM/dd");
    DateFormat dateFormat2 = DateFormat("yyyy-MM-dd");
    if(ExpApadBonam == "" || LicenseDate == "null"){
      return colour.commonColor;
    }
    DateTime FormatlicenseDate = dateFormat.parse(LicenseDate);
    DateTime FormatExpDate = dateFormat2.parse(ExpApadBonam);
    if (FormatlicenseDate.isBefore(FormatExpDate) || FormatlicenseDate.isAtSameMomentAs(FormatExpDate) ) {
      return colour.commonColorred;
    }  else {
      return colour.commonColor;
    }
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
                        Text("Job No : ${detailsList["JobNo"]}",style:GoogleFonts
                            .lato(
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colour
                                  .commonColor,
                            )),),
                        Text("Vessel Name : ${detailsList["VesselName"]}",style:GoogleFonts
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
                        Text("Truck Size : ${detailsList["truckSize"]}",style:GoogleFonts
                            .lato(
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colour
                                  .commonColor,
                            )),),
                        Text("Truck Name : ${detailsList["TruckName"]}",style:GoogleFonts
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
  Future _shareRTI( int Id ,String RTINo) async {
if(RTINo == ""){
  RTINo = "DriverRTI";
}
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
  Future<void> _showSalaryDetails(Map detailsList) async {

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
                        Text("Salary : ${detailsList["Salary"]}",style:GoogleFonts
                            .lato(
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colour
                                  .commonColor,
                            )),),
                        Text("Add Pickup : ${detailsList["PickupAmount"]}",style:GoogleFonts
                            .lato(
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colour
                                  .commonColor,
                            )),),
                        Text("Add Drop : ${detailsList["DropAmount"]}",style:GoogleFonts
                            .lato(
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colour
                                  .commonColor,
                            )),),
                        Text("Sleeping Allowance : ${detailsList["SleepingAmount"]}",style:GoogleFonts
                            .lato(
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colour
                                  .commonColor,
                            )),),
                        Text("Empty Pickup : ${detailsList["ExitAmount"]}",style:GoogleFonts
                            .lato(
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colour
                                  .commonColor,
                            )),),
                        Text("Empty Delivery : ${detailsList["EmptyDeliveryAmount"]}",style:GoogleFonts
                            .lato(
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colour
                                  .commonColor,
                            )),),
                        Text("Manpower Allowance : ${detailsList["ManpwAmount"]}",style:GoogleFonts
                            .lato(
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colour
                                  .commonColor,
                            )),),
                        Text("Amount : ${detailsList["Amount"]}",style:GoogleFonts
                            .lato(
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colour
                                  .commonColor,
                            )),),
                        Text("Place : ${detailsList["FullDestination"]}",style:GoogleFonts
                            .lato(
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colour
                                  .commonColor,
                            )),),
                        Text("Collection : ${detailsList["Origin"]}",style:GoogleFonts
                            .lato(
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colour
                                  .commonColor,
                            )),),
                        Text("Delivery : ${detailsList["Destination"]}",style:GoogleFonts
                            .lato(
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colour
                                  .commonColor,
                            )),),
                        Text("Collection Date: ${detailsList["PickupDate"]}",style:GoogleFonts
                            .lato(
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colour
                                  .commonColor,
                            )),),
                        Text("Delivery Date: ${detailsList["DeliveryDate"]}",style:GoogleFonts
                            .lato(
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colour
                                  .commonColor,
                            )),),
                        Text("Customer : ${detailsList["CustomerName"]}",style:GoogleFonts
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
  late File ff;
  bool show = false;
  Future<void> pickImage(RTIDetailsViewModel detail, bool fromCamera) async {
    final ImagePicker picker = ImagePicker();

    final XFile? pickedFile = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      detail.imageFile = pickedFile;        // ✅ IMPORTANT
      detail.imagePath = pickedFile.path;   // ✅ OPTIONAL (preview/json)
    }
  }

  Future<void> SaveRTIData(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      var Comid = objfun.storagenew.getInt('Comid') ?? 0;

      var uri = Uri.parse("${objfun.apiRTIDetailsInsert}$Comid");
      var request = http.MultipartRequest("POST", uri);

      // ✅ MUST MATCH SERVER PARAM NAME
      request.fields["objReceipt"] = jsonEncode(selectedDetails);
      request.fields["Comid"] = Comid.toString();

      for (var d in objfun.RTIViewDetailList) {
        if (d.isChecked && d.imageFile != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              "Files_${d.Id}",
              d.imageFile!.path,
              filename: d.imageFile!.name,
            ),
          );
        }
      }

      var response = await request.send();
      var respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text("Success"),
                ],
              ),
              content: const Text("Saved successfully"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Error"),
            content: Text("Failed to save (${response.statusCode})"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }

    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return objfun.MalevaScreen == 1
        ? mobiledesign(this, context)
        : tabletdesign(this, context);

  }
}
