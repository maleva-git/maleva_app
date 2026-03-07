library tabletpos.globals;

import 'dart:async';
import 'dart:convert';
import 'dart:core' as cc;
import 'dart:io';
import 'package:bluetooth_print_plus/bluetooth_print_plus.dart' as bpp;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:maleva/DashBoard/User/UserDashboard.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
import 'package:flutter/material.dart' as col;
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';
import 'package:app_version_update/app_version_update.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import '../../MasterSearch/Employee.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/pages/login_page.dart.dart';
import 'package:url_launcher/url_launcher.dart';
String appversion="1.1.10+97";
bool homepagecall = false;
AssetImage logo = const AssetImage('assets/company/logo.png');
AssetImage splashlogo = const AssetImage('assets/company/roundlogo.png');
AssetImage calendar = const AssetImage('assets/common/calendar.png');
AssetImage lockimg = const AssetImage('assets/common/lockImg.png');

// String port0 = "http://192.168.1.100:8085/";
// String port = "http://192.168.1.13:9007/";
//String port = "http://103.215.139.8:8001/";
// String port = "http://192.168.1.101:8003/";
//String port = "http://103.215.139.121:9001/"; //Demos
//String port = "http://103.215.139.8:8001/"; //Demolatest
String port = "https://maleva.my"; //Live

//String razorpaykey = "rzp_live_GmuWNB2PVXAnLt";

String imagepath = "$port/Upload/$Comid/";
String apiPostimage = "$port/api/CommonApp/UploadFile/";
String apiPostfile = "$port/api/CommonApp/UploadFile2/";
String apiuploadpdffile = "$port/api/CommonApp/UploadPdfFile/";
String apiGetimage = "$port/api/CommonApp/FetchFiles?ImageDirectory=";
String apiDeleteimage = "$port/api/CommonApp/DeleteFile";
//String apiPostimage = port + "/api/SaleOrderApp/ImageUpload/";

String apiInsertForwarding = "$port/api/ForwardingSalaryApp/InsertForwardingSalary";
String apiSelectForwarding = "$port/api/ForwardingSalaryApp/SelectForwardingSalary";

String apiLoginSuccess = "$port/api/LoginApp/LoginAppSuccess?Userid=";
String apiSelectUser = "$port/api/LoginApp/SelectLoginUser?Comid=";
String apiSelectCustomer = "$port/api/CustomerApp/GetCustomer?Comid=";
String apiSelectLocation = "$port/api/LocationApp/SelectLocation?Comid=";

String apiSelectEmployee = "$port/api/EmployeeApp/GetEmployee?Comid=";
String apiSelectEmailData = "$port/api/EmployeeApp/SelectEmailData";
String apiInsertMailMaster = "$port/api/EmployeeApp/InsertMailMaster";
//New
String apiUpdateSaleOrderMaster = "$port/api/SaleOrderApp/UpdateSaleorderMaster";

String apiSelectJobStatus = "$port/api/JobStatusApp/SelectJobStatus?Comid=";
String apiMaxSaleOrderNo = "$port/api/SaleOrderApp/MaxSaleOrderNo?Comid=";
String apiSelectJobType = "$port/api/JobTypeApp/SelectJobType?Comid=";
String apiSelectAllJobStatus = "$port/api/JobTypeApp/SelectJobAllData?Comid=";
String apiGetRTINo = "$port/api/RTIApp/SelectRTINo?Comid=";
String apiSelectAgentCompany =
    "$port/api/AgentCompanyApp/SelectAgentCompany?Comid=";
String apiSelectAgentAll = "$port/api/AgentApp/SelectAgentAll?Comid=";
String apiGetProductList = "$port/api/ItemApp/GetProductList?Comid=";
String apiSelectAddressList =
    "$port/api/AddressApp/SelectDistinctAddress?Comid=";
String apiSelectSalesOrder = "$port/api/SaleOrderApp/SelectSaleOrder";
String apiSelectTVSaleOrder = "$port/api/SaleOrderApp/SelectTVSaleOrder";
String apiEditPassword = "$port/api/LoginApp/EditPassword?password=";
String apiEditSalesOrder = "$port/api/SaleOrderApp/EditSaleOrder?Id=";
String apiInsertSalesOrder = "$port/api/SaleOrderApp/InsertSaleOrder";
String apiDeleteSalesOrder = "$port/api/SaleOrderApp/DeleteSaleOrder?Id=";
String apiSelectAddressDetails = "$port/api/AddressApp/SelectAddress?Comid=";
String apiGetJobNo = "$port/api/SaleOrderApp/GetJobNo?Comid=";
String apiUpdateForwarding = "$port/api/SaleOrderApp/UpdateForwarding";
String apiUpdateBoardingDetails = "$port/api/SaleOrderApp/UpdateBoardingDetails";
String apiUpdateBoardingOfficer = "$port/api/SaleOrderApp/UpdateBoardingOfficier";
String apiUpdateAirFrieghtDetails = "$port/api/SaleOrderApp/UpdateAirFrieght";
String apiselectBillordercheck = "$port/api/SaleOrderApp/GetBillordercheck";
String apiGetTruckList = "$port/api/TruckApp/GetTruck?Comid=";

String apiGetReceipt = "$port/api/ReceiptApp/SelectReceipt?Comid=";
String apiSelectReceipt = "$port/api/TransactionReportApp/SelectCustomerBalance";
String apiGetpettycash = "$port/api/BIllorderApp/SelectpetticashApp?Comid=";
String apiGeteditepettycash = "$port/api/BIllorderApp/SelectpetticashApp?Comid=";

//Employee

String apiSelectEmployeeDetails = "$port/api/EmployeeApp/SelectEmployee?Comid=";
String apiInsertEmployeeDetails = "$port/api/EmployeeApp/InsertEmployee";
String apiSelectEmployeeType = "$port/api/EmployeeApp/SelectEmployeeType";
String apiDeleteEmployeeType = "$port/api/EmployeeApp/DeleteEmployee?Id=";

String apiSelectPaymentPending = "$port/api/DashBoardApp/SelectPendingPayment";

String apiSelectAllInventory = "$port/api/CustomerApp/SelectAllInventoryt";

String apiSelectTruckDetails = "$port/api/MasterReportApp/TruckReportView";

String apiSelectDriverDetails = "$port/api/MasterReportApp/DriverReportView";

String apiSelectSpeedingReport = "$port/api/MasterReportApp/SpeedingReportView";
String apiSelectFuelFillingReport = "$port/api/MasterReportApp/SelectFuelFillings";
String apiSelectEangiehoursReport = "$port/api/MasterReportApp/SelectEngineHours";
String apiSelectDriverSalary = "$port/api/TransactionReportApp/DriverRTIDetailedReport";
String apiSelectBoardingSalary = "$port/api/SaleOrderApp/GetBoardingSalary";
String apiSelectGoogleReview = "$port/api/EmployeeApp/SelectGoogleReview";
String apiDeleteGoogleReview = "$port/api/EmployeeApp/DeleteGoogleReview?Id=";
/// Declear the  varibale  call  for the  checlsaleorder invoice
String apiSelectSaleorderinvoicecheck = "$port/api/MasterReportApp/SelectChecksalesinvoice";
String apiEditTruckDetails = "$port/api/TruckApp/SelectTruck?Comid=";

String apiUpdateTruckDetails = "$port/api/TruckApp/InsertTruck?Comid=";
String apiGetDriverList = "$port/api/DriverApp/GetDriver?Comid=";
String apiSelectRTIView = "$port/api/RTIApp/SelectRTI?Comid=";
String apiSelectRTIDetailsView = "$port/api/RTIApp/SelectRTIView?Comid=";
String apiViewRTIPdf = "$port/api/RTIApp/RTIVIEW?RTINo=";
String apiRTIMail = "$port/api/RTIApp/SendStatusMail";
String apiViewDOConvert = "$port/api/SaleOrderApp/DoConvert?BillNo=";
String apiViewInvoice = "$port/api/SaleOrderApp/InvoiceConvert?BillNo=";
String apiGetSalesData = "$port/api/LoginApp/GetSalesData?Comid=";
String apiGetEmployeeSalesData = "$port/api/LoginApp/GetEmployeeSalesData?Comid=";
String apiGetEmployeeInvData = "$port/api/LoginApp/GetEmployeeInvData?Comid=";
String apiGetFWData = "$port/api/LoginApp/GetFWData?Comid=";

String apiGetMaintenance = "$port/api/DashboardApp/LoadSupplierExpenseData?Comid=";
String apiGetMaintenance1 = "$port/api/DashboardApp/LoadExpenseData?Comid=";
String apiGetMaintenance2= "$port/api/DashboardApp/SelectStatusBO?Comid=";
String apiGetReceiptView= "$port/api/ReceiptApp/SelectTruck?Comid=";

String apiGetExpData = "$port/api/LoginApp/GetExpData?Comid=";
String apiGetComboS1 = "$port/api/SaleOrderApp/SelectComboS1?Comid=";
String apiGetCurrencyValue = "$port/api/SaleOrderApp/GetCurrencyValue?Comid=";
String apiBoardingMail = "$port/api/SaleOrderApp/SendBoardingMail";

String apiSelectExpenseDetails = "$port/api/DashboardApp/SelectExpenseName";


String apiGoogleReviewInsert = "$port/api/EmployeeApp/InsertGoogleReview";

String apiRTIDetailsInsert = "$port/api/RTIApp/InsertRTIStatus?Comid=";

//PreAlert Report

String apiPreAlertReport = "$port/api/TransactionReportApp/PreAlertReport?PreAlertName=";
String apiViewPlanningPdf = "$port/api/PlanningApp/PLANINGVIEW?PlanningNo=";
String apiSelectPlanning = "$port/api/PlanningApp/SelectPLANING";
String apiEditPlanning = "$port/api/PlanningApp/EditPLANING?Id=";
String PLANINGSearch = "$port/api/PlanningApp/PLANINGSearch";

String AirFrieghtDB = "$port/api/DashBoardApp/AirFrieghtDB";
String VESSELPLANINGDB = "$port/api/DashBoardApp/VESSELPLANINGDB";
String PLANINGSearchDB = "$port/api/DashBoardApp/PLANINGSearchDB";
String PLANINGDriverSearch = "$port/api/DashBoardApp/PLANINGDriverSearch";
String SaleInvoiceCountDB = "$port/api/DashBoardApp/CheckSaleInvoiceCount";


String SelectSalesOrderStatus = "$port/api/DashBoardApp/SelectSalesOrderStatus";


String LoadRulesType = "$port/api/DashBoardApp/LoadRulesType";
String LoadUnReleaseNo = "$port/api/DashBoardApp/LoadUnReleaseNo";
String LoadK8UnReleaseNo = "$port/api/DashBoardApp/LoadK8UnReleaseNo";

String apiViewVesselPlanningPdf = "$port/api/VesselPlanningApp/VESSELPLANINGVIEW?VesselPlanningNo=";
String apiSelectVesselPlanning = "$port/api/VesselPlanningApp/SelectVESSELPLANING";
String apiEditVesselPlanning = "$port/api/VesselPlanningApp/EditVESSELPLANING?Id=";
//Fuel Entry
String apiInsertFuelEntry = "$port/api/FuelEntryApp/InsertFuelEntry";
String apiMaxFuelEntryNo = "$port/api/FuelEntryApp/MaxFuelEntryNo?Comid=";
String apiDeleteFuelEntry = "$port/api/FuelEntryApp/DeleteFuelEntry?Id=";
String apiEditFuelEntry = "$port/api/FuelEntryApp/EditFuelEntry?Id=";
String apiSelectFuelEntry = "$port/api/FuelEntryApp/SelectFuelEntry";

String apiInsertEnquiry = "$port/api/EnquiryMasterApp/InsertEnquiryMaster";
String apiSelectEnquiryMaster = "$port/api/EnquiryMasterApp/SelectEnquiryMaster";
String apiUpdateEnquiryMaster = "$port/api/EnquiryMasterApp/UpdateEnquiryMaster?Id=";
//Driver view
  String apiDriverViewRecords = "$port/api/DriverApp/SelectDriver?Comid=";
  //comit
  String apiBillorderview = "$port/api/BIllorderApp/SelectBillsOrderApp?Comid=";
  String apiPettyCashview = "$port/api/PettyCashApp/SelectPettyCashMaster?Comid=";
  String apiLicenseViewRecords = "$port/api/LicenseApp/SelectLicense";
//Stock
String apiSelectStockDetails = "$port/api/StockApp/SelectSaleStock?Comid=";
String apiEditStockIn = "$port/api/StockApp/EditStockIn?Id=";
String apiUpdateStockIn = "$port/api/StockApp/UpdateStockIn?Id=";
String apiUpdateStockTransfer = "$port/api/StockApp/UpdateStockTransfer?Id=";
String apiInsertStockIn = "$port/api/StockApp/InsertStockIn?Comid=";
String apiMaxStockNo = "$port/api/StockApp/MaxStockInNo?Comid=";
String apiSaleOrderDetailsLoad = "$port/api/StockApp/SelectSaleStock?Comid=";
String apiPrintStock = "$port/api/StockApp/SelectStockPrint?Id=";
String apiSelectStockJob = "$port/api/StockApp/SelectStockJob?Comid=";

String apiWareHouseCombo = "$port/api/StockApp/SelectPortList?Comid=";
String apiInsertSpareParts = "$port/api/TruckSparePartsApp/InsertSpareParts";
String apiGetSpareParts = "$port/api/TruckSparePartsApp/SelectSpareParts?Comid=";


String apiInsertSpotSaleEntry = "$port/api/TruckSparePartsApp/InsertSpotSaleEntry";
String apiGetSpotSaleEntry = "$port/api/TruckSparePartsApp/SelectSpotSaleEntry?Comid=";

String apiInsertSummonParts = "$port/api/TruckSparePartsApp/InsertSummon";
String apiGetSummonParts = "$port/api/TruckSparePartsApp/SelectSummon?Comid=";


final navigatorKey = GlobalKey<NavigatorState>();
SharedPreferences storagenew = storagenew;
final txtLoginEmployee = TextEditingController();
final txtLoginPassword = TextEditingController();
var commonexpirydays = 15;
var ExpenseDueDays = 5;
var apadbonamexpirydays = 60;
var ExpServiceAligmentGreecedays = 5;
int DriverLogin = 0;
int DriverTruckRefId = 0;
int MalevaScreen = storagenew.getInt('DeviceView') ?? 1;
String DriverTruckName='';
class SizeConfig {
  static MediaQueryData _mediaQueryData = const MediaQueryData();
  static double screenWidth = 0;
  static double screenHeight = 0;
  static double blockSizeHorizontal = 0;
  static double blockSizeVertical = 0;

  static double _safeAreaHorizontal = 0;
  static double _safeAreaVertical = 0;
  static double safeBlockHorizontal = 0;
  static double safeBlockVertical = 0;
  int reducesize = 0;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;
    if (screenWidth < 412) {
      double hh = 411 - screenWidth;
      int sizereduce = (hh / 20).round();
      reducesize = sizereduce;
    }
  }
}

Future<void> localstoragecall() async {
  storagenew = await SharedPreferences.getInstance();
}

Future<List<dynamic>> apiAllinoneSelect(api, insertDetails,
    Map<String, String>? header, BuildContext context) async {
  //returntype
  //1 list
  //2 status
  //3 int
  //4 string
  //5 double
  //rawbody
  //0 OFF
  //1 ON

  String apiname = api.toString().split('?')[0];
  apiname = "${apiname.replaceAll('$port/api/', '')}: ";
  try {
    header ??= <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };

    String token = storagenew.getString('Tokenkey') ?? "";
    String Userid = storagenew.getString('Userid') ?? "";
    String Profile = storagenew.getString('Profile') ?? "";
    if (token != "") {
      header.addAll(<String, String>{
        'Authorization': 'Bearer $token',
        'Userid': Userid,
        'Profile': Profile,
      });
    }
    String body = json.encode(insertDetails);
    debugPrint(api);
    if (body != '' && body != 'null') {
      debugPrint(body);
    }
    http.Response result =
        await http.post(Uri.parse(api), headers: header, body: body);
    if (result.statusCode == 200) {
      if (result.body == "") {
        return [];
      } else {
        return jsonDecode(result.body);
      }
    } else if (result.statusCode == 401) {
      ConfirmationOK("Authentication Failed !!!..ReLogin !!!", context);
      ResponseViewModel? value =
          ResponseViewModel.fromJson(jsonDecode(result.body));
      msgshow(value.Message, "", Colors.white, Colors.green, null,
          18.00 - reducesize, tll, tgc, context, 2);
      return [];
    } else if (result.statusCode == 406) {
      ConfirmationOK(
          "Already Login Another User.ReLogin or Change Password !!!", context);
      loginId = 0;
      loginname = '';
      storagenew.setString('Username', "");
      storagenew.setString('Password', "");
      storagenew.setString('OldUsername', "");

      // ResponseViewModel? value = ResponseViewModel.fromJson(jsonDecode(result.body));
      // msgshow(value.Message,"",Colors.white,Colors.green,null,18.00 - reducesize,tll,tgc,context,2);
      return [];
    } else if (result.statusCode == 404) {
      ResponseViewModel? value =
          ResponseViewModel.fromJson(jsonDecode(result.body));
      msgshow(value.Message, "", Colors.white, Colors.green, null,
          18.00 - reducesize, tll, tgc, context, 2);
      return [];
    } else if (result.statusCode == 500) {
      ResponseViewModel? value =
          ResponseViewModel.fromJson(jsonDecode(result.body));
      msgshow(value.Message, "", Colors.white, Colors.green, null,
          18.00 - reducesize, tll, tgc, context, 2);
      return [];
    } else {
      throw Exception('${result.statusCode} Unknown Error Occurred');
    }
  } on SocketException catch (_) {
    throw Exception('Check Your Network Connection');
  }
  // on Exception catch (ms) {
  //   throw Exception(ms.toString());
  // }
  catch (error) {
    throw Exception('$apiname$error');
  }
}



Future<dynamic> apiAllinoneMapSelect(
    api,
    insertDetails,
    Map<String, String>? header,
    BuildContext context) async {
  String apiname = api.toString().split('?')[0];
  apiname = "${apiname.replaceAll('$port/api/', '')}: ";
  try {
    header ??= <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };

    String token = storagenew.getString('Tokenkey') ?? "";
    String Userid = storagenew.getString('Userid') ?? "";
    String Profile = storagenew.getString('Profile') ?? "";
    if (token != "") {
      header.addAll(<String, String>{
        'Authorization': 'Bearer $token',
        'Userid': Userid,
        'Profile': Profile,
      });
    }

    String body = json.encode(insertDetails);
    debugPrint(api);
    if (body != '' && body != 'null') {
      debugPrint(body);
    }

    http.Response result =
    await http.post(Uri.parse(api), headers: header, body: body);

    if (result.statusCode == 200) {
      if (result.body == "") {
        return [];
      } else {
        final decoded = jsonDecode(result.body);

        // 🔹 If response is Map
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        // 🔹 If response is List
        else if (decoded is List) {
          return decoded;
        }
        // 🔹 Any other type, return as-is
        else {
          return decoded;
        }
      }
    } else if (result.statusCode == 401) {
      ConfirmationOK("Authentication Failed !!!..ReLogin !!!", context);
      ResponseViewModel? value =
      ResponseViewModel.fromJson(jsonDecode(result.body));
      msgshow(value.Message, "", Colors.white, Colors.green, null,
          18.00 - reducesize, tll, tgc, context, 2);
      return [];
    } else if (result.statusCode == 406) {
      ConfirmationOK(
          "Already Login Another User.ReLogin or Change Password !!!", context);
      loginId = 0;
      loginname = '';
      storagenew.setString('Username', "");
      storagenew.setString('Password', "");
      storagenew.setString('OldUsername', "");
      return [];
    } else if (result.statusCode == 404 ||
        result.statusCode == 500) {
      ResponseViewModel? value =
      ResponseViewModel.fromJson(jsonDecode(result.body));
      msgshow(value.Message, "", Colors.white, Colors.green, null,
          18.00 - reducesize, tll, tgc, context, 2);
      return [];
    } else {
      throw Exception('${result.statusCode} Unknown Error Occurred');
    }
  } on SocketException catch (_) {
    throw Exception('Check Your Network Connection');
  } catch (error) {
    throw Exception('$apiname$error');
  }
}

Future<List<dynamic>> apiAllinoneSelectWithOutAuth(api, insertDetails,
    Map<String, String>? header, BuildContext context) async {
  //returntype
  //1 list
  //2 status
  //3 int
  //4 string
  //5 double
  //rawbody
  //0 OFF
  //1 ON
  String apiname = api.toString().split('?')[0];
  apiname = "${apiname.replaceAll('$port/api/', '')}: ";
  try {
    header ??= <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };

    String token = storagenew.getString('Tokenkey') ?? "";
    String Userid = storagenew.getString('Userid') ?? "";
    String Profile = storagenew.getString('Profile') ?? "";

    String body = json.encode(insertDetails);
    debugPrint(api);
    if (body != '' && body != 'null') {
      debugPrint(body);
    }
    http.Response result =
        await http.post(Uri.parse(api), headers: header, body: body);
    if (result.statusCode == 200) {
      if (result.body == "") {
        return [];
      } else {
        return jsonDecode(result.body);
      }
    } else if (result.statusCode == 401) {
      ConfirmationOK("Authentication Failed !!!..ReLogin !!!", context);
      ResponseViewModel? value =
          ResponseViewModel.fromJson(jsonDecode(result.body));
      msgshow(value.Message, "", Colors.white, Colors.green, null,
          18.00 - reducesize, tll, tgc, context, 2);
      return [];
    } else if (result.statusCode == 406) {
      ConfirmationOK(
          "Already Login Another User.ReLogin or Change Password !!!", context);
      loginId = 0;
      loginname = '';

      storagenew.setString('Username', "");
      storagenew.setString('Password', "");
      storagenew.setString('OldUsername', "");

      // ResponseViewModel? value = ResponseViewModel.fromJson(jsonDecode(result.body));
      // msgshow(value.Message,"",Colors.white,Colors.green,null,18.00 - reducesize,tll,tgc,context,2);
      return [];
    } else if (result.statusCode == 404) {
      ResponseViewModel? value =
          ResponseViewModel.fromJson(jsonDecode(result.body));
      msgshow(value.Message, "", Colors.white, Colors.green, null,
          18.00 - reducesize, tll, tgc, context, 2);
      return [];
    } else if (result.statusCode == 500) {
      ResponseViewModel? value =
          ResponseViewModel.fromJson(jsonDecode(result.body));
      msgshow(value.Message, "", Colors.white, Colors.green, null,
          18.00 - reducesize, tll, tgc, context, 2);
      return [];
    } else {
      throw Exception('${result.statusCode} Unknown Error Occurred');
    }
  } on SocketException catch (_) {
    throw Exception('Check Your Network Connection');
  }
  // on Exception catch (ms) {
  //   throw Exception(ms.toString());
  // }
  catch (error) {
    throw Exception('$apiname$error');
  }
}

Future<dynamic> apiAllinoneSelectArrayWithOutAuth(api, insertDetails,
    Map<String, String>? header, BuildContext context) async {
  //returntype
  //1 list
  //2 status
  //3 int
  //4 string
  //5 double
  //rawbody
  //0 OFF
  //1 ON

  String apiname = api.toString().split('?')[0];
  apiname = "${apiname.replaceAll('$port/api/', '')}: ";
  try {
    header ??= <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };

    String token = storagenew.getString('Tokenkey') ?? "";
    String Userid = storagenew.getString('Userid') ?? "";
    String Profile = storagenew.getString('Profile') ?? "";
    if (token != "") {
      // header.addAll(<String, String>{
      //   'Userid': Userid,
      //   'Profile': Profile,
      // });
    }

    String body = json.encode(insertDetails);
    debugPrint(api);
    if (body != '' && body != 'null') {
      debugPrint(body);
    }
    http.Response result =
        await http.post(Uri.parse(api), headers: header, body: body);
    if (result.statusCode == 200) {
      if (result.body == "") {
        return [];
      } else {
        return jsonDecode(result.body);
      }
    } else if (result.statusCode == 401) {
      ConfirmationOK("Authentication Failed !!!..ReLogin !!!", context);
      ResponseViewModel? value =
          ResponseViewModel.fromJson(jsonDecode(result.body));
      msgshow(value.Message, "", Colors.white, Colors.green, null,
          18.00 - reducesize, tll, tgc, context, 2);
      return [];
    } else if (result.statusCode == 406) {
      ConfirmationOK(
          "Already Login Another User.ReLogin or Change Password !!!", context);
      loginId = 0;
      loginname = '';

      storagenew.setString('Username', "");
      storagenew.setString('Password', "");
      storagenew.setString('OldUsername', "");

      // ResponseViewModel? value = ResponseViewModel.fromJson(jsonDecode(result.body));
      // msgshow(value.Message,"",Colors.white,Colors.green,null,18.00 - reducesize,tll,tgc,context,2);
      return [];
    } else if (result.statusCode == 404) {
      ResponseViewModel? value =
          ResponseViewModel.fromJson(jsonDecode(result.body));
      msgshow(value.Message, "", Colors.white, Colors.green, null,
          18.00 - reducesize, tll, tgc, context, 2);
      return [];
    } else if (result.statusCode == 500) {
      ResponseViewModel? value =
          ResponseViewModel.fromJson(jsonDecode(result.body));
      msgshow(value.Message, "", Colors.white, Colors.green, null,
          18.00 - reducesize, tll, tgc, context, 2);
      return [];
    } else {
      throw Exception('${result.statusCode} Unknown Error Occurred');
    }
  } on SocketException catch (_) {
    throw Exception('Check Your Network Connection');
  }
  // on Exception catch (ms) {
  //   throw Exception(ms.toString());
  // }
  catch (error) {
    throw Exception('$apiname$error');
  }
}
// create teh  test  jsut write th e conmmand
Future<dynamic> apiAllinoneSelectArray(api, insertDetails,
    Map<String, String>? header, BuildContext context) async {
  //returntype
  //1 list
  //2 status
  //3 int
  //4 string
  //5 double
  //rawbody
  //0 OFF
  //1 ON

  String apiname = api.toString().split('?')[0];
  apiname = "${apiname.replaceAll('$port/api/', '')}: ";
  try {
    header ??= <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };

    String token = storagenew.getString('Tokenkey') ?? "";
    String Userid = storagenew.getString('Userid') ?? "";
    String Profile = storagenew.getString('Profile') ?? "";
    if (token != "") {
      header.addAll(<String, String>{
        'Authorization': 'Bearer $token',
        'Userid': Userid,
        'Profile': Profile,
      });
    }

    String body = json.encode(insertDetails);
    debugPrint(api);
    if (body != '' && body != 'null') {
      debugPrint(body);
    }
    http.Response result = await http.post(Uri.parse(api), headers: header, body: body);
    if (result.statusCode == 200) {
      if (result.body == "") {
        return [];
      } else {
        return jsonDecode(result.body);
      }
    } else if (result.statusCode == 401) {
      ConfirmationOK("Authentication Failed !!!..ReLogin !!!", context);
      ResponseViewModel? value =
          ResponseViewModel.fromJson(jsonDecode(result.body));
      msgshow(value.Message, "", Colors.white, Colors.green, null,
          18.00 - reducesize, tll, tgc, context, 2);
      return [];
    } else if (result.statusCode == 406) {
      ConfirmationOK(
          "Already Login Another User.ReLogin or Change Password !!!", context);
      loginId = 0;
      loginname = '';
      storagenew.setString('Username', "");
      storagenew.setString('Password', "");
      storagenew.setString('OldUsername', "");

      // ResponseViewModel? value = ResponseViewModel.fromJson(jsonDecode(result.body));
      // msgshow(value.Message,"",Colors.white,Colors.green,null,18.00 - reducesize,tll,tgc,context,2);
      return [];
    } else if (result.statusCode == 404) {
      ResponseViewModel? value =
          ResponseViewModel.fromJson(jsonDecode(result.body));
      msgshow(value.Message, "", Colors.white, Colors.green, null,
          18.00 - reducesize, tll, tgc, context, 2);
      return [];
    } else if (result.statusCode == 500) {
      ResponseViewModel? value =
          ResponseViewModel.fromJson(jsonDecode(result.body));
      msgshow(value.Message, "", Colors.white, Colors.green, null,
          18.00 - reducesize, tll, tgc, context, 2);
      return [];
    } else {
      throw Exception('${result.statusCode} Unknown Error Occurred');
    }
  } on SocketException catch (_) {
    throw Exception('Check Your Network Connection');
  }
  // on Exception catch (ms) {
  //   throw Exception(ms.toString());
  // }
  catch (error) {
       throw Exception('$apiname$error');
  }
}

Future<dynamic> apiAllinone(api, insertDetails, Map<String, String>? header, BuildContext context) async {
  //returntype
  //1 list
  //2 status
  //3 int
  //4 string
  //5 double
  //rawbody
  //0 OFF
  //1 ON

  String apiname = api.toString().split('?')[0];
  apiname = "${apiname.replaceAll('$port/api/', '')}: ";
  try {
    header ??= <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };

    String token = storagenew.getString('Tokenkey') ?? "";
    String Userid = storagenew.getString('Userid') ?? "";
    String Profile = storagenew.getString('Profile') ?? "";
    if (token != "") {
      header.addAll(<String, String>{
        'Authorization': 'Bearer $token',
        'Userid': Userid,
        'Profile': Profile,
      });
    }

    String body = json.encode(insertDetails);
    debugPrint(api);
    if (body != '' && body != 'null') {
      debugPrint(body);
    }
    http.Response result =
        await http.post(Uri.parse(api), headers: header, body: body);
    if (result.statusCode == 200) {
      return true;
    } else if (result.statusCode == 401) {
      ConfirmationOK("Authentication Failed !!!..ReLogin !!!", context);
      ResponseViewModel? value =
          ResponseViewModel.fromJson(jsonDecode(result.body));
      msgshow(value.Message, "", Colors.white, Colors.green, null,
          18.00 - reducesize, tll, tgc, context, 2);
      return [];
    } else if (result.statusCode == 406) {
      ConfirmationOK(
          "Already Login Another User.ReLogin or Change Password !!!", context);
      loginId = 0;
      loginname = '';

      storagenew.setString('Username', "");
      storagenew.setString('Password', "");
      storagenew.setString('OldUsername', "");

      // ResponseViewModel? value = ResponseViewModel.fromJson(jsonDecode(result.body));
      // msgshow(value.Message,"",Colors.white,Colors.green,null,18.00 - reducesize,tll,tgc,context,2);
      return [];
    } else if (result.statusCode == 404) {
      ResponseViewModel? value =
          ResponseViewModel.fromJson(jsonDecode(result.body));
      msgshow(value.Message, "", Colors.white, Colors.green, null,
          18.00 - reducesize, tll, tgc, context, 2);
      return false;
    } else if (result.statusCode == 406) {
      ConfirmationOK("Already login another devices.Please ReLogin.", context);

      return false;
    } else if (result.statusCode == 409) {
      ResponseViewModel? value =
          ResponseViewModel.fromJson(jsonDecode(result.body));
      msgshow(value.Message, "", Colors.white, Colors.green, null,
          18.00 - reducesize, tll, tgc, context, 2);
      return false;
    } else if (result.statusCode == 500) {
      ResponseViewModel? value =
          ResponseViewModel.fromJson(jsonDecode(result.body));
      msgshow(value.Message, "", Colors.white, Colors.green, null,
          18.00 - reducesize, tll, tgc, context, 2);
      return false;
    } else {
      throw Exception('${result.statusCode} Unknown Error Occurred');
    }
  } on SocketException catch (_) {
    msgshow('Check Your Network Connection', "", Colors.white, Colors.red, null,
        18.00 - reducesize, tll, tgc, context, 2);
    throw Exception('Check Your Network Connection');
  }
  // on Exception catch (ms) {
  //   throw Exception(ms.toString());
  // }
  catch (error) {
    msgshow('Check Your Network Connection', "", Colors.white, Colors.red, null,
        18.00 - reducesize, tll, tgc, context, 2);
    throw Exception('$apiname$error');
  }
}


Future<String> apiGetString(api) async {
  try {
    debugPrint(api);
    numberofapicalls = numberofapicalls + 1;
    var result = await http.post(Uri.parse(api));
    if (result.statusCode == 200) {
      numberofapicalls = numberofapicalls - 1;
      return jsonDecode(result.body).toString();
    } else {
      numberofapicalls = numberofapicalls - 1;
      throw Exception('Failed to Get String');
    }
  } on SocketException catch (_) {
    networkConnection = false;
    currenttryconnection = currenttryconnection + 1;
    throw Exception('There is No Network !!');
  }
}
// ─── Replace your existing msgshow function with this ─────────────────────────

void msgshow(
    String msg,
    String value,
    col.Color? tcolor,
    col.Color? bcolor,
    Duration? dur,
    double? fsize,
    Toast? length,
    ToastGravity? gravity,
    BuildContext? context,
    int type) async {
  if (context != null) {
    await Future.delayed(const Duration(milliseconds: 300));
    // ignore: use_build_context_synchronously
    _showTopBanner(
      context: context,
      message: msg + value,
      backgroundColor: bcolor == Colors.green || bcolor == Colors.greenAccent
          ? const Color(0xFF1555F3)
          : bcolor ?? const Color(0xFF1555F3),
      textColor: tcolor ?? Colors.white,
      duration: dur ?? const Duration(seconds: 3),
    );
  } else {
    Fluttertoast.showToast(
        msg: msg,
        textColor: tcolor ?? Colors.white,
        fontSize: fsize ?? 14,
        toastLength: length ?? Toast.LENGTH_SHORT,
        backgroundColor: bcolor ?? Colors.black,
        gravity: gravity ?? ToastGravity.CENTER);
  }
}

// ─── Top Banner Implementation ─────────────────────────────────────────────────
void _showTopBanner({
  required BuildContext context,
  required String message,
  required col.Color backgroundColor,
  required col.Color textColor,
  required Duration duration,
}) {
  final overlay = Overlay.of(context);

  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => _TopBannerWidget(
      message: message,
      backgroundColor: backgroundColor,
      textColor: textColor,
      duration: duration,
      onDismiss: () => entry.remove(),
    ),
  );

  overlay.insert(entry);
}

// ─── Top Banner Widget ─────────────────────────────────────────────────────────
class _TopBannerWidget extends StatefulWidget {
  final String message;
  final col.Color backgroundColor;
  final col.Color textColor;
  final Duration duration;
  final VoidCallback onDismiss;

  const _TopBannerWidget({
    required this.message,
    required this.backgroundColor,
    required this.textColor,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_TopBannerWidget> createState() => _TopBannerWidgetState();
}

class _TopBannerWidgetState extends State<_TopBannerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // Slide in
    _controller.forward();

    // Auto dismiss
    Future.delayed(widget.duration, () async {
      if (mounted) {
        await _controller.reverse();
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Pick icon based on background color
  IconData _getIcon() {
    final bg = widget.backgroundColor;
    if (bg == Colors.red || bg == Colors.redAccent) {
      return Icons.error_outline_rounded;
    } else if (bg == Colors.green || bg == Colors.greenAccent) {
      return Icons.check_circle_outline_rounded;
    } else if (bg == Colors.orange || bg == Colors.orangeAccent) {
      return Icons.warning_amber_rounded;
    } else {
      return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTap: () async {
              await _controller.reverse();
              widget.onDismiss();
            },
            child: Container(
              margin: EdgeInsets.only(
                top: topPadding + 10,
                left: 16,
                right: 16,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: widget.backgroundColor.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(_getIcon(), color: widget.textColor, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        color: widget.textColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.close_rounded,
                      color: widget.textColor.withOpacity(0.6), size: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
Toast tls = Toast.LENGTH_SHORT;
Toast tll = Toast.LENGTH_LONG;
ToastGravity tgc = ToastGravity.CENTER;
void msgshow1(
    String msg,
    String value,
    col.Color? tcolor,
    col.Color? bcolor,
    Duration? dur,
    double? fsize,
    Toast? length,
    ToastGravity? gravity,
    BuildContext? context,
    int type) async {
  if (context != null) {
    await Future.delayed(const Duration(seconds: 1));
    // ignore: use_build_context_synchronously

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        msg + value,
        style: TextStyle(color: tcolor ?? Colors.white),
      ),
      backgroundColor: bcolor ?? Colors.black,
      duration: dur ?? const Duration(seconds: 5),
    ));
  } else {
    Fluttertoast.showToast(
        msg: msg,
        textColor: tcolor ?? Colors.white,
        fontSize: fsize ?? 14,
        toastLength: length ?? Toast.LENGTH_SHORT,
        backgroundColor: bcolor ?? Colors.black,
        gravity: gravity ?? ToastGravity.CENTER);
  }
}

Future<bool> ConfirmationMsgYesNo(context, String Msg) async {
  return await showDialog(
    context: context,
    builder: (BuildContext context) {
      // return object of type Dialog
      return AlertDialog(
        titlePadding: EdgeInsets.zero,
        title: Container(
          height: MalevaScreen == 1
              ? 35 : 45,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(0.0),
            color: colour.commonColor,
            border: Border.all(
              color: colour.commonColorLight,
            ),
            // side: const BorderSide(color: colour.commonColorLight, width: 1, style: BorderStyle.solid),
          ),
          child: Text(
            "Maleva",
            style: GoogleFonts.lato(
              textStyle:  TextStyle(
                  color: colour.whiteText,
                  fontWeight: FontWeight.bold,
                  fontSize: FontLarge,
                  letterSpacing: 0.3),
            ),
          ),
        ),
        content: SizedBox(
        width: MalevaScreen == 1
            ?150: 300.0, // Adjust width as needed
        height: MalevaScreen == 1
            ?50 :70.0, // Adjust height as needed
      child: Row(

          children: [
          //   const Expanded(flex:2,child:Icon(
          //   Icons.question_mark_outlined,
          //   color: colour.commonColor,
          //   // size: 35.0,
          // ),),
          Expanded(
              flex: 10,
              child: Text(
                Msg,
                style: GoogleFonts.lato(
                  textStyle:  TextStyle(
                      color: colour.commonColor,
                      fontWeight: FontWeight.bold,
                      fontSize: FontMedium,
                      letterSpacing: 0.3),
                ),
              )),
        ]),),
        actions: <Widget>[
          // usually buttons at the bottom of the dialog
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colour.commonColor,
              side: const BorderSide(
                  color: colour.commonColorLight,
                  width: 1,
                  style: BorderStyle.solid),
              textStyle: const TextStyle(color: Colors.black),
              elevation: 20.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              padding: const EdgeInsets.all(4.0),
            ),
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: Text(
              'No',
              style: GoogleFonts.lato(
                  fontSize:MalevaScreen == 1
                      ? FontMedium - 2 : FontMedium,
                  // height: 1.45,
                  fontWeight: FontWeight.bold,
                  color: colour.commonColorLight),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colour.commonColor,
              side: const BorderSide(
                  color: colour.commonColorLight,
                  width: 1,
                  style: BorderStyle.solid),
              textStyle: const TextStyle(color: Colors.black),
              elevation: 20.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              padding: const EdgeInsets.all(4.0),
            ),
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: Text(
              'Yes',
              style: GoogleFonts.lato(
                  fontSize: MalevaScreen == 1
                      ? FontMedium - 2 : FontMedium,
                  // height: 1.45,
                  fontWeight: FontWeight.bold,
                  color: colour.commonColorLight),
            ),
          ),
        ],
      );
    },
  ).then((exit) {
    if (exit == null) return false;
    if (exit) {
      return true;
    } else {
      // user pressed No button
      return false;
    }
  });
}

Future<bool> ConfirmationOK(String Msg, context) async {
  return await showDialog(
    context: context,
    builder: (BuildContext context) {
      // return object of type Dialog
      return AlertDialog(
        titlePadding: EdgeInsets.zero,
        title: Container(
          height:  MalevaScreen == 1
              ?35 : 45,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(0.0),
            color: colour.commonColor,
            border: Border.all(
              color: colour.commonColorLight,
            ),
            // side: const BorderSide(color: colour.commonColorLight, width: 1, style: BorderStyle.solid),
          ),
          child: Text(
            "Maleva",
            style: GoogleFonts.lato(
              textStyle:  TextStyle(
                  color: colour.whiteText,
                  fontWeight: FontWeight.bold,
                  fontSize: FontLarge,
                  letterSpacing: 0.3),
            ),
          ),
        ),
        content: SizedBox(
      width: MalevaScreen == 1
      ?150: 300.0, // Adjust width as needed
      height: MalevaScreen == 1
      ?30 :50.0, // Adjust height as needed
      child:  Text(
          Msg,
          style: GoogleFonts.lato(
            textStyle:  TextStyle(
                color: colour.commonColor,
                fontWeight: FontWeight.bold,
                fontSize:  MalevaScreen == 1
                    ? FontLow : FontMedium,
                letterSpacing: 0.3),
          ),
        ),),
        actions: <Widget>[
          // usually buttons at the bottom of the dialog
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colour.commonColor,
              side: const BorderSide(
                  color: colour.commonColorLight,
                  width: 1,
                  style: BorderStyle.solid),
              textStyle: const TextStyle(color: Colors.black),
              elevation: 20.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              padding: const EdgeInsets.all(4.0),
            ),
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: Text(
              'OK',
              style: GoogleFonts.lato(
                  fontSize:  MalevaScreen == 1
                      ? FontMedium - 2 : FontMedium,
                  // height: 1.45,
                  fontWeight: FontWeight.bold,
                  color: colour.commonColorLight),
            ),
          ),
        ],
      );
    },
  ).then((exit) {
    if (exit == null) return false;
    if (exit) {
      return true;
    } else {
      // user pressed No button
      return false;
    }
  });
}



void toastMsg(msg, value, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Row(
      children: [
        Expanded(
            flex: 1,
            child: Text(
              msg + value.toString(),
              style:  GoogleFonts.lato(
                textStyle: TextStyle(
                  fontSize:  MalevaScreen == 1
                      ? FontLow : FontMedium,
                  fontWeight: FontWeight.bold,
                  color: colour.commonColor)),
            ))
      ],
    ),
    padding: const EdgeInsets.all(15),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5.0),
    ),
    margin: const EdgeInsets.all(15),
    behavior: SnackBarBehavior.floating,
    backgroundColor: colour.commonColorLight,
    duration: const Duration(seconds: 1),
  ));
}
String currentdate(int days)  {
  DateTime currentDate = DateTime.now();

  // Add the days
  DateTime newDate = currentDate.add(Duration(days: days));

  // Format the new date
  String formattedDate = DateFormat('yyyy-MM-dd').format(newDate);
  return formattedDate;

}
Future launchInBrowser(String url) async {
  if (!await launchUrl(
    Uri.parse(url),
    mode: LaunchMode.externalApplication,
  )) {
    throw Exception('Could not launch $url');
  }
}
Future<void> EmployeeLogin(context, int type) async {
  if (type != 1) {
    bool result =
        await ConfirmationMsgYesNo(context, "Are you sure to logout ?? ");
    if (result == false) {
      return;
    }
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const Homemobile()));
  }
  EmpRefId = 0;
  storagenew.setInt('EmpRefId', 0);
  storagenew.setString('Username', "");
  storagenew.setString('Password', "");
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      // return object of type Dialog
      return AlertDialog(
        titlePadding: EdgeInsets.zero,
        title: Container(
          height: 35,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(0.0),
            color: colour.commonColor,
            border: Border.all(
              color: colour.commonColorLight,
            ),
            // side: const BorderSide(color: colour.commonColorLight, width: 1, style: BorderStyle.solid),
          ),
          child: Text(
            "Employee Login",
            style: GoogleFonts.lato(
              textStyle: const TextStyle(
                  color: colour.whiteText,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  letterSpacing: 0.3),
            ),
          ),
        ),
        content: SizedBox(
          height: 165,
          child: Column(children: [
            Container(
              width: SizeConfig.safeBlockHorizontal * 99,
              height: SizeConfig.safeBlockVertical * 7,
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(bottom: 5),
              child: TextField(
                textCapitalization: TextCapitalization.characters,
                controller: txtLoginEmployee,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.name,
                readOnly: true,
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                      color: colour.commonColor,
                      fontWeight: FontWeight.bold,
                      fontSize: FontLow,
                      letterSpacing: 0.3),
                ),
                decoration: InputDecoration(
                  hintText: "Employee Name",
                  hintStyle:GoogleFonts.lato(
                    textStyle: TextStyle(
                      fontSize: FontMedium,
                      fontWeight: FontWeight.bold,
                      color: colour.commonColorLight)),
                  suffixIcon: InkWell(
                      child: Icon(
                          (txtLoginEmployee.text.isNotEmpty)
                              ? Icons.close
                              : Icons.search_rounded,
                          color: colour.commonColorred,
                          size: 30.0),
                      onTap: () async {
                        if (txtLoginEmployee.text == "") {
                          await OnlineApi.SelectEmployee(
                              context, 'Sales', 'admin');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const Employee(Searchby: 1, SearchId: 0)),
                          ).then((dynamic value) async {
                            //setState(() {
                            txtLoginEmployee.text =
                                SelectEmployeeList.AccountName;
                            LoginEmpId = SelectEmployeeList.Id;
                            SelectEmployeeList = EmployeeModel.Empty();
                            // });
                          });
                        } else {
                          //setState(() {
                          txtLoginEmployee.text = "";
                          LoginEmpId = 0;
                          SelectEmployeeList = EmployeeModel.Empty();
                          // });
                        }
                      }),
                  fillColor: Colors.black,
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide(color: colour.commonColor),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide(color: colour.commonColorred),
                  ),
                  contentPadding:
                      const EdgeInsets.only(left: 10, right: 20, top: 10.0),
                ),
              ),
            ),
            Container(
              width: SizeConfig.safeBlockHorizontal * 99,
              height: SizeConfig.safeBlockVertical * 7,
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(bottom: 5),
              child: TextField(
                cursorColor: colour.commonColor,
                controller: txtLoginPassword,
                autofocus: false,
                showCursor: true,
                decoration: InputDecoration(
                  hintText: ('Password'),
                  hintStyle:GoogleFonts.lato(
                    textStyle: TextStyle(
                      fontSize: FontMedium,
                      fontWeight: FontWeight.bold,
                      color: colour.commonColorLight)),
                  fillColor: colour.commonColor,
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide(color: colour.commonColor),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide(color: colour.commonColorred),
                  ),
                  contentPadding:
                      const EdgeInsets.only(left: 10, right: 20, top: 10.0),
                ),
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.characters,
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                      color: colour.commonColor,
                      fontWeight: FontWeight.bold,
                      fontSize: FontLow,
                      letterSpacing: 0.3),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colour.commonColor,
                side: const BorderSide(
                    color: colour.commonColorLight,
                    width: 1,
                    style: BorderStyle.solid),
                textStyle: const TextStyle(color: Colors.black),
                elevation: 20.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                padding: const EdgeInsets.all(4.0),
              ),
              onPressed: () {
                if (txtLoginPassword != "" && LoginEmpId != 0) {
                  var EmployeeDetailsList = EmployeeList.where((item) =>
                      item.Id == LoginEmpId &&
                      item.Password == txtLoginPassword.text).toList();
                  if (EmployeeDetailsList.isNotEmpty) {
                    EmpRefId = EmployeeDetailsList[0].Id;
                    storagenew.setString(
                        'Username', EmployeeDetailsList[0].AccountName);
                    storagenew.setString(
                        'Password', EmployeeDetailsList[0].Password);
                    storagenew.setInt(
                        'EmpRefId', EmployeeDetailsList[0].Id );
                    txtLoginEmployee.text = "";
                    txtLoginPassword.text = "";
                    LoginEmpId = 0;
                    SelectEmployeeList = EmployeeModel.Empty();
                  } else {
                    ConfirmationOK("Invalid Employee and Password", context);
                  }

                  Navigator.pop(context, true);
                } else {
                  ConfirmationOK(
                      "Enter Employee Name and Password !!", context);
                }
              },
              child: Text(
                'Login',
                style: GoogleFonts.lato(
                    fontSize: 22.0,
                    // height: 1.45,
                    fontWeight: FontWeight.bold,
                    color: colour.commonColorLight),
              ),
            ),
          ]),
        ),
      );
    },
  );
}
bool downloadprogress = false;
double? progress = 0;
get downloadProgress => progress;

Future startDownloading(String urlpath) async {
  try {
    downloadprogress = true;
    progress = null;
    String filename = urlpath.split('/').last;
    // List<String> filelist =urlpath.split('/');
    // if(filelist.isNotEmpty){
    //   filename=filelist[filelist.length-1];
    //   filename =filelist.last;
    // }
    // else{
    //   filename=urlpath.split('/').last;
    // }
    final url = urlpath;

    final request = Request('GET', Uri.parse(url));
    final StreamedResponse response = await Client().send(request);

    final contentLength = response.contentLength;
    progress = 0;
    List<int> bytes = [];

    final file = await _getFile(filename);
    response.stream.listen(
          (List<int> newBytes) {
        bytes.addAll(newBytes);
        final downloadedLength = bytes.length;
        progress = downloadedLength / contentLength!;
      },
      onDone: () async {
        // var status1 = await Permission.manageExternalStorage.status;
        // if (!status1.isGranted) {
        //   await Permission.manageExternalStorage.request();
        // }
        downloadprogress = false;
        progress = 0;
        await file.writeAsBytes(bytes);
        // Share.shareFiles(file.path);
        Share.shareXFiles([XFile(file.path)], text: 'BillMaster_Invoice.jpg');
        // final result = await  OpenFile.open(file.path);
        // print("type=${result.type}  message=${result.message}");
      },
      onError: (e) {
        downloadprogress = false;
      },
      cancelOnError: true,
    );
  } on Error catch (_) {
    downloadprogress = false;
  }
}
Future<File> _getFile(String filename) async {
  final dir = await getApplicationDocumentsDirectory();
  return File("${dir.path}/$filename");
}

String networkimage = '';
Future<String> upload(File imageFile, String imageapi,int Id,String FolderName ,String SubFolderName) async {networkimage = '';
  var stream = http.ByteStream(imageFile.openRead());
  stream.cast();
  var length = await imageFile.length();

  var uri = Uri.parse(imageapi);

  var request = http.MultipartRequest("POST", uri);
  var multipartFile = http.MultipartFile('MyImages0', stream, length,
      filename: basename(imageFile.path),
      contentType: MediaType('image', 'jpeg'));

  request.files.add(multipartFile);
  Map<String, String> header = {
    'Comid': Comid.toString(),
    'Id' : Id.toString(),
    'FolderName' : FolderName,
    'FileName' :basename(imageFile.path),
    'SubFolderName' : SubFolderName

  };

  request.headers.addAll(header);

  // Map<String, String> parameters = {
  //   "imagefolder": 'KmImages',
  // };
  // request.headers.addAll(parameters);
  http.Response response = await http.Response.fromStream(await request.send());
  if (response.statusCode == 200) {
    String imagename1 = response.body.replaceRange(0, 1, '');
    String imagename =
    imagename1.replaceRange(imagename1.length - 1, imagename1.length, '');
//      networkimage= port + imagepath + imagename;
    networkimage = imagename;
    return networkimage;
  } else {
    return networkimage;
  }
}



Future<String> uploadPdfOrImage(File file, int comid,int Id,String apiUploadPdfFile, String folderName, String subFolderName) async {String networkFileName = "";
try {
  var stream = http.ByteStream(file.openRead());
  var length = await file.length();

  var uri = Uri.parse(apiUploadPdfFile);

  // Multipart request
  var request = http.MultipartRequest("POST", uri);

  // File -> key must be "MyFiles0" (your .NET code)
  var multipartFile = http.MultipartFile(
    'MyFiles0', // important: matches .NET API
    stream,
    length,
    filename: basename(file.path),
    contentType: MediaType('application', 'octet-stream'),
  );

  request.files.add(multipartFile);

  // Required headers
  request.headers.addAll({
    'Comid': comid.toString(),
    'Id' : Id.toString(),
    'FolderName': folderName,
    'FileName': basename(file.path),
    'SubFolderName': subFolderName,
  });

  // Send request
  var response = await http.Response.fromStream(await request.send());

  if (response.statusCode == 200) {

    String fileName1 = response.body.replaceRange(0, 1, '');
    String fileName = fileName1.replaceRange(fileName1.length - 1, fileName1.length, '');

    networkFileName = fileName;
    return networkFileName;
  }
  else {
    print("❌ Upload failed: ${response.statusCode}");
    return "";
  }
} catch (e) {
  print("⚠️ Error uploading: $e");
  return "";
}
}




Future logout(context) async {
  bool result =
      await ConfirmationMsgYesNo(context, "Are you sure to logout ?? ");
  if (result == false) {
    return;
  }
  loginId = 0;
  loginname = '';
  DriverLogin = 0;
  DriverTruckRefId = 0;
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => LoginBloc(),
        child: const Appuserloginmobile(),
      ),
    ),
  );


  storagenew.setString('Username', "");
  storagenew.setString('Password', "");
  storagenew.setString('OldUsername', "");
}
String barcodestring = '';
bool barcodeerror = false;
Future barcodeScanning() async {
  try {
    barcodestring = "";
    barcodeerror = false;
    barcodestring = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancel', true, ScanMode.BARCODE);
    if (barcodestring == '-1') {
      barcodestring = '';
    }
  } on PlatformException catch (e) {
    Fluttertoast.showToast(
        msg: 'Failed to get platform version: $e',
        textColor: Colors.black,
        fontSize: 18.00,
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.white,
        gravity: ToastGravity.CENTER);
    // barcodestring = 'Unknown error: $e';
    debugPrint(e.toString());
    barcodeerror = true;
  } on FormatException {
    Fluttertoast.showToast(
        msg: 'Nothing captured.',
        textColor: Colors.black,
        fontSize: 18.00,
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.white,
        gravity: ToastGravity.CENTER);
    // barcodestring = 'Nothing captured.';
    barcodeerror = true;
  } catch (e) {
    Fluttertoast.showToast(
        msg: 'Unknown error: $e',
        textColor: Colors.black,
        fontSize: 18.00,
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.white,
        gravity: ToastGravity.CENTER);
    // barcodestring = 'Unknown error: $e';
    barcodeerror = true;
  }
}
Future checkVersion(BuildContext context) async {
  await AppVersionUpdate.checkForUpdates(
    appleId: '6738003436',
    playStoreId: 'com.kassapos.maleva',
    // country: 'in',
  ).then((result) async {
    if (result.canUpdate!) {
      // await AppVersionUpdate.showBottomSheetUpdate(context: context, appVersionResult: appVersionResult)
      // await AppVersionUpdate.showPageUpdate(context: context, appVersionResult: appVersionResult)
      // or use your own widget with information received from AppVersionResult

      //##############################################################################################
      await AppVersionUpdate.showAlertUpdate(
        appVersionResult: result,
        context: context,
        backgroundColor: Colors.grey[200],
        title: 'New Update Available Now',
        titleTextStyle: GoogleFonts.lato(
          textStyle: const TextStyle(
            color: colour.commonColor,
            fontWeight: FontWeight.w600,
            fontSize: 24.0)),
        content: 'Would you like to update your app to the latest version?',
        contentTextStyle: GoogleFonts.lato(
    textStyle: const TextStyle(
          color: colour.commonColor,
          fontWeight: FontWeight.w400,
        )),
        updateButtonText: 'Update',
        cancelButtonText: 'Later',
        mandatory: true,
      );

      // // ## AppVersionUpdate.showBottomSheetUpdate ##
      // await AppVersionUpdate.showBottomSheetUpdate(
      //   context: context,
      //   mandatory: false,
      //   appVersionResult: result,
      //   content:   Text(
      //     'An update V ${result.storeVersion} is available would you like to update now ?',
      //   )
      //
      // );
      //
      // // ## AppVersionUpdate.showPageUpdate ##
      //
      // await AppVersionUpdate.showPageUpdate(
      //   context: context,
      //   mandatory: false,
      //   appVersionResult: result,
      // );
    }
  });
  // TODO: implement initState
}

Map<String, dynamic> printrow = {
  'Id': 0,
};
//Variables
int cashierLoginId = 0;
String cashierloginname = '';
int loginId = 1;
String loginname = '';
String loginpower = '';
int CloudTrial = 0;
DateTime Cloud_Ldate = DateTime.now();
bool networkConnection = false;
int maxytryconnection = 5;
int currenttryconnection = 6;
int numberofapicalls = 0;
int mCompanyRefid = 2;
bool onlineMirrorTable = false;
// int CompanyRefid = 1;
int reducesize = 0;
double progresspercentage = 0.00;
String progresspercentagestring = "0.0";
String downlaodname = "";
bool downloadbreak = false;
//Company Details
String companyname = 'Maleva';
String caddress1 = 'No.1/184A, Vijayalakshmi';
String caddress2 = 'Nagar 2nd Street,Abinadhan Nagar';
String ccity = 'Chennai';
String cmobileno = '+91 87540 31480';
String cgstino = 'GST-X123456';
String cwebsite = 'https://www.webpos.in/';
String cfootermsg1 = 'This is Footer Msg1';
String cfootermsg2 = 'This is Footer Msg2';
String selectedCompanyName = "";
String tcompanyname = 'TabletPOS';
String tcaddress1 = 'No.1/184A, Vijayalakshmi';
String tcaddress2 = 'Nagar 2nd Street,Abinadhan Nagar';
String tccity = 'Chennai';

List<MenuMasterModel> objMenuMaster = [];
List<MenuMasterModel> parentclass = [];

List<MainsettingModel> mainsettinglist = [];

List<EmployeeModel> EmployeeList = [];
EmployeeModel SelectEmployeeList = EmployeeModel.Empty();
List<UserLoginModel> UserList = [];
List<CustomerModel> CustomerList = [];
List<LocationModel> LocationList = [];
List<WareHouseModel> WareHouseList = [];
List<WareHouseModel> StockJobList = [];
CustomerModel SelectCustomerList = CustomerModel.Empty();
LocationModel SelectLocationList = LocationModel.Empty();
List<JobStatusModel> JobStatusList = [];
JobStatusModel SelectJobStatusList = JobStatusModel.Empty();
List<JobTypeModel> JobTypeList = [];
JobTypeModel SelectJobTypeList = JobTypeModel.Empty();
List<JobAllStatusModel> JobAllStatusList = [];
JobAllStatusModel SelectAllStatusList = JobAllStatusModel.Empty();
List<AgentCompanyModel> AgentCompanyList = [];
AgentCompanyModel SelectAgentCompanyList = AgentCompanyModel.Empty();
List<AgentModel> AgentAllList = [];
AgentModel SelectAgentAllList = AgentModel.Empty();
List<ProductModel> ProductList = [];
ProductModel SelectProductList = ProductModel.Empty();
List<ForwardingModel> ForwardingList = [];
ForwardingModel SelectForwardingList = ForwardingModel.Empty();
List<GetTruckModel> GetTruckList = [];




GetTruckModel SelectTruckList = GetTruckModel.Empty();
List<JobTypeDetailsModel> JobTypeDetailsList = [];
List<TruckDetailsModel> TruckDetailsList = [];

TruckDetailsModel SelectTruckDetails = TruckDetailsModel.Empty();
List<BarcodePrintModel> BarcodeList=[];
List<BluetoothModel> bluetoothdeviceList = [];

WareHouseModel SelectWareHouseList = WareHouseModel.Empty();
List<WareHouseModel> WareHouseModelAllList = [];

List<dynamic> AddressList = [];
List<dynamic> SaleOrderMasterList = [];
List<dynamic> SaleOrderDetailList = [];
List<dynamic> PlanningMasterList = [];
List<dynamic> PlanningDetailsList = [];
List<dynamic> PlanningEditList = [];
List<dynamic> VesselPlanningMasterList = [];
List<dynamic> VesselPlanningDetailsList = [];
List<dynamic> VesselPlanningEditList = [];
List<SaleEditDetailModel> SaleEditDetailList = [];
List<dynamic> SaleEditMasterList = [];
List<dynamic> ComboS1List = [];
List<dynamic> GetImagesList = [];
List<AddressDetailsModel> AddressDetailedList = [];
List<GetTruckModel> GetDriverList = [];
GetTruckModel SelectDriverList = GetTruckModel.Empty();
List<dynamic> RTIViewMasterList = [];
List<dynamic> RTIViewDetailList = [];

List<RTIDetailsViewModel> RTIViewDetailList1 = [];

List<RTIDetailsViewModel> RTIDetailsDetailList = [];
List<dynamic> EnquiryMasterList = [];
List<dynamic> PickupQuantityList = [];
//List<SaleEditMasterModel> SaleEditMasterList = [];
String SelectAddressList = "";

List<dynamic> JobNoList = [];
String MaxSaleOrderNum = '';
String MaxStockNum = '';
int EmpRefId = 0;
int LoginEmpId = 0;
int Comid = 0;
double CustomerCurrencyValue = 0.0;
int SelectedId = 0;
double FontKeypad = 26;
double FontLarge = 24;
double FontMedium = 20;
double FontLow = 18;
double FontCardText = 14;
String SelectedName = '';
String SelectedPortName = '';
String SelectedVesselTypeName = '';
String SelectedCommodityName = '';
String SelectedCargoName = '';

List<ListItem> Paymentload = [
  ListItem(1, 'GPAY'),
  ListItem(2, 'HDFC'),
  ListItem(3, 'CASH')
];

List<ListItem> MisHoursload = [
  ListItem(1, 'Software Demo(Direct)'),
  ListItem(2, 'Software Demo(Online)'),
  ListItem(3, 'Software Installation(Online)'),
  ListItem(4, 'Software Installation(Direct)'),
  ListItem(5, 'Software Demo-Installation(Online)'),
  ListItem(6, 'Staff Meeting'),
  ListItem(7, 'Quotation'),
  ListItem(8, 'Leave'),
];

List<ListItem> Portlist = [
  ListItem(1, 'WESTPORT-B18'),
  ListItem(2, 'NORTHPORT- B10'),
  ListItem(3, 'SOUTHPORT-B11'),
  ListItem(4, 'WESTPORT LBT- B7X'),
  ListItem(5, 'WESTPORT DRY BULK- B7Y'),
  ListItem(6, 'PULAU KETAM JETTY'),
  ListItem(7, 'KAPAR POWERSTATION-B11'),
  ListItem(8, 'WESTPORT CRIUSE TERMINAL-B7S'),
  ListItem(9, 'PTP-J33'),
  ListItem(10, 'PASIRGUDANG PORT- J15'),
  ListItem(11, 'TANJUNG LANGSAT-J76'),
  ListItem(12, 'TANJUNG BIN- J33'),
  ListItem(13, 'PASIR PUTIH JETTY'),
  ListItem(14, 'PENGERENG PORT-J15'),
  ListItem(15, 'PENDAS JETTY'),
  ListItem(16, 'PARMESWARA JETTY MELAKA- M14'),
  ListItem(17, 'TANJUNG BRUAS MELAKA-M14'),
  ListItem(18, 'SUNGAI UDANG MELAKA-M15'),
  ListItem(19, 'SUNGAI LINGGI-M23'),
  ListItem(20, 'PORT DICKSON- N11'),
  ListItem(21, 'KUANTAN PORT -C13'),
  ListItem(22, 'KEMAMAN PORT (KSB)- T16'),
  ListItem(23, 'LIKIR BULK TERMINAL LUMUT A22'),
  ListItem(24, 'MARITIME TERMINAL LUMUT A22'),
  ListItem(25, 'VALI PORT A13'),
  ListItem(26, 'KERTEH'),
  ListItem(27, 'MMHE'),
  ListItem(28, 'BWCT -PENANG P15'),
  ListItem(29, 'BUTTERWORTH'),
  ListItem(30, 'PBCT-PENANG P88'),
  ListItem(31, 'NBCT-PENANG P14'),
  ListItem(32, 'SPCT-PENANG P20'),
  ListItem(33, 'TOK BALI'),
  ListItem(34, 'KSB WEST KEMAMAN T15'),
  ListItem(35, 'KPK KEMAMAN T16'),
  ListItem(36, 'KEMAMAN PORT (KSB) T16'),
  ListItem(37, 'LUMUT PORT-A22'),
  ListItem(38, 'SAPANGAR BAY CONTAINER PORT'),
  ListItem(39, 'KOTA KINABALU PORT'),
  ListItem(40, 'SAPANGAR BAY OIL TERMINAL'),
  ListItem(41, 'KUDAT PORT'),
  ListItem(42, 'SANDAKAN PORT'),
  ListItem(43, 'LAHAD DATU PORT'),
  ListItem(44, 'KUNAK PORT'),
  ListItem(45, 'TAWAU PORT'),
  ListItem(46, 'LABUAN PORT'),
  ListItem(47, 'MIRI PORT'),
  ListItem(48, 'SAMALAJU PORT'),
  ListItem(49, 'RAJANG PORT'),
  ListItem(50, 'TANJUNG MANIS PORT'),
  ListItem(51, 'KUCHING PORT'),
  ListItem(52, 'SIBU PORT'),
  ListItem(53, 'SARIKEI PORT'),
  ListItem(54, 'BINTULU PORT'),
];


col.AppBar Appbar(BuildContext context) {
  return AppBar(
    automaticallyImplyLeading: true,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
    );
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}


//Firebase Credentials---------------------------------------
String channeltopic="MALEVA";
String channelId = "MALEVA"; //Required for Android 8.0 or after
String channelName = "MALEVA channel"; //Required for Android 8.0 or after
String channelDescription = "this is our MALEVA channel";
String mobiletoken="";
getDeviceToken() async {
  await Firebase.initializeApp();
  FirebaseMessaging fcm = FirebaseMessaging.instance;
  String? fcmToken = await fcm.getToken();
  if (fcmToken != null) {
    mobiletoken = fcmToken;
    print_(mobiletoken);
  }

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {});
  // fcm.subscribeToTopic('puppies');
  // fcm.unsubscribeFromTopic('puppies');
}
void print_(dynamic msg) {
  if (kDebugMode) {
    print(msg);
  }
}


//Printer Work---------------
bool currentconnectionstate=false;
bool esccommand=false;
Future printerinit() async {
  // await Future.delayed(Duration(seconds: 2));
  try{
    await bpp.BluetoothPrintPlus.connect(bpp.BluetoothDevice(
        bluetoothdeviceList[0].name, bluetoothdeviceList[0].address));
  }
  catch(e){
    var check = e;
  }

}
Future printfunction(List<BarcodePrintModel> obj) async {
  if (currentconnectionstate) {
    printdata(obj);
  }
  else {
    printerinit();
  }
}

Future printdata(List<BarcodePrintModel> obj) async {
  List<Uint8List?> obj1 = [];
  if (esccommand) {
    obj1 = await escTemplateCmd(obj);
  }
  else {
    obj1 = await tscTemplateCmd(obj);
  }
  for (var i = 0; i < obj1.length; i++) {
     bpp.BluetoothPrintPlus.write(obj1[i]);
  }
}
final escCommand = bpp.EscCommand();
Future<List<Uint8List?>> escTemplateCmd(List<BarcodePrintModel> obj) async {
  List<Uint8List?> returndata = [];
  for (var i = 0; i < obj.length; i++) {
    await escCommand.cleanCommand();
    await escCommand.print(feedLines: 1);
    await escCommand.newline();
    await escCommand.text(
        content: obj[i].CompanyName_Data,
        alignment: bpp.Alignment.center,
        style: bpp.EscTextStyle.underline,
        fontSize: bpp.EscFontSize.size7);
    await escCommand.newline();
    await escCommand.text(
        content: obj[i].ShipName_Data,
        alignment: bpp.Alignment.center,
        style: bpp.EscTextStyle.underline,
        fontSize: bpp.EscFontSize.size7);
    await escCommand.newline();
    await escCommand.code128(content: obj[i].Barcode_Data,alignment:bpp.Alignment.center,height: 120,width:4 ,hriPosition: bpp.HriPosition.below);
    await escCommand.newline();
    // await escCommand.qrCode(content: obj[i].Barcode_Data);
    // await escCommand.newline();
    await escCommand.text(
        content:"Date : ${obj[i].Date_Data}",
        alignment: bpp.Alignment.center,
        style: bpp.EscTextStyle.underline,
        fontSize: bpp.EscFontSize.size7);
    await escCommand.newline();
    await escCommand.text(
        content:"Job No : ${obj[i].JobNo_Data}",
        alignment: bpp.Alignment.center,
        style: bpp.EscTextStyle.underline,
        fontSize: bpp.EscFontSize.size7);
    await escCommand.newline();
    await escCommand.text(
        content:"Pkg : ${obj[i].Pkg_Data}",
        alignment: bpp.Alignment.center,
        style: bpp.EscTextStyle.underline,
        fontSize: bpp.EscFontSize.size7);
    await escCommand.print(feedLines: 1);
    final cmd = await escCommand.getCommand();
    returndata.add(cmd);
  }
  return returndata;
}
final tscCommand = bpp.TscCommand();
Future<List<Uint8List?>> tscTemplateCmd(List<BarcodePrintModel> obj) async {
  List<Uint8List?> returndata = [];
  for (var i = 0; i < obj.length; i++) {
    await tscCommand.cleanCommand();
    await tscCommand.size(width: 60, height: 62);
    await tscCommand.cls(); // most after size
    await tscCommand.speed(8);
    await tscCommand.density(8);
    await tscCommand.text(
      content: obj[i].CompanyName_Data,
      x: 50,
      y: 10,
      xMulti: 2,
      yMulti: 2,
    );
    await tscCommand.text(
      content: obj[i].ShipName_Data,
      x: 50,
      y: 65,
      xMulti: 2,
      yMulti: 2,
    );
    await tscCommand.qrCode(
        content: obj[i].Barcode_Data,
        x: 50,
        y: 120,
        cellWidth: 6);
    await tscCommand.text(
      content: obj[i].JobNo_Data,
      x: 50,
      y: 270,
      xMulti: 2,
      yMulti: 2,
    );
    await tscCommand.text(
      content: obj[i].Pkg_Data,
      x: 50,
      y: 320,
      xMulti: 2,
      yMulti: 2,
    );
    await tscCommand.text(
      content:  obj[i].Date_Data,
      x: 50,
      y: 370,
      xMulti: 2,
      yMulti: 2,
    );
    await tscCommand.print(1);
    final cmd = await tscCommand.getCommand();
    returndata.add(cmd);
  }
  return returndata;
}