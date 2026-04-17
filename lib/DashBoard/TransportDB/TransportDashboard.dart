import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:maleva/GoogleReview/ReviewGridScreen.dart';
import 'package:maleva/Transaction/EnquiryTR/AddEnquiryTR.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/menu/menulist.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:http/http.dart' as http;
import '../../Transaction/SaleOrder/SalesOrderAdd.dart';
part 'package:maleva/DashBoard/TransportDB/mobileTransportDashboard.dart';
part 'package:maleva/DashBoard/TransportDB/tabletTransportDashboard.dart';

class TransportDashboard extends StatefulWidget {
  final Review? existingReview;
  final int initialTabIndex;
  const TransportDashboard({super.key,this.existingReview, this.initialTabIndex = 0});

  @override
  TransportDashboardState createState() => TransportDashboardState();
}

class TransportDashboardState extends State<TransportDashboard> with TickerProviderStateMixin {
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
  List<dynamic> selectedDetails = [];
  final ImagePicker _picker = ImagePicker();
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
  final TextEditingController searchController = TextEditingController();
  final txtRTINo = TextEditingController();
  List <dynamic> SalesReport=[];
  List<Map<String, dynamic>>  ListMonthData=[];
  List<String> LoadMonthsList = [];
  String currentMonthName = "";

  late TabController _tabController;
  late TabController _tabmainController;
  final txtEmployee = TextEditingController();
  String? dropdownValueEMp;
  int DriverId = 0;
  List<EmployeeModel> _employees = [];

  final txtPort = TextEditingController();
  final txtRemarks = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _shopCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  int TruckId = objfun.DriverTruckRefId ;
  final _reviewMsgCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  int? _selectedEmpId;
  int _selectedReview = 1;
  String RdtpToDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  String RdtpFromDate = DateFormat("yyyy-MM-dd")
      .format(DateTime.now().subtract(Duration(days: 10)));

  List<RTIMasterViewModel> allRTIMasterList = [];
  List<RTIMasterViewModel> filteredRTIMasterList = [];
  //Email - Inbox
  EmployeeModel? _selectedEmployee;
  List<EmailModel> emails = [];
  int EmailId = 0;
  bool _showMobileField = false;
  bool _isLoading = false;

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 3);
    _tabmainController = TabController(vsync: this, length: 6, initialIndex: widget.initialTabIndex);
     dtpEFromDate = DateFormat("yyyy-MM-dd").format(DateTime(now.year, now.month, 1));
    EmpId = objfun.EmpRefId;
    loaddata1();
    startup();
    super.initState();

  }


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
        for (var item in resultData) {
          RulesTypeEmployee.add(item);
        }
        final ids = RulesTypeEmployee.map((e) => e['Id'].toString()).toList();
        if (ids.contains(objfun.EmpRefId.toString())) {
          dropdownValueEMp = objfun.EmpRefId.toString();
        } else {
          dropdownValueEMp = null;
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
      FromDate = "2025-02-01";
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
        objfun.VESSELPLANINGDB, master, header, context)
        .then((resultData) async {
      if (resultData != "") {
        setState(() {
          progress = true;
        });
        if (resultData.length != 0) {
          SaleCustReport=resultData;


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
  Future<void> _showDialogVessel(Map detailsList) async {

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
                        Text("Customer : ${detailsList["CustomerName"]}",style:GoogleFonts
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
                        Text("AWB/BL No : ${detailsList["AWBNo"]}/${detailsList["BLCopy"]}",style:GoogleFonts
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

      final rawResult = await objfun.apiAllinoneMapSelect(
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

  late File ff;
  bool show = false;

  @override
  Widget build(BuildContext context) {
    return objfun.MalevaScreen == 1
        ? mobiledesign(this, context)
        : tabletdesign(this, context);

  }
}
