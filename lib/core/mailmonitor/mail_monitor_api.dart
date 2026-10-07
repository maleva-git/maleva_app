import 'package:dio/dio.dart';
import 'package:maleva/core/mailmonitor/mail_monitor_models.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// The Super Admin's Mailbox Monitor on the shared Java API (backend change add-mail-monitor,
/// the same endpoints React uses). The server refuses every other role (403) and answers 503
/// while the monitor is not set up; each failure arrives as an ApiFailure with the server's
/// own message. Nothing here is stored on the device.
class MailMonitorApi {
  MailMonitorApi(this._dio, {required int Function() companyId}) : _companyId = companyId;

  final Dio _dio;
  final int Function() _companyId;

  static const _base = '/api/mail-monitor';

  Future<MailboxList> mailboxes() =>
      _get('$_base/mailboxes', {}).then((d) => MailboxList.fromJava(JsonRead.map(d)));

  /// The latest five unread: sender, subject, time.
  Future<List<PreviewItem>> preview(int mailboxId) => _get('$_base/mailboxes/$mailboxId/unread-preview', {})
      .then((d) => JsonRead.listOfMaps(JsonRead.map(d)['items']).map(PreviewItem.fromJava).toList());

  /// One page of all unread mail, newest first, read live from the mailbox. [query] is searched
  /// by the mail server in subject and sender.
  Future<UnreadPage> unread(int mailboxId, {int page = 0, int size = 50, String query = ''}) =>
      _get('$_base/mailboxes/$mailboxId/unread', {
        'page': page,
        'size': size,
        if (query.trim().isNotEmpty) 'q': query.trim(),
      }).then((d) => UnreadPage.fromJava(JsonRead.map(d)));

  /// Opens one mail read-only: it stays unread; the server records the open.
  Future<MailMessage> message(int mailboxId, int uid) =>
      _get('$_base/mailboxes/$mailboxId/messages/$uid', {}).then((d) => MailMessage.fromJava(JsonRead.map(d)));

  /// Emails the mailbox's active owners. 429 when one was sent in the last 30 minutes.
  Future<ReminderResult> remind(int mailboxId) =>
      _post('$_base/mailboxes/$mailboxId/remind').then((d) => ReminderResult.fromJava(JsonRead.map(d)));

  /// Starts a check of every mailbox in the background. 409 while one is running.
  Future<void> checkNow() => _post('$_base/check-now');

  Future<dynamic> _get(String path, Map<String, dynamic> query) async {
    try {
      final r = await _dio.get<dynamic>(path, queryParameters: {'companyId': _companyId(), ...query});
      return JavaResponse.data(r.data);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }

  Future<dynamic> _post(String path) async {
    try {
      final r = await _dio.post<dynamic>(path, queryParameters: {'companyId': _companyId()});
      return JavaResponse.data(r.data);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }
}
