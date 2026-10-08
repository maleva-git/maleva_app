import 'package:maleva/core/utils/json_read.dart';

/// The shared Java `/api/mail-monitor/my-unread` shape (backend change add-my-unread-mail-notice), read as
/// the server sends it: the signed-in employee's linked mailboxes, counts and times only.

DateTime? _time(dynamic v) {
  final s = JsonRead.stringOrNull(v);
  return s == null ? null : DateTime.tryParse(s)?.toLocal();
}

class MyMailbox {
  const MyMailbox({
    required this.mailboxId,
    required this.address,
    required this.displayName,
    required this.role,
    required this.unread,
    required this.oldestUnreadAt,
    required this.level,
    required this.status,
    required this.remindersOn,
  });

  factory MyMailbox.fromJava(Map<String, dynamic> m) => MyMailbox(
        mailboxId: JsonRead.integer(m['mailboxId']),
        address: JsonRead.string(m['address']),
        displayName: JsonRead.string(m['displayName']),
        role: JsonRead.string(m['role']),
        unread: JsonRead.intOrNull(m['unread']),
        oldestUnreadAt: _time(m['oldestUnreadAt']),
        level: JsonRead.stringOrNull(m['level']),
        status: JsonRead.stringOrNull(m['status']) ?? 'PENDING',
        remindersOn: JsonRead.boolean(m['remindersOn']),
      );

  final int mailboxId;
  final String address;
  final String displayName;

  /// OWNER or MEMBER.
  final String role;

  /// Null before the first check.
  final int? unread;
  final DateTime? oldestUnreadAt;

  /// CLEAR, NEW, AGEING or OVERDUE at the last check.
  final String? level;

  /// OK, ERROR, AUTH_FAILED, NO_SECRET or PENDING.
  final String status;
  final bool remindersOn;

  bool get checked => status == 'OK';
}

class LatestNotice {
  const LatestNotice({required this.id, required this.sentAt, required this.title, required this.body});

  factory LatestNotice.fromJava(Map<String, dynamic> m) => LatestNotice(
        id: JsonRead.string(m['id']),
        sentAt: _time(m['sentAt']),
        title: JsonRead.string(m['title']),
        body: JsonRead.string(m['body']),
      );

  final String id;
  final DateTime? sentAt;
  final String title;
  final String body;
}

class MyUnreadMail {
  const MyUnreadMail({required this.total, required this.mailboxes, required this.latestNotice});

  factory MyUnreadMail.fromJava(Map<String, dynamic> m) {
    final notice = m['latestNotice'];
    return MyUnreadMail(
      total: JsonRead.integer(m['total']),
      mailboxes: JsonRead.listOfMaps(m['mailboxes']).map(MyMailbox.fromJava).toList(),
      latestNotice: notice is Map ? LatestNotice.fromJava(JsonRead.map(notice)) : null,
    );
  }

  /// Unread mail in the mailboxes whose last check was OK.
  final int total;
  final List<MyMailbox> mailboxes;
  final LatestNotice? latestNotice;

  bool get linked => mailboxes.isNotEmpty;

  /// The oldest unread mail over the checked mailboxes.
  DateTime? get oldest {
    DateTime? out;
    for (final m in mailboxes) {
      final t = m.oldestUnreadAt;
      if (m.checked && (m.unread ?? 0) > 0 && t != null && (out == null || t.isBefore(out))) out = t;
    }
    return out;
  }

  /// Mailboxes with mail first, most unread first, then by address.
  List<MyMailbox> get byUnread => [...mailboxes]
    ..sort((a, b) {
      final c = (b.unread ?? -1).compareTo(a.unread ?? -1);
      return c != 0 ? c : a.address.compareTo(b.address);
    });
}
