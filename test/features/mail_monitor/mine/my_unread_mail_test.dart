import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/mailmonitor/mail_monitor_api.dart';
import 'package:maleva/core/mailmonitor/my_unread_models.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/features/mail_monitor/mine/my_unread_mail_cubit.dart';
import 'package:maleva/features/mail_monitor/mine/my_unread_mail_views.dart';
import 'package:maleva/features/mail_monitor/mine/push_route.dart';
import 'package:mocktail/mocktail.dart';

class _Api extends Mock implements MailMonitorApi {}

/// As the Java API sends it (ApiResponse Data1 already unwrapped by the API class).
Map<String, dynamic> javaMine({int total = 5, List<Map<String, dynamic>>? boxes, Map<String, dynamic>? notice}) => {
      'total': total,
      'mailboxes': boxes ??
          [
            {'mailboxId': 1, 'address': 'cs1@maleva.com.my', 'displayName': 'cs1', 'role': 'MEMBER', 'unread': 3,
              'oldestUnreadAt': '2026-10-06T01:35:00Z', 'level': 'AGEING', 'status': 'OK', 'lastCheckedAt': '2026-10-06T02:00:00Z', 'remindersOn': true},
            {'mailboxId': 2, 'address': 'shalini@maleva.com.my', 'displayName': 'shalini', 'role': 'OWNER', 'unread': 2,
              'oldestUnreadAt': '2026-10-06T01:50:00Z', 'level': 'NEW', 'status': 'OK', 'lastCheckedAt': '2026-10-06T02:00:00Z', 'remindersOn': false},
            {'mailboxId': 3, 'address': 'old@maleva.com.my', 'displayName': 'old', 'role': 'MEMBER', 'unread': 9,
              'oldestUnreadAt': '2026-01-01T00:00:00Z', 'level': null, 'status': 'ERROR', 'lastCheckedAt': null, 'remindersOn': true},
          ],
      'latestNotice': notice,
    };

void main() {
  group('MyUnreadMail model', () {
    test('reads the Java fields, sorts by unread and finds the oldest checked mail', () {
      final mail = MyUnreadMail.fromJava(javaMine(notice: {'id': 'n1', 'sentAt': '2026-10-06T01:58:00Z', 'title': 'You have 5 unread emails', 'body': 'cs1 3'}));
      expect(mail.total, 5);
      expect(mail.linked, isTrue);
      expect(mail.byUnread.map((m) => m.mailboxId), [3, 1, 2]);
      expect(mail.oldest, DateTime.parse('2026-10-06T01:35:00Z').toLocal());
      expect(mail.mailboxes[1].remindersOn, isFalse);
      expect(mail.mailboxes[2].checked, isFalse);
      expect(mail.latestNotice!.title, 'You have 5 unread emails');
      expect(MyUnreadMail.fromJava({'total': 0, 'mailboxes': [], 'latestNotice': null}).linked, isFalse);
    });
  });

  group('push routing', () {
    test('only the unread-mail notice opens a screen', () {
      expect(routeForPush({'type': 'MAIL_UNREAD', 'total': '5'}), myUnreadMailPath);
      expect(routeForPush({'type': 'PLANNING'}), isNull);
      expect(routeForPush(null), isNull);
      expect(routeForPayload('MAIL_UNREAD'), myUnreadMailPath);
      expect(routeForPayload(''), isNull);
      PendingPushRoute.value = myUnreadMailPath;
      expect(PendingPushRoute.take(), myUnreadMailPath);
      expect(PendingPushRoute.take(), isNull);
    });
  });

  group('MyUnreadMailCubit', () {
    late _Api api;
    setUp(() => api = _Api());

    test('loads, keeps the last numbers on a failure, and reloads when a notice arrives', () async {
      final signals = StreamController<void>.broadcast();
      when(() => api.myUnread()).thenAnswer((_) async => MyUnreadMail.fromJava(javaMine()));
      final cubit = MyUnreadMailCubit(api, signals: signals.stream);
      await cubit.load();
      expect(cubit.state.mail!.total, 5);

      when(() => api.myUnread()).thenThrow(const ApiFailure('Server down', statusCode: 503));
      await cubit.load();
      expect(cubit.state.mail!.total, 5);
      expect(cubit.state.error, isNull);

      when(() => api.myUnread()).thenAnswer((_) async => MyUnreadMail.fromJava(javaMine(total: 0, boxes: [])));
      signals.add(null);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.mail!.linked, isFalse);
      await cubit.close();
      await signals.close();
    });

    test('a driver or a failure with no numbers keeps nothing on screen', () async {
      when(() => api.myUnread()).thenThrow(const ApiFailure('Unread mail is for employees', statusCode: 403));
      final cubit = MyUnreadMailCubit(api, signals: const Stream.empty());
      await cubit.load();
      expect(cubit.state.mail, isNull);
      expect(cubit.state.error, contains('employees'));
      await cubit.close();
    });
  });

  group('My unread mail screen', () {
    testWidgets('the screen lists each mailbox with its count', (tester) async {
      final api = _Api();
      when(() => api.myUnread()).thenAnswer((_) async => MyUnreadMail.fromJava(javaMine()));
      await tester.pumpWidget(MaterialApp(home: MyUnreadMailPage(api: api)));
      await tester.pump();
      expect(find.text('5 unread'), findsOneWidget);
      expect(find.text('cs1@maleva.com.my'), findsOneWidget);
      expect(find.textContaining('reminders off'), findsOneWidget);
      expect(find.textContaining('Could not be checked'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });
  });
}
