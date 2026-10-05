import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/stock/stock_in_api.dart';
import 'package:maleva/core/rti/rti_api.dart';
import 'package:maleva/core/network/dio_client.dart';
import 'package:maleva/core/network/java_api_client.dart';
import 'package:maleva/core/network/java_route.dart';
import 'package:maleva/core/network/legacy_call_adapter.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:maleva/core/models/shared/agent_company_model.dart';
import 'package:maleva/features/operations/models/job_all_status_model.dart';
import 'package:maleva/features/operations/models/job_type_model.dart';
import 'package:maleva/core/models/shared/get_truck_model.dart';
import 'package:maleva/features/auth/models/user_login_model.dart';
import 'package:maleva/core/models/shared/customer_model.dart';
import 'package:maleva/core/models/shared/truck_details_model.dart';
import 'package:maleva/core/models/shared/ware_house_model.dart';
import 'package:maleva/core/models/shared/agent_model.dart';
import 'package:maleva/features/operations/models/job_status_model.dart';
import 'package:maleva/core/models/shared/product_model.dart';
import 'package:maleva/features/operations/models/job_type_details_model.dart';
import 'package:maleva/core/models/shared/employee_model.dart';
import 'package:maleva/core/models/shared/location_model.dart';

class LegacyApiRepository {
  final DioClient _dioClient;
  final JavaApiClient? _javaClient;

  LegacyApiRepository(this._dioClient, {JavaApiClient? java}) : _javaClient = java;

  /// The client for [url]: the Java client (session token, refresh on 401)
  /// for a Java URL, the legacy client otherwise. [url] is already resolved
  /// with [JavaRoute.resolve].
  /// A POST to [url]: an old lookup or fuel call is answered by the shared Java
  /// APIs; a moved controller goes to Java; anything else to .NET.
  Future<Response<dynamic>> _routedPost(String url, {Object? data, Options? options}) {
    if (LegacyCallAdapter.handles(url)) {
      return LegacyCallAdapter.asResponse(url, body: data, headers: options?.headers);
    }
    final resolved = JavaRoute.resolve(url);
    return _dioFor(resolved).post(resolved, data: data, options: options);
  }

  Dio _dioFor(String url) =>
      JavaRoute.isJava(url) ? (_javaClient ?? GetIt.instance<JavaApiClient>()).dio : _dioClient.dio;

  List<dynamic> _ensureList(dynamic data) {
    if (data == null) return [];
    if (data is List) return data;
    if (data is Map) return [data];
    return [];
  }

  dynamic _ensureMap(dynamic data) {
    if (data == null) return {};
    if (data is Map) return data;
    if (data is List && data.isNotEmpty) return data[0];
    return {};
  }

  // Generic methods for direct ApiLegacyHelper replacements
  Future<dynamic> post(String url, {dynamic data, Map<String, String>? headers, BuildContext? context}) async {
    try {
      print("🚀 [POST] URL: $url");
      try {
        print("📦 [POST BODY]: ${jsonEncode(data)}");
      } catch (_) {
        print("📦 [POST BODY]: $data");
      }
      
      final options = headers != null ? Options(headers: headers) : null;
      final response = await _routedPost(url, data: data ?? {}, options: options);
      return response.data;
    } on DioException catch (e) {
      // Return the response body even on 4xx/5xx — callers can inspect IsSuccess/StatusCode
      if (e.response?.data != null) {
        print("API ${e.response?.statusCode}: ${url.split('/').last} → ${e.response?.data?['Message'] ?? e.message}");
        return e.response!.data;
      }
      print("API Error: $e");
      return null;
    } catch (e) {
      print("API Error: $e");
      return null;
    }
  }

  Future<List<dynamic>> postList(String url, {dynamic data, Map<String, String>? headers, BuildContext? context}) async {
    try {
      print("🚀 [POST LIST] URL: $url");
      try {
        print("📦 [POST LIST BODY]: ${jsonEncode(data)}");
      } catch (_) {
        print("📦 [POST LIST BODY]: $data");
      }

      final options = headers != null ? Options(headers: headers) : null;
      final response = await _routedPost(url, data: data ?? {}, options: options);
      return _ensureList(response.data);
    } on DioException catch (e) {
      if (e.response?.data != null) {
        print("API ${e.response?.statusCode}: ${url.split('/').last} → ${e.response?.data?['Message'] ?? e.message}");
        return _ensureList(e.response!.data);
      }
      print("API Error: $e");
      return [];
    } catch (e) {
      print("API Error: $e");
      return [];
    }
  }

  // Backward compatible methods for ApiLegacyHelper replacement
  Future<List<dynamic>> apiAllinoneSelect(dynamic api, [dynamic insertDetails, Map<String, String>? header, BuildContext? context]) async {
    header ??= {}; header['Accept-Language'] = 'en-GB';
    print("\n--- API REQUEST ---\nURI: ${api.toString()}\nHeaders: $header\nPayload: $insertDetails\n-------------------");
    final result = await postList(api.toString(), data: insertDetails, headers: header);
    return result;
  }

  Future<dynamic> apiAllinoneSelectArray(dynamic api, [dynamic insertDetails, Map<String, String>? header, BuildContext? context]) async {
    header ??= {}; header['Accept-Language'] = 'en-GB';
      print("\n--- API REQUEST ---\nURI: ${api.toString()}\nHeaders: $header\nPayload: $insertDetails\n-------------------");
      final result = await post(api.toString(), data: insertDetails, headers: header);
    return result;
  }

  Future<dynamic> apiAllinone(dynamic api, [dynamic insertDetails, Map<String, String>? header, BuildContext? context]) async {
    header ??= {}; header['Accept-Language'] = 'en-GB';
      print("\n--- API REQUEST ---\nURI: ${api.toString()}\nHeaders: $header\nPayload: $insertDetails\n-------------------");
      final result = await post(api.toString(), data: insertDetails, headers: header);
    return result;
  }

  Future<String> apiGetString(dynamic api, [dynamic insertDetails, Map<String, String>? header, BuildContext? context]) async {
    try {
      final options = header != null ? Options(headers: header) : null;
      final response = await _routedPost(api.toString(), data: insertDetails ?? {}, options: options);
      return response.data?.toString() ?? '';
    } catch (e) {
      print("API Error: $e");
      return '';
    }
  }


Future SelectUser(context) async {
  try {
    AppGlobals.UserList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = _ensureList((await _routedPost(
            Uri.encodeFull("${ApiConstants.apiSelectUser}$Comid"), data: null ?? {})).data);
  if (resultData.isNotEmpty) {
        AppGlobals.UserList = resultData
            .map((element) => UserLoginModel.fromJson(element))
            .toList();
      }
} catch (e) { print("API Error: $e"); }

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectCustomer(context) async {
  try {
    AppGlobals.CustomerList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = _ensureList((await _routedPost(
            Uri.encodeFull("${ApiConstants.apiSelectCustomer}$Comid"), data: null ?? {})).data);
  if (resultData.isNotEmpty) {
        AppGlobals.CustomerList = resultData
            .map((element) => CustomerModel.fromJson(element))
            .toList();
      }
} catch (e) { print("API Error: $e"); }

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectLocation(context) async {
  try {
    AppGlobals.LocationList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = _ensureList((await _routedPost(
        Uri.encodeFull("${ApiConstants.apiSelectLocation}$Comid"), data: null ?? {})).data);
  if (resultData.isNotEmpty) {
        AppGlobals.LocationList = resultData
            .map((element) => LocationModel.fromJson(element))
            .toList();
      }
} catch (e) { print("API Error: $e"); }

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectWareHouse(context) async {
  // the shared Java GET /api/stock-ins/warehouses (ported from .NET StockApp/SelectPortList)
  AppGlobals.WareHouseList.clear();
  try {
    final comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    final rows = await GetIt.instance<StockInApi>().warehouses(comid);
    AppGlobals.WareHouseList = rows.map(WareHouseModel.fromJava).toList();
  } catch (e) {
    print("API Error: $e");
  }
}

Future SelectEmployee(context, String type, String type1) async {
  try {
    AppGlobals.EmployeeList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = _ensureList((await _routedPost(
            Uri.encodeFull("${ApiConstants.apiSelectEmployee}$Comid&type=$type&type1=$type1"), data: null ?? {})).data);
  if (resultData.isNotEmpty) {
        AppGlobals.EmployeeList = resultData
            .map((element) => EmployeeModel.fromJson(element))
            .toList();
      }
} catch (e) { print("API Error: $e"); }

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectJobStatus(context) async {
  try {
    AppGlobals.JobStatusList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = _ensureList((await _routedPost(
            Uri.encodeFull("${ApiConstants.apiSelectJobStatus}$Comid"), data: null ?? {})).data);
  if (resultData.isNotEmpty) {
        AppGlobals.JobStatusList = resultData
            .map((element) => JobStatusModel.fromJson(element))
            .toList();
      }
} catch (e) { print("API Error: $e"); }

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectJobType(context) async {
  try {
    AppGlobals.JobTypeList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = _ensureList((await _routedPost(
            Uri.encodeFull("${ApiConstants.apiSelectJobType}$Comid"), data: null ?? {})).data);
  if (resultData.isNotEmpty) {
        AppGlobals.JobTypeList = resultData
            .map((element) => JobTypeModel.fromJson(element))
            .toList();
      }
} catch (e) { print("API Error: $e"); }

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectAllJobStatus(context, int Jobid) async {
  try {
    AppGlobals.JobAllStatusList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = _ensureList((await _routedPost(
            Uri.encodeFull("${ApiConstants.apiSelectAllJobStatus}$Comid&Jobid=$Jobid"), data: null ?? {})).data);
  if (resultData.isNotEmpty) {
        var resultDetails = resultData[0]["JobTypeDetails"];
        var result = resultData[0]["JobStatusDetails"];
        AppGlobals.JobAllStatusList = result
            .map((element) => JobAllStatusModel.fromJson(element))
            .toList()
            .cast<JobAllStatusModel>();
        AppGlobals.JobTypeDetailsList = resultDetails
            .map((element) => JobTypeDetailsModel.fromJson(element))
            .toList()
            .cast<JobTypeDetailsModel>();
      }
} catch (e) { print("API Error: $e"); }

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectAgentCompany(context) async {
  try {
    AppGlobals.AgentCompanyList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = _ensureList((await _routedPost(
            Uri.encodeFull("${ApiConstants.apiSelectAgentCompany}$Comid"), data: null ?? {})).data);
  if (resultData.isNotEmpty) {
        AppGlobals.AgentCompanyList = resultData
            .map((element) => AgentCompanyModel.fromJson(element))
            .toList();
      }
} catch (e) { print("API Error: $e"); }

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectAgentAll(context, int AgentCompanyId) async {
  try {
    AppGlobals.AgentAllList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = _ensureList((await _routedPost(
            Uri.encodeFull("${ApiConstants.apiSelectAgentAll}$Comid&Jobid=$AgentCompanyId"), data: null ?? {})).data);
  if (resultData.isNotEmpty) {
        AppGlobals.AgentAllList =
            resultData.map((element) => AgentModel.fromJson(element)).toList();
      }
} catch (e) { print("API Error: $e"); }

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectProductList(context) async {
  try {
    AppGlobals.ProductList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = _ensureList((await _routedPost(
            Uri.encodeFull("${ApiConstants.apiGetProductList}$Comid"), data: null ?? {})).data);
  if (resultData.isNotEmpty) {
        AppGlobals.ProductList = resultData
            .map((element) => ProductModel.fromJson(element))
            .toList();
      }
} catch (e) { print("API Error: $e"); }

  } catch (error) {
    if (error.toString() == "") {}
  }
}


Future<void> GetRTINoForwarding(BuildContext ?context, int billId) async {
  // every RTI number of the company, from the shared Java RTI API
  try {
    AppGlobals.JobNoList = await GetIt.instance<RtiApi>().numbers();
  } catch (e) {
    AppGlobals.JobNoList = [];
    print("API Error: $e");
  }
}

Future SelectTruckList(context,String? Type) async {
  try {
    AppGlobals.GetTruckList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;

    try {
  final resultData = _ensureList((await _routedPost(
        Uri.encodeFull("${ApiConstants.apiGetTruckList}$Comid&type="), data: null ?? {})).data);
  if (resultData.isNotEmpty) {
        AppGlobals.GetTruckList = resultData
            .map((element) => GetTruckModel.fromJson(element))
            .toList();
      }
} catch (e) { print("API Error: $e"); }

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future EditTruckList(context,int Keyword,String Column,String? Type) async {
  try {
    AppGlobals.TruckDetailsList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = _ensureList((await _routedPost(
        Uri.encodeFull("${ApiConstants.apiEditTruckDetails}$Comid&Startindex=0&PageCount=0&Keyword=$Keyword&Column=$Column&type="), data: null ?? {})).data);
  if (resultData.isNotEmpty) {
        AppGlobals.TruckDetailsList = resultData
            .map((element) => TruckDetailsModel.fromJson(element))
            .toList();
      }
} catch (e) { print("API Error: $e"); }

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectDriverList(context,String? Type) async {
  try {
    AppGlobals.GetDriverList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;

    try {
  final resultData = _ensureList((await _routedPost(
        Uri.encodeFull("${ApiConstants.apiGetDriverList}$Comid&type="), data: null ?? {})).data);
  if (resultData.isNotEmpty) {
        AppGlobals.GetDriverList = resultData
            .map((element) => GetTruckModel.fromJson(element))
            .toList();
      }
} catch (e) { print("API Error: $e"); }

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future<List<String>> GetEmployeeport(context) async {
  try {
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    var empId = AppGlobals.storagenew.getInt('EmpRefId') ?? 0;
    
    // Using apiAllinoneSelect as it handles GET requests returning JSON arrays well
    final resultData = _ensureList((await _routedPost(
        Uri.encodeFull("${ApiConstants.port}/api/EmployeeApp/GetEmployeeport?Comid=$Comid&id=$empId"), data: null ?? {})).data);
        
    return resultData.map((e) => e["AccountName"].toString()).toList();
    } catch (error) {
    debugPrint("Error fetching employee ports: $error");
  }
  return [];
}

}
