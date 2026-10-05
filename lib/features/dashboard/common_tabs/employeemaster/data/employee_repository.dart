import 'package:get_it/get_it.dart';
import 'package:maleva/core/employee/employee_api.dart';
import 'package:maleva/core/models/shared/employee_details_model.dart';

/// Employee Master, on the shared Java employee APIs the web uses (change
/// `employee-lookups-on-shared-java-api`).
class EmployeeRepository {
  EmployeeRepository({EmployeeApi? api}) : _api = api;

  final EmployeeApi? _api;

  EmployeeApi get _employees => _api ?? GetIt.instance<EmployeeApi>();

  /// The company's employees (not deleted), up to 100, as the screen listed them.
  Future<List<EmployeeDetailsModel>> fetchEmployees() async =>
      (await _employees.search()).map(EmployeeDetailsModel.fromJava).toList();

  /// The roles an employee can hold: `{id, name}`.
  Future<List<Map<String, dynamic>>> fetchRoles() => _employees.roles();

  /// Soft-deletes an employee of the company.
  Future<void> deleteEmployee({required int id}) => _employees.delete(id);

  /// Adds (id 0) or updates an employee; answers the saved id.
  Future<int> saveEmployee(EmployeeDetailsModel employee) => _employees.save(employee.toJava());
}
