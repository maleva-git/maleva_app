import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_globals.dart';

class TransportSalesRepository {
  /// Fetches the employee rules type
  Future<dynamic> fetchRules(int comId, int empId) async {
    final body = {
      'Comid': comId,
      "Employeeid": empId,
    };
    return await ApiClient.postRequest(AppGlobals.LoadRulesType, body);
  }

  /// Fetches the invoice count based on specific parameters
  Future<dynamic> fetchInvoiceCount(Map<String, dynamic> body) async {
    return await ApiClient.postRequest(AppGlobals.SaleInvoiceCountDB, body);
  }

  /// Fetches the overall sales order status
  Future<dynamic> fetchOrderStatus(int comId, int empId) async {
    final body = {
      'Comid': comId,
      "Employeeid": empId,
    };
    return await ApiClient.postRequest(AppGlobals.SelectSalesOrderStatus, body);
  }
}