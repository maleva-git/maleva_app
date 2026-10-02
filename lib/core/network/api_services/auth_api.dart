import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/features/auth/models/user_login_model.dart';

class AuthApi {
  AuthApi._();
  static final AuthApi instance = AuthApi._();




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
  static Future<dynamic> getEmployeeSalesData({required int type}) async {
    final comid  = AppPreferences.getComid();
    final result = await ApiClient.postRequest(
      '${ApiConstants.apiGetEmployeeSalesData}$comid&type=$type',
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
  static Future<dynamic> getEmployeeInvData({required int type}) async {
    final comid = AppPreferences.getComid();
    final result = await ApiClient.postRequest(
      '${ApiConstants.apiGetEmployeeInvData}$comid&type=$type',
      null,
    );
    return result;
  }
}