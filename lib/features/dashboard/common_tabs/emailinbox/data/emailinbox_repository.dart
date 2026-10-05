import 'package:maleva/core/models/shared/employee_model.dart';
import 'package:get_it/get_it.dart';
import 'package:maleva/core/employee/employee_api.dart';
import 'package:maleva/core/employee/email_inbox_api.dart';
import 'package:maleva/core/models/shared/email_model.dart';

class EmailInboxRepository {
  /// The employees, from the shared Java employee list
  Future<List<EmployeeModel>> fetchEmployees({required int comId}) =>
      GetIt.instance<EmployeeApi>().dropdown();


  /// The employee's unanswered mail of the last day (shared Java inbox).
  Future<List<EmailModel>> fetchEmails({required int employeeId}) =>
      GetIt.instance<EmailInboxApi>().unanswered(employeeId);

  /// Keeps the ticked mails as the employee's inbox entries; answers how many.
  Future<int> saveEmails({required int employeeId, required List<EmailModel> emails}) =>
      GetIt.instance<EmailInboxApi>().keep(employeeId, emails);
}
