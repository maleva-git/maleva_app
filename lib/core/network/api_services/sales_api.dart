// core/network/api_services/sales_api.dart
// Sales Order, Planning, Vessel Planning, Job No, Combo — ella sales calls inga

import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/utils/app_preferences.dart';

class SalesApi {
  SalesApi._();

  // ─── Max Sale Order Number ────────────────────────────────────────────────
  static Future<String> getMaxSaleOrderNo(String billType) async {
    final comid = AppPreferences.getComid();
    return await ApiClient.getString(
      '${ApiConstants.apiMaxSaleOrderNo}$comid&BillType=$billType',
    );
  }

  // ─── Edit Sales Order ────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> editSalesOrder(int id, int saleNo) async {
    final comid  = AppPreferences.getComid();
    final result = await ApiClient.postRequest(
      '${ApiConstants.apiEditSalesOrder}$id&SaleorderNo=$saleNo&Comid=$comid',
      null,
    );
    final list    = result as List;
    final master  = list[0];
    final details = (list[0]['SaleDetails'] as List)
        .map((e) => SaleEditDetailModel.fromJson(e))
        .toList();
    return {'master': master, 'details': details};
  }

  // ─── Delete Sales Order ──────────────────────────────────────────────────
  // Returns success message or throws exception
  static Future<String> deleteSalesOrder(int id) async {
    final comid  = AppPreferences.getComid();
    final result = await ApiClient.postRequest(
      '${ApiConstants.apiDeleteSalesOrder}$id&Comid=$comid',
      null,
    );
    final value = ResponseViewModel.fromJson(result as Map<String, dynamic>);
    if (value.IsSuccess == true) {
      return value.Message ?? 'Deleted successfully';
    }
    throw Exception(value.Message ?? 'Delete failed');
  }

  // ─── Get Job No (Forwarding) ──────────────────────────────────────────────
  static Future<Map<String, dynamic>> getJobNoForwarding(int billId) async {
    final comid  = AppPreferences.getComid();
    final result = await ApiClient.postRequest(
      '${ApiConstants.apiGetJobNo}$comid&JobType=$billId',
      null,
    );
    final data1 = result['Data1'] as List;
    return {
      'forwardingList': data1.map((e) => ForwardingModel.fromJson(e)).toList(),
      'jobNoList': data1,
    };
  }

  // ─── RTI No ───────────────────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getRTINumbers() async {
    final comid  = AppPreferences.getComid();
    final result = await ApiClient.postRequest(
      '${ApiConstants.apiGetRTINo}$comid',
      null,
    );
    if (result is! List) return [];
    return result
        .whereType<Map<String, dynamic>>()
        .map((item) => {
      'CNumber': item['RTINoDisplay']?.toString() ?? '',
      'Id':      item['Id'] ?? 0,
    })
        .toList();
  }

  // ─── Currency Value ───────────────────────────────────────────────────────
  static Future<double> getCustomerCurrencyValue(int customerId) async {
    final comid  = AppPreferences.getComid();
    final result = await ApiClient.postRequest(
      '${ApiConstants.apiGetCurrencyValue}$comid&CustId=$customerId',
      null,
    );
    return (result['Data1'] as num?)?.toDouble() ?? 0.0;
  }

  // ─── Combo S1 (multiple dropdown data) ───────────────────────────────────
  static Future<List<dynamic>> getComboS1(int type) async {
    final comid  = AppPreferences.getComid();
    final result = await ApiClient.postRequest(
      '${ApiConstants.apiGetComboS1}$comid&type=$type',
      null,
    );
    return [
      result['Data1'], result['Data2'], result['Data3'],
      result['Data4'], result['Data5'], result['Data6'],
    ];
  }

  // ─── Edit Planning ────────────────────────────────────────────────────────
  static Future<List<dynamic>> editPlanning(int id, int planningNo) async {
    final comid  = AppPreferences.getComid();
    final result = await ApiClient.postRequest(
      '${ApiConstants.apiEditPlanning}$id&PLANINGNo=$planningNo&Comid=$comid',
      null,
    );
    final list = result as List;
    return (list[0]['SaleDetails'] as List).toList();
  }

  // ─── Edit Vessel Planning ─────────────────────────────────────────────────
  static Future<List<dynamic>> editVesselPlanning(int id, int planningNo) async {
    final comid  = AppPreferences.getComid();
    final result = await ApiClient.postRequest(
      '${ApiConstants.apiEditVesselPlanning}$id&VESSELPLANINGNo=$planningNo&Comid=$comid',
      null,
    );
    final list = result as List;
    return (list[0]['SaleDetails'] as List).toList();
  }

  // ─── RTI View List ────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getRTIViewList({
    required String fromDate,
    required String toDate,
    required int dId,
    required int tId,
    required int employeeId,
    required String search,
  }) async {
    final comid  = AppPreferences.getComid();
    final result = await ApiClient.postRequest(
      '${ApiConstants.apiSelectRTIView}$comid&Fromdate=$fromDate'
          '&Todate=$toDate&DId=$dId&TId=$tId&Employeeid=$employeeId&Search=$search',
      null,
    );
    final list = result as List;
    return {
      'master':  (list[0]['salemaster'] as List).map((e) => RTIMasterViewModel.fromJson(e)).toList(),
      'details': (list[0]['saledetails'] as List).map((e) => RTIDetailsViewModel.fromJson(e)).toList(),
    };
  }

  // ─── Max Stock No ─────────────────────────────────────────────────────────
  static Future<dynamic> getMaxStockNo() async {
    final comid  = AppPreferences.getComid();
    final result = await ApiClient.postRequest(
      '${ApiConstants.apiMaxStockNo}$comid',
      null,
    );
    return result['Data1'];
  }

  // ─── Dashboard — Sale Invoice Count ──────────────────────────────────────
  static Future<int> getSaleInvoiceCount({
    required String fromDate,
    required String toDate,
    required int employeeId,
    required int remarks,
    bool invoice = false,
  }) async {
    final comid  = AppPreferences.getComid();
    final result = await ApiClient.postRequest(
      ApiConstants.SaleInvoiceCountDB,
      {
        'Comid':                  comid,
        'Fromdate':               fromDate,
        'Todate':                 toDate,
        'Statusid':               0,
        'Employeeid':             employeeId,
        'Remarks':                remarks,
        'Search':                 '0',
        'completestatusnotshow':  false,
        'Invoice':                invoice,
      },
    );
    return (result as List).length;
  }

  // ─── Dashboard — Sales Order Status ──────────────────────────────────────
  static Future<List<dynamic>> getSalesOrderStatus(int employeeId) async {
    final comid  = AppPreferences.getComid();
    final result = await ApiClient.postRequest(
      ApiConstants.SelectSalesOrderStatus,
      {'Comid': comid, 'Employeeid': employeeId},
    );
    return result as List;
  }
}