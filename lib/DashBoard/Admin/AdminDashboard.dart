import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/bluetooth/bluetoothmanager.dart';
import 'package:maleva/GoogleReview/ReviewGridScreen.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/menu/menulist.dart';
import 'package:maleva/core/models/model.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:http/http.dart' as http;
import '../../MasterSearch/Port.dart';
import '../../SaleOrderView/SaleOrderView.dart';
import '../../SparePartsEntry/SparePartsViewPage.dart';
import '../../SummonEntry/SummonViewPage.dart';
import '../../Transaction/SaleOrder/SalesOrderAdd.dart';
import '../Boarding/SpotSaleEntryView.dart';
import '../HR/AddEmployee.dart';
part 'package:maleva/DashBoard/Admin/mobileAdminDashboard.dart';
part 'package:maleva/DashBoard/Admin/tabletAdminDashboard.dart';

class AdminDashboard extends StatefulWidget {
  final Review? existingReview;
  final int initialTabIndex;
  final int? editId;

  const AdminDashboard({super.key,this.existingReview,this.editId,this.initialTabIndex = 0});

  @override
  AdminDashboardState createState() => AdminDashboardState();
}

class AdminDashboardState extends State<AdminDashboard> with TickerProviderStateMixin {
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
  int EmpId = 0;
  var ExpDate = "";
  static const List<String> DashBoardList = <String>['INV', 'SO', 'FW'];
  String? dropdownValueFW;
  TextEditingController searchController = TextEditingController();
  String dtpToDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  String dtpFromDate = DateFormat("yyyy-MM-dd").format(DateTime.now());

  String dtpEFromDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  String dtpEToDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  double totalAmount = 0;
  double totalBalance = 0;
   // Months are 1-indexed
  List<String> monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  List <dynamic> SaleDataAll=[];
  List <dynamic> SalewaitingbillingAll=[];
  List <dynamic> SaleDataWith=[];
  List <dynamic> SaleDataWithout=[];
  List <dynamic> SaleMonthData=[];
  List<EmployeeDetailsModel> EmployeeViewRecords = [];
  List<LicenseViewModel> LicenseViewRecords = [];
  List <dynamic> SaleCustReport=[];
  List <dynamic> SaleTransReport=[];

  List <SpeedingView> speedingRecords=[];
  List<TruckDetailsModel> truckData = [];
  List<DriverDetailsModel> driverData = [];

  List<FuelFilling> fuelFillingRecords = [];
  List<EngineHoursdata> EngineHoursRecords = [];
  List<FuelselectModel> fulerecord = [];
  List<BoDetailResponse> boiDetails = [];

  List <dynamic> SaleExpReport=[];
  List <dynamic> SaleEmployeeSalesReport=[];
  List <dynamic> SaleExpDetailsReport=[];
  List <dynamic> SaleExpReport2=[];
  List <dynamic> SaleFWReport=[];
  List <dynamic> SaleFWReport2=[];
  List<dynamic> spareList = [];
  List<dynamic> spareViewList = [];
  List <dynamic> Maintenancedata=[];
  List <dynamic> Maintenancedata1=[];

  List<Map<String, dynamic>>  ListMonthData=[];
  List<String> LoadMonthsList = [];
  String currentMonthName = "";

  String BillingStatus ="";

  late TabController _tabController;
  late TabController _tabmainController;
  final txtPort = TextEditingController();
  final txtRemarks = TextEditingController();

  List<PaymentPendingModel> masterList = [];
  List<InventoryModel> masterList1 = [];
  List<PaymentPendingModel> detailsList = []; // using same model for details as jqx had similar structure
  TextEditingController fromCtrl = TextEditingController();
  TextEditingController toCtrl = TextEditingController();

  DateTime? fromDate;
  DateTime? toDate;

  // UI state
  String searchText = "";
  bool loading = false;
  String selectedFilter = "All";
  String selectedPaidFilter = "All Payments";



  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();
  final _shopCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();

  final _reviewMsgCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  int? _selectedEmpId;
  int _selectedReview = 1;
  List<EmployeeModel> _employees = [];
  int DriverId = 0;
  //Email - Inbox
  EmployeeModel? _selectedEmployee;
  List<EmailModel> emails = [];
  int EmailId = 0;
  bool _showMobileField = false;


  int? selectedFilterId;
  final List<Map<String, dynamic>> Inventoryfilters = [
    {"id": 1, "name": "PTP"},
    {"id": 2, "name": "WP"},
    {"id": 3, "name": "NP"},
    {"id": 4, "name": "SP"},
    {"id": 5, "name": "Klia"},
    {"id": 6, "name": "PasirGudang"},
  ];
  List<RTIMasterViewModel> allRTIMasterList = [];
  List<RTIMasterViewModel> filteredRTIMasterList = [];

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController driverController = TextEditingController();
  final TextEditingController SummonTypeController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  final TextEditingController sparePartsController = TextEditingController();
  final TextEditingController PortPassController = TextEditingController();
  final TextEditingController TruckLcnMntController = TextEditingController();
  final TextEditingController LevyController = TextEditingController();
  final TextEditingController FuelController = TextEditingController();

  final TextEditingController VehicleNameController = TextEditingController();
  final TextEditingController AWBNoController = TextEditingController();
  final TextEditingController QuantityController = TextEditingController();
  final TextEditingController TotalWeightController = TextEditingController();
  String RdtpToDate = DateFormat("yyyy-MM-dd").format(DateTime.now());

  // Months are 1-indexed
  String RdtpFromDate = DateFormat("yyyy-MM-dd")
      .format(DateTime.now().subtract(Duration(days: 20)));
  File? _pickedImage;
  File? _pickedPDF;
  String? selectedJobType; // Truck Id
  String? selectedJobStatus; // Truck Id
  String? selectedPort; // Truck Id
  String? selectedCustomer; // Truck Id
  String? _NetworkImageUrl; // Truck Id
  final ImagePicker _picker = ImagePicker();
  String? selectedTruck; // Truck Id
  DateTime? selectedDate; // Selected Date
  final txtRTINo = TextEditingController();
  bool isChecked = false;
  CustomerModel? selectedCustomerView;
  int ?sid;
  int ?PSid;
  int ?CustomerVId ;
  List<dynamic> selectedDetails = [];
  int Status = 0;
  bool _isLoading = false;
  String selectedCountry = "Malaysia";
  String? selectedSummon;
  int TruckId = objfun.DriverTruckRefId ;
  List<String> malaysiaList = ["MAJLIS", "JPJ", "PDRM (traffic)"];
  List<String> singaporeList = ["LTA", "POLICE", "URA"];
  final List<String> filters = [
    "All",
    "Hire Purchase",
    "Vendor",
    "Utility",
    "Tenancy",
    "Monthly Purpose",
    "All Payments",
    "Paid",
    "Not Paid"
  ];
  final List<String> Paidfilters = [
    "All Payments",
    "Paid",
    "Not Paid"
  ];

  List<Map<String, dynamic>> receiptMaster = [];
  List<Map<String, dynamic>> receiptDetails = [];

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 3);
    _tabmainController = TabController(vsync: this, length: 26,initialIndex: widget.initialTabIndex);
     dtpEFromDate = DateFormat("yyyy-MM-dd").format(DateTime(now.year, now.month, 1));
    EmpId = objfun.EmpRefId;

    if (widget.editId != null && widget.editId != 0){
      int EId = widget.editId ?? 0;
      fetchData(EId);
    }

    startup();
    super.initState();
  }
  // Example of your function
  Future loaddata1() async {
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
  void myOnSearchBoxTap() {
    // Do whatever you want here
    debugPrint("User tapped search box!");
  }
  Future startup() async {
    monthIndex = now.month ;
    currentMonthName =  monthNames[monthIndex-1];
    dropdownValueFW = "INV";
    fromDate = DateTime.now();
    toDate = DateTime.now();
    loaddata(0);
    loaddata1();
    loadTruck();
    loadDrive();
    loadSpeeding();
    await OnlineApi.SelectJobStatus(context);
    await OnlineApi.SelectJobType(context);
    loadFuelFilling();
    loadEingeHours();
    loadfueldifference();
    LoadEmployeeViewRecords();
    loadReceipt();
    loadpettycash();
    fetchSalesReport(EmpId);
    loadTruckList();
    setState(() {
      progress = true;
    });
  }


  Future

  loadInventory({bool isDateSearch = false,int ?id} ) async {
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
  Future<void> loadTruckList() async {
    await OnlineApi.SelectTruckList(context, null);
    print("Truck Count: ${objfun.GetTruckList.length}");
    setState(() {}); // Refresh UI after list load
  }
  Future<void> submitData1(BuildContext context) async {
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
  Future<void> submitData(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

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
  Future loadReceipt({bool isDateSearch = false}) async {
    setState(() {
      progress = false;
    });

    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    String fromDateStr = DateFormat('yyyy-MM-dd').format(fromDate!);
    String toDateStr = DateFormat('yyyy-MM-dd').format(toDate!);


    if (isDateSearch && fromDate != null && toDate != null) {
      fromDateStr = DateFormat('yyyy-MM-dd').format(fromDate!);
      toDateStr = DateFormat('yyyy-MM-dd').format(toDate!);
    } else {
      // default one week logic (as you already have)
      DateTime now = DateTime.now();

      DateTime before30 = now.subtract(Duration(days: 900));

      fromDateStr = DateFormat('yyyy-MM-dd').format(before30);
      toDateStr = DateFormat('yyyy-MM-dd').format(now);

    }

    var master = {
      "tilldate": toDateStr,
      "fromdate": fromDateStr,
      "CompanyRefId" : objfun.Comid
    };


    await objfun.apiAllinoneSelectArray(
      "${objfun.apiSelectReceipt}",
      master,
      header,
      context,
    ).then((resultData) async {
      if (resultData != null && resultData.isNotEmpty) {
        setState(() {
          progress = true;
        });

        var data = resultData;

        if (data["Data1"] is List && data["Data1"].isNotEmpty)
        {
          receiptMaster = List<Map<String, dynamic>>.from(data["Data1"]);
        }
        totalAmount = 0;
        totalBalance = 0;

        if (receiptMaster.isNotEmpty) {
          var m = receiptMaster;       // First item
         for (int i = 0 ; i < m.length ; i++){
           totalAmount += double.tryParse(m[i]["BillAmount"].toString()) ?? 0;
           totalBalance += double.tryParse(m[i]["Balance"].toString()) ?? 0;
         }
        }


// Convert to 2 decimal
        totalBalance = double.parse(totalBalance.toStringAsFixed(2));
        totalAmount = double.parse(totalAmount.toStringAsFixed(2));

      }

    }).onError((error, stackTrace) {
      print("🔥 ERROR OCCURRED:");
      print(error);
      print(stackTrace);

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
  List<PaymentPendingModel> filteredMaster(){
    final q = searchText.trim().toLowerCase();
    return masterList.where((m) {
      // filter by category - assumes there is a field to match categories (example uses BankName or another)
      // If you have a specific field in model for Supplier/Category replace this condition accordingly.
      bool matchesFilter = selectedFilter == "All" ||
          (m.BankName != null && m.BankName!.toLowerCase() == selectedFilter.toLowerCase()) ||
          (m.SubExpenseName != null && m.SubExpenseName!.toLowerCase() == selectedFilter.toLowerCase()) ||
          // fallback: check ExpenseName contains filter text (useful if you encode category in name)
          (m.ExpenseName != null && m.ExpenseName!.toLowerCase().contains(selectedFilter.toLowerCase()));

      bool matchesSearch = q.isEmpty ||
          (m.ExpenseName != null && m.ExpenseName!.toLowerCase().contains(q)) ||
          (m.BankName != null && m.BankName!.toLowerCase().contains(q)) ||
          (m.SubExpenseName != null && m.SubExpenseName!.toLowerCase().contains(q));

      return matchesFilter && matchesSearch;
    }).toList();
  }
  double get _totalFiltered {
    final list = filteredMaster(); // <- FIX
    double total = 0;

    for (var m in list) {
      total += (m.Amount ?? 0);
    }
    return total;
  }
  void _openDetailPopup(PaymentPendingModel master) {
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

                  Text(master.ExpenseName ?? "",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text("Bank: ${master.BankName ?? ""}",
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
                            title: Text(d.SubExpenseName ?? ""),
                            subtitle: Text("Due: ${d.DueDate}"),
                            trailing: Text(
                              "RM ${((d.Amount ?? 0)).toStringAsFixed(2)}",
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
  List<PaymentPendingModel> _getRelatedDetails(PaymentPendingModel master) {
/*    print("---- DEBUG START ----");
    print("MASTER VALUE: '${master.SubExpenseName}'");

    for (var d in detailsList) {
      print("DETAIL VALUE: '${d.SubExpenseName}'");
    }

    print("---- DEBUG END ----");*/

    return detailsList.where((detail) =>
    detail.SubExpenseName?.toLowerCase().contains(
        master.SubExpenseName!.split(" ")[0].toLowerCase()
    ) ?? false
    ).toList();

  }
  Future loadData({bool isDateSearch = false}) async {
    setState(() {
      progress = false;
    });


    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    // final from = DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(Duration(days: 30)));
    // final to = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String FromDate;
    String ToDate;

    if (isDateSearch && fromDate != null && toDate != null) {
      FromDate = DateFormat('yyyy-MM-dd').format(fromDate!);
      ToDate = DateFormat('yyyy-MM-dd').format(toDate!);
    } else {
      // default one week logic (as you already have)
      DateTime now = DateTime.now();
      DateTime newDate = now.add(Duration(days: 6));
      FromDate = DateFormat('yyyy-MM-dd').format(newDate);
      ToDate = DateFormat('yyyy-MM-dd').format(newDate);
    }

    Map<String, dynamic> master = {};
    var type = 400;
    master = {

      'Comid': objfun.storagenew.getInt('Comid') ?? 0,
      'Fromdate': FromDate,
      'Todate': ToDate,
      'SupplierId': sid,
      'SupplierId1': PSid,

    };
    await objfun
        .apiAllinoneSelectArray(
        "${objfun.apiSelectPaymentPending}?Startindex=0&PageCount=$type"
        , master, header, context)
        .then((result) async {
      // The jqx code had Data[0].ExpenseReportModel and ExpenseReportDetailsModel
      // Handle common shapes:
      List<dynamic>? masterJson;
      List<dynamic>? detailsJson;

      if (result != null && result.isNotEmpty) {
        final first = result[0];

        // If API returns the nested object structure:
        if (first is Map && (first.containsKey('ExpenseReportModel') || first.containsKey('ExpenseReportDetailsModel'))) {
          masterJson = (first['ExpenseReportModel'] ?? []) as List<dynamic>?;
          detailsJson = (first['ExpenseReportDetailsModel'] ?? []) as List<dynamic>?;
        } else {
          // If API returns direct list of master rows, assume result is master list
          // Also attempt to find details array if present in result as second element
          if (result.length >= 2 && result[1] is List) {
            masterJson = result[0] as List<dynamic>?;
            detailsJson = result[1] as List<dynamic>?;
          } else {
            // fallback: assume entire result is master rows
            masterJson = result as List<dynamic>?;
            detailsJson = [];
          }
        }
      }

      // Map JSON to models (assuming PaymentPendingModel.fromJson exists)
      if (masterJson != null) {
        masterList = masterJson
            .map<PaymentPendingModel>((e) => PaymentPendingModel.fromJson(e))
            .toList();
      } else {
        masterList = [];
      }

      if (detailsJson != null) {
        detailsList = detailsJson
            .map<PaymentPendingModel>((e) => PaymentPendingModel.fromJson(e))
            .toList();
      } else {
        detailsList = [];
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
  String formatTruckDate(String dateString) {
    if (dateString == null || dateString.isEmpty) return "Not Available";

    List<String> formats = ['yyyy-MM-dd', 'yyyy/MM/dd'];

    for (var fmt in formats) {
      try {
        DateTime parsedDate = DateFormat(fmt).parse(dateString);
        return DateFormat('dd MMM yyyy').format(parsedDate); // e.g., 25 Nov 2025
      } catch (e) {
        // ignore and try next format
      }
    }

    return dateString; // fallback if parsing fails
  }
  List<PattycashMasterModel> pettycashMaster = [];
  List<PattyCashDetailsModel> pettycashDetails = [];
  Widget buildExpiryRow(String title, String date, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            "$title: ",
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          Expanded(
            child: Text(
              date,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
  Future loadpettycash() async {
    setState(() {
      progress = false;
    });

    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    String fromDateStr = DateFormat('yyyy-MM-dd').format(fromDate!);
    String toDateStr = DateFormat('yyyy-MM-dd').format(toDate!);

    await objfun.apiAllinoneSelectArray(
      "${objfun.apiGetpettycash}${objfun.Comid}"
          "&Fromdate=$fromDateStr"
          "&Todate=$toDateStr"
          "&Employeeid=0&Search=""&PaymentStatus=""&PaymentTo",
      null,
      header,
      context,
    ).then((resultData) async {
      if (resultData != null && resultData.isNotEmpty) {
        var data = resultData[0];
        if (data != null) {
          // Parse master data
          if (data['PattycashMasterModel'] != null) {
            pettycashMaster = (data['PattycashMasterModel'] as List)
                .map((item) => PattycashMasterModel.fromJson(item))
                .toList();
          }
          
          // Parse details data
          if (data['PattyCashDetailsModel'] != null) {
            pettycashDetails = (data['PattyCashDetailsModel'] as List)
                .map((item) => PattyCashDetailsModel.fromJson(item))
                .toList();
          }
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
  Future<void> pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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
  Future<void> fetchSalesReport(int empId) async {
    // Prepare request header
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    String currentDate = DateFormat('yyyy/MM/dd').format(DateTime.now());
    // Prepare request body
    Map<String, dynamic> master = {
      'Comid': objfun.storagenew.getInt('Comid') ?? 0,
      "DashboardStatus": 0,
      'Fromdate': '2025/08/16',
      "Employeeid ": 0,
      'Id':  0,
      "Invoice": true,
      'Offvesselname': "",
      "Invoicecheck": false,
      'Remarks':2,
      "Search": 3,
      'Todate': currentDate,
      "completestatusnotshow": false,
    };
    try {
      // Call API
      final resultData = await objfun.apiAllinoneSelectArray(
        objfun.apiSelectSaleorderinvoicecheck,
        master,
        header,
        context,
      );
      // If API returns data
      if (resultData != "") {
        setState(() {
          progress = true;
          SalewaitingbillingAll = List<Map<String, dynamic>>.from(resultData);
        });
      }
    } catch (error, stackTrace) {
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
      setState(() {
        progress = true; // finished loading (true means loaded in your logic)
      });
    }
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
//Maintenance Data
  Future loadMaintenance(String fromDate,String toDate) async {
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
  Future<void> LoadEmployeeViewRecords() async {
    setState(() {
      EmployeeViewRecords = [];
      progress = false;
    });

    var comid = objfun.storagenew.getInt('Comid') ?? 0;
    final keyword = ''; // ensure empty string
    final Column = 'All' ;
    final type = '' ;

    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    try {
      final apiUrl =
          "${objfun.apiSelectEmployeeDetails}$comid&Startindex=0&PageCount=100&keyword=$keyword&Column=$Column&type=$type";

      final resultData = await objfun.apiAllinoneSelectArray(
        apiUrl,
        '',
        header,
        context,
      );

      if (resultData != null && resultData is List) {
        final dataList = resultData;

        if (dataList != null && dataList is List && dataList.isNotEmpty) {
          final List<EmployeeDetailsModel> convertedList = dataList
              .map((item) => EmployeeDetailsModel.fromJson(item as Map<String, dynamic>))
              .toList();

          setState(() {
            EmployeeViewRecords = convertedList;
            progress = true;
          });
        } else {
          setState(() {
            progress = true;
          });
        }
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
  List<BoDetailResponse> boDetails = [];
  Future<void> loadBOC(String value) async {
    Map<String, dynamic> master = {
      "Comid": objfun.Comid,
      "Fromdate": "",
      "Todate": "",
      "Id": 0,
      "Employeeid": 0,
      "Search": value,
      "Remarks": 0,
      "status": "",
      "TId": 0,
      "DId": 0,
      "Offvesselname": ""
    };

    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    await objfun
        .apiAllinoneSelectArray(
      objfun.apiselectBillordercheck,
      master,
      header,
      context,
    )
        .then((resultData) async {
      if (resultData != null && resultData.isNotEmpty) {
        var data1 = resultData['Data1'] as List?; // ✅ Top-level array

        if (data1 != null && data1.isNotEmpty) {
          boDetails = data1
              .map((e) => BoDetailResponse.fromJson(e))
              .toList()
              .cast<BoDetailResponse>();
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
  void showBillingBottomSheet(BuildContext context, List<dynamic> billingData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Title + Close button
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Waiting for Billing Details",
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(),

                // Scrollable list with modern design
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: billingData.length,
                    itemBuilder: (context, index) {
                      final item = billingData[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Color(0xFFFAD691),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            // Open detailed dialog
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFAD691),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Billing Details",
                                                style: GoogleFonts.lato(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.close, color: Colors.black),
                                                onPressed: () => Navigator.pop(context),
                                              )
                                            ],
                                          ),
                                          const SizedBox(height: 12),

                                          // Details
                                          _buildDetailRow(Icons.confirmation_number, "Bill No", "${item['BillNoDisplay']}"),
                                          _buildDetailRow(Icons.date_range, "Bill Date", "${item['BillDate']}"),
                                          _buildDetailRow(Icons.access_time, "Bill Time", "${item['BillTime']}"),
                                          _buildDetailRow(Icons.assignment, "Job Status", "${item['JobStatus']}"),
                                          _buildDetailRow(Icons.person, "Customer", "${item['CustomerName']}"),
                                          _buildDetailRow(Icons.badge, "Employee", "${item['EmployeeName']}"),
                                          _buildDetailRow(Icons.local_shipping, "Vessel", "${item['Loadingvesselname']}"),
                                          _buildDetailRow(Icons.anchor, "Port", "${item['SPort']}"),
                                          _buildDetailRow(Icons.calendar_today, "Pickup Date", "${item['SPickupDate']}"),
                                          _buildDetailRow(Icons.flight_takeoff, "ETA", "${item['ETA']}"),
                                          _buildDetailRow(Icons.monetization_on, "Net Amount", "₹${item['NetAmt']}"),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                             child: Row(
                          children: [
                          // Left Icon inside circle
                          Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.receipt_long, color: Color(0xFFE67E22), size: 28),
                        ),
                        const SizedBox(width: 12),

                        // Texts
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Bill No: ${item['BillNo'] ?? ''}",
                                style: GoogleFonts.lato(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Customer: ${item['CustomerName'] ?? ''}",
                                style: GoogleFonts.lato(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF145A32),
                                ),
                              ),

                              const SizedBox(height: 2),
                              Text(
                                "Amount: ${item['NetAmt'] ?? ''}",
                                style: GoogleFonts.lato(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE67E22),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Trailing arrow inside box
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFE67E22)),
                        ),
                        ],
                      ),

                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
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
//Email - InBox
  Future<void> _loadEmployee() async {
    try {
      final comId = objfun.storagenew.getInt('Comid') ?? 0;

      final resultData = await objfun.apiAllinoneSelect(
        "${objfun.apiSelectEmployee}$comId&type=&type1=",
        null,
        null,
        context,
      );

      if (resultData != null && resultData.isNotEmpty) {
        final list = resultData
            .map<EmployeeModel>((e) => EmployeeModel.fromJson(e))
            .toList();

        setState(() => _employees = list);

        if (_employees.isNotEmpty) {
          _selectedEmployee = _employees.first;
          loadEmails(_selectedEmployee!.Id);
        }
      }
    } catch (e, stack) {
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
  Future<void> loadEmails(int empId) async {
    try {
      final header = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Comid': (objfun.storagenew.getInt('Comid') ?? 0).toString(),
      };

      final master = [
        {"Id": empId}
      ];

      final rawResult = await objfun. apiAllinoneMapSelect(
        objfun.apiSelectEmailData,
        master,
        header,
        context,
      );
      List<dynamic> emailsJson = [];
      final result = jsonDecode(rawResult);
      if (result is Map<String, dynamic>) {
        debugPrint("Raw API response: $result");

        if (result["unread_unreplied_emails"] is List) {
          emailsJson = result["unread_unreplied_emails"] as List;
        } else {
          debugPrint("⚠️ unread_unreplied_emails is not a list");
        }

        debugPrint("Emails JSON from API: $emailsJson");
      }

      setState(() {
        emails = emailsJson
            .map((e) => EmailModel.fromJson(e as Map<String, dynamic>))
            .toList();
      });

    } catch (e, stack) {
      setState(() => emails = []);
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
  Future<void> saveEmails() async {
    final confirm = await objfun.ConfirmationMsgYesNo(
      context,
      "Do You Want to Update?",
    );
    if (!confirm) return;

    // Only save emails where Active checkbox is true
    final toSave = emails.where((e) => e.isActive).toList();
    if (toSave.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No active emails selected to save")),
      );
      return;
    }

    setState(() => progress = true);

    try {
      final header = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Comid': (objfun.storagenew.getInt('Comid') ?? 0).toString(),
      };

      final payload = toSave.map((e) => {
        'Id': 0, // new email
        'EmployeeRefId': _selectedEmployee?.Id,
        'EmailID': e.emailId,
        'Subject': e.subject,
        'Sender': e.sender,
        'MessageId': e.messageId,
        'ReceivedDate': e.receivedDate.toIso8601String(),
        'Comid': objfun.storagenew.getInt('Comid') ?? 0,
        'IsUnread': e.isUnread ? 1 : 0,
        'IsReplied': e.isReplied ? 1 : 0,
        'Active': 1, // mark as active
      }).toList();

      final result = await objfun.apiAllinoneMapSelect(
        objfun.apiInsertMailMaster,
        payload,
        header,
        context,
      );

      if (result is String && result.isNotEmpty) {
        // Show result as success message
        await objfun.ConfirmationOK('Updated Successfully:\n$result', context);
        //  Navigator.pop(context);
      } else {
        // If result is empty or null
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
    } catch (e, stack) {
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
    } finally {
      setState(() => progress = false);
    }
  }
//Google - Review
  Future _saveReview() async {
    List<Map<String, dynamic>> master = [
      {
        "Id": widget.existingReview?.id ?? 0,
        "ShopName": _shopCtrl.text.trim().toUpperCase(),
        "MobileNo": _mobileCtrl.text.trim(),
        "GoogleReview": _selectedReview.toString(),
        "GoogleMsg": _reviewMsgCtrl.text.trim(),
        "RefDate": _selectedDate.toIso8601String().split('T')[0],
        "EmpReffid": _selectedEmpId!,
      }
    ];

    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    await objfun
        .apiAllinoneSelectArray(
      objfun.apiGoogleReviewInsert,
      master,
      header,
      context,
    )
        .then((resultData) async {
      if (resultData != null && resultData.toString().isNotEmpty) {
        // Case 1: resultData is a JSON object
        if (resultData is Map) {
          bool isSuccess = resultData['ok'] ?? false;
          String message = resultData['message'] ?? 'Something went wrong';

          await objfun.ConfirmationOK(message, context);
        }
        // Case 2: resultData is just a number (ID)
        else {
          int id = int.tryParse(resultData.toString()) ?? 0;

          if (id > 0) {
            await objfun.ConfirmationOK('Updated Successfully', context);
          } else {
            await objfun.ConfirmationOK('Unexpected response', context);
          }
        }
        _shopCtrl.clear();
        _mobileCtrl.clear();

        _reviewMsgCtrl.clear();
        _selectedDate = DateTime.now(); // reset to today or any default
        _selectedEmpId = null; // reset dropdown/selected employee
        _selectedReview = 1;
        setState(() {
          progress = true;
        });
      }

    }).onError((error, stackTrace) {
      setState(() {
        progress = true;
      });
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
