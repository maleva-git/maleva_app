// core/network/api_services/reports_api.dart
// Dashboard data, RTI view, Truck/Driver reports, Planning DB calls

import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:intl/intl.dart';

class ReportsApi {
  ReportsApi._();

  // ─── Dashboard: Rules Type (employee dropdown) ────────────────────────────
  static Future<List<Map<String, dynamic>>> loadRulesType(int empRefId) async {
    final comid  = AppPreferences.getComid();
    final result = await ApiClient.postRequest(
      ApiConstants.LoadRulesType,
      {'Comid': comid, 'Employeeid': empRefId},
    );
    return List<Map<String, dynamic>>.from(result as List);
  }

  // ─── Dashboard: Air Freight ───────────────────────────────────────────────
  static Future<dynamic> getAirFreightDashboard(Map<String, dynamic> filter) async {
    final result = await ApiClient.postRequest(ApiConstants.AirFrieghtDB, filter);
    return result;
  }

  // ─── Dashboard: Vessel Planning ───────────────────────────────────────────
  static Future<dynamic> getVesselPlanningDashboard(Map<String, dynamic> filter) async {
    final result = await ApiClient.postRequest(ApiConstants.VESSELPLANINGDB, filter);
    return result;
  }

  // ─── Dashboard: Planning Search ───────────────────────────────────────────
  static Future<dynamic> getPlanningSearchDashboard(Map<String, dynamic> filter) async {
    final result = await ApiClient.postRequest(ApiConstants.PLANINGSearchDB, filter);
    return result;
  }

  // ─── Dashboard: Driver Search ────────────────────────────────────────────
  static Future<dynamic> getDriverSearchDashboard(Map<String, dynamic> filter) async {
    final result = await ApiClient.postRequest(ApiConstants.PLANINGDriverSearch, filter);
    return result;
  }

  // ─── Dashboard: Maintenance/Expense ──────────────────────────────────────
  static Future<dynamic> getMaintenanceData() async {
    final comid  = AppPreferences.getComid();
    final result = await ApiClient.postRequest('${ApiConstants.apiGetMaintenance}$comid', null);
    return result;
  }

  static Future<dynamic> getExpenseData() async {
    final comid  = AppPreferences.getComid();
    final result = await ApiClient.postRequest('${ApiConstants.apiGetMaintenance1}$comid', null);
    return result;
  }

  static Future<dynamic> getStatusBO() async {
    final comid  = AppPreferences.getComid();
    final result = await ApiClient.postRequest('${ApiConstants.apiGetMaintenance2}$comid', null);
    return result;
  }

  // ─── Dashboard: UnRelease Numbers ────────────────────────────────────────
  static Future<dynamic> getUnReleaseNo(Map<String, dynamic> data) async {
    final result = await ApiClient.postRequest(ApiConstants.LoadUnReleaseNo, data);
    return result;
  }

  static Future<dynamic> getK8UnReleaseNo(Map<String, dynamic> data) async {
    final result = await ApiClient.postRequest(ApiConstants.LoadK8UnReleaseNo, data);
    return result;
  }

  // ─── Truck Report ─────────────────────────────────────────────────────────
  static Future<List<dynamic>> getTruckReport(Map<String, dynamic> filter) async {
    final result = await ApiClient.postRequest(ApiConstants.apiSelectTruckDetails, filter);
    return result as List;
  }

  // ─── Driver Report ────────────────────────────────────────────────────────
  static Future<List<dynamic>> getDriverReport(Map<String, dynamic> filter) async {
    final result = await ApiClient.postRequest(ApiConstants.apiSelectDriverDetails, filter);
    return result as List;
  }

  // ─── Speeding Report ──────────────────────────────────────────────────────
  static Future<List<dynamic>> getSpeedingReport(Map<String, dynamic> filter) async {
    final result = await ApiClient.postRequest(ApiConstants.apiSelectSpeedingReport, filter);
    return result as List;
  }

  // ─── Fuel Filling Report ─────────────────────────────────────────────────
  static Future<List<dynamic>> getFuelFillingReport(Map<String, dynamic> filter) async {
    final result = await ApiClient.postRequest(ApiConstants.apiSelectFuelFillingReport, filter);
    return result as List;
  }

  // ─── Engine Hours Report ──────────────────────────────────────────────────
  static Future<List<dynamic>> getEngineHoursReport(Map<String, dynamic> filter) async {
    final result = await ApiClient.postRequest(ApiConstants.apiSelectEngineHoursReport, filter);
    return result as List;
  }

  // ─── Driver Salary Report ─────────────────────────────────────────────────
  static Future<List<dynamic>> getDriverSalaryReport(Map<String, dynamic> filter) async {
    final result = await ApiClient.postRequest(ApiConstants.apiSelectDriverSalary, filter);
    return result as List;
  }

  // ─── Pre Alert Report ─────────────────────────────────────────────────────
  static Future<List<dynamic>> getPreAlertReport(String preAlertName) async {
    final result = await ApiClient.postRequest(
      '${ApiConstants.apiPreAlertReport}$preAlertName', null,
    );
    return result as List;
  }

  // ─── Payment Pending ──────────────────────────────────────────────────────
  static Future<List<dynamic>> getPaymentPending(Map<String, dynamic> filter) async {
    final result = await ApiClient.postRequest(ApiConstants.apiSelectPaymentPending, filter);
    return result as List;
  }

  // ─── Customer Balance ─────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getCustomerBalance(
      Map<String, dynamic> master,
      Map<String, String> header) async {

    final result = await ApiClient.postRequest(
      ApiConstants.apiSelectReceipt,
      master,
      headers: header,
    );

    return Map<String, dynamic>.from(result);
  }
}