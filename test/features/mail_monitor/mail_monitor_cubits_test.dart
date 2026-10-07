import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/mailmonitor/mail_monitor_api.dart';
import 'package:maleva/core/mailmonitor/mail_monitor_models.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/features/mail_monitor/bloc/mailbox_list_cubit.dart';
import 'package:maleva/features/mail_monitor/bloc/unread_mail_cubit.dart';
import 'package:maleva/features/mail_monitor/view/level_look.dart';
import 'package:maleva/features/mail_monitor/view/mail_monitor_tab.dart';
import 'package:mocktail/mocktail.dart';

class _Api extends Mock implements MailMonitorApi {}

const _summary = MailMonitorSummary(totalUnread: 3, withUnread: 1, overdue: 0, errors: 0, mailboxes: 1, lastFullCheckAt: null);

MailboxRow row(int id, {String status = 'OK', String? level = 'CLEAR', int? unread = 0, DateTime? oldest}) => MailboxRow(
      id: id,
      address: 'box$id@maleva.com.my',
      displayName: 'Box $id',
      kind: 'SHARED',
      department: null,
      enabled: true,
      warnMinutes: 60,
      overdueMinutes: 240,
      members: const [],
      credentialSet: true,
      unread: unread,
      oldestUnreadAt: oldest,
      newestUnreadAt: null,
      lastCheckedAt: null,
      status: status,
      level: level,
      errorMessage: null,
    );

PreviewItem item(int uid) => PreviewItem(uid: uid, sender: 's$uid', subject: 'Subject $uid', receivedAt: null);

void main() {
  late _Api api;
  setUp(() => api = _Api());

  group('MailboxListCubit', () {
    test('loads the list, and a failure with no list shows the server message', () async {
      when(() => api.mailboxes()).thenAnswer((_) async => MailboxList(summary: _summary, mailboxes: [row(1)]));
      final cubit = MailboxListCubit(api);
      await cubit.load();
      expect(cubit.state.list!.mailboxes.single.id, 1);

      when(() => api.mailboxes()).thenThrow(const ApiFailure('Only the Super Admin can use the mailbox monitor', statusCode: 403));
      final refused = MailboxListCubit(api);
      await refused.load();
      expect(refused.state.list, isNull);
      expect(refused.state.error, contains('Super Admin'));
      await cubit.close();
      await refused.close();
    });

    test('a failed refresh keeps the shown list and says why', () async {
      when(() => api.mailboxes()).thenAnswer((_) async => MailboxList(summary: _summary, mailboxes: [row(1)]));
      final cubit = MailboxListCubit(api);
      await cubit.load();
      when(() => api.mailboxes()).thenThrow(const ApiFailure('Server error occurred.'));
      await cubit.load();
      expect(cubit.state.list, isNotNull);
      expect(cubit.state.notice, 'Server error occurred.');
      await cubit.close();
    });

    test('check now while a check runs shows the 409 message', () async {
      when(() => api.checkNow()).thenThrow(const ApiFailure('A check is already running.', statusCode: 409));
      final cubit = MailboxListCubit(api);
      await cubit.checkNow();
      expect(cubit.state.notice, 'A check is already running.');
      await cubit.close();
    });
  });

  group('UnreadMailCubit', () {
    test('scrolling asks for the next page and appends it; a search restarts at page 0', () async {
      when(() => api.unread(7, page: 0, size: 50, query: '')).thenAnswer(
          (_) async => UnreadPage(total: 120, page: 0, size: 50, items: [for (var i = 0; i < 50; i++) item(1000 - i)]));
      when(() => api.unread(7, page: 1, size: 50, query: '')).thenAnswer(
          (_) async => UnreadPage(total: 120, page: 1, size: 50, items: [for (var i = 50; i < 100; i++) item(1000 - i)]));
      when(() => api.unread(7, page: 0, size: 50, query: 'LYRIC POET'))
          .thenAnswer((_) async => UnreadPage(total: 1, page: 0, size: 50, items: [item(5)]));

      final cubit = UnreadMailCubit(api, 7);
      await cubit.search('');
      await cubit.loadMore();
      expect(cubit.state.items, hasLength(100));
      expect(cubit.state.items[50].uid, 950);
      expect(cubit.state.hasMore, isTrue);

      await cubit.search(' LYRIC POET ');
      expect(cubit.state.items.single.uid, 5);
      expect(cubit.state.hasMore, isFalse);
      await cubit.close();
    });
  });

  group('looks and order', () {
    test('only the Super Admin gets the tab', () {
      expect(mailMonitorAllowed(100), isTrue);
      expect(mailMonitorAllowed(200), isFalse);
      expect(mailMonitorAllowed(500), isFalse);
    });

    test('every state has words and an icon, and an unknown status is neutral', () {
      expect(lookOf(row(1, level: 'OVERDUE')).label, 'Overdue');
      expect(lookOf(row(1, status: 'AUTH_FAILED', level: null)).hint, contains('web'));
      expect(lookOf(row(1, status: 'SOMETHING_NEW', level: null)).label, 'Waiting for first check');
    });

    test('overdue and broken mailboxes come first', () {
      final now = DateTime(2026, 10, 7, 12);
      final sorted = attentionFirst([
        row(1),
        row(2, level: 'AGEING', unread: 2, oldest: now.subtract(const Duration(hours: 2))),
        row(3, level: 'OVERDUE', unread: 9, oldest: now.subtract(const Duration(hours: 6))),
        row(4, status: 'AUTH_FAILED', level: null, unread: null),
      ]);
      expect(sorted.map((r) => r.id), [3, 4, 2, 1]);
    });

    test('ages and dates read the way the web shows them', () {
      final now = DateTime(2026, 10, 7, 12);
      expect(ageText(now.subtract(const Duration(minutes: 392)), now), '6 h 32 m');
      expect(ageText(now.subtract(const Duration(days: 99, hours: 18)), now), '99 d 18 h');
      expect(dateTimeText(DateTime(2026, 10, 6, 11, 26)), '6 Oct 2026, 11:26');
      expect(sizeText(245760), '240 KB');
    });
  });
}
