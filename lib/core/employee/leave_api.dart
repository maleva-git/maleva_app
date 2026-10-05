import 'package:dio/dio.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// Leave requests, from the shared Java `/api/leave` (ported from .NET
/// LeaveRequestApp and SP_LeaveRequestMaster, change
/// `leave-on-shared-java-api`). Applicant type 1 = employee, 2 = driver; status
/// 1 = pending, 2 = approved, 3 = rejected. A driver token may only request
/// and list its own leave; the server enforces it. A refusal is an
/// [ApiFailure] with the server's reason.
///
/// A request is `id`, `applicantType`, `applicantRefId`, `applicantName`,
/// `leaveTypeRefId`, `leaveTypeName`, `fromDate`, `toDate`, `totalDays`,
/// `reason`, `statusRefId`, `statusName`, `reviewedBy`, `reviewedByName`,
/// `reviewRemark`.
class LeaveApi {
  LeaveApi(this._dio, {required int Function() companyId}) : _companyId = companyId;

  final Dio _dio;
  final int Function() _companyId;

  int get companyId => _companyId();

  /// The active leave types: `id`, `name`.
  Future<List<Map<String, dynamic>>> types() async =>
      JsonRead.listOfMaps(await _send(() => _dio.get<dynamic>('/api/leave/types')));

  /// The company's requests, newest first; [fromDate] / [toDate] (`yyyy-MM-dd`)
  /// filter the leave's start day.
  Future<List<Map<String, dynamic>>> search({
    int? applicantType,
    int? applicantRefId,
    String? fromDate,
    String? toDate,
  }) async =>
      JsonRead.listOfMaps(await _send(() => _dio.post<dynamic>('/api/leave/search', data: {
            'companyRefId': companyId,
            if (applicantType != null && applicantType > 0) 'applicantType': applicantType,
            if (applicantRefId != null && applicantRefId > 0) 'applicantRefId': applicantRefId,
            if (fromDate != null && fromDate.isNotEmpty) 'fromDate': _dayStart(fromDate),
            if (toDate != null && toDate.isNotEmpty) 'toDate': _dayStart(toDate),
          })));

  /// Requests leave (a new, pending request). Answers the saved request.
  Future<Map<String, dynamic>> request({
    required int applicantType,
    required int applicantRefId,
    required int leaveTypeRefId,
    required DateTime fromDate,
    required DateTime toDate,
    required int totalDays,
    required String reason,
    required int createdBy,
  }) async =>
      JsonRead.map(await _send(() => _dio.post<dynamic>('/api/leave/save',
          queryParameters: {'companyId': companyId},
          data: {
            'applicantType': applicantType,
            'applicantRefId': applicantRefId,
            'leaveTypeRefId': leaveTypeRefId,
            'fromDate': _time(fromDate),
            'toDate': _time(toDate),
            'totalDays': totalDays,
            'reason': reason,
            'statusRefId': 1,
            'createdBy': createdBy,
          })));

  /// Approves (2) or rejects (3) a request, with the reviewer and remark.
  Future<void> setStatus(int id, {required int statusRefId, required int reviewedBy, required String reviewRemark}) async {
    await _send(() => _dio.put<dynamic>('/api/leave/$id/status',
        queryParameters: {'companyId': companyId},
        data: {'statusRefId': statusRefId, 'reviewedBy': reviewedBy, 'reviewRemark': reviewRemark}));
  }

  static String _time(DateTime d) => d.toIso8601String().split('.').first;

  static String _dayStart(String day) => day.length == 10 ? '${day}T00:00:00' : day;

  Future<dynamic> _send(Future<Response<dynamic>> Function() call) async {
    try {
      return JavaResponse.data((await call()).data);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }
}
