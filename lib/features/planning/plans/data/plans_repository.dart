import 'package:maleva/core/employee/employee_api.dart';
import 'package:maleva/core/network/java_report.dart';
import 'package:maleva/core/planning/planning_api.dart';
import 'package:maleva/core/session/app_session.dart';
import 'package:maleva/core/widgets/ui/picker_sheet.dart';
import 'package:maleva/features/planning/plans/models/plan_row.dart';

/// Planning View's data: the saved plans (`POST /api/planing/select-planning`), the employees
/// for the picker, and the plan report (`GET /api/planning/reports/{id}/pdf-ticket`), on the
/// shared Java API the web uses.
class PlansRepository {
  PlansRepository({required PlanningApi planning, required EmployeeApi employees, required AppSession session})
      : _planning = planning,
        _employees = employees,
        _session = session;

  final PlanningApi _planning;
  final EmployeeApi _employees;
  final AppSession _session;

  int get companyId => _session.companyId;

  /// EmployeeMaster id of the user (0 for a driver login).
  int get employeeId => _session.employeeId;

  /// `{comid, fromdate, todate, search, employeeid}`; a plan number ignores the dates on the server.
  Future<List<PlanRow>> list({required DateTime from, required DateTime to, String search = '', int employeeId = 0}) async {
    final answer = await _planning.list(from: from, to: to, search: search, employeeId: employeeId);
    return PlanRow.fromSelectPlanning(answer.masters, answer.details);
  }

  Future<List<PickOption<int>>> employees() async => [
        for (final e in await _employees.dropdown())
          if (e.Id > 0) PickOption(value: e.Id, label: e.AccountName),
      ];

  /// The report's full URL for [reportDate] (the page's Report Date), or '' when none came back.
  Future<String> reportUrl(int planningId, DateTime reportDate) async {
    final path = (await _planning.reportPath(planningId, reportDate: reportDate)).trim();
    return path.isEmpty ? '' : javaReportUrl(path);
  }
}
