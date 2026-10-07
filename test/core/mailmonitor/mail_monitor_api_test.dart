import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/mailmonitor/mail_monitor_api.dart';
import 'package:maleva/core/network/api_failure.dart';

import '../network/java_api_client_test.dart' show QueueAdapter;

Map<String, dynamic> ok(Object? data) => {'IsSuccess': true, 'StatusCode': 200, 'Message': 'Success', 'Data1': data};
Map<String, dynamic> refused(String message, int status) => {'IsSuccess': false, 'StatusCode': status, 'Message': message};

const mailboxJson = {
  'id': 1,
  'address': 'cs1@maleva.com.my',
  'displayName': 'customerservice cs1',
  'kind': 'PERSONAL',
  'department': 'cs1',
  'enabled': true,
  'warnMinutes': 60,
  'overdueMinutes': 240,
  'members': [
    {'employeeId': 10, 'name': 'SIVASANKARI.K', 'role': 'OWNER', 'getsReminders': true, 'active': true},
  ],
  'credentialSet': true,
  'credentialSetAt': '2026-10-06T03:29:00Z',
  'unread': 20661,
  'oldestUnreadAt': '2026-06-28T09:00:00Z',
  'newestUnreadAt': '2026-10-06T03:41:00Z',
  'lastCheckedAt': '2026-10-06T03:47:00Z',
  'lastOkAt': '2026-10-06T03:47:00Z',
  'status': 'OK',
  'level': 'OVERDUE',
  'errorMessage': null,
};

/// The Mailbox Monitor on the shared Java API (mail-monitor-on-shared-java-api).
void main() {
  late QueueAdapter adapter;
  late MailMonitorApi api;

  setUp(() {
    adapter = QueueAdapter();
    api = MailMonitorApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter, companyId: () => 6);
  });

  String lastUrl() => adapter.requests.last.uri.toString();

  test('the list sends the company and reads the Java summary and rows', () async {
    adapter.replies.add((200, jsonEncode(ok({
      'summary': {'totalUnread': 20661, 'withUnread': 1, 'overdue': 1, 'errors': 0, 'mailboxes': 1, 'lastFullCheckAt': '2026-10-06T03:47:00Z'},
      'mailboxes': [mailboxJson],
    }))));

    final list = await api.mailboxes();

    expect(lastUrl(), 'https://java.test/api/mail-monitor/mailboxes?companyId=6');
    expect(list.summary.totalUnread, 20661);
    expect(list.mailboxes.single.address, 'cs1@maleva.com.my');
    expect(list.mailboxes.single.level, 'OVERDUE');
    expect(list.mailboxes.single.activeOwners.single.name, 'SIVASANKARI.K');
  });

  test('the unread page sends page, size and the search, and leaves out an empty search', () async {
    adapter.replies
      ..add((200, jsonEncode(ok({'total': 120, 'page': 1, 'size': 50, 'items': [{'uid': 950, 'sender': 'a@x.com', 'subject': 'Hi', 'receivedAt': '2026-10-06T03:20:00Z'}]}))))
      ..add((200, jsonEncode(ok({'total': 0, 'page': 0, 'size': 50, 'items': []}))));

    final page = await api.unread(1, page: 1);
    expect(lastUrl(), 'https://java.test/api/mail-monitor/mailboxes/1/unread?companyId=6&page=1&size=50');
    expect(page.items.single.uid, 950);

    await api.unread(1, query: '  LYRIC POET ');
    expect(adapter.requests.last.uri.queryParameters['q'], 'LYRIC POET');
  });

  test('preview, message, remind and check-now use the shared endpoints', () async {
    adapter.replies
      ..add((200, jsonEncode(ok({'mailboxId': 1, 'checkedAt': null, 'items': [{'uid': 41, 'sender': 'ops', 'subject': 'RE: MV KURT PAUL', 'receivedAt': null}]}))))
      ..add((200, jsonEncode(ok({'uid': 41, 'from': 'ops', 'to': 'cs1@maleva.com.my', 'cc': '', 'subject': 'RE: MV KURT PAUL',
          'sentAt': null, 'receivedAt': null, 'html': null, 'text': 'Hello', 'truncated': false,
          'attachments': [{'name': 'note.pdf', 'contentType': 'application/pdf', 'size': 245760}]}))))
      ..add((200, jsonEncode(ok({'sentTo': ['cs1@maleva.com.my'], 'nextAllowedAt': '2026-10-06T04:17:00Z'}))))
      ..add((202, jsonEncode(ok(null))));

    expect((await api.preview(1)).single.subject, 'RE: MV KURT PAUL');
    expect(lastUrl(), 'https://java.test/api/mail-monitor/mailboxes/1/unread-preview?companyId=6');
    final m = await api.message(1, 41);
    expect(lastUrl(), 'https://java.test/api/mail-monitor/mailboxes/1/messages/41?companyId=6');
    expect(m.attachments.single.name, 'note.pdf');
    expect((await api.remind(1)).sentTo, ['cs1@maleva.com.my']);
    expect(adapter.requests.last.method, 'POST');
    expect(lastUrl(), 'https://java.test/api/mail-monitor/mailboxes/1/remind?companyId=6');
    await api.checkNow();
    expect(lastUrl(), 'https://java.test/api/mail-monitor/check-now?companyId=6');
  });

  test('a refusal keeps the server message and status', () async {
    adapter.replies
      ..add((403, jsonEncode(refused('Only the Super Admin can use the mailbox monitor', 403))))
      ..add((429, jsonEncode(refused('A reminder was sent recently.', 429))))
      ..add((503, jsonEncode(refused('Mail monitor key: mail.monitor.key is not set.', 503))))
      ..add((404, jsonEncode(refused('This mail is no longer in the inbox', 404))));

    Future<ApiFailure> failure(Future<Object?> call) async {
      try {
        await call;
      } on ApiFailure catch (e) {
        return e;
      }
      fail('expected an ApiFailure');
    }

    expect((await failure(api.mailboxes())).statusCode, 403);
    expect((await failure(api.remind(1))).message, 'A reminder was sent recently.');
    expect((await failure(api.mailboxes())).message, contains('not set'));
    expect((await failure(api.message(1, 41))).message, 'This mail is no longer in the inbox');
  });
}
