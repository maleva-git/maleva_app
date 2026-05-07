import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

class InventoryReportRepository {
  /// Fetches the Customer List for the dropdown/selection
  Future<dynamic> fetchCustomers(int comId) async {
    return await ApiClient.postRequest("${objfun.apiSelectCustomer}$comId", null);
  }

  /// Fetches the main Inventory Report data
  Future<dynamic> fetchInventoryReport(Map<String, dynamic> body) async {
    return await ApiClient.postRequest(objfun.apiSelectAllInventory, body);
  }
}