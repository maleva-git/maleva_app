import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/mailmonitor/mail_monitor_api.dart';
import 'package:maleva/core/mailmonitor/mail_monitor_models.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/features/mail_monitor/view/mail_message_page.dart';
import 'package:maleva/features/mail_monitor/view/mail_monitor_tab.dart';
import 'package:maleva/features/mail_monitor/view/mailbox_detail_page.dart';
import 'package:mocktail/mocktail.dart';

import 'mail_monitor_cubits_test.dart' show row;

class _Api extends Mock implements MailMonitorApi {}

Widget app(Widget child) => MaterialApp(theme: ThemeData(useMaterial3: true), home: Scaffold(body: child));

void main() {
  late _Api api;
  setUp(() => api = _Api());

  testWidgets('the tab shows the summary and puts the overdue mailbox first', (tester) async {
    when(() => api.mailboxes()).thenAnswer((_) async => MailboxList(
          summary: const MailMonitorSummary(totalUnread: 20661, withUnread: 1, overdue: 1, errors: 0, mailboxes: 2, lastFullCheckAt: null),
          mailboxes: [row(1), row(2, level: 'OVERDUE', unread: 20661, oldest: DateTime.now().subtract(const Duration(days: 99)))],
        ));
    await tester.pumpWidget(app(MailMonitorTab(api: api)));
    await tester.pump();

    expect(find.text('20,661'), findsWidgets);
    expect(find.text('Overdue'), findsWidgets);
    final first = tester.getTopLeft(find.text('box2@maleva.com.my')).dy;
    final second = tester.getTopLeft(find.text('box1@maleva.com.my')).dy;
    expect(first, lessThan(second));
    await tester.pumpWidget(const SizedBox()); // closes the cubit and its refresh timer
  });

  testWidgets('a refused list shows the server message', (tester) async {
    when(() => api.mailboxes()).thenThrow(const ApiFailure('Mail monitor key: mail.monitor.key is not set.', statusCode: 503));
    await tester.pumpWidget(app(MailMonitorTab(api: api)));
    await tester.pump();

    expect(find.text('Mailbox Monitor is not available'), findsOneWidget);
    expect(find.textContaining('not set'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('no owner: no reminder button, a hint to add one on the web', (tester) async {
    when(() => api.preview(2)).thenAnswer((_) async => const []);
    await tester.pumpWidget(MaterialApp(home: MailboxDetailPage(row: row(2, level: 'OVERDUE', unread: 9), api: api)));
    await tester.pump();

    expect(find.textContaining('Add an owner'), findsOneWidget);
    expect(find.textContaining('Email '), findsNothing);
    expect(find.text('View all unread (9)'), findsOneWidget);
  });

  testWidgets('an HTML-only mail is shown as text, with attachment names and the read-only note', (tester) async {
    when(() => api.message(1, 41)).thenAnswer((_) async => MailMessage(
          uid: 41,
          from: 'ops <ops@anchormarine.com.sg>',
          to: 'cs1@maleva.com.my',
          cc: '',
          subject: 'RE: MV KURT PAUL',
          sentAt: DateTime(2026, 10, 6, 11, 22),
          receivedAt: DateTime(2026, 10, 6, 11, 22),
          html: '<p>Please confirm the <b>ETA</b>.</p><script>alert(1)</script><img src="https://tracker.example/p.gif">',
          text: null,
          truncated: false,
          attachments: const [MailAttachment(name: 'Delivery note.pdf', contentType: 'application/pdf', size: 245760)],
        ));
    await tester.pumpWidget(MaterialApp(home: MailMessagePage(api: api, mailboxId: 1, uid: 41)));
    await tester.pump();

    expect(find.text('Please confirm the ETA.'), findsOneWidget);
    expect(find.textContaining('alert'), findsNothing);
    expect(find.textContaining('tracker'), findsNothing);
    expect(find.text('Delivery note.pdf · 240 KB'), findsOneWidget);
    expect(find.text('6 Oct 2026, 11:22'), findsNWidgets(2));
    expect(find.textContaining('Stays unread'), findsOneWidget);
  });

  testWidgets('a mail that is gone shows the server message', (tester) async {
    when(() => api.message(1, 41)).thenThrow(const ApiFailure('This mail is no longer in the inbox', statusCode: 404));
    await tester.pumpWidget(MaterialApp(home: MailMessagePage(api: api, mailboxId: 1, uid: 41)));
    await tester.pump();

    expect(find.text('This mail is no longer in the inbox'), findsOneWidget);
  });
}
