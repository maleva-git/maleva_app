import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:maleva/core/models/shared/agent_company_model.dart';
import 'package:maleva/features/operations/models/job_all_status_model.dart';
import 'package:maleva/features/operations/models/job_type_model.dart';
import 'package:maleva/core/models/shared/get_truck_model.dart';
import 'package:maleva/core/models/shared/address_details_model.dart';
import 'package:maleva/features/auth/models/user_login_model.dart';
import 'package:maleva/core/models/shared/customer_model.dart';
import 'package:maleva/core/models/shared/truck_details_model.dart';
import 'package:maleva/core/models/shared/ware_house_model.dart';
import 'package:maleva/features/operations/models/forwarding_model.dart';
import 'package:maleva/core/models/shared/sale_edit_detail_model.dart';
import 'package:maleva/core/models/shared/agent_model.dart';
import 'package:maleva/features/operations/models/job_status_model.dart';
import 'package:maleva/core/models/shared/product_model.dart';
import 'package:maleva/features/operations/models/job_type_details_model.dart';
import 'package:maleva/core/models/shared/r_t_i_master_view_model.dart';
import 'package:maleva/core/models/shared/employee_model.dart';
import 'package:maleva/core/models/shared/menu_master_model.dart';
import 'package:maleva/core/models/shared/location_model.dart';
import 'package:maleva/core/models/shared/response_view_model.dart';
import 'package:maleva/core/models/shared/r_t_i_details_view_model.dart';

class LegacyApiRepository {
  final DioClient _dioClient;

  LegacyApiRepository(this._dioClient);

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
      final options = headers != null ? Options(headers: headers) : null;
      final response = await _dioClient.dio.post(url, data: data ?? {}, options: options);
      return response.data;
    } catch (e) {
      print("API Error: $e");
      return null;
    }
  }

  Future<List<dynamic>> postList(String url, {dynamic data, Map<String, String>? headers, BuildContext? context}) async {
    try {
      final options = headers != null ? Options(headers: headers) : null;
      final response = await _dioClient.dio.post(url, data: data ?? {}, options: options);
      return _ensureList(response.data);
    } catch (e) {
      print("API Error: $e");
      return [];
    }
  }

  // Backward compatible methods for ApiLegacyHelper replacement
  Future<List<dynamic>> apiAllinoneSelect(dynamic api, [dynamic insertDetails, Map<String, String>? header, BuildContext? context]) async {
    final result = await postList(api.toString(), data: insertDetails, headers: header);
    return result;
  }

  Future<dynamic> apiAllinoneSelectArray(dynamic api, [dynamic insertDetails, Map<String, String>? header, BuildContext? context]) async {
    final result = await post(api.toString(), data: insertDetails, headers: header);
    return result;
  }

  Future<dynamic> apiAllinone(dynamic api, [dynamic insertDetails, Map<String, String>? header, BuildContext? context]) async {
    final result = await post(api.toString(), data: insertDetails, headers: header);
    return result;
  }

  Future<String> apiGetString(dynamic api, [dynamic insertDetails, Map<String, String>? header, BuildContext? context]) async {
    try {
      final options = header != null ? Options(headers: header) : null; final response = await _dioClient.dio.post(api.toString(), data: insertDetails ?? {}, options: options);
      return response.data?.toString() ?? '';
    } catch (e) {
      print("API Error: $e");
      return '';
    }
  }

Future<bool> Login(String Username, String Password, String OldUsername,int DriverId, context) async {
  try {

    int flag = 0;
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Token':AppGlobals.mobiletoken,
    };
    try {
  final result = ((await _dioClient.dio.post(Uri.encodeFull("${ApiConstants.apiLoginSuccess}$Username&Pwd=$Password&olduserid=$OldUsername&DriverId=$DriverId"), data: null ?? {})).data);
  if (result != null) {

        if (result is Map<String, dynamic>) {
          ResponseViewModel? value = ResponseViewModel.fromJson(result);


          if (value.IsSuccess == true) {
            var IdNew = value.data1[0]["UserId"] ?? 0;
            var Comid = value.data1[0]["Comid"] ?? 0;
            var MComid = value.data1[0]["MComid"] ?? 0;
            AppGlobals.selectedCompanyName = value.data1[0]["CompanyName"] ?? '';
            AppGlobals.EmpRefId = value.data1[0]["UserId"];
            AppGlobals.storagenew.setString('EnquiryOpen', "false");
            if (IdNew != "") {
              AppGlobals.storagenew.setString('Username', Username);
              AppGlobals.storagenew.setString('Password', Password);
              AppGlobals.storagenew.setInt('DriverId', DriverId);
              AppGlobals.DriverLogin = DriverId;

              AppGlobals.storagenew.setString(
                  'RulesType', value.data1[0]["RulesType"] ?? '');
              AppGlobals.storagenew.setInt('Comid', Comid);
              AppGlobals.Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
              AppGlobals.DriverTruckRefId = value.data1[0]["TruckRefId"] ?? 0;
              AppGlobals.DriverTruckName = value.data1[0]["TruckName"] ?? '';
              AppGlobals.storagenew.setInt('MComid', MComid);
              AppGlobals.storagenew.setString('OldUsername', IdNew.toString());
              if (OldUsername == "") {
                var menudata = value.data3 ?? [];
                if (menudata != null && menudata.isNotEmpty) {
                  AppGlobals.objMenuMaster.clear();
                  AppGlobals.parentclass.clear();
                  AppGlobals.storagenew.setString(
                      'loadmenu', json.encode(menudata));
                  for (int i = 0; i < menudata.length; i++) {
                    AppGlobals.objMenuMaster
                        .add(MenuMasterModel.fromJson(menudata[i]));
                  }

                  AppGlobals.parentclass.addAll(AppGlobals.objMenuMaster
                      .where((element) => element.ParentId == 0)
                      .toList());
                }
              }
              else {
                String? temp1 = AppGlobals.storagenew.getString('loadmenu');
                if (temp1 != null && temp1 != 'null') {
                  var decoded = json.decode(temp1);
                  List menudata = decoded;

                  if (menudata.isNotEmpty) {
                    AppGlobals.objMenuMaster.clear();
                    AppGlobals.parentclass.clear();
                    for (int i = 0; i < menudata.length; i++) {
                      if (menudata[i]['FormText'] == null) {
                        continue;
                      }
                      AppGlobals.objMenuMaster
                          .add(MenuMasterModel.fromJson(menudata[i]));
                    }
                    AppGlobals.parentclass.addAll(AppGlobals.objMenuMaster
                        .where((element) => element.ParentId == 0)
                        .toList());
                  }
                }
              }
            }
            flag = 1;
          }
          else if (value.StatusCode != 500) {
            msgshow(
                "Invaild Username & Password",
                "",
                Colors.white,
                Colors.green,
                null,
                18.00 - AppGlobals.reducesize,
                AppGlobals.tll,
                AppGlobals.tgc,
                context,
                2);
            flag = 0;
          }
          else {
            msgshow(
                value.Message,
                value.data1,
                Colors.white,
                Colors.red,
                null,
                18.00 - AppGlobals.reducesize,
                AppGlobals.tll,
                AppGlobals.tgc,
                context,
                2);
            flag = 0;
          }
        }

        else {
          msgshow(
            "Unexpected response from server",
            "",
            Colors.white,
            Colors.red,
            null,
            18.00 - AppGlobals.reducesize,
            AppGlobals.tll,
            AppGlobals.tgc,
            context,
            2,
          );
          flag = 0;
        }
      }
} catch (e) { print("API Error: $e"); }

    if (flag == 1) {
      return true;
    } else {
      return false;
    }
  } catch (error) {
    return false;
  }
}

Future SelectUser(context) async {
  try {
    AppGlobals.UserList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = _ensureList((await _dioClient.dio.post(
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
  final resultData = _ensureList((await _dioClient.dio.post(
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
  final resultData = _ensureList((await _dioClient.dio.post(
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
  try {
    AppGlobals.WareHouseList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = ((await _dioClient.dio.post(
        Uri.encodeFull("${ApiConstants.apiWareHouseCombo}$Comid"), data: null ?? {})).data);
  if (resultData.isNotEmpty) {
        AppGlobals.WareHouseList = resultData["Data1"]
            .map((element) => WareHouseModel.fromJson(element))
            .toList().cast<WareHouseModel>();
      }
} catch (e) { print("API Error: $e"); }

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectStockJob(context) async {
  try {
    AppGlobals.StockJobList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = ((await _dioClient.dio.post(
        Uri.encodeFull("${ApiConstants.apiSelectStockJob}$Comid"), data: null ?? {})).data);
  if (resultData.isNotEmpty) {
        AppGlobals.StockJobList = resultData["Data1"]
            .map((element) => WareHouseModel.fromJson(element))
            .toList().cast<WareHouseModel>();
      }
} catch (e) { print("API Error: $e"); }

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectEmployee(context, String type, String type1) async {
  try {
    AppGlobals.EmployeeList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = _ensureList((await _dioClient.dio.post(
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
  final resultData = _ensureList((await _dioClient.dio.post(
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

Future MaxSaleOrderNo(context, String BillType) async {
  try {
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = ((await _dioClient.dio.post(
            "${ApiConstants.apiMaxSaleOrderNo}$Comid&BillType=$BillType", data: {})).data?.toString() ?? "");
  if (resultData.isNotEmpty) {
        AppGlobals.MaxSaleOrderNum = resultData;
      }
} catch (e) { print("API Error: $e"); }

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future MaxStockNo(context) async {
  try {
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = ((await _dioClient.dio.post(
            Uri.encodeFull("${ApiConstants.apiMaxStockNo}$Comid"), data: null ?? {})).data);
  if (resultData.isNotEmpty) {
       // var checkdata = resultData["Data1"];
        AppGlobals.MaxStockNum = resultData["Data1"];
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
  final resultData = _ensureList((await _dioClient.dio.post(
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
  final resultData = _ensureList((await _dioClient.dio.post(
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
  final resultData = _ensureList((await _dioClient.dio.post(
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
  final resultData = _ensureList((await _dioClient.dio.post(
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
  final resultData = _ensureList((await _dioClient.dio.post(
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

Future<List<dynamic>?> selectAddressList() async {
  try {
    AppGlobals.AddressList.clear();
    final int comId = AppGlobals.storagenew.getInt('Comid') ?? 0;

    // Call ApiClient.postRequest and pass null for the body
    final resultData = ((await _dioClient.dio.post(
      "${ApiConstants.apiSelectAddressList}$comId", data: null ?? {})).data);

    // ApiClient decodes the response automatically.
    // We just ensure it's returned as a List safely.
    if (resultData is List) {
      return resultData;
    } else if (resultData != null) {
      return [resultData]; // Wrap in list if a map is returned
    }

    return [];

  } on TimeoutException {
    throw Exception("Server timeout. Please try again.");
  } on SocketException {
    throw Exception("No internet connection.");
  } catch (error) {
    // ApiClient already gives clean error messages,
    // so we can just pass them along smoothly.
    throw Exception(error.toString().replaceAll('Exception: ', ''));
  }
}

Future EditSalesOrder(int Id, int SaleNo, {BuildContext? context}) async {
  try {
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    var resultData = _ensureList((await _dioClient.dio.post(
        Uri.encodeFull("${ApiConstants.apiEditSalesOrder}$Id&SaleorderNo=$SaleNo&Comid=$Comid"), data: null ?? {})).data);

    if (resultData.isNotEmpty) {
      AppGlobals.SaleEditMasterList = resultData;
      AppGlobals.SaleEditDetailList = resultData[0]["SaleDetails"]
          .map((element) => SaleEditDetailModel.fromJson(element))
          .toList()
          .cast<SaleEditDetailModel>();
    } else {
      throw Exception("Data empty ah iruku");
    }
  } catch (error) {
    throw Exception("Sales Order failed: $error");
  }
}

Future loadCustomerCurrency(context, int CustomerId) async {
  try {
AppGlobals.CustomerCurrencyValue = 0.0;
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = ((await _dioClient.dio.post(
        Uri.encodeFull("${ApiConstants.apiGetCurrencyValue}$Comid&CustId=$CustomerId"), data: null ?? {})).data);
  if (resultData.length != 0) {
        AppGlobals.CustomerCurrencyValue = resultData["Data1"];
      }
} catch (e) { print("API Error: $e"); }

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future loadComboS1(context, int type) async {
  try {
    AppGlobals.ComboS1List=[];
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = ((await _dioClient.dio.post(
            Uri.encodeFull("${ApiConstants.apiGetComboS1}$Comid&type=$type"), data: null ?? {})).data);
  if (resultData.length != 0) {
        AppGlobals.ComboS1List.add(resultData["Data1"]);
        AppGlobals.ComboS1List.add(resultData["Data2"]);
        AppGlobals.ComboS1List.add(resultData["Data3"]);
        AppGlobals.ComboS1List.add(resultData["Data4"]);
        AppGlobals.ComboS1List.add(resultData["Data5"]);
        AppGlobals.ComboS1List.add(resultData["Data6"]);

      }
} catch (e) { print("API Error: $e"); }

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future EditPlanning(context, int Id, int PlanningNo) async {
  try {
    // AppGlobals.PlanningEditList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = _ensureList((await _dioClient.dio.post(
            Uri.encodeFull("${ApiConstants.apiEditPlanning}$Id&PLANINGNo=$PlanningNo&Comid=$Comid"), data: null ?? {})).data);
  if (resultData.isNotEmpty) {
        AppGlobals.PlanningEditList = resultData[0]["SaleDetails"].toList();
      }
} catch (e) { print("API Error: $e"); }

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future EditVesselPlanning(context, int Id, int PlanningNo) async {
  try {
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = _ensureList((await _dioClient.dio.post(
        Uri.encodeFull("${ApiConstants.apiEditVesselPlanning}$Id&VESSELPLANINGNo=$PlanningNo&Comid=$Comid"), data: null ?? {})).data);
  if (resultData.isNotEmpty) {
        AppGlobals.VesselPlanningEditList = resultData[0]["SaleDetails"].toList();
      }
} catch (e) { print("API Error: $e"); }

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future DeleteSalesOrder(context, int Id) async {
  try {
    // AppGlobals.AddressList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = ((await _dioClient.dio.post(
            Uri.encodeFull("${ApiConstants.apiDeleteSalesOrder}$Id&Comid=$Comid"), data: null ?? {})).data);
  if (resultData.length != 0) {
        ResponseViewModel? value = ResponseViewModel.fromJson(resultData);
        if (value.IsSuccess == true) {
          await ConfirmationOK(value.Message, context);
        }
      }
} catch (e) { print("API Error: $e"); }

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectAddressDetails(context, String Keyword) async {
  try {
    AppGlobals.AddressDetailedList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = _ensureList((await _dioClient.dio.post(
            Uri.encodeFull("${ApiConstants.apiSelectAddressDetails}$Comid&KeyWord=$Keyword"), data: null ?? {})).data);
  if (resultData.isNotEmpty) {
        AppGlobals.AddressDetailedList = resultData
            .map((element) => AddressDetailsModel.fromJson(element))
            .toList();
      }
} catch (e) { print("API Error: $e"); }

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future GetJobNoForwarding(context,int BillId) async {
  try {
    AppGlobals.ForwardingList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = ((await _dioClient.dio.post(
        Uri.encodeFull("${ApiConstants.apiGetJobNo}$Comid&JobType=$BillId"), data: null ?? {})).data);
  if (resultData.length != 0) {   
        AppGlobals.ForwardingList = resultData["Data1"]
            .map((element) => ForwardingModel.fromJson(element))
            .toList().cast<ForwardingModel>();
        AppGlobals.JobNoList =  resultData["Data1"].toList();
      }
} catch (e) { print("API Error: $e"); }

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future<void> GetRTINoForwarding(BuildContext ?context, int billId) async {
  try {
    // Clear existing job list
    AppGlobals.JobNoList.clear();

    // Get company ID from storage
    final int comId = AppGlobals.storagenew.getInt('Comid') ?? 0;

    // Construct the API URL
    final String apiUrl = '${ApiConstants.apiGetRTINo}$comId';

    // Call the API
    final resultData = ((await _dioClient.dio.post(
        apiUrl, data: null ?? {})).data);

    // Check response validity and content
    if (resultData != null && resultData is List) {
      final List<dynamic> dataList = resultData;

      // Clear existing job list
      AppGlobals.JobNoList.clear();

      for (var item in dataList) {
        // Safety check: ensure item is a Map
        if (item is Map<String, dynamic>) {
          final String cNumber = item['RTINoDisplay']?.toString() ?? '';
          final int id = item['Id'] ?? 0;

          AppGlobals.JobNoList.add({
            'CNumber': cNumber,
            'Id': id,
          });
        }
      }
    } else {
      AppGlobals.JobNoList = []; // Default to empty list
    }
  }
  catch (e) { print("API Error: $e"); }
}

Future SelectTruckList(context,String? Type) async {
  try {
    AppGlobals.GetTruckList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;

    try {
  final resultData = _ensureList((await _dioClient.dio.post(
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
  final resultData = _ensureList((await _dioClient.dio.post(
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
  final resultData = _ensureList((await _dioClient.dio.post(
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

Future SelectRTIDetailViewList(context,String Fromdate,String Todate,int DId, int TId, int Employeeid,String Search) async {
  try {
    AppGlobals.RTIViewMasterList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = _ensureList((await _dioClient.dio.post(
        Uri.encodeFull("${ApiConstants.apiSelectRTIDetailsView}$Comid&Fromdate=$Fromdate&Todate=$Todate&DId=$DId&TId=$TId&Employeeid=$Employeeid&Search$Search"), data: null ?? {})).data);
  if (resultData.isNotEmpty) {
        AppGlobals.RTIViewMasterList = resultData[0]["salemaster"]
            .map((element) => RTIMasterViewModel.fromJson(element))
            .toList();
        AppGlobals.RTIViewDetailList = resultData[0]["saledetails"]
            .map((element) => RTIDetailsViewModel.fromJson(element))
            .toList();
      }
} catch (e) { print("API Error: $e"); }

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectRTIViewList(context,String Fromdate,String Todate,int DId, int TId, int Employeeid,String Search) async {
  try {
    AppGlobals.RTIViewMasterList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = _ensureList((await _dioClient.dio.post(
        Uri.encodeFull("${ApiConstants.apiSelectRTIView}$Comid&Fromdate=$Fromdate&Todate=$Todate&DId=$DId&TId=$TId&Employeeid=$Employeeid&Search=$Search"), data: null ?? {})).data);
  if (resultData.isNotEmpty) {
        AppGlobals.RTIViewMasterList = resultData[0]["salemaster"]
            .map((element) => RTIMasterViewModel.fromJson(element))
            .toList();
        AppGlobals.RTIViewDetailList = resultData[0]["saledetails"]
            .map((element) => RTIDetailsViewModel.fromJson(element))
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
    final resultData = _ensureList((await _dioClient.dio.post(
        Uri.encodeFull("${ApiConstants.port}/api/EmployeeApp/GetEmployeeport?Comid=$Comid&id=$empId"), data: null ?? {})).data);
        
    return resultData.map((e) => e["AccountName"].toString()).toList();
    } catch (error) {
    debugPrint("Error fetching employee ports: $error");
  }
  return [];
}

}
