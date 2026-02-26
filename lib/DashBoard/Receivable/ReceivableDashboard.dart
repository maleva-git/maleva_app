import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/bluetooth/bluetoothmanager.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/menu/menulist.dart';
import 'package:maleva/core/models/model.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
part 'package:maleva/DashBoard/Receivable/mobileReceivableDashboard.dart';
part 'package:maleva/DashBoard/Receivable/tabletReceivableDashboard.dart';



class ReceivableDashboard extends StatefulWidget {
  const ReceivableDashboard({super.key});

  @override
  ReceivableDashboardState createState() => ReceivableDashboardState();
}

class ReceivableDashboardState extends State<ReceivableDashboard> with TickerProviderStateMixin {
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
  TextEditingController fromCtrl = TextEditingController();
  TextEditingController toCtrl = TextEditingController();
  List<dynamic> spareList = [];
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


  DateTime? fromDate;
  DateTime? toDate;
  bool loading = false;

  List<Map<String, dynamic>> receiptMaster = [];
  List<Map<String, dynamic>> receiptDetails = [];
  List <dynamic> SalewaitingbillingAll=[];
  int EmpId = 0;
  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 2);
    _tabmainController = TabController(vsync: this, length: 2);
    dtpEFromDate = DateFormat("yyyy-MM-dd").format(DateTime(now.year, now.month, 1));
    startup();
    super.initState();
  }

  Future startup() async {
    monthIndex = now.month ;
    currentMonthName =  monthNames[monthIndex-1];
    fromDate = DateTime.now();
    toDate = DateTime.now();
    dropdownValueFW = "INV";
    loaddata(0);
    loadMaintenance();
    fetchSalesReport(EmpId);
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
  Future loadReceipt() async {
    setState(() {
      progress = false;
    });

    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    String fromDateStr = DateFormat('yyyy-MM-dd').format(fromDate!);
    String toDateStr = DateFormat('yyyy-MM-dd').format(toDate!);

    await objfun.apiAllinoneSelectArray(
      "${objfun.apiGetReceipt}${objfun.Comid}"
          "&Fromdate=$fromDateStr"
          "&Todate=$toDateStr"
          "&SId=0&Employeeid=0&Search=",
      null,
      header,
      context,
    ).then((resultData) async {
      if (resultData != null && resultData.isNotEmpty) {
        setState(() {
          progress = true;
        });

        var data = resultData[0];

        if ((data["ReceiptMaster"] is List && data["ReceiptMaster"].isNotEmpty) &&
            (data["ReceiptDetails"] is List && data["ReceiptDetails"].isNotEmpty)) {

          receiptMaster = List<Map<String, dynamic>>.from(data["ReceiptMaster"]);
          receiptDetails = List<Map<String, dynamic>>.from(data["ReceiptDetails"]);
        }

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
  Future<void> fetchData() async {
    setState(() => progress = true);

    String from = fromDate != null
        ? DateFormat("yyyy-MM-dd").format(fromDate!)
        : DateFormat("yyyy-MM-dd").format(DateTime.now());

    String to = toDate != null
        ? DateFormat("yyyy-MM-dd").format(toDate!)
        : DateFormat("yyyy-MM-dd").format(DateTime.now());

    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    await objfun.apiAllinoneSelectArray(
      "${objfun.apiGetSpareParts}${objfun.Comid}&Fromdate=$from&Todate=$to",
      null,
      header,
      context,
    ).then((data) {
      setState(() {
        progress = false;
        print(data);
        spareList = List<Map<String, dynamic>>.from(
          data,
        );
      });
    }).onError((error, stack) {
      setState(() => progress = false);
      objfun.msgshow(error.toString(), stack.toString(), Colors.white,
          Colors.red, null, 16, objfun.tll, objfun.tgc, context, 2);
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
  Future<void> pickFromDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: fromDate ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));

    if (picked != null) {
      setState(() {
        fromDate = picked;
        fromCtrl.text = DateFormat("yyyy-MM-dd").format(picked);
      });
    }
  }
  Future<void> pickToDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: toDate ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));

    if (picked != null) {
      setState(() {
        toDate = picked;
        toCtrl.text = DateFormat("yyyy-MM-dd").format(picked);
      });
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

  Future loadReceiptView(String fromDate, String toDate) async {
    setState(() {
      progress = false;
    });

    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    await objfun
        .apiAllinoneSelectArray(
        "${objfun.apiGetReceiptView}${objfun.Comid}&Fromdate=$fromDate&Todate=$toDate",
        null,
        header,
        context)
        .then((resultData) async {
      if (resultData != "") {
        setState(() {
          progress = true;
        });

        Maintenancedata2 = resultData.map((e) => MaintenanceModel.fromJson(e)).toList();


     /*   for (var item in Maintenancedata2) {
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
        }*/
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
