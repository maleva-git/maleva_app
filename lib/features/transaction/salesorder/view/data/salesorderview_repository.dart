import 'package:maleva/features/operations/models/job_status_model.dart';
import 'package:maleva/core/lookups/job_status_api.dart';
import 'package:maleva/core/models/shared/customer_model.dart';
import 'package:maleva/core/lookups/customer_api.dart';
import 'package:maleva/core/models/shared/employee_model.dart';
import 'package:get_it/get_it.dart';
import 'package:maleva/core/employee/employee_api.dart';
import 'package:maleva/core/utils/session_manager.dart';

class SalesOrderViewRepository {
  final SessionManager _sessionManager;

  SalesOrderViewRepository(this._sessionManager);

  /// Customer options (shared Java /api/customers/options).
  Future<List<CustomerModel>> selectCustomer() async =>
      (await GetIt.instance<CustomerApi>().options()).map(CustomerModel.fromJava).toList();

  /// The shared Java employee list for the pickers.
  Future<List<EmployeeModel>> selectEmployee(String type, String type1) =>
      GetIt.instance<EmployeeApi>().dropdown(type: type, type1: type1);


  /// The company's job statuses (shared Java job status master).
  Future<List<JobStatusModel>> selectJobStatus() async =>
      (await GetIt.instance<JobStatusApi>().statuses()).map(JobStatusModel.fromJava).toList();
}
