import 'dart:convert';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

class AuthApi {
  AuthApi._();
  static final AuthApi instance = AuthApi._();
  // ─── Login ────────────────────────────────────────────────────────────────
  Future<dynamic> loginUserRaw({
    required String username,
    required String password,
    required String oldUsername,
    required int driverId,
    required String fcmToken,
  }) async {
    final url = '${ApiConstants.apiLoginSuccess}$username'
        '&Pwd=$password&olduserid=$oldUsername&DriverId=$driverId';

    final result = await ApiClient.postRequest(
      url,
      null,
      headers: {'Content-Type': 'application/json; charset=UTF-8', 'Token': fcmToken},
      skipAuth: true,
    );

    if (result == null) throw Exception('No response from server');

    if (result is! Map<String, dynamic>) {
      throw Exception('Unexpected response format');
    }

    return result;
  }

  static Future<bool> loginUser({
    required String username,
    required String password,
    required String oldUsername,
    required int driverId,
  }) async {
    final fcmToken = AppPreferences.getFcmToken();

    final url = '${ApiConstants.apiLoginSuccess}$username'
        '&Pwd=$password&olduserid=$oldUsername&DriverId=$driverId';

    final result = await ApiClient.postRequest(
      url,
      null,
      headers: {'Content-Type': 'application/json; charset=UTF-8', 'Token': fcmToken},
      skipAuth: true,
    );

    if (result == null) throw Exception('No response from server');

    if (result is! Map<String, dynamic>) {
      throw Exception('Unexpected response format');
    }

    final value = ResponseViewModel.fromJson(result);

    if (value.IsSuccess == true) {
      await _saveLoginData(value, username, password, driverId, oldUsername);
      return true;
    } else if (value.StatusCode != 500) {
      throw Exception('Invalid Username & Password');
    } else {
      throw Exception(value.Message ?? 'Server Error');
    }
  }

  // ─── Save login data to preferences ──────────────────────────────────────
  static Future<void> _saveLoginData(
      ResponseViewModel value,
      String username,
      String password,
      int driverId,
      String oldUsername,
      ) async {
    final data = value.data1[0];
    final idNew = data['UserId'] ?? 0;
    final comid = data['Comid'] ?? 0;
    final mComid = data['MComid'] ?? 0;

    objfun.selectedCompanyName = data['CompanyName'] ?? '';
    objfun.EmpRefId = idNew;

    await AppPreferences.setEnquiryOpen('false');
    await AppPreferences.setUsername(username);
    await AppPreferences.setPassword(password);
    await AppPreferences.setDriverId(driverId);
    await AppPreferences.setRulesType(data['RulesType'] ?? '');
    await AppPreferences.setComid(comid);
    await AppPreferences.setMComid(mComid);
    await AppPreferences.setOldUsername(idNew.toString());

    objfun.Comid = comid;
    objfun.DriverTruckRefId = data['TruckRefId'] ?? 0;
    objfun.DriverTruckName  = data['TruckName'] ?? '';

    // Menu data
    if (oldUsername.isEmpty) {
      final menudata = value.data3 ?? [];
      if (menudata.isNotEmpty) {
        objfun.objMenuMaster.clear();
        objfun.parentclass.clear();
        await AppPreferences.setLoadMenu(json.encode(menudata));
        for (var item in menudata) {
          objfun.objMenuMaster.add(MenuMasterModel.fromJson(item));
        }
        objfun.parentclass.addAll(
          objfun.objMenuMaster.where((e) => e.ParentId == 0),
        );
      }
    } else {
      final temp = AppPreferences.getLoadMenu();
      if (temp.isNotEmpty && temp != 'null') {
        final menudata = json.decode(temp) as List;
        objfun.objMenuMaster.clear();
        objfun.parentclass.clear();
        for (var item in menudata) {
          if (item['FormText'] == null) continue;
          objfun.objMenuMaster.add(MenuMasterModel.fromJson(item));
        }
        objfun.parentclass.addAll(
          objfun.objMenuMaster.where((e) => e.ParentId == 0),
        );
      }
    }
  }

  // ─── Select Users ─────────────────────────────────────────────────────────
  static Future<List<UserLoginModel>> selectUsers() async {
    final comid  = AppPreferences.getComid();
    final result = await ApiClient.postRequest(
      '${ApiConstants.apiSelectUser}$comid',
      null,
    );
    return (result as List).map((e) => UserLoginModel.fromJson(e)).toList();
  }

  // ─── Sales data (dashboard) ───────────────────────────────────────────────
  static Future<dynamic> getSalesData(int type) async {
    final comid = AppPreferences.getComid();

    final result = await ApiClient.postRequest(
      '${ApiConstants.apiGetSalesData}$comid&type=$type',
      null,
    );

    return result;
  }


  static Future<dynamic> getSalesInvoiceCheck(
      Map<String, dynamic> master) async {

    final result = await ApiClient.postRequest(
      ApiConstants.apiSelectSaleorderinvoicecheck,
      master,
    );

    return result;
  }
  static Future<dynamic> getEmployeeSalesData() async {
    final comid  = AppPreferences.getComid();
    final result = await ApiClient.postRequest(
      '${ApiConstants.apiGetEmployeeSalesData}$comid',
      null,
    );
    return result;
  }

  static Future<dynamic> getExpData() async {
    final comid  = AppPreferences.getComid();
    final result = await ApiClient.postRequest(
      '${ApiConstants.apiGetExpData}$comid',
      null,
    );
    return result;
  }
}