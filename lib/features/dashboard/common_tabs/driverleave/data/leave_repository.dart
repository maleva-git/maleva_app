import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/employee/leave_api.dart';
import 'package:maleva/core/utils/session_manager.dart';
import 'leave_calendar.dart';
import 'leave_request_model.dart';

/// Leave requests on the shared Java `/api/leave` (was .NET LeaveRequestApp).
/// A refusal throws an ApiFailure with the server's reason.
class LeaveRepository {
  final SessionManager _sessionManager;

  LeaveRepository(this._sessionManager);

  LeaveApi get _api => sl<LeaveApi>();

  Future<bool> addLeaveRequest({
    required int leaveTypeRefId,
    required DateTime fromDate,
    required DateTime toDate,
    required int totalDays,
    required String reason,
    required int applicantRefId,
    int applicantType = 2,
    String? part,
  }) async {
    await _api.request(
      part: part,
      applicantType: applicantType,
      applicantRefId: applicantRefId,
      leaveTypeRefId: leaveTypeRefId,
      fromDate: fromDate,
      toDate: toDate,
      totalDays: totalDays,
      reason: reason,
      createdBy: _sessionManager.empRefId,
    );
    return true;
  }

  Future<List<LeaveRequestModel>> getLeaveRequests({
    int? applicantType,
    int? applicantRefId,
    String? fromDate,
    String? toDate,
  }) async {
    final rows = await _api.search(
        applicantType: applicantType, applicantRefId: applicantRefId, fromDate: fromDate, toDate: toDate);
    return rows.map(LeaveRequestModel.fromJava).toList();
  }

  Future<bool> updateLeaveStatus({
    required int id,
    required int statusRefId,
    required String reviewRemark,
    required int reviewedBy,
  }) async {
    await _api.setStatus(id, statusRefId: statusRefId, reviewedBy: reviewedBy, reviewRemark: reviewRemark);
    return true;
  }

  /// The calendar the form counts on (HR Sprint 2); the defaults with half days hidden when it can't be read.
  Future<LeaveCalendar> getCalendar({required bool driver, required Iterable<int> years}) async {
    try {
      final weeks = await _api.workWeek();
      final holidays = <Map<String, dynamic>>[];
      for (final y in years.toSet()) {
        holidays.addAll(await _api.holidays(y));
      }
      return LeaveCalendar.fromJava(weeks, holidays, driver: driver);
    } catch (_) {
      return LeaveCalendar.off;
    }
  }

  Future<List<LeaveTypeModel>> getLeaveTypes() async =>
      (await _api.types()).map(LeaveTypeModel.fromJava).toList();
}
