import 'package:dio/dio.dart';
import 'package:maleva/core/models/shared/email_model.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// The staff email inbox, from the shared Java `/api/email-inboxes` (ported
/// from .NET EmployeeApp SelectEmailData / InsertMailMaster and SP_EmailInbox,
/// change `email-inbox-on-shared-java-api`). A refusal (no mailbox set up, a
/// refused login) is an [ApiFailure] with the server's message.
class EmailInboxApi {
  EmailInboxApi(this._dio, {required int Function() companyId}) : _companyId = companyId;

  final Dio _dio;
  final int Function() _companyId;

  int get companyId => _companyId();

  /// The employee's mail of the last day not answered and not kept yet.
  Future<List<EmailModel>> unanswered(int employeeId) async {
    final data = JsonRead.map(await _send(() => _dio.get<dynamic>('/api/email-inboxes/unanswered',
        queryParameters: {'companyId': companyId, 'employeeId': employeeId})));
    return JsonRead.listOfMaps(data['emails']).map(EmailModel.fromJava).toList();
  }

  /// Keeps the [emails] as the employee's active inbox entries; answers how many.
  Future<int> keep(int employeeId, List<EmailModel> emails) async => JsonRead.integer(await _send(() =>
      _dio.post<dynamic>('/api/email-inboxes/entries',
          queryParameters: {'companyId': companyId},
          data: [for (final e in emails) e.toJava(employeeId)])));

  Future<dynamic> _send(Future<Response<dynamic>> Function() call) async {
    try {
      return JavaResponse.data((await call()).data);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }
}
