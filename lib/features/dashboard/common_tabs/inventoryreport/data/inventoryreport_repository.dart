import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_globals.dart';

class InventoryReportRepository {
  /// Fetches the Customer List for the dropdown/selection
  Future<dynamic> fetchCustomers(int comId) async {
    return await ApiClient.postRequest("${ApiConstants.apiSelectCustomer}$comId", null);
  }

  /// Fetches the main Inventory Report data
  Future<dynamic> fetchInventoryReport(Map<String, dynamic> body) async {
    return await ApiClient.postRequest(ApiConstants.apiSelectAllInventory, body);
  }
}