import 'package:maleva/core/models/shared/agent_company_model.dart';
import 'package:maleva/core/models/shared/agent_model.dart';
import 'package:maleva/core/lookups/agent_api.dart';
import 'package:maleva/core/lookups/job_status_api.dart';
import 'package:maleva/features/operations/models/job_type_model.dart';
import 'package:maleva/core/models/shared/customer_model.dart';
import 'package:maleva/core/lookups/job_type_api.dart';
import 'package:maleva/core/lookups/customer_api.dart';
import 'package:get_it/get_it.dart';
import 'package:maleva/core/employee/employee_api.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/sale_order/sale_order_api.dart';

class SaleOrderDetailsRepository {
  final int comid = AppPreferences.getComid();

  // ─── Initial Startup Data ──────────────────────────────────────────────────
  Future<Map<String, dynamic>> fetchInitialData(String billType) async {
    final maxNum = await fetchMaxOrderNo(billType);
    final agentCompanies = (await sl<AgentApi>().agentCompanies()).map(AgentCompanyModel.fromJava).toList();
    // the Operation employees, from the shared Java employee list
    final employees = await GetIt.instance<EmployeeApi>().dropdown(type: 'Operation');

    return {
      'maxSaleOrderNum': maxNum,
      'agentCompanies': agentCompanies,
      'employees': employees,
    };
  }

  // ─── Master Dependencies (For loading the edit view) ───────────────────────
  Future<Map<String, dynamic>> fetchMasterDependencies(int jobMasterRefId, int agentCompanyRefId) async {
    final customers = (await sl<CustomerApi>().options()).map(CustomerModel.fromJava).toList();
    final jobTypes = (await sl<JobTypeApi>().jobTypes()).map(JobTypeModel.fromJava).toList();

    final steps = await sl<JobStatusApi>().steps(jobMasterRefId);
    final agents = (await sl<AgentApi>().agents(agentCompanyId: agentCompanyRefId)).map(AgentModel.fromJava).toList();

    return {
      'customers': customers,
      'jobTypes': jobTypes,
      'jobStatuses': steps.statuses,
      'jobTypeDetails': steps.details,
      'agents': agents,
    };
  }

  /// The next job number of the bill type (Java sequence, as the web).
  Future<String> fetchMaxOrderNo(String billType) => sl<SaleOrderApi>().nextJobNo(billType);
}