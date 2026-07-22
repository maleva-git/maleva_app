import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/models/shared/response_view_model.dart';

class FWBreakSealRepository {

  // 1. Fetch the Job List
  Future<List<Map<String, dynamic>>> fetchJobs(int type) async {
    final comid = AppPreferences.getComid();

    // MATCHED: String apiGetJobNo = "$port/api/SaleOrderApp/GetJobNo?Comid=";
    final String url = "${ApiConstants.apiGetJobNo}$comid&JobType=$type";

    final response = await ApiClient.postRequest(url, null);

    if (response != null && response is List) {
      return List<Map<String, dynamic>>.from(response);
    }
    return [];
  }

  // 2. Fetch Sales Order Details
  Future<Map<String, dynamic>> fetchSalesOrderDetails(int id, int cNumber) async {
    // MATCHED: String apiEditSalesOrder = "$port/api/SaleOrderApp/EditSaleOrder?Id=";
    final String url = "${ApiConstants.apiEditSalesOrder}$id&CNumber=$cNumber";

    final response = await ApiClient.postRequest(url, null);

    if (response != null && response is List && response.isNotEmpty) {
      return response[0] as Map<String, dynamic>;
    }
    return {};
  }

  // 3. Fetch Employees
  Future<List<dynamic>> fetchEmployees() async {
    final comid = AppPreferences.getComid();

    final String url = "${ApiConstants.apiSelectEmployee}$comid&AccountName=&Type=Operation";

    final response = await ApiClient.postRequest(url, null);
    return response is List ? response : [];
  }

  Future<ResponseViewModel?> updateForwarding(Map<String, dynamic> master) async {

    final response = await ApiClient.postRequest(ApiConstants.apiUpdateForwarding, master);

    if (response != null) {
      return ResponseViewModel.fromJson(response);
    }
    return null;
  }
}