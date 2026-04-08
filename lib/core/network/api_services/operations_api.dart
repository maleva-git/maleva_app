// core/network/api_services/operations_api.dart
// RTI operations, Fuel Entry, Stock, Truck update, Forwarding Salary

import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/utils/app_preferences.dart';

class OperationsApi {
  OperationsApi._();

  // ─── Forwarding Salary ────────────────────────────────────────────────────
  static Future<void> insertForwardingSalary(Map<String, dynamic> data) async {
    await ApiClient.postRequest(ApiConstants.apiInsertForwarding, data);
  }

  static Future<List<dynamic>> selectForwardingSalary() async {
    final result = await ApiClient.postRequest(ApiConstants.apiSelectForwarding, null);
    return result as List;
  }

  // ─── RTI Status Insert ────────────────────────────────────────────────────
  static Future<void> insertRTIStatus(Map<String, dynamic> data) async {
    final comid = AppPreferences.getComid();
    await ApiClient.postRequest('${ApiConstants.apiRTIDetailsInsert}$comid', data);
  }

  // ─── Fuel Entry ───────────────────────────────────────────────────────────
  static Future<void> insertFuelEntry(Map<String, dynamic> data) async {
    await ApiClient.postRequest(ApiConstants.apiInsertFuelEntry, data);
  }

  static Future<String> getMaxFuelEntryNo() async {
    final comid = AppPreferences.getComid();
    return await ApiClient.getString('${ApiConstants.apiMaxFuelEntryNo}$comid');
  }

  static Future<void> deleteFuelEntry(int id) async {
    await ApiClient.postRequest('${ApiConstants.apiDeleteFuelEntry}$id', null);
  }

  static Future<dynamic> editFuelEntry(int id) async {
    final result = await ApiClient.postRequest('${ApiConstants.apiEditFuelEntry}$id', null);
    return result;
  }

  static Future<List<dynamic>> selectFuelEntries(Map<String, dynamic> filter) async {
    final result = await ApiClient.postRequest(ApiConstants.apiSelectFuelEntry, filter);
    return result as List;
  }

  // ─── Stock ────────────────────────────────────────────────────────────────
  static Future<List<dynamic>> selectStockDetails() async {
    final comid  = AppPreferences.getComid();
    final result = await ApiClient.postRequest(
      '${ApiConstants.apiSelectStockDetails}$comid', null,
    );
    return result as List;
  }

  static Future<dynamic> editStockIn(int id) async {
    final result = await ApiClient.postRequest('${ApiConstants.apiEditStockIn}$id', null);
    return result;
  }

  static Future<void> updateStockIn(int id, Map<String, dynamic> data) async {
    await ApiClient.postRequest('${ApiConstants.apiUpdateStockIn}$id', data);
  }

  static Future<void> updateStockTransfer(int id, Map<String, dynamic> data) async {
    await ApiClient.postRequest('${ApiConstants.apiUpdateStockTransfer}$id', data);
  }

  static Future<void> insertStockIn(Map<String, dynamic> data) async {
    final comid = AppPreferences.getComid();
    await ApiClient.postRequest('${ApiConstants.apiInsertStockIn}$comid', data);
  }

  static Future<dynamic> printStock(int id) async {
    final result = await ApiClient.postRequest('${ApiConstants.apiPrintStock}$id', null);
    return result;
  }

  // ─── Truck Update ─────────────────────────────────────────────────────────
  static Future<void> updateTruckDetails(Map<String, dynamic> data) async {
    final comid = AppPreferences.getComid();
    await ApiClient.postRequest('${ApiConstants.apiUpdateTruckDetails}$comid', data);
  }

  // ─── Spare Parts ──────────────────────────────────────────────────────────
  static Future<void> insertSpareParts(Map<String, dynamic> data) async {
    await ApiClient.postRequest(ApiConstants.apiInsertSpareParts, data);
  }

  static Future<List<dynamic>> getSpareParts() async {
    final comid  = AppPreferences.getComid();
    final result = await ApiClient.postRequest('${ApiConstants.apiGetSpareParts}$comid', null);
    return result as List;
  }

  // ─── Spot Sale ────────────────────────────────────────────────────────────
  static Future<void> insertSpotSaleEntry(Map<String, dynamic> data) async {
    await ApiClient.postRequest(ApiConstants.apiInsertSpotSaleEntry, data);
  }

  static Future<List<dynamic>> getSpotSaleEntries() async {
    final comid  = AppPreferences.getComid();
    final result = await ApiClient.postRequest('${ApiConstants.apiGetSpotSaleEntry}$comid', null);
    return result as List;
  }

  // ─── Summon ───────────────────────────────────────────────────────────────
  static Future<void> insertSummon(Map<String, dynamic> data) async {
    await ApiClient.postRequest(ApiConstants.apiInsertSummonParts, data);
  }

  static Future<List<dynamic>> getSummons() async {
    final comid  = AppPreferences.getComid();
    final result = await ApiClient.postRequest('${ApiConstants.apiGetSummonParts}$comid', null);
    return result as List;
  }

  // ─── Enquiry ──────────────────────────────────────────────────────────────
  static Future<void> insertEnquiry(Map<String, dynamic> data) async {
    await ApiClient.postRequest(ApiConstants.apiInsertEnquiry, data);
  }

  static Future<List<dynamic>> selectEnquiries(Map<String, dynamic>? filter) async {
    final result = await ApiClient.postRequest(ApiConstants.apiSelectEnquiryMaster, filter);
    return result as List;
  }

  static Future<void> updateEnquiry(int id, Map<String, dynamic> data) async {
    await ApiClient.postRequest('${ApiConstants.apiUpdateEnquiryMaster}$id', data);
  }

  // ─── Sales boarding / airfreight update ───────────────────────────────────
  static Future<void> updateForwarding(Map<String, dynamic> data) async {
    await ApiClient.postRequest(ApiConstants.apiUpdateForwarding, data);
  }

  static Future<void> updateBoardingDetails(Map<String, dynamic> data) async {
    await ApiClient.postRequest(ApiConstants.apiUpdateBoardingDetails, data);
  }

  static Future<void> updateAirFreightDetails(Map<String, dynamic> data) async {
    await ApiClient.postRequest(ApiConstants.apiUpdateAirFrieghtDetails, data);
  }
}