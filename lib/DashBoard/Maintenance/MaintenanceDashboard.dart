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
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/menu/menulist.dart';
import 'package:maleva/core/models/model.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:http/http.dart' as http;
import '../../MasterSearch/Port.dart';
import 'package:intl/intl.dart';
import 'package:maleva/Transaction/SaleOrder/SalesOrderAdd.dart';

import '../../SparePartsEntry/SparePartsViewPage.dart';

part 'package:maleva/DashBoard/Maintenance/mobileMaintenanceDashboard.dart';
part 'package:maleva/DashBoard/Maintenance/tabletMaintenanceDashboard.dart';



class MaintenanceDashboard extends StatefulWidget {
  const MaintenanceDashboard({super.key});

  @override
  MaintenanceDashboardState createState() => MaintenanceDashboardState();
}

class MaintenanceDashboardState extends State<MaintenanceDashboard> with TickerProviderStateMixin {
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

  List <dynamic> Maintenancedata=[];
  List <dynamic> Maintenancedata1=[];
  List <dynamic> Maintenancedata2=[];

  List <SpeedingView> speedingRecords=[];
  List<TruckDetailsModel> truckData = [];
  List<DriverDetailsModel> driverData = [];
  List<FuelFilling> fuelFillingRecords = [];
  List<EngineHoursdata> EngineHoursRecords = [];
  DateTime? fromDate;
  DateTime? toDate;

  TextEditingController fromCtrl = TextEditingController();
  TextEditingController toCtrl = TextEditingController();


  List<dynamic> spareList = [];

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

  double breakdownAmount = 0;
  int breakdownCount = 0;

  double repairAmount = 0;
  int repairCount = 0;

  double serviceAmount = 0;
  int serviceCount = 0;

  double sparePartsAmount = 0;
  int sparePartsCount = 0;

  var commonexpirydays = 15;
  var ExpDate = "";
  final Color themeColor = Colors.deepOrange;

  late TabController _tabController;
  late TabController _tabmainController;
  final txtPort = TextEditingController();
  final txtRemarks = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController driverController = TextEditingController();
  final TextEditingController sparePartsController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  File? _pickedImage;
  File? _pickedPDF;
  final ImagePicker _picker = ImagePicker();
  String? selectedTruck; // Truck Id
  DateTime? selectedDate; // Selected Date
  bool _isLoading = false;


  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 3);
    _tabmainController = TabController(vsync: this, length: 10);
    dtpEFromDate = DateFormat("yyyy-MM-dd").format(DateTime(now.year, now.month, 1));
    startup();
    super.initState();
    loadTruckList();
  }
  Future<void> loadTruckList() async {
    await OnlineApi.SelectTruckList(context, null);
    print("Truck Count: ${objfun.GetTruckList.length}");
    setState(() {}); // Refresh UI after list load
  }
  Future startup() async {
    monthIndex = now.month ;
    currentMonthName =  monthNames[monthIndex-1];

    dropdownValueFW = "INV";
    loaddata(0);
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

  late File ff;
  bool show = false;

  @override
  Widget build(BuildContext context) {
    return objfun.MalevaScreen == 1
        ? mobiledesign(this, context)
        : tabletdesign(this, context);

  }
}
