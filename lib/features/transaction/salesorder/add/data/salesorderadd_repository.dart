import 'package:maleva/core/models/shared/address_details_model.dart';
import 'package:maleva/core/lookups/address_api.dart';
import 'package:maleva/core/models/shared/agent_company_model.dart';
import 'package:maleva/core/models/shared/agent_model.dart';
import 'package:maleva/core/lookups/agent_api.dart';
import 'package:maleva/core/lookups/job_steps.dart';
import 'package:maleva/core/lookups/job_status_api.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/features/operations/models/job_type_model.dart';
import 'package:maleva/core/models/shared/customer_model.dart';
import 'package:maleva/core/lookups/job_type_api.dart';
import 'package:maleva/core/lookups/customer_api.dart';
import 'package:maleva/core/models/shared/employee_model.dart';
import 'package:get_it/get_it.dart';
import 'package:maleva/core/employee/employee_api.dart';

class SalesOrderAddRepository {
  // every list now comes from the shared Java APIs (no legacy client, no session needed)
  SalesOrderAddRepository();

  /// The address names (shared Java address master).
  Future<List<String>> selectAddressList() => sl<AddressApi>().names();

  /// The addresses whose name contains [keyword] (shared Java address search).
  Future<List<AddressDetailsModel>> selectAddressDetails(String keyword) async =>
      (await sl<AddressApi>().search(keyword)).map(AddressDetailsModel.fromJava).toList();

  /// Agent companies (shared Java agent company master).
  Future<List<AgentCompanyModel>> selectAgentCompany() async =>
      (await sl<AgentApi>().agentCompanies()).map(AgentCompanyModel.fromJava).toList();

  /// The shared Java employee list for the pickers.
  Future<List<EmployeeModel>> selectEmployee(String searchVal, String deptName) =>
      GetIt.instance<EmployeeApi>().dropdown(type: searchVal, type1: deptName);


  /// The job type's steps and status order (shared Java select-all-data).
  Future<JobSteps> selectAllJobStatus(int jobId) => sl<JobStatusApi>().steps(jobId);

  /// Customer options (shared Java /api/customers/options).
  Future<List<CustomerModel>> selectCustomer() async =>
      (await sl<CustomerApi>().options()).map(CustomerModel.fromJava).toList();

  /// Job types (shared Java /api/job-type-master/jobtypes/{companyId}).
  Future<List<JobTypeModel>> selectJobType() async =>
      (await sl<JobTypeApi>().jobTypes()).map(JobTypeModel.fromJava).toList();

  /// The agents of an agent company (shared Java /api/agents/select-all).
  Future<List<AgentModel>> selectAgentAll(int agentCompanyId) async =>
      (await sl<AgentApi>().agents(agentCompanyId: agentCompanyId)).map(AgentModel.fromJava).toList();
}
