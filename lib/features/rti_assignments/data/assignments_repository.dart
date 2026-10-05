import 'package:maleva/core/employee/employee_api.dart';
import 'package:maleva/core/rti/employee_assignments_api.dart';
import 'package:maleva/core/rti/rti_list_api.dart';
import 'package:maleva/core/session/app_session.dart';
import 'package:maleva/core/widgets/ui/formats.dart';
import 'package:maleva/core/widgets/ui/picker_sheet.dart';
import 'package:maleva/features/rti_assignments/models/employee_assignment.dart';

/// Employee Assignments' data on the shared Java API: the assignments
/// (`POST /api/rti/employee-assignments`), the employees for the picker and the RTI report.
class AssignmentsRepository {
  AssignmentsRepository({
    required EmployeeAssignmentsApi assignments,
    required RtiListApi rti,
    required EmployeeApi employees,
    required AppSession session,
    required String Function() userName,
  })  : _assignments = assignments,
        _rti = rti,
        _employees = employees,
        _session = session,
        _userName = userName;

  final EmployeeAssignmentsApi _assignments;
  final RtiListApi _rti;
  final EmployeeApi _employees;
  final AppSession _session;
  final String Function() _userName;

  int get companyId => _session.companyId;
  int get employeeId => _session.employeeId;

  /// The signed-in user's name, which "My Job Only" matches against the employee and driver
  /// names (React's `userName`, `EmployeeAssignmentsPage.tsx:59-65`).
  String get userName => _userName();

  Future<List<EmployeeAssignment>> fetch({required DateTime from, required DateTime to, int employeeId = 0}) async =>
      (await _assignments.fetch(fromDate: Fmt.ymd(from), toDate: Fmt.ymd(to), employeeId: employeeId))
          .map(EmployeeAssignment.fromJava)
          .toList();

  Future<List<PickOption<int>>> employees() async => [
        for (final e in await _employees.dropdown())
          if (e.Id > 0) PickOption(value: e.Id, label: e.AccountName),
      ];

  Future<String> reportUrl(int rtiId) => _rti.reportUrl(rtiId);
}
