import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/bluetooth/bluetoothmanager.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/menu/menulist.dart';
import 'package:maleva/core/models/model.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:http/http.dart' as http;
import '../../MasterSearch/Employee.dart';
import '../../MasterSearch/Port.dart';
import 'package:maleva/Transaction/SaleOrder/SalesOrderAdd.dart';
import '../../SparePartsEntry/SparePartsViewPage.dart';
import '../../Transaction/Planning/PlanningDetails.dart';
import '../Boarding/SpotSaleEntryView.dart';
 part 'package:maleva/DashBoard/OperationAdmin/mobileOperationAdminDashboard.dart';
 part 'package:maleva/DashBoard/OperationAdmin/tabletOperationAdminDashboard.dart';



class OldOperationAdminDashboard extends StatefulWidget {
  final int? editId;
  const OldOperationAdminDashboard({super.key,this.editId});


  @override
  OldOperationAdminDashboardState createState() => OldOperationAdminDashboardState();
}

class OldOperationAdminDashboardState extends State<OldOperationAdminDashboard> with TickerProviderStateMixin {
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
  int ?sid;
  int ?PSid;
  static const List<String> DashBoardList = <String>['INV', 'SO', 'FW'];
  String? dropdownValueFW;
  int DriverId = 0;
  String dtpToDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  String dtpFromDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  bool checkBoxValueLEmp = true;
  int EmpId = 0;
  String dtpEFromDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  String dtpEToDate = DateFormat("yyyy-MM-dd").format(DateTime.now());

  String? selectedCustomer;
  // Months are 1-indexed


  String RdtpToDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  String RdtpFromDate = DateFormat("yyyy-MM-dd").format(DateTime.now());

  // Months are 1-indexed
  List<String> monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  List <dynamic> SaleDataAll=[];
  List <dynamic> SaleDataWith=[];
  List <dynamic> SaleDataWithout=[];
  List <dynamic> SaleMonthData=[];
  List<RTIMasterViewModel> masterList = [];
  List<RTIDetailsViewModel> detailsList = [];
  List <dynamic> SaleCustReport=[];
  List <dynamic> SaleTransReport=[];

  List <dynamic> SaleExpReport=[];

  List <dynamic> Maintenancedata=[];
  List <dynamic> Maintenancedata1=[];
  List <dynamic> Maintenancedata2=[];

  List <SpeedingView> speedingRecords=[];
  List<TruckDetailsModel> truckData = [];
  List<DriverDetailsModel> driverData = [];
  List<FuelFilling> fuelFillingRecords = [];
  List<EngineHoursdata> EngineHoursRecords = [];

  List <dynamic> SaleEmployeeSalesReport=[];
  List<FuelselectModel> fulerecord = [];
  List <dynamic> SaleExpDetailsReport=[];
  List <dynamic> SaleExpReport2=[];
  List <dynamic> SaleFWReport=[];
  List <dynamic> SaleFWReport2=[];
  List<Map<String, dynamic>>  ListMonthData=[];
  List<String> LoadMonthsList = [];
  String currentMonthName = "";
  String SupplierName = "";
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<RTIMasterViewModel> allRTIMasterList = [];
  List<RTIMasterViewModel> filteredRTIMasterList = [];
  final TextEditingController driverController = TextEditingController();
  final TextEditingController sparePartsController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  TextEditingController fromCtrl = TextEditingController();
  TextEditingController toCtrl = TextEditingController();

  final TextEditingController VehicleNameController = TextEditingController();
  final TextEditingController AWBNoController = TextEditingController();
  final TextEditingController QuantityController = TextEditingController();
  final TextEditingController TotalWeightController = TextEditingController();
  File? _pickedImage;
  File? _pickedImage1;
  File? _pickedPDF;
  File? _pickedPDF1;
  final ImagePicker _picker = ImagePicker();
  List<dynamic> selectedDetails = [];
  String? selectedTruck; // Truck Id
  DateTime? selectedDate; // Selected Date
  bool _isLoading = false;
  DateTime? fromDate;
  DateTime? toDate;
  String? selectedPort; // Truck Id
  String? selectedJobStatus; // Truck Id
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();
  List<dynamic> PlanningDetailedList = [];
  late List<bool> VisiblePlanningDetails;
  final txtPlanningNo = TextEditingController();
  final txtEmployee = TextEditingController();
  final txtPassword = TextEditingController();
  String? selectedJobType; // Truck Id
  double breakdownAmount = 0;
  int breakdownCount = 0;

  double repairAmount = 0;
  int repairCount = 0;
  String UserName = objfun.storagenew.getString('Username') ?? "";
  double serviceAmount = 0;
  int serviceCount = 0;
  String? _NetworkImageUrl; // Truck Id
  double sparePartsAmount = 0;
  int sparePartsCount = 0;
  bool loading = false;
  var commonexpirydays = 15;
  var ExpDate = "";
  final Color themeColor = Colors.deepOrange;
  List<dynamic> spareViewList = [];
  late TabController _tabController;
  late TabController _tabmainController;
  final txtPort = TextEditingController();
  final txtRemarks = TextEditingController();
  int TruckId = objfun.DriverTruckRefId ;
  final txtRTINo = TextEditingController();
  int _currentlyVisibleIndex = -1;
  int EditId = 0;
  final List<Map<String, dynamic>> Inventoryfilters = [

    {"id": 2, "name": "WP"},
    {"id": 3, "name": "NP"},
    {"id": 4, "name": "SP"},

  ];
  CustomerModel? selectedCustomerView;
  int ?CustomerVId ;
  bool isChecked = false;
  int Status = 0;
  List<InventoryModel> masterList1 = [];
  int? selectedFilterId;
  @override
  void initState() {
    VisiblePlanningDetails = List<bool>.filled(10, false);
    _tabController = TabController(vsync: this, length: 3);
    _tabmainController = TabController(vsync: this, length: 13);
    dtpEFromDate = DateFormat("yyyy-MM-dd").format(DateTime(now.year, now.month, 1));
    if (widget.editId != null && widget.editId != 0){
      int EId = widget.editId ?? 0;
      fetchData(EId);
    }

    startup();
    super.initState();
  }

  Future startup() async {
    monthIndex = now.month ;
    fromDate = DateTime.now();
    toDate = DateTime.now();
    currentMonthName =  monthNames[monthIndex-1];
    await OnlineApi.SelectJobStatus(context);
    await OnlineApi.SelectJobType(context);

    loadTruckList();
    dropdownValueFW = "INV";
    loaddata(0);
    loaddata1();
    loadMaintenance();
    loadVesseldata(0);
    loadTruck();
    loadDrive();
    loadSpeeding();
    loadFuelFilling();
    loadEingeHours();
    loadfueldifference();
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
          masterList1 = masterJson
              .map<InventoryModel>((e) => InventoryModel.fromJson(e))
              .toList();
        }
        else {
          masterList1 = [];
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
                                      await OnlineApi.EditPlanning(
                                          context, Id, PlanningNo);
                                      Navigator.push(
                                          context, MaterialPageRoute(builder: (context) => const PlanningDetailsView()));
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
  Future<void> LoadRTIDetails() async {
    setState(() {
      progress = false;
    });

    objfun.RTIViewMasterList.clear();
    objfun.RTIViewDetailList1.clear();
    DateTime yearStart = DateTime(now.year, 1, 1);
    DateTime yearEnd   = DateTime(now.year, 12, 31);

    final int comId = objfun.storagenew.getInt('Comid') ?? 0;
    String Fromdate = fromDate != null
        ? DateFormat("yyyy-MM-dd").format(fromDate!)
        : DateFormat("yyyy-MM-dd").format(yearStart);

    String Todate = toDate != null
        ? DateFormat("yyyy-MM-dd").format(toDate!)
        : DateFormat("yyyy-MM-dd").format(yearEnd);

    try {
      final resultData = await objfun.apiAllinoneSelect(
        "${objfun.apiSelectRTIView}"
            "$comId&Fromdate=$Fromdate&Todate=$Todate"
            "&DId=0&TId=0&Employeeid=0&Search=",
        null,
        null,
        context,
      );

      if (resultData != null &&
          resultData.isNotEmpty &&
          resultData[0] != null) {

        final data = resultData[0];

        objfun.RTIViewMasterList = (data["salemaster"] as List)
            .map((e) => RTIMasterViewModel.fromJson(e))
            .toList();

        objfun.RTIViewDetailList1 = (data["saledetails"] as List)
            .map((e) => RTIDetailsViewModel.fromJson(e))
            .toList();
      }
    } catch (e, stackTrace) {
      objfun.msgshow(
        e.toString(),
        stackTrace.toString(),
        Colors.white,
        Colors.red,
        null,
        18.00 - objfun.reducesize,
        objfun.tll,
        objfun.tgc,
        context,
        2,
      );
    }

    setState(() {
      progress = true;
    });
  }

  Future<void> _selectDate(bool isFrom) async {
    DateTime initialDate = DateTime.now();

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }


  Future<void> loadTruckList() async {
    await OnlineApi.SelectTruckList(context, null);
    print("Truck Count: ${objfun.GetTruckList.length}");
    setState(() {}); // Refresh UI after list load
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
  Future loadfueldifference() async {
    setState(() {
      fulerecord = [];
      progress = false;
    });

    Map<String, dynamic> master = {
      'Comid': objfun.storagenew.getInt('Comid') ?? 0,
      'Fromdate': dtpFromDate,
      'Todate': dtpToDate,
      'Employeeid': 0,
      'DId': 0,
      'TId': 0,
      'Search': '',
    };

    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    try {
      final resultData = await objfun.apiAllinoneSelectArray(
        objfun.apiSelectFuelEntry,
        master,
        header,
        context,
      );

      if (resultData != null && resultData is List && resultData.isNotEmpty) {
        // 🔹 Convert List<dynamic> → List<FuelEntryModel>
        final List<FuelselectModel> convertedList = resultData
            .map((item) => FuelselectModel.fromJson(item as Map<String, dynamic>))
            .toList();

        setState(() {
          fulerecord = convertedList;
          progress = true;
        });
      } else {
        setState(() {
          progress = true;
        });
      }
    } catch (e, st) {
      objfun.msgshow(
        e.toString(),
        st.toString(),
        Colors.white,
        Colors.red,
        null,
        18.00 - objfun.reducesize,
        objfun.tll,
        objfun.tgc,
        context,
        2,
      );

      setState(() {
        progress = true;
      });
    }
  }

  Future<void> submitSpotSaleOrder(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      int comId = objfun.storagenew.getInt('Comid') ?? 0;
      int employeeId =
          int.tryParse(objfun.storagenew.getString('OldUsername') ?? '0') ?? 0;

      /// ✅ JSON DATA (numeric values fixed)
      List<Map<String, dynamic>> spotSalesOrderList = [
        {
          "CompanyRefId": comId,
          "Id": widget.editId ?? 0,
          "EmployeeRefId": employeeId,
          "JobMasterRefId": selectedJobType,
          "CustomerRefId": 0,
          "VechicelName": VehicleNameController.text.trim(),
          "AWBNo": AWBNoController.text.trim(),
          "Quantity": int.tryParse(QuantityController.text.trim()) ?? 0,
          "TotalWeight": double.tryParse(TotalWeightController.text.trim()) ?? 0,
          "JStatus": selectedJobStatus,
          "Port": selectedPort,
          "DocumentPath": ""
        }
      ];

      var uri = Uri.parse("${objfun.apiInsertSpotSaleEntry}?Comid=$comId");

      var request = http.MultipartRequest("POST", uri);

      /// ✅ REQUIRED FORM FIELDS
      request.fields["details"] = jsonEncode(spotSalesOrderList);
      request.fields["Comid"] = comId.toString();

      /// ✅ FILE UPLOAD (single key name)
      if (_pickedImage1 != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "file",
            _pickedImage1!.path,
          ),
        );
      }

      if (_pickedPDF1 != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "file",
            _pickedPDF1!.path,
          ),
        );
      }

      /// 🚀 SEND REQUEST
      var response = await request.send();
      var respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print("SUCCESS => $respStr");
        await objfun.ConfirmationOK('Updated Successfully:', context);
        /// ✅ CLEAR FORM
        setState(() {
          selectedJobType = null;
          selectedCustomer = null;
          selectedJobStatus = null;
          selectedPort = null;
          selectedDate = null;

          driverController.clear();
          VehicleNameController.clear();
          AWBNoController.clear();
          QuantityController.clear();
          TotalWeightController.clear();

          _pickedImage1 = null;
          _pickedPDF1 = null;
          _NetworkImageUrl = null;
          _isLoading = false;
        });
      } else {
        print("FAILED ${response.statusCode} => $respStr");
        setState(() => _isLoading = false);
      }
    } catch (e, stackTrace) {
      setState(() => _isLoading = false);

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
          "SpareParts": sparePartsController.text.trim(),
          "EntryDate": selectedDate == null
              ? DateFormat('yyyy-MM-dd').format(DateTime.now())
              : DateFormat('yyyy-MM-dd').format(selectedDate!),

          "Amount": amountController.text.trim(),
          "DocumentPath": ""
        }
      ];

      // API URL
      var uri = Uri.parse("${objfun.apiInsertSpareParts}?Comid=$Comid");

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
          driverController.clear();
          sparePartsController.clear();
          amountController.clear();
          dateController.clear();
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
  Future loaddata1() async {
    setState(() {
      progress = false;
    });
    var Employeeid = 0;

    if(objfun.DriverLogin == 1){
      DriverId = objfun.EmpRefId;
    }

    await OnlineApi.SelectRTIDetailViewList(context, RdtpFromDate, RdtpToDate, DriverId, TruckId, Employeeid, txtRTINo.text);
    allRTIMasterList = List.from(objfun.RTIViewMasterList);

    filteredRTIMasterList = List.from(allRTIMasterList);

    setState(() {
      progress = true;
    });
  }
  Future loaddata2() async {
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
        objfun.apiSelectPlanning, master, header, context)
        .then((resultData) async {
      if (resultData != "") {
        setState(() {
          progress = true;
        });
        if (resultData.length != 0) {
          objfun.PlanningMasterList = resultData[0]["salemaster"]
              .map((element) => PlanningMasterModel.fromJson(element))
              .toList();
          objfun.PlanningDetailsList = resultData[0]["saledetails"].toList();
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
  Future loaddata(int type) async {
    setState(() {
      progress = false;
    });
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    await objfun
        .apiAllinoneSelectArray(
        "${objfun.apiGetSalesData}${objfun.Comid}&type=$type", null, header, context)
        .then((resultData) async {
      if (resultData != "") {
        setState(() {
          progress = true;
        });
        if (resultData.length != 0) {
          SaleDataAll=resultData["Data1"];
          SaleMonthData=resultData["Data2"];
          /* SaleDataWith=resultData["Data2"];
         SaleDataWithout=resultData["Data3"];*/
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
    Is6Months = true;
    Is6Months2 = true;
    Is6Months3 = true;
    monthdata(6);
    setState(() {
      progress = true;
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
  Future loadFWdata(String fromDate,String toDate) async {
    setState(() {
      progress = false;
    });
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    await objfun
        .apiAllinoneSelectArray(
        "${objfun.apiGetFWData}${objfun.Comid}&startDate=$fromDate&endDate=$toDate", null, header, context)
        .then((resultData) async {
      if (resultData != "") {
        setState(() {
          progress = true;
        });
        if (resultData.length != 0) {
          SaleFWReport=resultData["Data1"];
          SaleFWReport2=resultData["Data2"];
          /* SaleDataWith=resultData["Data2"];
         SaleDataWithout=resultData["Data3"];*/
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
  Future loadExpdata(String fromDate,String toDate) async {
    setState(() {
      progress = false;
    });
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    await objfun
        .apiAllinoneSelectArray(
        "${objfun.apiGetExpData}${objfun.Comid}&startDate=$fromDate&endDate=$toDate", null, header, context)
        .then((resultData) async {
      if (resultData != "") {
        setState(() {
          progress = true;
        });
        if (resultData.length != 0) {
          SaleExpReport=resultData["Data1"];
          SaleExpReport2=resultData["Data2"];

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
  Future loadMaintenance() async {
    setState(
            () {
      progress = false;
    });
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    await objfun
        .apiAllinoneSelectArray(
        "${objfun.apiGetMaintenance}${objfun.Comid}", null, header, context)
        .then((resultData) async {
      if (resultData != "") {
        setState(() {
          progress = true;
        });
        if (resultData.length != 0) {
          Maintenancedata = resultData.map((e) => MaintenanceModel.fromJson(e)).toList();


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
  Future loadMaintenance1(String fromDate,String toDate) async {
    setState(() {
      progress = false;
    });
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    await objfun
        .apiAllinoneSelectArray(
        "${objfun.apiGetMaintenance1}${objfun.Comid}&Fromdate=$fromDate&Todate=$toDate", null, header, context)
        .then((resultData) async {
      if (resultData != "") {
        setState(() {
          progress = true;
        });
        if (resultData.length != 0) {
          Maintenancedata1 = resultData.map((e) => MaintenanceModel.fromJson(e)).toList();


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
  Future loadMaintenance2(String fromDate, String toDate) async {
    setState(() {
      progress = false;
    });

    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    await objfun
        .apiAllinoneSelectArray(
        "${objfun.apiGetMaintenance2}${objfun.Comid}&Fromdate=$fromDate&Todate=$toDate",
        null,
        header,
        context)
        .then((resultData) async {
      if (resultData != "") {
        setState(() {
          progress = true;
        });

        Maintenancedata2 = resultData.map((e) => MaintenanceModel.fromJson(e)).toList();


        for (var item in Maintenancedata2) {
          switch (item.Description.toUpperCase()) {
            case "BREAKDOWN":
              breakdownCount = int.tryParse(item.PStatus.toString()) ?? 0;
              breakdownAmount = double.tryParse(item.Amount.toString()) ?? 0.0;
              break;
            case "REPAIR":
              repairCount = int.tryParse(item.PStatus.toString()) ?? 0;
              repairAmount = double.tryParse(item.Amount.toString()) ?? 0.0;
              break;
            case "SERVICE":
              serviceCount = int.tryParse(item.PStatus.toString()) ?? 0;
              serviceAmount = double.tryParse(item.Amount.toString()) ?? 0.0;
              break;
            case "SPARE PARTS":
              sparePartsCount = int.tryParse(item.PStatus.toString()) ?? 0;
              sparePartsAmount = double.tryParse(item.Amount.toString()) ?? 0.0;
              break;
          }
        }
            setState(() {
            progress = true;
            });
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
  Future loadTruck() async {
    setState(() {
      progress = false;
    });

    String currentDate = DateFormat("yyyy-MM-dd").format(DateTime.now().add(Duration(days: 5)));

    Map<String, dynamic> truckRequestPayload = {
      'ExpDate': currentDate,
      'ExpApadBonam': currentDate,
      'ExpServiceAligmentGreece': currentDate,
      'Id': 0,
      'SFromDate': null,
      'Comid': objfun.Comid,
      'AccountId': 0,
    };


    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    await objfun
        .apiAllinoneSelectArray(
        "${objfun.apiSelectTruckDetails}",
        truckRequestPayload,
        header,
        context)
        .then((resultData) async {
      if (resultData != "") {
        setState(() {
          progress = true;
        });

        if (resultData != "") {
          if (resultData.length != 0) {
            truckData = resultData
                .map((element) => TruckDetailsModel.fromJson(element))
                .toList().cast<TruckDetailsModel>();
          }
        }

        // 🟡 Set count/amount by Description

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

  Future loadDrive() async {

    ExpDate = objfun.currentdate(objfun.commonexpirydays);

    Map<String, dynamic> master = {};

    master = {

      'ExpDate':"",
      'Id':0,
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
          driverData = resultData
              .map((element) => DriverDetailsModel.fromJson(element))
              .toList().cast<DriverDetailsModel>();
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

  /// Loads the speeding report for the current month.
  ///
  /// This method is just a thin wrapper around [loadMonthlyReport] that:
  /// 1. Specifies the speeding report API endpoint.
  /// 2. Defines how to parse each JSON object into a [SpeedingView] model.
  /// 3. Assigns the parsed list to [speedingRecords].
  Future<void> loadSpeeding() async {
    await loadMonthlyReport<SpeedingView>(
      apiEndpoint: objfun.apiSelectSpeedingReport,
      fromJson: (json) => SpeedingView.fromJson(json),
      onDataLoaded: (records) => speedingRecords = records,
    );
  }

  /// Loads the fuel filling report for the current month.
  ///
  /// This method is just a thin wrapper around [loadMonthlyReport] that:
  /// 1. Specifies the fuel filling report API endpoint.
  /// 2. Defines how to parse each JSON object into a [FuelFilling] model.
  /// 3. Assigns the parsed list to [fuelFillingRecords].
  Future<void> loadFuelFilling() async {
    await loadMonthlyReport<FuelFilling>(
      apiEndpoint: objfun.apiSelectFuelFillingReport,
      fromJson: (json) => FuelFilling.fromJson(json),
      onDataLoaded: (records) => fuelFillingRecords = records,
    );
  }
  /// Loads the fuel filling report for the current month.
  ///
  /// This method is just a thin wrapper around [loadEingeHours] that:
  /// 1. Specifies the fuel filling report API endpoint.
  /// 2. Defines how to parse each JSON object into a [EngineHoursdata] model.
  /// 3. Assigns the parsed list to [EngineHoursRecords].
  Future<void> loadEingeHours() async {
    await loadMonthlyReport<EngineHoursdata>(
      apiEndpoint: objfun.apiSelectEangiehoursReport,
      fromJson: (json) => EngineHoursdata.fromJson(json),
      onDataLoaded: (records) => EngineHoursRecords = records,
    );
  }
  /// Generic function to load monthly report data from an API.
  ///
  /// [apiEndpoint] - The API endpoint to call.
  /// [fromJson] - A function to convert a JSON map into the desired model object.
  /// [onDataLoaded] - A callback to update the corresponding data list.
  ///
  /// This method:
  /// 1. Calculates the current month's start and end date.
  /// 2. Prepares request body and headers.
  /// 3. Calls the API.
  /// 4. Parses response into a list of model objects.
  /// 5. Handles errors and updates UI state.
  Future<void> loadMonthlyReport<T>({required String apiEndpoint, required T Function(Map<String, dynamic>) fromJson, required void Function(List<T>) onDataLoaded,}) async {

    DateTime today = DateTime.now();

    // Calculate first & last day of current month
    DateTime startOfMonth = DateTime(today.year, today.month, 1);
    DateTime endOfMonth = DateTime(today.year, today.month + 1, 0);

    // Format dates for API
    String fromDate = DateFormat('MM/dd/yyyy').format(startOfMonth);
    String toDate = DateFormat('MM/dd/yyyy').format(endOfMonth);

    // Request body
    Map<String, dynamic> master = {
      'Todate': toDate,
      'Fromdate': fromDate,
      'Comid': objfun.Comid,
    };

    // Request headers
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    try {
      // Call the API
      var resultData = await objfun.apiAllinoneSelectArray(
        apiEndpoint,
        master,
        header,
        context,
      );

      // Parse if not empty
      if (resultData != "" && resultData.isNotEmpty) {
        List<T> records = resultData
            .map<T>((element) => fromJson(element))
            .toList()
            .cast<T>();

        onDataLoaded(records); // Update the list in state
      }
    } catch (error, stackTrace) {
      // Error handling
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
        2,
      );
    } finally {
      // Ensure UI updates
      setState(() {
        progress = true;
      });
    }
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
      FromDate = "2025-02-01";
      //FromDate = "2024-10-01";
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
        .apiAllinoneSelectArray(objfun.VESSELPLANINGDB, master, header, context).then((resultData) async {
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
    String URL = "";
    if(type == 0){
      URL = objfun.PLANINGSearchDB;
    }
    else{
      URL = objfun.PLANINGSearch;
    }

    Map<String, dynamic> master = {};

    master = {

      'Comid': objfun.storagenew.getInt('Comid') ?? 0,
      'Fromdate': FromDate,
      'Todate': ToDate,
      'Search': '',
      'Employeeid': eid,
      'ETAType' : 0

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
          SaleTransReport=resultData;
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
  Future monthdata(int index) async {
    LoadMonthsList = [];
    ListMonthData =[];
    for (int i = 0; i < index; i++) {
      int CurrentIndex = ((monthIndex-1) - i) % 12;
      if (CurrentIndex < 0) {
        CurrentIndex += 12; // Handle negative index
      }
      LoadMonthsList.add(monthNames[CurrentIndex]);
    }
    if(SaleMonthData.isNotEmpty){
      for(int i = 0; i < index; i++){
        ListMonthData.add(SaleMonthData[i]);
      }
    }

    setState(() {
      progress = true;
    });
  }
  Future<void> _showDialogVessel(Map detailsList) async {

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
  Future loadEmpSalesdata(int type) async {
    setState(() {
      progress = false;
    });
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    await objfun
        .apiAllinoneSelectArray(
        "${objfun.apiGetEmployeeSalesData}${objfun.Comid}&type=$type", null, header, context)
        .then((resultData) async {
      if (resultData != "") {
        setState(() {
          progress = true;
        });
        if (resultData.length != 0) {
          SaleEmployeeSalesReport=resultData["Data1"];
          _showDialogEmpDetails(SaleEmployeeSalesReport);
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
  Future loadExpenseDetails(String expenseName, String fromDate, String toDate) async {
    setState(() {
      progress = false;
    });

    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    Map<String, dynamic> requestBody = {
      'ExpenseName': expenseName,
      'Active':1,
      'Comid': objfun.storagenew.getInt('Comid') ?? 0,
      'FromDate': fromDate,
      'ToDate': toDate,
    };

    await objfun
        .apiAllinoneSelectArray(
        "${objfun.apiSelectExpenseDetails}", requestBody, header, context)
    // apiSelectExpenseDetails, requestBody, header, context)
        .then((resultData) async {
      if (resultData != "") {
        setState(() {
          progress = true;
        });

        if (resultData.length != 0) {
          SaleExpDetailsReport = resultData; // Store the result if needed
          _showDialogExpenseDetails(SaleExpDetailsReport); // show in a dialog
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
        2,
      );
    });

    setState(() {
      progress = true;
    });
  }
  Future<void> _showDialogExpenseDetails(List<dynamic> detailsList) async {
    if (detailsList.isEmpty) return;

    await showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          elevation: 40.0,
          child: Column(
            children: [
              // Title Header Row
              Container(
                width: 250,
                height: 30,
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 10, right: 2.0, left: 2.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        "EXPENSE",
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                            color: colour.blackText,
                            fontWeight: FontWeight.bold,
                            fontSize: objfun.FontLow,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Count",
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                            color: colour.blackText,
                            fontWeight: FontWeight.bold,
                            fontSize: objfun.FontLow,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Amount",
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                            color: colour.blackText,
                            fontWeight: FontWeight.bold,
                            fontSize: objfun.FontLow,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // List Content
              Container(
                width: 250,
                height: 500,
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 10, right: 2.0, left: 2.0),
                child: ListView.builder(
                  itemCount: detailsList.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = detailsList[index];
                    return SizedBox(
                      height: 50,
                      child: Card(
                        child: Row(
                          children: [
                            // Expense Name
                            Expanded(
                              flex: 3,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                child: Text(
                                  item["ExpenseName"] ?? '',
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: GoogleFonts.lato(
                                    textStyle: TextStyle(
                                      color: colour.commonColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: objfun.FontCardText,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Count
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                child: Text(
                                  (item["ExpCount"] ?? 0).toString(),
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: GoogleFonts.lato(
                                    textStyle: TextStyle(
                                      color: colour.commonColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: objfun.FontCardText,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Amount
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                child: Text(
                                  (item["ExpAmount"] ?? 0 ).toString() ,

                                  // (item["ExpAmount"] != null
                                  //     ? (item["ExpAmount"] as num).toDouble().toStringAsFixed(0)
                                  //     : '0'),
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: GoogleFonts.lato(
                                    textStyle: TextStyle(
                                      color: colour.commonColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: objfun.FontCardText,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  Future loadEmpInvdata(int type) async {
    setState(() {
      progress = false;
    });
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    await objfun
        .apiAllinoneSelectArray(
        "${objfun.apiGetEmployeeInvData}${objfun.Comid}&type=$type", null, header, context)
        .then((resultData) async {
      if (resultData != "") {
        setState(() {
          progress = true;
        });
        if (resultData.length != 0) {
          SaleEmployeeSalesReport=resultData["Data1"];
          _showDialogEmpDetails(SaleEmployeeSalesReport);
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
  Future<void> _showDialogEmpDetails(List<dynamic> detailsList) async {

    await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              elevation: 40.0,
              child:Column( children: [
                Container(
                    width: 250,
                    height: 30,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(
                      top:10,
                      right: 2.0,
                      left: 2.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child:  Text(
                            "EMPLOYEE" ,
                            textAlign:
                            TextAlign
                                .left,
                            overflow:
                            TextOverflow
                                .ellipsis,
                            maxLines: 1,
                            style: GoogleFonts
                                .lato(
                              textStyle: TextStyle(
                                  color: colour
                                      .blackText,
                                  fontWeight:
                                  FontWeight
                                      .bold,
                                  fontSize:
                                  objfun
                                      .FontLow,
                                  letterSpacing:
                                  0.3),
                            ),
                          ),),
                        Expanded(
                          flex: 2,
                          child: Text(
                            "Count" ,
                            textAlign:
                            TextAlign
                                .left,
                            overflow:
                            TextOverflow
                                .ellipsis,
                            maxLines: 1,
                            style: GoogleFonts
                                .lato(
                              textStyle: TextStyle(
                                  color: colour
                                      .blackText,
                                  fontWeight:
                                  FontWeight
                                      .bold,
                                  fontSize:
                                  objfun
                                      .FontLow,
                                  letterSpacing:
                                  0.3),
                            ),
                          ),),
                        Expanded(
                          flex: 2,
                          child:  Text(
                            "Amount" ,
                            textAlign:
                            TextAlign
                                .left,
                            overflow:
                            TextOverflow
                                .ellipsis,
                            maxLines: 1,
                            style: GoogleFonts
                                .lato(
                              textStyle: TextStyle(
                                  color: colour
                                      .blackText,
                                  fontWeight:
                                  FontWeight
                                      .bold,
                                  fontSize:
                                  objfun
                                      .FontLow,
                                  letterSpacing:
                                  0.3),
                            ),
                          ),),
                      ],
                    )
                ),
                Container(
                  width: 250,
                  height: 500,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(
                    top:10,
                    right: 2.0,
                    left: 2.0,
                  ),
                  child:// Text("Hello world")
                  ListView.builder(
                      itemCount:
                      detailsList.length,
                      itemBuilder:
                          (BuildContext context, int index) {
                        return SizedBox(
                            height: 50,
                            child: InkWell(
                              onLongPress: () {

                              },
                              child: Card(

                                  child: Row(
                                    children: [
                                      Expanded(
                                          flex: 3,
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            crossAxisAlignment:
                                            CrossAxisAlignment
                                                .center,
                                            children: <Widget>[
                                              Expanded(
                                                flex: 1,
                                                child: Container(
                                                  padding:
                                                  const EdgeInsets
                                                      .all(5),
                                                  child: Text(" ${detailsList[index]["EmployeeName"]}" ,
                                                    textAlign:
                                                    TextAlign
                                                        .left,
                                                    overflow:
                                                    TextOverflow
                                                        .ellipsis,
                                                    maxLines: 1,
                                                    style: GoogleFonts
                                                        .lato(
                                                      textStyle: TextStyle(
                                                          color: colour
                                                              .commonColor,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          fontSize:
                                                          objfun
                                                              .FontCardText,
                                                          letterSpacing:
                                                          0.3),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                            ],
                                          )),
                                      Expanded(
                                          flex: 2,
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            crossAxisAlignment:
                                            CrossAxisAlignment
                                                .center,
                                            children: <Widget>[
                                              Expanded(
                                                flex: 1,
                                                child: Container(
                                                  padding:
                                                  const EdgeInsets
                                                      .all(5),
                                                  child: Text(
                                                    detailsList[index]["SalesCount"].toString() ,
                                                    textAlign:
                                                    TextAlign
                                                        .left,
                                                    overflow:
                                                    TextOverflow
                                                        .ellipsis,
                                                    maxLines: 1,
                                                    style: GoogleFonts
                                                        .lato(
                                                      textStyle: TextStyle(
                                                          color: colour
                                                              .commonColor,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          fontSize:
                                                          objfun
                                                              .FontCardText,
                                                          letterSpacing:
                                                          0.3),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                            ],
                                          )),
                                      Expanded(
                                          flex: 2,
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            crossAxisAlignment:
                                            CrossAxisAlignment
                                                .center,
                                            children: <Widget>[
                                              Expanded(
                                                flex: 1,
                                                child: Container(
                                                  padding:
                                                  const EdgeInsets
                                                      .all(5),
                                                  child: Text(
                                                    detailsList[index]["Amount"].toString() ,
                                                    textAlign:
                                                    TextAlign
                                                        .left,
                                                    overflow:
                                                    TextOverflow
                                                        .ellipsis,
                                                    maxLines: 1,
                                                    style: GoogleFonts
                                                        .lato(
                                                      textStyle: TextStyle(
                                                          color: colour
                                                              .commonColor,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          fontSize:
                                                          objfun
                                                              .FontCardText,
                                                          letterSpacing:
                                                          0.3),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                            ],
                                          )),
                                    ],
                                  )),
                            ));
                      }),
                )],)
          );
        });
  }
  List<RTIDetailsViewModel> _getRelatedDetails(RTIMasterViewModel master) {
/*    print("---- DEBUG START ----");
    print("MASTER VALUE: '${master.SubExpenseName}'");

    for (var d in detailsList) {
      print("DETAIL VALUE: '${d.SubExpenseName}'");
    }

    print("---- DEBUG END ----");*/


    return detailsList
        .where((detail) => detail.RTIMasterRefId == master.Id)
        .toList();



  }
  void _openDetailPopup(RTIMasterViewModel master) {
    final related = _getRelatedDetails(master);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 70,
                      height: 6,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(master.TruckName ?? "",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text("Bank: ${master.DriverName ?? ""}",
                      style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 10),
                  const Divider(),

                  const SizedBox(height: 10),
                  const Text("Details",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  related.isEmpty
                      ? const Expanded(
                    child: Center(
                      child: Text("No detail records available"),
                    ),
                  )
                      : Expanded(
                    child: ListView.builder(
                      controller: controller,
                      itemCount: related.length,
                      itemBuilder: (_, i) {
                        final d = related[i];
                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: Colors.indigo.shade50,
                          child: ListTile(
                            title: Text(d.CustomerName ?? ""),
                            subtitle: Text("Due: ${d.PPIC}"),
                            trailing: Text(
                              "RM ${((d.Salary ?? 0)).toStringAsFixed(2)}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.indigo),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child:
                      const Text("Close", style: TextStyle(fontSize: 16)),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
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
        if (d.isVerified) {

          if (d.imageFile != null) {
            // new image selected
            request.files.add(
              await http.MultipartFile.fromPath(
                "Files_${d.Id}",
                d.imageFile!.path,
                filename: d.imageFile!.name,
              ),
            );
          } else if (d.imagePath != null && d.imagePath!.isNotEmpty) {
            // image already exists → send empty dummy file
            request.files.add(
              http.MultipartFile.fromBytes(
                "Files_${d.Id}",
                [],
                filename: "existing.jpg",
              ),
            );
          }
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
              content: const Text("Verified successfully"),
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
  late File ff;
  bool show = false;

  @override
  Widget build(BuildContext context) {
      return objfun.MalevaScreen == 1
          ? mobiledesign(this, context)
          : tabletdesign(this, context);
    }
}
