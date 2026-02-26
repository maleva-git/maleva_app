import 'dart:convert';
import 'dart:io';
import 'package:flutter/Material.dart';
import 'package:flutter/Material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:http/http.dart' as http;
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import '../../menu/menulist.dart';
import '../../core/models/model.dart';
import '../Boarding/SpotSaleEntryView.dart';
part 'package:maleva/DashBoard/WareHouse/mobileWareHouseDashboard.dart';


class Warehousedashboard extends StatefulWidget {
  final int? editId;
  final int initialTabIndex;
  const Warehousedashboard({super.key, this.editId,this.initialTabIndex = 0});


  @override
  WarehousedashboardState createState() => WarehousedashboardState();
}

class WarehousedashboardState extends State<Warehousedashboard>  with TickerProviderStateMixin{

  late TabController _tabmainController;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
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
  int Status = 0;
  int ?CustomerVId ;
  List<dynamic> selectedDetails = [];
  DateTime? fromDate;
  DateTime? toDate;
  bool progress = false;
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
  bool _isLoading = false;
  // Months are 1-indexed
  String RdtpFromDate = DateFormat("yyyy-MM-dd")
      .format(DateTime.now().subtract(Duration(days: 20)));
  final List<Map<String, dynamic>> Inventoryfilters = [

    {"id": 2, "name": "WP"},
    {"id": 3, "name": "NP"},
    {"id": 4, "name": "SP"},

  ];
  int? selectedFilterId;
  List<InventoryModel> masterList1 = [];
  TextEditingController fromCtrl = TextEditingController();
  TextEditingController toCtrl = TextEditingController();
  bool loading = false;

  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 3);
    _tabmainController = TabController(vsync: this, length: 2,initialIndex: widget.initialTabIndex);

    startup();
    super.initState();
  }
  Future startup() async {
    await OnlineApi.SelectJobStatus(context);
    await OnlineApi.SelectJobType(context);
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
  @override
  Widget build(BuildContext context) {
    return mobiledesign(this, context);
  }
}
