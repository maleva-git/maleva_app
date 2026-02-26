import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/utils/clsfunction.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/menu/menulist.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:http/http.dart' as http;
import '../../core/bluetooth/bluetoothmanager.dart';
import '../../MasterSearch/Port.dart';
import '../../Transaction/Stock/StockUpdate.dart';
import '../../core/utils/clsfunction.dart';
import '../../core/utils/clsfunction.dart';
import '../../core/utils/clsfunction.dart';
import 'SpotSaleEntryView.dart';
part 'package:maleva/DashBoard/Boarding/mobileBoardingDashboard.dart';
part 'package:maleva/DashBoard/Boarding/tabletBoardingDashboard.dart';

class BoardingDashboard extends StatefulWidget {
  final int ?editId;
  final int ?viewId;

  const BoardingDashboard({super.key, this.editId, this.viewId});

  @override
  BoardingDashboardState createState() => BoardingDashboardState();
}

class BoardingDashboardState extends State<BoardingDashboard> with TickerProviderStateMixin {
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
  double SalaryAmount = 0.0;
  List<dynamic> DriverSalaryList = [];
  String searchText = "";
  bool loading = false;
  static const List<String> DashBoardList = <String>['INV', 'SO', 'FW'];
  String? dropdownValueFW;

  String dtpToDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  String dtpFromDate = DateFormat("yyyy-MM-dd").format(DateTime.now());

  String dtpEFromDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  String dtpEToDate = DateFormat("yyyy-MM-dd").format(DateTime.now());

   // Months are 1-indexed
  List<String> monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  List <dynamic> SaleDataAll=[];
  List <dynamic> SaleDataWith=[];
  List <dynamic> SaleDataWithout=[];
  List <dynamic> SaleMonthData=[];

  List <dynamic> SaleCustReport=[];
  List <dynamic> SaleTransReport=[];

  List <dynamic> SaleExpReport=[];
  List <dynamic> SaleExpReport2=[];
  List <dynamic> SaleFWReport=[];
  List <dynamic> SaleFWReport2=[];
  static List<Map<String, dynamic>> RulesTypeEmployee=[];

  List <dynamic> SalesReport=[];
  List<Map<String, dynamic>>  ListMonthData=[];
  List<String> LoadMonthsList = [];
  String currentMonthName = "";

  late TabController _tabmainController;
  final txtEmployee = TextEditingController();
  final txtPort = TextEditingController();
  final txtRemarks = TextEditingController();
  String selectedFilter = "All";
  int? selectedFilterId;

  var empId = objfun.EmpRefId;

  List<Map<String, dynamic>> filters = [];

  void loadFilters() {
    var empId = objfun.EmpRefId;

    if ( empId == 127) {
      filters = [
        {"id": 1, "name": "PTP"},
        {"id": 6, "name": "PasirGudang"},
      ];
    } else if (empId == 38){
      filters = [
        {"id": 3, "name": "NP"},
        {"id": 4, "name": "SP"},
      ];
    }
    else if (empId == 117){
      filters = [
        {"id": 1, "name": "PTP"},
        {"id": 6, "name": "PasirGudang"},
      ];
    }
    else if (empId == 121){
      filters = [
        {"id": 1, "name": "PTP"},
        {"id": 6, "name": "PasirGudang"},
      ];
    }
    else {
      filters = [
        {"id": 2, "name": "WP"},
      ];
    }
  }

  DateTime? fromDate;
  DateTime? toDate;

  TextEditingController fromCtrl = TextEditingController();
  TextEditingController toCtrl = TextEditingController();


  List<dynamic> spareList = [];
  List<dynamic> spareViewList = [];


  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController driverController = TextEditingController();
  final TextEditingController sparePartsController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  final TextEditingController VehicleNameController = TextEditingController();
  final TextEditingController AWBNoController = TextEditingController();
  final TextEditingController QuantityController = TextEditingController();
  final TextEditingController TotalWeightController = TextEditingController();

  List<InventoryModel> masterList = [];
  List<PaymentPendingModel> detailsList = [];

  File? _pickedImage;
  File? _pickedPDF;
  final ImagePicker _picker = ImagePicker();
  String? selectedTruck; // Truck Id


  String? selectedEmployee; // Truck Id
  String? selectedJobType; // Truck Id
  String? selectedJobStatus; // Truck Id
  String? selectedPort; // Truck Id
  String? selectedCustomer; // Truck Id
  String? _NetworkImageUrl; // Truck Id

  DateTime? selectedDate; // Selected Date
  bool _isLoading = false;

  bool isChecked = false;
  CustomerModel? selectedCustomerView;

  int ?CustomerVId ;

  int Status = 0;

  String? dropdownValueEMp;
  @override
  void initState() {

    _tabmainController = TabController(vsync: this, length: 4,initialIndex: widget.viewId ?? 0);
     dtpEFromDate = DateFormat("yyyy-MM-dd").format(DateTime(now.year, now.month, 1));
    EmpId = objfun.EmpRefId;

    if (widget.editId != null && widget.editId != 0){
      int EId = widget.editId ?? 0;
      fetchData(EId);
    }
    startup();
    super.initState();

  }

  Future startup() async {
    loadFilters();
    await OnlineApi.SelectJobStatus(context);
    await OnlineApi.SelectJobType(context);
    await OnlineApi.SelectCustomer(context);
    loadVesseldata(0);
    setState(() {
      progress = true;
    });
  }


  Future loadInventory({bool isDateSearch = false,int ?id} ) async {
    setState(() {
      progress = false;
    });

    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    String FromDate;
    String ToDate;

    if (isDateSearch && fromDate != null && toDate != null) {
      FromDate = DateFormat('yyyy-MM-dd').format(fromDate!);
      ToDate = DateFormat('yyyy-MM-dd').format(toDate!);
    } else {

      DateTime now = DateTime.now();
      DateTime newDate = now.add(Duration(days: 6));
      FromDate = DateFormat('yyyy-MM-dd').format(newDate);
      ToDate = DateFormat('yyyy-MM-dd').format(newDate);
    }

    Map<String, dynamic> master = {};
    int portType = id ?? 0;

    master = {

      'Comid': objfun.storagenew.getInt('Comid') ?? 0,
      'Fromdate': FromDate,
      'Todate': ToDate,
      'PortType': portType,
      'CustomerId': CustomerVId,
      'Status': Status,

    };
    await objfun
        .apiAllinoneSelectArray(
        "${objfun.apiSelectAllInventory}"
        , master, header, context)
        .then((result) async {

      List<dynamic>? masterJson;

      if (result != null && result.isNotEmpty) {
        masterJson = result;
        if (masterJson != null) {
          masterList = masterJson
              .map<InventoryModel>((e) => InventoryModel.fromJson(e))
              .toList();
        }
        else {
          masterList = [];
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

  Future<void> fetchData(int EditId) async {
    setState(() => progress = true);
    DateTime now = DateTime.now();
    DateTime yearStart = DateTime(now.year, 1, 1);
    DateTime yearEnd   = DateTime(now.year, 12, 31);
    String from = fromDate != null
        ? DateFormat("yyyy-MM-dd").format(fromDate!)
        : DateFormat("yyyy-MM-dd").format(yearStart);

    String to = toDate != null
        ? DateFormat("yyyy-MM-dd").format(toDate!)
        : DateFormat("yyyy-MM-dd").format(yearEnd);

    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    await objfun.apiAllinoneSelectArray(
      "${objfun.apiGetSpotSaleEntry}${objfun.Comid}&Fromdate=$from&Todate=$to&Id=$EditId",
      null,
      header,
      context,
    ).then((data) {
      setState(() {
        progress = false;
        print(data);
        spareViewList = List<Map<String, dynamic>>.from(
          data,
        );

        if ((spareViewList[0]['JobMasterRefId']?.toString() ?? '') != '0') {
          selectedJobType =
              spareViewList[0]['JobMasterRefId']?.toString() ?? '';
        }
        if ((spareViewList[0]['JStatus']?.toString() ?? '') != '0') {
          selectedJobStatus = spareViewList[0]['JStatus']?.toString() ?? '';
        }
        if ((spareViewList[0]['Port']?.toString() ?? '') != '0') {
          selectedPort = spareViewList[0]['Port']?.toString() ?? '';
        }

        QuantityController.text =
            spareViewList[0]['Quantity']?.toString() ?? '';

        VehicleNameController.text =
            spareViewList[0]['SVehicleName']?.toString() ?? '';

        AWBNoController.text =
            spareViewList[0]['AWBNo']?.toString() ?? '';

        TotalWeightController.text =
            spareViewList[0]['TotalWeight']?.toString() ?? '';
        //_picker = spareViewList[0]['TotalWeight'];
         _NetworkImageUrl = objfun.port + spareViewList[0]['DocumentPath'];


      });
    }).onError((error, stack) {
      setState(() => progress = false);
      objfun.msgshow(error.toString(), stack.toString(), Colors.white,
          Colors.red, null, 16, objfun.tll, objfun.tgc, context, 2);
    });
  }

  Future<void> submitSpotSaleOrder(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      var Comid = objfun.storagenew.getInt('Comid') ?? 0;
      var EmployeeId = int.tryParse(
          objfun.storagenew.getString('OldUsername') ?? '0'
      ) ?? 0;



      List<Map<String, dynamic>> SpotSalesOrderList = [
        {
          "CompanyRefId": Comid,
          "Id": widget.editId,
          "EmployeeRefId": EmployeeId,
          "JobMasterRefId": selectedJobType,
          "CustomerRefId": 0,
          "VechicelName": VehicleNameController.text.trim(),
          "AWBNo": AWBNoController.text.trim(),
          "Quantity": QuantityController.text.trim(),
          "TotalWeight": TotalWeightController.text.trim(),
          "JStatus": selectedJobStatus,
          "Port": selectedPort,
          // "EntryDate": selectedDate == null
          //     ? DateFormat('yyyy-MM-dd').format(DateTime.now())
          //     : DateFormat('yyyy-MM-dd').format(selectedDate!),
          "DocumentPath": ""
        }
      ];

      // API URL
      var uri = Uri.parse("${objfun.apiInsertSpotSaleEntry}?Comid=$Comid");

      // Create Multipart Request
      var request = http.MultipartRequest("POST", uri);

      // JSON → string
      request.fields["details"] = jsonEncode(SpotSalesOrderList);
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
          selectedJobType = null;
          selectedCustomer = null;
          selectedJobStatus = null;
          selectedPort = null;
          EmployeeId = 0;
          selectedDate = null;
          driverController.clear();
          VehicleNameController.clear();
          AWBNoController.clear();
          QuantityController.clear();
          TotalWeightController.clear();
          _pickedImage = null;
          _NetworkImageUrl = null;
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
  Future loadSalaryData() async {


    Map<String, dynamic> master = {};

    master = {
      'Comid': objfun.Comid,
      'Employeeid': objfun.EmpRefId,
      'FromDate': dtpFromDate,
      'ToDate': dtpToDate,
    };
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    await objfun
        .apiAllinoneSelectArrayWithOutAuth(
        objfun.apiSelectBoardingSalary, master, header, context)
        .then((resultData) async {
      if (resultData != "")
      {
        ResponseViewModel? value = ResponseViewModel.fromJson(resultData);
        if (value.IsSuccess == true && value.data1 != null && value.data1.length != 0 ) {

          DriverSalaryList = value.data1;
          var salarySum = 0.0;
          for(var i = 0 ; i < DriverSalaryList.length ; i++){
            salarySum = salarySum + DriverSalaryList[i]["NetAmt"];
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
  Future<void> _showSalaryDetails(Map detailsList) async {

    await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              elevation: 40.0,
              child: Container(
                  width: 200,
                  height: 250,
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

                        Text("Collection : ${detailsList["Origin"]}",style:GoogleFonts
                            .lato(
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colour
                                  .commonColor,
                            )),),
                        SizedBox(height: 5,),
                        Text("Delivery : ${detailsList["Destination"]}",style:GoogleFonts
                            .lato(
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colour
                                  .commonColor,
                            )),),
                        SizedBox(height: 5,),
                        Text("Collection Date: ${detailsList["SPickupDate"]}",style:GoogleFonts
                            .lato(
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colour
                                  .commonColor,
                            )),),
                        SizedBox(height: 5,),
                        Text("Delivery Date: ${detailsList["SDeliveryDate"]}",style:GoogleFonts
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
  late File ff;
  bool show = false;

  @override
  Widget build(BuildContext context) {
    return objfun.MalevaScreen == 1
        ? mobiledesign(this, context)
        : tabletdesign(this, context);

  }
}
