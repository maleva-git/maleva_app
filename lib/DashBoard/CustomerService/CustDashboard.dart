import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/menu/menulist.dart';
import 'package:maleva/core/models/model.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;

import '../../MasterSearch/Port.dart';
import '../../Transaction/Enquiry/AddEnquiry.dart';
import '../../Transaction/SaleOrder/SalesOrderAdd.dart';
part 'package:maleva/DashBoard/CustomerService/mobileCustDashboard.dart';
part 'package:maleva/DashBoard/CustomerService/tabletCustDashboard.dart';

class CustDashboard extends StatefulWidget {
  const CustDashboard({super.key});

  @override
  CustDashboardState createState() => CustDashboardState();
}

class CustDashboardState extends State<CustDashboard> with TickerProviderStateMixin {
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
  List<FuelselectModel> fulerecord = [];
  List <dynamic> SalesReport=[];
  List<Map<String, dynamic>>  ListMonthData=[];
  List<String> LoadMonthsList = [];
  String currentMonthName = "";
  List<PaymentPendingModel> masterList = [];
  List<PaymentPendingModel> detailsList = []; // using same model for details as jqx had similar structure
  TextEditingController fromCtrl = TextEditingController();
  TextEditingController toCtrl = TextEditingController();
  DateTime? fromDate;
  DateTime? toDate;
  int ?sid;
  int ?PSid;
  int ?CustomerVId ;
  // UI state
  String searchText = "";
  bool loading = false;
  String selectedFilter = "All";

  String selectedPaidFilter = "All Payments";

  // radio/filter options
  final List<String> filters = [
    "All",
    "Hire Purchase",
    "Vendor",
    "Utility",
    "Tenancy",
    "Monthly Purpose"
  ];
  final List<String> Paidfilters = [
    "All Payments",
    "Paid",
    "Not Paid"
  ];

  late TabController _tabController;
  late TabController _tabmainController;
  final txtEmployee = TextEditingController();
  final txtPort = TextEditingController();
  final txtRemarks = TextEditingController();
  String? dropdownValueEMp;
  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 3);
    _tabmainController = TabController(vsync: this, length: 6);
     dtpEFromDate = DateFormat("yyyy-MM-dd").format(DateTime(now.year, now.month, 1));
    EmpId = objfun.EmpRefId;
    startup();
    super.initState();

  }

  Future startup() async {
    monthIndex = now.month ;
    currentMonthName =  monthNames[monthIndex-1];
    dropdownValueFW = "INV";
    loadSalesdata();
    loadRulesType();
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
  double get _totalFiltered {
    final list = filteredMaster(); // <- FIX
    double total = 0;

    for (var m in list) {
      total += (m.Amount ?? 0);
    }
    return total;
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
  Future loadSalesdata() async {
    setState(() {
      progress = false;
    });
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    DateTime now = DateTime.now();
    DateTime newDate = now.add(const Duration(days: 0));
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    String FromDate = DateFormat('yyyy-MM-dd').format(firstDayOfMonth);
    String ToDate = DateFormat('yyyy-MM-dd').format(newDate);
  // Get the current date and time


    Map<String, dynamic> master = {};

    master = {

      'Comid': objfun.storagenew.getInt('Comid') ?? 0,
      'Fromdate': "2024-10-01",
      'Todate': ToDate,
      "Statusid": 0,
      "Employeeid": EmpId ,
      "Remarks": 2,
      "Search": "0",
      "completestatusnotshow": false,
      "Invoice": false,

    };
    await objfun
        .apiAllinoneSelectArray(
        objfun.SaleInvoiceCountDB, master, header, context)
        .then((resultData) async {
      if (resultData != "") {
        setState(() {
          progress = true;
        });

        withoutInvoiceCount=resultData.length;


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

    master = {

      'Comid': objfun.storagenew.getInt('Comid') ?? 0,
      'Fromdate': FromDate,
      'Todate': ToDate,
      "Statusid": 0,
      "Employeeid": EmpId ,
      "Remarks": 0,
      "Search": "0",
      "completestatusnotshow": false,
      "Invoice": false,

    };
    await objfun
        .apiAllinoneSelectArray(
        objfun.SaleInvoiceCountDB, master, header, context)
        .then((resultData) async {
      if (resultData != "") {
        setState(() {
          progress = true;
        });

          TotalCount=resultData.length;


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

    master = {

      'Comid': objfun.storagenew.getInt('Comid') ?? 0,
      'Fromdate': FromDate,
      'Todate': ToDate,
      "Statusid": 0,
      "Employeeid":EmpId ,
      "Remarks": 1,
      "Search": "0",
      "completestatusnotshow": false,
      "Invoice": false,

    };
    await objfun
        .apiAllinoneSelectArray(
        objfun.SaleInvoiceCountDB, master, header, context)
        .then((resultData) async {
      if (resultData != "") {
        setState(() {
          progress = true;
        });

        TotalBilledCount=resultData.length;


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

    master = {

      'Comid': objfun.storagenew.getInt('Comid') ?? 0,
      'Fromdate': FromDate,
      'Todate': ToDate,
      "Statusid": 0,
      "Employeeid": EmpId ,
      "Remarks": 2,
      "Search": "0",
      "completestatusnotshow": false,
      "Invoice": false,

    };
    await objfun
        .apiAllinoneSelectArray(
        objfun.SaleInvoiceCountDB, master, header, context)
        .then((resultData) async {
      if (resultData != "") {
        setState(() {
          progress = true;
        });

        TotalUnBilledCount=resultData.length;


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

    master = {

      'Comid': objfun.storagenew.getInt('Comid') ?? 0,
      "Employeeid": EmpId ,

    };
    await objfun
        .apiAllinoneSelectArray(
        objfun.SelectSalesOrderStatus, master, header, context)
        .then((resultData) async {
      if (resultData != "") {
        setState(() {
          progress = true;
        });

        SalesReport=resultData;


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


  // apply search + radio filter
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

  Future loadRulesType() async {
    setState(() {
      progress = false;
    });
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    Map<String, dynamic> master = {};

    master = {
      'Comid': objfun.storagenew.getInt('Comid') ?? 0,
      "Employeeid": objfun.EmpRefId ,
    };
    await objfun
        .apiAllinoneSelectArray(
        objfun.LoadRulesType, master, header, context)
        .then((resultData) async {
      if (resultData != "") {
        setState(() {
          progress = true;
        });
        RulesTypeEmployee.clear();
        for(var i = 0 ; i < resultData.length ; i++)
        {
          RulesTypeEmployee.add(resultData[i]);

        }
        dropdownValueEMp = objfun.EmpRefId.toString();

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
  Future loadEnqdata() async {
    setState(() {
      progress = false;
    });

    Map<String, dynamic> master = {
      "Comid": objfun.storagenew.getInt('Comid') ?? 0,
      "Fromdate": null,
      "Todate": null,
      "Employeeid": objfun.EmpRefId,
      "Invoice": false,
      "Id": 0,
      "JId": 0,
      "DashboardStatus": 2,
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
  Future loadEmpSalesdata(int type) async {
    setState(() {
      progress = false;
    });
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    await  objfun
        .apiAllinoneSelectArray(
        "${objfun.apiGetEmployeeSalesData}${objfun.Comid}&type=$type", null, header, context)
        .then((resultData) async {
      if (resultData != "") {
        setState(() {
          progress = true;
        });
        if (resultData.length != 0) {
          var SaleEmployeeSalesReport=resultData["Data1"];
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
        loadEnqdata();

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
  Color? _CardColorVessel(int index) {

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
  Future<void> _showDialogEnqDetails(Map detailsList) async {
    var CollectionDate = "";
    var EtaDate = "";
    var OEtaDate = "";
    if(detailsList["SPickupDate"] != ""){
      CollectionDate = DateFormat('dd-MM-yyyy HH:mm').format(DateTime.parse(detailsList["PickupDate"])).toString();
    }
    if(detailsList["SETA"] != ""){
      EtaDate = DateFormat('dd-MM-yyyy HH:mm').format(DateTime.parse(detailsList["ETA"])).toString();
    }
    if(detailsList["SOETA"] != ""){
      OEtaDate = DateFormat('dd-MM-yyyy HH:mm').format(DateTime.parse(detailsList["OETA"])).toString();
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
                        Text("L Vessel : ${detailsList["Loadingvesselname"]}",style:GoogleFonts
                            .lato(
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colour
                                  .commonColor,
                            )),),
                        Text("O Vessel : ${detailsList["Offvesselname"]}",style:GoogleFonts
                            .lato(
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colour
                                  .commonColor,
                            )),),
                        Text("ETA : $EtaDate",
                            style:GoogleFonts.lato(
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colour
                                      .commonColor,
                                ))),
                        Text("OETA : $OEtaDate",
                            style:GoogleFonts.lato(
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colour
                                      .commonColor,
                                ))),
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
  late File ff;
  bool show = false;
  @override
  Widget build(BuildContext context) {
    return objfun.MalevaScreen == 1
        ? mobiledesign(this, context)
        : tabletdesign(this, context);

  }
}
