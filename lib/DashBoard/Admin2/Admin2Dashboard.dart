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
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:http/http.dart' as http;
import '../../GoogleReview/ReviewGridScreen.dart';
import '../../MasterSearch/Port.dart';
import '../../Transaction/Enquiry/AddEnquiry.dart';
import '../../Transaction/SaleOrder/SalesOrderAdd.dart';
import '../Boarding/SpotSaleEntryView.dart';
import '../HR/AddEmployee.dart';
part 'package:maleva/DashBoard/Admin2/mobileAdminDashboard.dart';
part 'package:maleva/DashBoard/Admin2/tabletCustDashboard.dart';

class Admin2Dashboard extends StatefulWidget {
  final Review? existingReview;
  final int initialTabIndex;
  final int ?editId;
  const Admin2Dashboard({super.key,this.existingReview,this.editId, this.initialTabIndex = 0});

  @override
  CustDashboardState createState() => CustDashboardState();
}

class CustDashboardState extends State<Admin2Dashboard> with TickerProviderStateMixin {


  final _formKey = GlobalKey<FormState>();
  final _shopCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  File? _pickedImage;
  File? _pickedPDF;
  final ImagePicker _picker = ImagePicker();
  String? selectedTruck; // Truck Id
  bool loading = false;
  TextEditingController fromCtrl = TextEditingController();
  TextEditingController toCtrl = TextEditingController();
  final _reviewMsgCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  int? _selectedEmpId;
  int _selectedReview = 1;
  List<EmployeeModel> _employees = [];
  DateTime? fromDate;
  DateTime? toDate;
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
  String? selectedEmployee; // Truck Id
  String? selectedJobType; // Truck Id
  String? selectedJobStatus; // Truck Id
  String? selectedPort; // Truck Id
  String? selectedCustomer; // Truck Id
  String? _NetworkImageUrl; // Truck Id
  DateTime? selectedDate; // Selected Date
  bool _isLoading = false;
  String dtpToDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  String dtpFromDate = DateFormat("yyyy-MM-dd").format(DateTime.now());

  String dtpEFromDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  String dtpEToDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  List<dynamic> spareList = [];
  List<dynamic> spareViewList = [];
  List<InventoryModel> masterList = [];

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController driverController = TextEditingController();
  final TextEditingController VehicleNameController = TextEditingController();
  final TextEditingController AWBNoController = TextEditingController();
  final TextEditingController QuantityController = TextEditingController();
  final TextEditingController TotalWeightController = TextEditingController();
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
  final List<Map<String, dynamic>> filters = [
    {"id": 1, "name": "PTP"},
    {"id": 2, "name": "WP"},
    {"id": 3, "name": "NP"},
    {"id": 4, "name": "SP"},
    {"id": 5, "name": "Klia"},
    {"id": 6, "name": "PasirGudang"},
  ];
  int? selectedFilterId;
  List <dynamic> SaleExpReport=[];
  List <dynamic> SaleExpReport2=[];
  List <dynamic> SaleFWReport=[];
  List <dynamic> SaleFWReport2=[];
  static List<Map<String, dynamic>> RulesTypeEmployee=[];
  List <dynamic> SaleEmployeeSalesReport=[];
  List <dynamic> SalesReport=[];
  List<Map<String, dynamic>>  ListMonthData=[];
  List<String> LoadMonthsList = [];
  String currentMonthName = "";
  List <dynamic> SalewaitingbillingAll=[];
  late TabController _tabController;
  late TabController _tabmainController;
  final txtEmployee = TextEditingController();
  final txtPort = TextEditingController();
  final txtRemarks = TextEditingController();
  String? dropdownValueEMp;
  List<EmployeeDetailsModel> EmployeeViewRecords = [];
  List<LicenseViewModel> LicenseViewRecords = [];
  //Email - Inbox
  EmployeeModel? _selectedEmployee;
  List<EmailModel> emails = [];
  int EmailId = 0;
  bool isChecked = false;
  CustomerModel? selectedCustomerView;

  int ?CustomerVId ;

  int Status = 0;
  bool _showMobileField = false;
  Review? _existingReview;
  @override
  void initState() {

    _tabController = TabController(vsync: this, length: 3);
    _tabmainController = TabController(vsync: this, length: 11, initialIndex: widget.initialTabIndex);
    dtpEFromDate = DateFormat("yyyy-MM-dd").format(DateTime(now.year, now.month, 1));
    EmpId = objfun.EmpRefId;
    _loadEmployee();
    if(widget.existingReview !=null){
      final r = widget.existingReview!;
      _shopCtrl.text = r.shopName;
      _mobileCtrl.text = r.mobileNo ?? '';

      _selectedReview = int.tryParse(r.googleReview ?? '1') ?? 1;

      _reviewMsgCtrl.text = r.googleMsg ?? '';
      _selectedDate = r.supportDate;
      _selectedEmpId = r.empReffid;
    }
    if (widget.editId != null && widget.editId != 0){
      int EId = widget.editId ?? 0;
      fetchData(EId);
    }

    startup();
    super.initState();

  }

  Future startup() async {
    await OnlineApi.SelectJobStatus(context);
    await OnlineApi.SelectJobType(context);
    monthIndex = now.month ;
    currentMonthName =  monthNames[monthIndex-1];
    dropdownValueFW = "INV";
    loaddata(0);
    loadSalesdata();
    loadRulesType();
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
                                          color: Color(0xFF2C3E50), // Dark Navy for readability
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Customer: ${item['CustomerName'] ?? ''}",
                                        style: GoogleFonts.lato(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold, // 👈 makes text bold
                                          color: Color(0xFF145A32),    // Dark green for readability
                                        ),
                                      ),

                                      const SizedBox(height: 2),
                                      Text(
                                        "Amount: ₹${item['NetAmt'] ?? ''}",
                                        style: GoogleFonts.lato(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFE67E22), // Elegant orange highlight
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
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6A994E), ),
          const SizedBox(width: 8),
          Text(
            "$label:",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2723),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color:Color(0xFF2C3E50),),
            ),
          ),
        ],
      ),
    );
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
    await objfun.apiAllinoneSelectArray(
        objfun.LoadRulesType, master, header, context)
        .then((resultData) async {
      if (resultData != "") {
        setState(() {
          progress = true;

          // 🔹 fill the list with data
          RulesTypeEmployee.clear();
          for (var item in resultData) {
            RulesTypeEmployee.add(item);
          }

          // 🔹 set dropdown value if exists
          final ids = RulesTypeEmployee.map((e) => e['Id'].toString()).toList();
          if (ids.contains(objfun.EmpRefId.toString())) {
            dropdownValueEMp = objfun.EmpRefId.toString();
          } else {
            dropdownValueEMp = null;
          }
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
    await objfun
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
//Email - InBox

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
