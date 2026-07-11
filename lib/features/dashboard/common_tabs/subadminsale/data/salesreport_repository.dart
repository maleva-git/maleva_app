import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_globals.dart';

class SalesReportRepository {
  /// Fetches the employee rules type
  Future<dynamic> fetchRules(int comId, int empId) async {
    final body = {
      'Comid': comId,
      'Employeeid': empId,
    };
    return await ApiClient.postRequest(AppGlobals.LoadRulesType, body);
  }

  /// Fetches the invoice counts (Total, Billed, Unbilled, Without Invoice)
  Future<dynamic> fetchInvoiceCount(Map<String, dynamic> body) async {
    return await ApiClient.postRequest(AppGlobals.SaleInvoiceCountDB, body);
  }

  /// Fetches the main sales report list
  Future<dynamic> fetchOrderStatus(int comId, int empId) async {
    final body = {
      'Comid': comId,
      "Employeeid": empId,
    };
    return await ApiClient.postRequest(AppGlobals.SelectSalesOrderStatus, body);
  }

  /// Fetches the specific employee invoice data for the Dialog
  Future<dynamic> fetchEmployeeInvData(int comId, int type) async {
    final url = "${AppGlobals.apiGetEmployeeInvData}$comId&type=$type";
    return await ApiClient.postRequest(url, null);
  }
}