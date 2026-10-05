import 'package:get_it/get_it.dart';
import 'package:maleva/core/employee/employee_api.dart';
import 'package:maleva/core/lookups/job_steps.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/sale_order/sale_order_api.dart';

class SaleOrderDetailsRepository {
  final int comid = AppPreferences.getComid();

  // ─── Initial Startup Data ──────────────────────────────────────────────────
  Future<Map<String, dynamic>> fetchInitialData(String billType) async {
    final maxNum = await fetchMaxOrderNo(billType);
    final addressResponse = await ApiClient.postRequest("${ApiConstants.apiSelectAddressList}$comid", null);
    final agentCompanyResponse = await ApiClient.postRequest("${ApiConstants.apiSelectAgentCompany}$comid", null);
    // the Operation employees, from the shared Java employee list
    final employees = await GetIt.instance<EmployeeApi>().dropdown(type: 'Operation');

    return {
      'maxSaleOrderNum': maxNum,
      'addresses': addressResponse is List ? addressResponse : [],
      'agentCompanies': agentCompanyResponse is List ? agentCompanyResponse : [],
      'employees': employees,
    };
  }

  // ─── Master Dependencies (For loading the edit view) ───────────────────────
  Future<Map<String, dynamic>> fetchMasterDependencies(int jobMasterRefId, int agentCompanyRefId) async {
    final customerResponse = await ApiClient.postRequest("${ApiConstants.apiSelectCustomer}$comid", null);
    final jobTypeResponse = await ApiClient.postRequest("${ApiConstants.apiSelectJobType}$comid", null);

    final jobStatusResponse = await ApiClient.postRequest("${ApiConstants.apiSelectAllJobStatus}$comid&Jobid=$jobMasterRefId", null);
    final agentAllResponse = await ApiClient.postRequest("${ApiConstants.apiSelectAgentAll}$comid&Jobid=$agentCompanyRefId", null);

    return {
      'customers': customerResponse is List ? customerResponse : [],
      'jobTypes': jobTypeResponse is List ? jobTypeResponse : [],
      'jobStatuses': JobSteps.statuses(jobStatusResponse),
      'jobTypeDetails': JobSteps.details(jobStatusResponse),
      'agents': agentAllResponse is List ? agentAllResponse : [],
    };
  }

  /// The next job number of the bill type (Java sequence, as the web).
  Future<String> fetchMaxOrderNo(String billType) => sl<SaleOrderApi>().nextJobNo(billType);
}