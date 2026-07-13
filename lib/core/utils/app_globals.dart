export 'dialog_helper.dart';
export 'printer_helper.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:core' as cc;
import 'dart:io';
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
import '../network/api_services/auth_api.dart';
import 'app_preferences.dart';
import '../network/api_constants.dart';
import '../network/api_client.dart';
import 'dialog_helper.dart';

class AppGlobals {
  AppGlobals._();

  static String appversion="1.1.10+114";
  static bool homepagecall = false;
  static AssetImage logo = const AssetImage('assets/company/logo.png');
  static AssetImage splashlogo = const AssetImage('assets/company/roundlogo.png');
  static AssetImage calendar = const AssetImage('assets/common/calendar.png');
  static AssetImage lockimg = const AssetImage('assets/common/lockImg.png');

  // String port0 = "http://192.168.1.100:8085/";
  // String port = "http://192.168.1.13:9007/";
  //String port = "http://103.215.139.8:8001/";
  // String port = "http://192.168.1.101:8003/";

  //String port = "http://103.215.139.121:9001/"; //Demos

  //String port = "http://103.215.139.8:8001/"; //Demolatest

  //String port = "https://maleva.my"; //Live

  static String port = ApiConstants.port;

  //String razorpaykey = "rzp_live_GmuWNB2PVXAnLt";

  static String imagepath = "$port/Upload/$Comid/";
  static String apiPostimage = ApiConstants.apiPostImage;
  static String apiPostfile = ApiConstants.apiPostFile;
  static String apiuploadpdffile = ApiConstants.apiUploadPdfFile;
  static String apiGetimage = ApiConstants.apiGetImage;
  static String apiDeleteimage = ApiConstants.apiDeleteImage;
  //String apiPostimage = port + "/api/SaleOrderApp/ImageUpload/";

  static String apiInsertForwarding = ApiConstants.apiInsertForwarding;
  static String apiSelectForwarding = ApiConstants.apiSelectForwarding;

  static String apiLoginSuccess = ApiConstants.apiLoginSuccess;
  static String apiSelectUser = ApiConstants.apiSelectUser;
  static String apiSelectCustomer = ApiConstants.apiSelectCustomer;
  static String apiSelectLocation = ApiConstants.apiSelectLocation;

  static String apiSelectEmployee = ApiConstants.apiSelectEmployee;
  static String apiSelectEmailData = ApiConstants.apiSelectEmailData;
  static String apiInsertMailMaster = ApiConstants.apiInsertMailMaster;
  //New
  static String apiUpdateSaleOrderMaster = ApiConstants.apiUpdateSaleOrderMaster;

  static String apiSelectJobStatus = ApiConstants.apiSelectJobStatus;
  static String apiMaxSaleOrderNo = ApiConstants.apiMaxSaleOrderNo;
  static String apiSelectJobType = ApiConstants.apiSelectJobType;
  static String apiSelectAllJobStatus = ApiConstants.apiSelectAllJobStatus;
  static String apiGetRTINo = ApiConstants.apiGetRTINo;
  static String apiSelectAgentCompany = ApiConstants.apiSelectAgentCompany;
  static String apiSelectAgentAll = ApiConstants.apiSelectAgentAll;
  static String apiGetProductList = ApiConstants.apiGetProductList;
  static String apiSelectAddressList = ApiConstants.apiSelectAddressList;
  static String apiSelectSalesOrder = ApiConstants.apiSelectSalesOrder;
  static String apiSelectTVSaleOrder = ApiConstants.apiSelectTVSaleOrder;
  static String apiEditPassword = ApiConstants.apiEditPassword;
  static String apiEditSalesOrder = ApiConstants.apiEditSalesOrder;
  static String apiInsertSalesOrder = ApiConstants.apiInsertSalesOrder;
  static String apiDeleteSalesOrder = ApiConstants.apiDeleteSalesOrder;
  static String apiSelectAddressDetails = ApiConstants.apiSelectAddressDetails;
  static String apiGetJobNo = ApiConstants.apiGetJobNo;
  static String apiUpdateForwarding = ApiConstants.apiUpdateForwarding;
  static String apiUpdateBoardingDetails = ApiConstants.apiUpdateBoardingDetails;
  static String apiUpdateBoardingOfficer = ApiConstants.apiUpdateBoardingOfficer;
  static String apiUpdateAirFrieghtDetails = ApiConstants.apiUpdateAirFrieghtDetails;
  static String apiselectBillordercheck = ApiConstants.apiselectBillordercheck;
  static String apiGetTruckList = ApiConstants.apiGetTruckList;

  static String apiGetReceipt = ApiConstants.apiGetReceipt;
  static String apiSelectReceipt = ApiConstants.apiSelectReceipt;
  static String apiGetpettycash = ApiConstants.apiGetpettycash;
  static String apiGeteditepettycash = ApiConstants.apiGetpettycash;

  //Employee

  static String apiSelectEmployeeDetails = ApiConstants.apiSelectEmployeeDetails;
  static String apiInsertEmployeeDetails = ApiConstants.apiInsertEmployeeDetails;
  static String apiSelectEmployeeType = ApiConstants.apiSelectEmployeeType;
  static String apiDeleteEmployeeType = ApiConstants.apiDeleteEmployeeType;

  static String apiSelectPaymentPending = ApiConstants.apiSelectPaymentPending;

  static String apiSelectAllInventory = ApiConstants.apiSelectAllInventory;

  static String apiSelectTruckDetails = ApiConstants.apiSelectTruckDetails;

  static String apiSelectDriverDetails = ApiConstants.apiSelectDriverDetails;

  static String apiSelectSpeedingReport = ApiConstants.apiSelectSpeedingReport;
  static String apiSelectFuelFillingReport = ApiConstants.apiSelectFuelFillingReport;
  static String apiSelectEangiehoursReport = ApiConstants.apiSelectEngineHoursReport;
  static String apiSelectDriverSalary = ApiConstants.apiSelectDriverSalary;
  static String apiSelectBoardingSalary = ApiConstants.apiSelectBoardingSalary;
  static String apiSelectGoogleReview = ApiConstants.apiSelectGoogleReview;
  static String apiDeleteGoogleReview = ApiConstants.apiDeleteGoogleReview;
  /// Declear the  varibale  call  for the  checlsaleorder invoice
  static String apiSelectSaleorderinvoicecheck = ApiConstants.apiSelectSaleorderinvoicecheck;
  static String apiEditTruckDetails = ApiConstants.apiEditTruckDetails;

  static String apiUpdateTruckDetails = ApiConstants.apiUpdateTruckDetails;
  static String apiGetDriverList = ApiConstants.apiGetDriverList;
  static String apiSelectRTIView = ApiConstants.apiSelectRTIView;
  static String apiSelectRTIDetailsView = ApiConstants.apiSelectRTIDetailsView;
  static String apiViewRTIPdf = ApiConstants.apiViewRTIPdf;
  static String apiRTIMail = ApiConstants.apiRTIMail;
  static String apiViewDOConvert = ApiConstants.apiViewDOConvert;
  static String apiViewInvoice = ApiConstants.apiViewInvoice;
  static String apiGetSalesData = ApiConstants.apiGetSalesData;
  static String apiGetEmployeeSalesData = ApiConstants.apiGetEmployeeSalesData;
  static String apiGetEmployeeInvData = ApiConstants.apiGetEmployeeInvData;
  static String apiGetFWData = ApiConstants.apiGetFWData;

  static String apiGetMaintenance = ApiConstants.apiGetMaintenance;
  static String apiGetMaintenance1 = ApiConstants.apiGetMaintenance1;
  static String apiGetMaintenance2 = ApiConstants.apiGetMaintenance2;
  static String apiGetReceiptView = ApiConstants.apiGetReceiptView;

  static String apiGetExpData = ApiConstants.apiGetExpData;
  static String apiGetComboS1 = ApiConstants.apiGetComboS1;
  static String apiGetCurrencyValue = ApiConstants.apiGetCurrencyValue;
  static String apiBoardingMail = ApiConstants.apiBoardingMail;

  static String apiSelectExpenseDetails = ApiConstants.apiSelectExpenseDetails;


  static String apiGoogleReviewInsert = ApiConstants.apiGoogleReviewInsert;

  static String apiRTIDetailsInsert = ApiConstants.apiRTIDetailsInsert;

  //PreAlert Report

  static String apiPreAlertReport = ApiConstants.apiPreAlertReport;
  static String apiViewPlanningPdf = ApiConstants.apiViewPlanningPdf;
  static String apiSelectPlanning = ApiConstants.apiSelectPlanning;
  static String apiEditPlanning = ApiConstants.apiEditPlanning;
  static String PLANINGSearch = ApiConstants.PLANINGSearch;

  static String AirFrieghtDB = ApiConstants.AirFrieghtDB;
  static String VESSELPLANINGDB = ApiConstants.VESSELPLANINGDB;
  static String PLANINGSearchDB = ApiConstants.PLANINGSearchDB;
  static String PLANINGDriverSearch = ApiConstants.PLANINGDriverSearch;
  static String SaleInvoiceCountDB = ApiConstants.SaleInvoiceCountDB;


  static String SelectSalesOrderStatus = ApiConstants.SelectSalesOrderStatus;


  static String LoadRulesType = ApiConstants.LoadRulesType;
  static String LoadUnReleaseNo = ApiConstants.LoadUnReleaseNo;
  static String LoadK8UnReleaseNo = ApiConstants.LoadK8UnReleaseNo;

  static String apiViewVesselPlanningPdf = ApiConstants.apiViewVesselPlanningPdf;
  static String apiSelectVesselPlanning = ApiConstants.apiSelectVesselPlanning;
  static String apiEditVesselPlanning = ApiConstants.apiEditVesselPlanning;
  static String apiVesselPlanningSearch = ApiConstants.apiVesselPlanningSearch;
  static String apiMaxVesselPlanningNo  = ApiConstants.apiMaxVesselPlanningNo;
  static String apiInsertVesselPlanning = ApiConstants.apiInsertVesselPlanning;
  static String apiDeleteVesselPlanning = ApiConstants.apiDeleteVesselPlanning;
  static String apiUpdateSaleOrderSpecific = ApiConstants.apiUpdateSaleOrderSpecific;
  //Fuel Entry
  static String apiInsertFuelEntry = ApiConstants.apiInsertFuelEntry;
  static String apiMaxFuelEntryNo = ApiConstants.apiMaxFuelEntryNo;
  static String apiDeleteFuelEntry = ApiConstants.apiDeleteFuelEntry;
  static String apiEditFuelEntry = ApiConstants.apiEditFuelEntry;
  static String apiSelectFuelEntry = ApiConstants.apiSelectFuelEntry;

  static String apiInsertEnquiry = ApiConstants.apiInsertEnquiry;
  static String apiSelectEnquiryMaster = ApiConstants.apiSelectEnquiryMaster;
  static String apiUpdateEnquiryMaster = ApiConstants.apiUpdateEnquiryMaster;
  //Driver view
  static   String apiDriverViewRecords = ApiConstants.apiDriverViewRecords;
    //comit
  static   String apiBillorderview = ApiConstants.apiBillorderview;
  static   String apiPettyCashview = ApiConstants.apiPettyCashview;
  static   String apiLicenseViewRecords = ApiConstants.apiLicenseViewRecords;
  //Stock
  static String apiSelectStockDetails = ApiConstants.apiSelectStockDetails;
  static String apiEditStockIn = ApiConstants.apiEditStockIn;
  static String apiUpdateStockIn = ApiConstants.apiUpdateStockIn;
  static String apiUpdateStockTransfer = ApiConstants.apiUpdateStockTransfer;
  static String apiInsertStockIn = ApiConstants.apiInsertStockIn;
  static String apiMaxStockNo = ApiConstants.apiMaxStockNo;
  static String apiSaleOrderDetailsLoad = ApiConstants.apiSelectStockDetails;
  static String apiPrintStock = ApiConstants.apiPrintStock;
  static String apiSelectStockJob = ApiConstants.apiSelectStockJob;

  static String apiWareHouseCombo = ApiConstants.apiWareHouseCombo;
  static String apiInsertSpareParts = ApiConstants.apiInsertSpareParts;
  static String apiGetSpareParts = ApiConstants.apiGetSpareParts;


  static String apiInsertSpotSaleEntry = ApiConstants.apiInsertSpotSaleEntry;
  static String apiGetSpotSaleEntry = ApiConstants.apiGetSpotSaleEntry;

  static String apiInsertSummonParts = ApiConstants.apiInsertSummonParts;
  static String apiGetSummonParts = ApiConstants.apiGetSummonParts;


  static final navigatorKey = GlobalKey<NavigatorState>();
  static SharedPreferences storagenew = storagenew;
  static final txtLoginEmployee = TextEditingController();
  static final txtLoginPassword = TextEditingController();
  static var commonexpirydays = 15;
  static var ExpenseDueDays = 5;
  static var apadbonamexpirydays = 60;
  static var ExpServiceAligmentGreecedays = 5;
  static int DriverLogin = 0;
  static int DriverTruckRefId = 0;
  static int MalevaScreen = storagenew.getInt('DeviceView') ?? 1;
  static String DriverTruckName='';


  static Future<void> localstoragecall() async {
    storagenew = await SharedPreferences.getInstance();
  }

  static Map<String, String> _buildRequestHeaders(Map<String, String>? customHeaders, {bool skipAuth = false}) {
  final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }
    if (!skipAuth) {
  String token = "";
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

  static Future<http.Response> _performPostRequest(String url, dynamic bodyData, Map<String, String> headers) async {
  String body;
    if (bodyData == null || bodyData == '') {
      body = "{}";
    } else {
      body = json.encode(bodyData);
    }
  
    debugPrint(url);
    if (body != '' && body != 'null' && body != '{}') {
      debugPrint(body);
    }
    return await http.post(Uri.parse(url), headers: headers, body: body).timeout(const Duration(seconds: 30));
  }

  static Future<List<dynamic>> apiAllinoneSelect(api, insertDetails,
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

  static Future<dynamic> apiAllinoneMapSelect(
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

  static Future<List<dynamic>> apiAllinoneSelectWithOutAuth(api, insertDetails,
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

  static Future<dynamic> apiAllinoneSelectArrayWithOutAuth(api, insertDetails,
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

  static Future<dynamic> apiAllinoneSelectArray(api, insertDetails,
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

  static Future<dynamic> apiAllinone(api, insertDetails, Map<String, String>? header, BuildContext context) async {
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

  static Future<String> apiGetString(api) async {
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

  static Toast tls = Toast.LENGTH_SHORT;
  static Toast tll = Toast.LENGTH_LONG;
  static ToastGravity tgc = ToastGravity.CENTER;

  static String currentdate(int days)  {
  DateTime currentDate = DateTime.now();

    // Add the days
  DateTime newDate = currentDate.add(Duration(days: days));

    // Format the new date
  String formattedDate = DateFormat('yyyy-MM-dd').format(newDate);
    return formattedDate;

  }
  static Future launchInBrowser(String url) async {
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    )) {
  throw Exception('Could not launch $url');
    }
  }
  static Future<void> EmployeeLogin(context, int type) async {
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
  static bool downloadprogress = false;
  static double? progress = 0;
  get downloadProgress => progress;

  static Future startDownloading(String urlpath) async {
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
  static Future<File> _getFile(String filename) async {
  final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/$filename");
  }

  static String networkimage = '';
  static Future<String> upload(File imageFile, String imageapi, int Id, String FolderName, String SubFolderName) async {
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

  static Future<String> uploadPdfOrImage(File file, int comid, int Id, String apiUploadPdfFile, String folderName, String subFolderName) async {
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



  static Future<void> logout(BuildContext context) async {
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


  static String barcodestring = '';
  static bool barcodeerror = false;
  static Future barcodeScanning() async {
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
  static Future checkVersion(BuildContext context) async {
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
  static int cashierLoginId = 0;
  static String cashierloginname = '';
  static int loginId = 1;
  static String loginname = '';
  static String loginpower = '';
  static int CloudTrial = 0;
  static DateTime Cloud_Ldate = DateTime.now();
  static bool networkConnection = false;
  static int maxytryconnection = 5;
  static int currenttryconnection = 6;
  static int numberofapicalls = 0;
  static int mCompanyRefid = 2;
  static bool onlineMirrorTable = false;
  // int CompanyRefid = 1;
  static int reducesize = 0;
  static double progresspercentage = 0.00;
  static String progresspercentagestring = "0.0";
  static String downlaodname = "";
  static bool downloadbreak = false;
  //Company Details
  static String companyname = 'Maleva';
  static String caddress1 = 'No.1/184A, Vijayalakshmi';
  static String caddress2 = 'Nagar 2nd Street,Abinadhan Nagar';
  static String ccity = 'Chennai';
  static String cmobileno = '+91 87540 31480';
  static String cgstino = 'GST-X123456';
  static String cwebsite = 'https://www.webpos.in/';
  static String cfootermsg1 = 'This is Footer Msg1';
  static String cfootermsg2 = 'This is Footer Msg2';
  static String selectedCompanyName = "";
  static String tcompanyname = 'TabletPOS';
  static String tcaddress1 = 'No.1/184A, Vijayalakshmi';
  static String tcaddress2 = 'Nagar 2nd Street,Abinadhan Nagar';
  static String tccity = 'Chennai';

  static List<MenuMasterModel> objMenuMaster = [];
  static List<MenuMasterModel> parentclass = [];

  static List<MainsettingModel> mainsettinglist = [];

  static List<EmployeeModel> EmployeeList = [];
  static EmployeeModel SelectEmployeeList = EmployeeModel.Empty();
  static List<UserLoginModel> UserList = [];
  static List<CustomerModel> CustomerList = [];
  static List<LocationModel> LocationList = [];
  static List<WareHouseModel> WareHouseList = [];
  static List<WareHouseModel> StockJobList = [];
  static CustomerModel SelectCustomerList = CustomerModel.Empty();
  static LocationModel SelectLocationList = LocationModel.Empty();
  static List<JobStatusModel> JobStatusList = [];
  static JobStatusModel SelectJobStatusList = JobStatusModel.Empty();
  static List<JobTypeModel> JobTypeList = [];
  static JobTypeModel SelectJobTypeList = JobTypeModel.Empty();
  static List<JobAllStatusModel> JobAllStatusList = [];
  static JobAllStatusModel SelectAllStatusList = JobAllStatusModel.Empty();
  static List<AgentCompanyModel> AgentCompanyList = [];
  static AgentCompanyModel SelectAgentCompanyList = AgentCompanyModel.Empty();
  static List<AgentModel> AgentAllList = [];
  static AgentModel SelectAgentAllList = AgentModel.Empty();
  static List<ProductModel> ProductList = [];
  static ProductModel SelectProductList = ProductModel.Empty();
  static List<ForwardingModel> ForwardingList = [];
  static ForwardingModel SelectForwardingList = ForwardingModel.Empty();
  static List<GetTruckModel> GetTruckList = [];




  static GetTruckModel SelectTruckList = GetTruckModel.Empty();
  static List<JobTypeDetailsModel> JobTypeDetailsList = [];
  static List<TruckDetailsModel> TruckDetailsList = [];

  static TruckDetailsModel SelectTruckDetails = TruckDetailsModel.Empty();
  static List<BarcodePrintModel> BarcodeList=[];

  static WareHouseModel SelectWareHouseList = WareHouseModel.Empty();
  static List<WareHouseModel> WareHouseModelAllList = [];

  static List<dynamic> AddressList = [];
  static List<dynamic> SaleOrderMasterList = [];
  static List<dynamic> SaleOrderDetailList = [];
  static List<dynamic> PlanningMasterList = [];
  static List<dynamic> PlanningDetailsList = [];
  static List<dynamic> PlanningEditList = [];
  static List<dynamic> VesselPlanningMasterList = [];
  static List<dynamic> VesselPlanningDetailsList = [];
  static List<dynamic> VesselPlanningEditList = [];
  static List<SaleEditDetailModel> SaleEditDetailList = [];
  static List<dynamic> SaleEditMasterList = [];
  static List<dynamic> ComboS1List = [];
  static List<dynamic> GetImagesList = [];
  static List<AddressDetailsModel> AddressDetailedList = [];
  static List<GetTruckModel> GetDriverList = [];
  static GetTruckModel SelectDriverList = GetTruckModel.Empty();
  static List<dynamic> RTIViewMasterList = [];
  static List<dynamic> RTIViewDetailList = [];

  static List<RTIDetailsViewModel> RTIViewDetailList1 = [];

  static List<RTIDetailsViewModel> RTIDetailsDetailList = [];
  static List<dynamic> EnquiryMasterList = [];
  static List<dynamic> PickupQuantityList = [];
  //List<SaleEditMasterModel> SaleEditMasterList = [];
  static String SelectAddressList = "";

  static List<dynamic> JobNoList = [];
  static String MaxSaleOrderNum = '';
  static String MaxStockNum = '';
  static int EmpRefId = 0;
  static int LoginEmpId = 0;
  static int Comid = 0;
  static double CustomerCurrencyValue = 0.0;
  static int SelectedId = 0;
  static double FontKeypad = 26;
  static double FontLarge = 24;
  static double FontMedium = 20;
  static double FontLow = 18;
  static double FontCardText = 14;
  static String SelectedName = '';
  static String SelectedPortName = '';
  static String SelectedVesselTypeName = '';
  static String SelectedCommodityName = '';
  static String SelectedCargoName = '';

  static List<ListItem> Paymentload = [
    ListItem(1, 'GPAY'),
    ListItem(2, 'HDFC'),
    ListItem(3, 'CASH')
  ];

  static List<ListItem> MisHoursload = [
    ListItem(1, 'Software Demo(Direct)'),
    ListItem(2, 'Software Demo(Online)'),
    ListItem(3, 'Software Installation(Online)'),
    ListItem(4, 'Software Installation(Direct)'),
    ListItem(5, 'Software Demo-Installation(Online)'),
    ListItem(6, 'Staff Meeting'),
    ListItem(7, 'Quotation'),
    ListItem(8, 'Leave'),
  ];

  static List<ListItem> Portlist = [
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




  //Firebase Credentials---------------------------------------
  static String channeltopic="MALEVA";
  static String channelId = "MALEVA"; //Required for Android 8.0 or after
  static String channelName = "MALEVA channel"; //Required for Android 8.0 or after
  static String channelDescription = "this is our MALEVA channel";
  static String mobiletoken="";
  static getDeviceToken() async {

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


  static void print_(dynamic msg) {
    if (kDebugMode) {
      print(msg);
    }
  }

}

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
static   int reducesize = 0;

static   void init(BuildContext context) {
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
