import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/utils/app_globals.dart';

class SalesOrderRepository {
  final int comid = AppPreferences.getComid();

  // ─── Initial Data Loading ──────────────────────────────────────────────────
  Future<Map<String, dynamic>> fetchInitialData(String billType) async {
    // Replace these with your actual ApiClient.postRequest calls mapping to objfun URLs
    final maxOrderResponse = await ApiClient.postRequest("${AppGlobals.apiMaxSaleOrderNo}$comid&BillType=$billType", null);
    final agentCompanyResponse = await ApiClient.postRequest("${AppGlobals.apiSelectAgentCompany}$comid", null);
    final employeeResponse = await ApiClient.postRequest("${AppGlobals.apiSelectEmployee}$comid&AccountName=&Type=Operation", null);

    // Determine Max Order Num safely
    String maxNum = '';
    if (maxOrderResponse != null && maxOrderResponse is List && maxOrderResponse.isNotEmpty) {
      maxNum = maxOrderResponse[0]['MaxNo']?.toString() ?? '';
    }

    return {
      'maxSaleOrderNum': maxNum,
      'agentCompanies': agentCompanyResponse is List ? agentCompanyResponse : [],
      'employees': employeeResponse is List ? employeeResponse : [],
    };
  }

  // ─── Master Data Loading (For Edits/Enquiries) ───────────────────────────
  Future<Map<String, dynamic>> fetchMasterData(int jobMasterRefId, int agentCompanyRefId, int customerRefId) async {
    final customerResponse = await ApiClient.postRequest("${AppGlobals.apiSelectCustomer}$comid", null);
    final jobTypeResponse = await ApiClient.postRequest("${AppGlobals.apiSelectJobType}$comid", null);
    final jobStatusResponse = await ApiClient.postRequest("${AppGlobals.apiSelectAllJobStatus}$comid&JobMasterRefId=$jobMasterRefId", null);
    final agentAllResponse = await ApiClient.postRequest("${AppGlobals.apiSelectAgentAll}$comid&AgentCompanyRefId=$agentCompanyRefId", null);
    final currencyResponse = await ApiClient.postRequest("${AppGlobals.apiGetCurrencyValue}$comid&CustomerRefId=$customerRefId", null);

    double currencyVal = 0.0;
    if (currencyResponse != null && currencyResponse is List && currencyResponse.isNotEmpty) {
      currencyVal = double.tryParse(currencyResponse[0]['CurrencyValue']?.toString() ?? '0') ?? 0.0;
    }

    return {
      'customers': customerResponse is List ? customerResponse : [],
      'jobTypes': jobTypeResponse is List ? jobTypeResponse : [],
      'jobStatuses': jobStatusResponse is List ? jobStatusResponse : [],
      'agents': agentAllResponse is List ? agentAllResponse : [],
      'currencyValue': currencyVal,
    };
  }

  // ─── Job Type Changed Data ───────────────────────────────────────────────
  Future<Map<String, dynamic>> fetchJobTypeDependencies(int jobTypeId) async {
    final jobStatusResponse = await ApiClient.postRequest("${AppGlobals.apiSelectAllJobStatus}$comid&JobMasterRefId=$jobTypeId", null);
    final comboS1Response = await ApiClient.postRequest("${AppGlobals.apiGetComboS1}$comid&JobMasterRefId=$jobTypeId", null);

    return {
      'jobStatuses': jobStatusResponse is List ? jobStatusResponse : [],
      'comboS1': comboS1Response is List ? comboS1Response : [],
    };
  }

  // ─── Save / Update ───────────────────────────────────────────────────────
  Future<ResponseViewModel?> saveSalesOrder(List<Map<String, dynamic>> master) async {
    final response = await ApiClient.postRequest('${AppGlobals.apiInsertSalesOrder}?Comid=$comid', master);
    return response != null ? ResponseViewModel.fromJson(response) : null;
  }

  Future<void> confirmEnquiry(int enquiryId) async {
    await ApiClient.postRequest('${AppGlobals.apiUpdateEnquiryMaster}$enquiryId&Comid=$comid&StatusName=CONFIRMED', null);
  }
}