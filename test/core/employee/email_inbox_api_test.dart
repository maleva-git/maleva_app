import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/employee/email_inbox_api.dart';
import 'package:maleva/core/network/api_failure.dart';

import '../network/java_api_client_test.dart' show QueueAdapter;

Map<String, dynamic> ok(Object? data) => {'IsSuccess': true, 'StatusCode': 200, 'Message': 'Success', 'Data1': data};

/// The staff email inbox on the shared Java API (email-inbox-on-shared-java-api).
void main() {
  late QueueAdapter adapter;
  late EmailInboxApi api;

  setUp(() {
    adapter = QueueAdapter();
    api = EmailInboxApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter, companyId: () => 6);
  });

  RequestOptions last() => adapter.requests.last;

  test('the unanswered mail reads in UTC and is kept back as UTC', () async {
    adapter.replies
      ..add((200, jsonEncode(ok({'employeeRefId': 15, 'employee': 'ANNA', 'emails': [
        {'subject': 'Quote', 'messageId': '<a@x>', 'emailId': '<a@x>', 'sender': 'Bob <bob@x>',
         'receivedDate': '2026-10-05T07:00:00', 'isUnread': true, 'isReplied': false, 'employeeRefId': 15, 'name': 'ANNA'}
      ]}))))
      ..add((200, jsonEncode(ok(1))));

    final mails = await api.unanswered(15);
    expect(last().uri.toString(), 'https://java.test/api/email-inboxes/unanswered?companyId=6&employeeId=15');
    final m = mails.single;
    expect([m.subject, m.emailId, m.isUnread, m.isReplied], ['Quote', '<a@x>', true, false]);
    expect(m.receivedDate, DateTime.utc(2026, 10, 5, 7));

    expect(await api.keep(15, mails), 1);
    expect(last().uri.toString(), 'https://java.test/api/email-inboxes/entries?companyId=6');
    expect(last().data, [{'id': 0, 'employeeRefId': 15, 'emailId': '<a@x>', 'subject': 'Quote', 'sender': 'Bob <bob@x>',
      'receivedDate': '2026-10-05T07:00:00', 'isUnread': 1, 'isReplied': 0, 'active': 1}]);
  });

  test('a refused login is the server message', () async {
    adapter.replies.add((400, jsonEncode({'status': 400, 'message': 'Authentication failed. Please check App Password and 2FA settings.'})));
    expect(() => api.unanswered(15),
        throwsA(isA<ApiFailure>().having((f) => f.message, 'message', startsWith('Authentication failed'))));
  });
}
