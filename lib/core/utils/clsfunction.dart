library tabletpos.globals;

export 'dialog_helper.dart';
export 'printer_helper.dart';

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
import 'package:url_launcher/url_launcher.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/home/view/home_tab.dart';
import '../../features/mastersearch/Employee.dart';
import '../config/app_config.dart';
import '../network/api_services/auth_api.dart';
import 'app_preferences.dart';
import '../network/api_constants.dart';
import '../network/api_client.dart';
import 'dialog_helper.dart';
String appversion="1.1.10+110";
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

//String port = "https://maleva.my"; //Live

String port = ApiConstants.port;

//String razorpaykey = "rzp_live_GmuWNB2PVXAnLt";

String imagepath = "$port/Upload/$Comid/";
String apiPostimage = ApiConstants.apiPostImage;
String apiPostfile = ApiConstants.apiPostFile;
String apiuploadpdffile = ApiConstants.apiUploadPdfFile;
String apiGetimage = ApiConstants.apiGetImage;
String apiDeleteimage = ApiConstants.apiDeleteImage;
//String apiPostimage = port + "/api/SaleOrderApp/ImageUpload/";

String apiInsertForwarding = ApiConstants.apiInsertForwarding;
String apiSelectForwarding = ApiConstants.apiSelectForwarding;

String apiLoginSuccess = ApiConstants.apiLoginSuccess;
String apiSelectUser = ApiConstants.apiSelectUser;
String apiSelectCustomer = ApiConstants.apiSelectCustomer;
String apiSelectLocation = ApiConstants.apiSelectLocation;

String apiSelectEmployee = ApiConstants.apiSelectEmployee;
String apiSelectEmailData = ApiConstants.apiSelectEmailData;
String apiInsertMailMaster = ApiConstants.apiInsertMailMaster;
//New
String apiUpdateSaleOrderMaster = ApiConstants.apiUpdateSaleOrderMaster;

String apiSelectJobStatus = ApiConstants.apiSelectJobStatus;
String apiMaxSaleOrderNo = ApiConstants.apiMaxSaleOrderNo;
String apiSelectJobType = ApiConstants.apiSelectJobType;
String apiSelectAllJobStatus = ApiConstants.apiSelectAllJobStatus;
String apiGetRTINo = ApiConstants.apiGetRTINo;
String apiSelectAgentCompany = ApiConstants.apiSelectAgentCompany;
String apiSelectAgentAll = ApiConstants.apiSelectAgentAll;
String apiGetProductList = ApiConstants.apiGetProductList;
String apiSelectAddressList = ApiConstants.apiSelectAddressList;
String apiSelectSalesOrder = ApiConstants.apiSelectSalesOrder;
String apiSelectTVSaleOrder = ApiConstants.apiSelectTVSaleOrder;
String apiEditPassword = ApiConstants.apiEditPassword;
String apiEditSalesOrder = ApiConstants.apiEditSalesOrder;
String apiInsertSalesOrder = ApiConstants.apiInsertSalesOrder;
String apiDeleteSalesOrder = ApiConstants.apiDeleteSalesOrder;
String apiSelectAddressDetails = ApiConstants.apiSelectAddressDetails;
String apiGetJobNo = ApiConstants.apiGetJobNo;
String apiUpdateForwarding = ApiConstants.apiUpdateForwarding;
String apiUpdateBoardingDetails = ApiConstants.apiUpdateBoardingDetails;
String apiUpdateBoardingOfficer = ApiConstants.apiUpdateBoardingOfficer;
String apiUpdateAirFrieghtDetails = ApiConstants.apiUpdateAirFrieghtDetails;
String apiselectBillordercheck = ApiConstants.apiselectBillordercheck;
String apiGetTruckList = ApiConstants.apiGetTruckList;

String apiGetReceipt = ApiConstants.apiGetReceipt;
String apiSelectReceipt = ApiConstants.apiSelectReceipt;
String apiGetpettycash = ApiConstants.apiGetpettycash;
String apiGeteditepettycash = ApiConstants.apiGetpettycash;

//Employee

String apiSelectEmployeeDetails = ApiConstants.apiSelectEmployeeDetails;
String apiInsertEmployeeDetails = ApiConstants.apiInsertEmployeeDetails;
String apiSelectEmployeeType = ApiConstants.apiSelectEmployeeType;
String apiDeleteEmployeeType = ApiConstants.apiDeleteEmployeeType;

String apiSelectPaymentPending = ApiConstants.apiSelectPaymentPending;

String apiSelectAllInventory = ApiConstants.apiSelectAllInventory;

String apiSelectTruckDetails = ApiConstants.apiSelectTruckDetails;

String apiSelectDriverDetails = ApiConstants.apiSelectDriverDetails;

String apiSelectSpeedingReport = ApiConstants.apiSelectSpeedingReport;
String apiSelectFuelFillingReport = ApiConstants.apiSelectFuelFillingReport;
String apiSelectEangiehoursReport = ApiConstants.apiSelectEngineHoursReport;
String apiSelectDriverSalary = ApiConstants.apiSelectDriverSalary;
String apiSelectBoardingSalary = ApiConstants.apiSelectBoardingSalary;
String apiSelectGoogleReview = ApiConstants.apiSelectGoogleReview;
String apiDeleteGoogleReview = ApiConstants.apiDeleteGoogleReview;
/// Declear the  varibale  call  for the  checlsaleorder invoice
String apiSelectSaleorderinvoicecheck = ApiConstants.apiSelectSaleorderinvoicecheck;
String apiEditTruckDetails = ApiConstants.apiEditTruckDetails;

String apiUpdateTruckDetails = ApiConstants.apiUpdateTruckDetails;
String apiGetDriverList = ApiConstants.apiGetDriverList;
String apiSelectRTIView = ApiConstants.apiSelectRTIView;
String apiSelectRTIDetailsView = ApiConstants.apiSelectRTIDetailsView;
String apiViewRTIPdf = ApiConstants.apiViewRTIPdf;
String apiRTIMail = ApiConstants.apiRTIMail;
String apiViewDOConvert = ApiConstants.apiViewDOConvert;
String apiViewInvoice = ApiConstants.apiViewInvoice;
String apiGetSalesData = ApiConstants.apiGetSalesData;
String apiGetEmployeeSalesData = ApiConstants.apiGetEmployeeSalesData;
String apiGetEmployeeInvData = ApiConstants.apiGetEmployeeInvData;
String apiGetFWData = ApiConstants.apiGetFWData;

String apiGetMaintenance = ApiConstants.apiGetMaintenance;
String apiGetMaintenance1 = ApiConstants.apiGetMaintenance1;
String apiGetMaintenance2 = ApiConstants.apiGetMaintenance2;
String apiGetReceiptView = ApiConstants.apiGetReceiptView;

String apiGetExpData = ApiConstants.apiGetExpData;
String apiGetComboS1 = ApiConstants.apiGetComboS1;
String apiGetCurrencyValue = ApiConstants.apiGetCurrencyValue;
String apiBoardingMail = ApiConstants.apiBoardingMail;

String apiSelectExpenseDetails = ApiConstants.apiSelectExpenseDetails;


String apiGoogleReviewInsert = ApiConstants.apiGoogleReviewInsert;

String apiRTIDetailsInsert = ApiConstants.apiRTIDetailsInsert;

//PreAlert Report

String apiPreAlertReport = ApiConstants.apiPreAlertReport;
String apiViewPlanningPdf = ApiConstants.apiViewPlanningPdf;
String apiSelectPlanning = ApiConstants.apiSelectPlanning;
String apiEditPlanning = ApiConstants.apiEditPlanning;
String PLANINGSearch = ApiConstants.PLANINGSearch;

String AirFrieghtDB = ApiConstants.AirFrieghtDB;
String VESSELPLANINGDB = ApiConstants.VESSELPLANINGDB;
String PLANINGSearchDB = ApiConstants.PLANINGSearchDB;
String PLANINGDriverSearch = ApiConstants.PLANINGDriverSearch;
String SaleInvoiceCountDB = ApiConstants.SaleInvoiceCountDB;


String SelectSalesOrderStatus = ApiConstants.SelectSalesOrderStatus;


String LoadRulesType = ApiConstants.LoadRulesType;
String LoadUnReleaseNo = ApiConstants.LoadUnReleaseNo;
String LoadK8UnReleaseNo = ApiConstants.LoadK8UnReleaseNo;

String apiViewVesselPlanningPdf = ApiConstants.apiViewVesselPlanningPdf;
String apiSelectVesselPlanning = ApiConstants.apiSelectVesselPlanning;
String apiEditVesselPlanning = ApiConstants.apiEditVesselPlanning;
//Fuel Entry
String apiInsertFuelEntry = ApiConstants.apiInsertFuelEntry;
String apiMaxFuelEntryNo = ApiConstants.apiMaxFuelEntryNo;
String apiDeleteFuelEntry = ApiConstants.apiDeleteFuelEntry;
String apiEditFuelEntry = ApiConstants.apiEditFuelEntry;
String apiSelectFuelEntry = ApiConstants.apiSelectFuelEntry;

String apiInsertEnquiry = ApiConstants.apiInsertEnquiry;
String apiSelectEnquiryMaster = ApiConstants.apiSelectEnquiryMaster;
String apiUpdateEnquiryMaster = ApiConstants.apiUpdateEnquiryMaster;
//Driver view
  String apiDriverViewRecords = ApiConstants.apiDriverViewRecords;
  //comit
  String apiBillorderview = ApiConstants.apiBillorderview;
  String apiPettyCashview = ApiConstants.apiPettyCashview;
  String apiLicenseViewRecords = ApiConstants.apiLicenseViewRecords;
//Stock
String apiSelectStockDetails = ApiConstants.apiSelectStockDetails;
String apiEditStockIn = ApiConstants.apiEditStockIn;
String apiUpdateStockIn = ApiConstants.apiUpdateStockIn;
String apiUpdateStockTransfer = ApiConstants.apiUpdateStockTransfer;
String apiInsertStockIn = ApiConstants.apiInsertStockIn;
String apiMaxStockNo = ApiConstants.apiMaxStockNo;
String apiSaleOrderDetailsLoad = ApiConstants.apiSelectStockDetails;
String apiPrintStock = ApiConstants.apiPrintStock;
String apiSelectStockJob = ApiConstants.apiSelectStockJob;

String apiWareHouseCombo = ApiConstants.apiWareHouseCombo;
String apiInsertSpareParts = ApiConstants.apiInsertSpareParts;
String apiGetSpareParts = ApiConstants.apiGetSpareParts;


String apiInsertSpotSaleEntry = ApiConstants.apiInsertSpotSaleEntry;
String apiGetSpotSaleEntry = ApiConstants.apiGetSpotSaleEntry;

String apiInsertSummonParts = ApiConstants.apiInsertSummonParts;
String apiGetSummonParts = ApiConstants.apiGetSummonParts;


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

Map<String, String> _buildRequestHeaders(Map<String, String>? customHeaders, {bool skipAuth = false}) {
  final headers = <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
  };
  if (customHeaders != null) {
    headers.addAll(customHeaders);
  }
  if (!skipAuth) {
    String token = storagenew.getString('Tokenkey') ?? "";
    String Userid = storagenew.getString('Userid') ?? "";
    String Profile = storagenew.getString('Profile') ?? "";
    if (token != "") {
      headers['Authorization'] = 'Bearer $token';
      headers['Userid'] = Userid;
      headers['Profile'] = Profile;
    }
  }
  return headers;
}

Future<http.Response> _performPostRequest(String url, dynamic bodyData, Map<String, String> headers) async {
  final body = json.encode(bodyData);
  debugPrint(url);
  if (body != '' && body != 'null') {
    debugPrint(body);
  }
  return await http.post(Uri.parse(url), headers: headers, body: body).timeout(const Duration(seconds: 30));
}

Future<List<dynamic>> apiAllinoneSelect(api, insertDetails,
    Map<String, String>? header, BuildContext ?context) async {
  String apiname = api.toString().split('?')[0];
  apiname = "${apiname.replaceAll('$port/api/', '')}: ";
  try {
    final headers = _buildRequestHeaders(header);
    final result = await _performPostRequest(api, insertDetails, headers);
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
      return [];
    } else if (result.statusCode == 404 || result.statusCode == 500) {
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

Future<dynamic> apiAllinoneMapSelect(
    api,
    insertDetails,
    Map<String, String>? header,
    BuildContext context) async {
  String apiname = api.toString().split('?')[0];
  apiname = "${apiname.replaceAll('$port/api/', '')}: ";
  try {
    final headers = _buildRequestHeaders(header);
    final result = await _performPostRequest(api, insertDetails, headers);

    if (result.statusCode == 200) {
      if (result.body == "") {
        return [];
      } else {
        final decoded = jsonDecode(result.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        } else if (decoded is List) {
          return decoded;
        } else {
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
    } else if (result.statusCode == 404 || result.statusCode == 500) {
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
  String apiname = api.toString().split('?')[0];
  apiname = "${apiname.replaceAll('$port/api/', '')}: ";
  try {
    final headers = _buildRequestHeaders(header, skipAuth: true);
    final result = await _performPostRequest(api, insertDetails, headers);
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
      return [];
    } else if (result.statusCode == 404 || result.statusCode == 500) {
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

Future<dynamic> apiAllinoneSelectArrayWithOutAuth(api, insertDetails,
    Map<String, String>? header, BuildContext ?context) async {
  String apiname = api.toString().split('?')[0];
  apiname = "${apiname.replaceAll('$port/api/', '')}: ";
  try {
    final headers = _buildRequestHeaders(header, skipAuth: true);
    final result = await _performPostRequest(api, insertDetails, headers);
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
      return [];
    } else if (result.statusCode == 404 || result.statusCode == 500) {
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

Future<dynamic> apiAllinoneSelectArray(api, insertDetails,
    Map<String, String>? header, BuildContext? context) async {
  String apiname = api.toString().split('?')[0];
  apiname = "${apiname.replaceAll('$port/api/', '')}: ";
  try {
    final headers = _buildRequestHeaders(header);
    final result = await _performPostRequest(api, insertDetails, headers);

    if (result.statusCode == 200) {
      if (result.body == "") {
        return [];
      } else {
        return jsonDecode(result.body);
      }
    } else if (result.statusCode == 401) {
      if (context != null) {
        ConfirmationOK("Authentication Failed !!!..ReLogin !!!", context);
        ResponseViewModel? value =
        ResponseViewModel.fromJson(jsonDecode(result.body));
        msgshow(value.Message, "", Colors.white, Colors.green, null,
            18.00 - reducesize, tll, tgc, context, 2);
      }
      return [];
    } else if (result.statusCode == 406) {
      loginId = 0;
      loginname = '';
      storagenew.setString('Username', "");
      storagenew.setString('Password', "");
      storagenew.setString('OldUsername', "");
      if (context != null) {
        ConfirmationOK(
            "Already Login Another User.ReLogin or Change Password !!!", context);
      }
      return [];
    } else if (result.statusCode == 404 || result.statusCode == 500) {
      if (context != null) {
        ResponseViewModel? value =
        ResponseViewModel.fromJson(jsonDecode(result.body));
        msgshow(value.Message, "", Colors.white, Colors.green, null,
            18.00 - reducesize, tll, tgc, context, 2);
      }
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

Future<dynamic> apiAllinone(api, insertDetails, Map<String, String>? header, BuildContext context) async {
  String apiname = api.toString().split('?')[0];
  apiname = "${apiname.replaceAll('$port/api/', '')}: ";
  try {
    final headers = _buildRequestHeaders(header);
    final result = await _performPostRequest(api, insertDetails, headers);
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
  } catch (error) {
    msgshow('Check Your Network Connection', "", Colors.white, Colors.red, null,
        18.00 - reducesize, tll, tgc, context, 2);
    throw Exception('$apiname$error');
  }
}

Future<String> apiGetString(api) async {
  try {
    debugPrint(api);
    numberofapicalls = numberofapicalls + 1;
    var result = await http.post(Uri.parse(api)).timeout(const Duration(seconds: 30));
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

Toast tls = Toast.LENGTH_SHORT;
Toast tll = Toast.LENGTH_LONG;
ToastGravity tgc = ToastGravity.CENTER;

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
Future<String> upload(File imageFile, String imageapi, int Id, String FolderName, String SubFolderName) async {
  try {
    return await ApiClient.uploadImage(
      imageFile,
      imageapi,
      comId: Comid,
      id: Id,
      folderName: FolderName,
      subFolderName: SubFolderName,
    );
  } catch (_) {
    return "";
  }
}

Future<String> uploadPdfOrImage(File file, int comid, int Id, String apiUploadPdfFile, String folderName, String subFolderName) async {
  try {
    return await ApiClient.uploadPdfOrFile(
      file,
      apiUploadPdfFile,
      comId: comid,
      id: Id,
      folderName: folderName,
      subFolderName: subFolderName,
    );
  } catch (_) {
    return "";
  }
}



Future<void> logout(BuildContext context) async {
  bool result = await ConfirmationMsgYesNo(context, "Are you sure you want to logout?");

  if (!result) {
    return;
  }

  // Clear Session Variables
  loginId = 0;
  loginname = '';
  DriverLogin = 0;
  DriverTruckRefId = 0;

  storagenew.setString('Username', "");
  storagenew.setString('Password', "");
  storagenew.setString('OldUsername', "");


  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => LoginBloc(
          authRepository: AuthRepository(
            authApi: AuthApi.instance,
          ),
        ),
        child: const Appuserloginmobile(),
      ),
    ),
        (Route<dynamic> route) => false,
  );
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

  FirebaseMessaging fcm = FirebaseMessaging.instance;
  String? fcmToken = await fcm.getToken();
  if (fcmToken != null) {
    mobiletoken = fcmToken;
    await AppPreferences.setFcmToken(fcmToken);
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
