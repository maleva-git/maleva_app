import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:maleva/core/mailmonitor/mail_monitor_models.dart';
import 'package:maleva/core/mailmonitor/my_unread_models.dart';
import 'package:maleva/core/mailmonitor/response_report_models.dart';
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

  Future<MailboxList> mailboxes() => _get('$_base/mailboxes', {}).then((d) => MailboxList.fromJava(JsonRead.map(d)));

  /// The signed-in employee's own linked mailboxes and their latest notice, for every employee role
  /// (backend change add-my-unread-mail-notice). Drivers get 403.
  Future<MyUnreadMail> myUnread() => _get('$_base/my-unread', {}).then((d) => MyUnreadMail.fromJava(JsonRead.map(d)));

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

  // ── Mail response report (backend change add-mail-response-report; app change
  // mail-response-report-tab). Super Admin only, like the web page.

  /// Reply times per mailbox for [range].
  Future<ResponseReport> responseReport(ReportRange range) =>
      _get('$_base/response-report', {'from': range.from, 'to': range.to})
          .then((d) => ResponseReport.fromJava(JsonRead.map(d)));

  /// One mailbox's slowest replies and mails still waiting.
  Future<LateList> responseLate(int mailboxId, ReportRange range, {int limit = 20}) =>
      _get('$_base/response-report/late', {'mailboxId': mailboxId, 'from': range.from, 'to': range.to, 'limit': limit})
          .then((d) => LateList.fromJava(JsonRead.map(d)));

  /// The mails behind a mailbox's numbers (backend change mail-count-own-mail): [group] COUNTED (needed its reply) or
  /// NOT_THEIRS (copied in, written to a colleague, answered by a colleague), each with its reason.
  Future<MailList> responseMails(int mailboxId, ReportRange range, String group) =>
      _get('$_base/response-report/mails', {'mailboxId': mailboxId, 'from': range.from, 'to': range.to, 'group': group})
          .then((d) => MailList.fromJava(JsonRead.map(d)));

  /// Corrects who a mail was for ([relevance] MINE or NOT_MINE), or sends it back to the rule (null)
  /// (backend change mail-team-credit-and-corrections). 503 until the server's script has run.
  Future<void> correctMail(int id, String? relevance) async {
    try {
      final r = await _dio.put<dynamic>('$_base/response-report/mails/$id/correction',
          queryParameters: {'companyId': _companyId()}, data: {'relevance': relevance});
      JavaResponse.data(r.data);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }

  /// Asks the server's AI to write about the numbers (no mail content is sent), in [language]
  /// (en, ta, ms, zh, es, hi; backend change mail-summary-language).
  Future<ResponseSummary> responseSummary(ReportRange range, {String language = 'en'}) =>
      _post('$_base/response-report/summary', {'from': range.from, 'to': range.to, 'language': language})
          .then((d) => ResponseSummary.fromJava(JsonRead.map(d)));

  /// Booking mail to sale order to job-number reply, per employee, in office minutes
  /// (backend change mail-reading-and-booking-speed).
  Future<BookingSpeedReport> bookingSpeed(ReportRange range) =>
      _get('$_base/booking-speed', {'from': range.from, 'to': range.to})
          .then((d) => BookingSpeedReport.fromJava(JsonRead.map(d)));

  /// The AI summary of the booking statistics (numbers only go to the AI; backend change booking-speed-insights).
  Future<BookingSummary> bookingSummary(ReportRange range, {String language = 'en'}) =>
      _post('$_base/booking-speed/summary', {'from': range.from, 'to': range.to, 'language': language})
          .then((d) => BookingSummary.fromJava(JsonRead.map(d)));

  /// The Super Admin's check of a booking-like mail: a booking (true), not a booking (false), or undo (null).
  Future<void> checkBooking(int id, bool? booking) async {
    try {
      final r = await _dio.put<dynamic>('$_base/booking-speed/mails/$id/booking',
          queryParameters: {'companyId': _companyId()}, data: {'booking': booking});
      JavaResponse.data(r.data);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }

  /// The server's PDF of the report (Jasper), as bytes. A refusal comes as JSON; its message is kept.
  Future<List<int>> responsePdf(ReportRange range) async {
    try {
      final r = await _dio.get<List<int>>('$_base/response-report/pdf',
          queryParameters: {'companyId': _companyId(), 'from': range.from, 'to': range.to},
          options: Options(responseType: ResponseType.bytes, headers: {'Accept': 'application/pdf, application/json'}));
      return r.data ?? const [];
    } on DioException catch (e) {
      final body = e.response?.data;
      if (body is List<int>) {
        try {
          final decoded = jsonDecode(utf8.decode(body));
          throw JavaResponse.fromDio(DioException(
              requestOptions: e.requestOptions,
              response: Response(requestOptions: e.requestOptions, statusCode: e.response?.statusCode, data: decoded)));
        } on FormatException {
          // Not JSON: fall through to the plain failure.
        }
      }
      throw JavaResponse.fromDio(e);
    }
  }

  Future<dynamic> _get(String path, Map<String, dynamic> query) async {
    try {
      final r = await _dio.get<dynamic>(path, queryParameters: {'companyId': _companyId(), ...query});
      return JavaResponse.data(r.data);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }

  Future<dynamic> _post(String path, [Map<String, dynamic> query = const {}]) async {
    try {
      final r = await _dio.post<dynamic>(path, queryParameters: {'companyId': _companyId(), ...query});
      return JavaResponse.data(r.data);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }
}
