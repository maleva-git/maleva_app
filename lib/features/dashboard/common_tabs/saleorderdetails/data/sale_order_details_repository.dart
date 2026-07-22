import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_preferences.dart';

class SaleOrderDetailsRepository {
  final int comid = AppPreferences.getComid();

  // ─── Initial Startup Data ──────────────────────────────────────────────────
  Future<Map<String, dynamic>> fetchInitialData(String billType) async {
    final maxOrderResponse = await ApiClient.postRequest("${ApiConstants.apiMaxSaleOrderNo}$comid&BillType=$billType", null);
    final addressResponse = await ApiClient.postRequest("${ApiConstants.apiSelectAddressList}$comid", null);
    final agentCompanyResponse = await ApiClient.postRequest("${ApiConstants.apiSelectAgentCompany}$comid", null);
    final employeeResponse = await ApiClient.postRequest("${ApiConstants.apiSelectEmployee}$comid&AccountName=&Type=Operation", null);

    String maxNum = '';
    if (maxOrderResponse != null && maxOrderResponse is List && maxOrderResponse.isNotEmpty) {
      maxNum = maxOrderResponse[0]['MaxNo']?.toString() ?? '';
    }

    return {
      'maxSaleOrderNum': maxNum,
      'addresses': addressResponse is List ? addressResponse : [],
      'agentCompanies': agentCompanyResponse is List ? agentCompanyResponse : [],
      'employees': employeeResponse is List ? employeeResponse : [],
    };
  }

  // ─── Master Dependencies (For loading the edit view) ───────────────────────
  Future<Map<String, dynamic>> fetchMasterDependencies(int jobMasterRefId, int agentCompanyRefId) async {
    final customerResponse = await ApiClient.postRequest("${ApiConstants.apiSelectCustomer}$comid", null);
    final jobTypeResponse = await ApiClient.postRequest("${ApiConstants.apiSelectJobType}$comid", null);

    // Note: Assuming this API returns the Job Statuses and Job Type Details
    final jobStatusResponse = await ApiClient.postRequest("${ApiConstants.apiSelectAllJobStatus}$comid&JobId=$jobMasterRefId", null);
    final agentAllResponse = await ApiClient.postRequest("${ApiConstants.apiSelectAgentAll}$comid&Jobid=$agentCompanyRefId", null);

    return {
      'customers': customerResponse is List ? customerResponse : [],
      'jobTypes': jobTypeResponse is List ? jobTypeResponse : [],
      'jobStatuses': jobStatusResponse is List ? jobStatusResponse : [], // May contain both status and details based on your API structure
      'agents': agentAllResponse is List ? agentAllResponse : [],
    };
  }

  Future<String> fetchMaxOrderNo(String billType) async {
    final maxOrderResponse = await ApiClient.postRequest("${ApiConstants.apiMaxSaleOrderNo}$comid&BillType=$billType", null);
    if (maxOrderResponse != null && maxOrderResponse is List && maxOrderResponse.isNotEmpty) {
      return maxOrderResponse[0]['MaxNo']?.toString() ?? '';
    }
    return '';
  }
}