import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/network/java_report.dart';
import 'package:maleva/core/network/legacy_api_repository.dart';
import 'package:maleva/core/planning/planning_api.dart';
import 'package:maleva/core/utils/app_globals.dart';

/// The Planning list screen's data, on the shared Java planning API (`PlanningApi`). The
/// employee picker is still the .NET employee list (it moves with the employee screens).
class PlanningRepository {
  PlanningRepository({PlanningApi? api}) : _api = api;

  final PlanningApi? _api;
  PlanningApi get _planning => _api ?? sl<PlanningApi>();

  /// Saved plans in the range ([planningNo] searches one plan); dates yyyy-MM-dd.
  Future<PlanList> getPlanning(String fromDate, String toDate, String planningNo, int empId) =>
      _planning.list(from: DateTime.parse(fromDate), to: DateTime.parse(toDate), search: planningNo, employeeId: empId);

  /// The plan's rows for the read-only planning details screen (`AppGlobals.PlanningEditList`).
  Future<void> editPlanning(int id) async {
    AppGlobals.PlanningEditList = (await _planning.edit(id))['SaleDetails'] as List? ?? [];
  }

  /// The plan's PDF link (public for a few minutes).
  Future<String> pdfUrl(int id) async => javaReportUrl(await _planning.reportPath(id));

  Future<void> selectEmployee(dynamic context, String type, String userType) async {
    await sl<LegacyApiRepository>().SelectEmployee(context, type, userType);
  }
}
