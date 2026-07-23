import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/network/api_client.dart';

class AirfreightRepository {
  /// Fetches the employee rules type
  Future<dynamic> fetchRules(int comId, int empId) async {
    final body = {
      'Comid': comId,
      'Employeeid': empId,
    };
    return await ApiClient.postRequest(ApiConstants.LoadRulesType, body);
  }

  /// Fetches the invoice counts
  Future<dynamic> fetchInvoiceCount(Map<String, dynamic> body) async {
    return await ApiClient.postRequest(ApiConstants.SaleInvoiceCountDB, body);
  }

  /// Fetches the main sales report list
  Future<dynamic> fetchOrderStatus(int comId, int empId) async {
    final body = {
      'Comid': comId,
      'Employeeid': empId,
    };
    return await ApiClient.postRequest(ApiConstants.SelectSalesOrderStatus, body);
  }
}