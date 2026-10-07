import 'package:maleva/core/utils/json_read.dart';

/// The shared Java `/api/mail-monitor` shapes (backend change add-mail-monitor), read as the
/// server sends them. Times are ISO-8601 UTC strings, parsed to local [DateTime]s. No shape
/// carries a mailbox password.

DateTime? _time(dynamic v) {
  final s = JsonRead.stringOrNull(v);
  return s == null ? null : DateTime.tryParse(s)?.toLocal();
}

class MailboxMember {
  const MailboxMember({required this.employeeId, required this.name, required this.role, required this.active});

  factory MailboxMember.fromJava(Map<String, dynamic> m) => MailboxMember(
        employeeId: JsonRead.integer(m['employeeId']),
        name: JsonRead.string(m['name']),
        role: JsonRead.string(m['role']),
        active: JsonRead.boolean(m['active']),
      );

  final int employeeId;
  final String name;

  /// OWNER or MEMBER. Owners get the reminder emails.
  final String role;
  final bool active;

  bool get isOwner => role == 'OWNER';
}

class MailboxRow {
  const MailboxRow({
    required this.id,
    required this.address,
    required this.displayName,
    required this.kind,
    required this.department,
    required this.enabled,
    required this.warnMinutes,
    required this.overdueMinutes,
    required this.members,
    required this.credentialSet,
    required this.unread,
    required this.oldestUnreadAt,
    required this.newestUnreadAt,
    required this.lastCheckedAt,
    required this.status,
    required this.level,
    required this.errorMessage,
  });

  factory MailboxRow.fromJava(Map<String, dynamic> m) => MailboxRow(
        id: JsonRead.integer(m['id']),
        address: JsonRead.string(m['address']),
        displayName: JsonRead.string(m['displayName']),
        kind: JsonRead.string(m['kind']),
        department: JsonRead.stringOrNull(m['department']),
        enabled: JsonRead.boolean(m['enabled']),
        warnMinutes: JsonRead.integer(m['warnMinutes'], fallback: 60),
        overdueMinutes: JsonRead.integer(m['overdueMinutes'], fallback: 240),
        members: JsonRead.listOfMaps(m['members']).map(MailboxMember.fromJava).toList(),
        credentialSet: JsonRead.boolean(m['credentialSet']),
        unread: JsonRead.intOrNull(m['unread']),
        oldestUnreadAt: _time(m['oldestUnreadAt']),
        newestUnreadAt: _time(m['newestUnreadAt']),
        lastCheckedAt: _time(m['lastCheckedAt']),
        status: JsonRead.string(m['status']),
        level: JsonRead.stringOrNull(m['level']),
        errorMessage: JsonRead.stringOrNull(m['errorMessage']),
      );

  final int id;
  final String address;
  final String displayName;
  final String kind;
  final String? department;
  final bool enabled;
  final int warnMinutes;
  final int overdueMinutes;
  final List<MailboxMember> members;
  final bool credentialSet;
  final int? unread;
  final DateTime? oldestUnreadAt;
  final DateTime? newestUnreadAt;
  final DateTime? lastCheckedAt;

  /// OK, AUTH_FAILED, ERROR, NO_SECRET, DISABLED or PENDING. Any other value is shown neutral.
  final String status;

  /// CLEAR, NEW, AGEING, OVERDUE, or null when the last check did not succeed.
  final String? level;
  final String? errorMessage;

  List<MailboxMember> get activeOwners => members.where((m) => m.isOwner && m.active).toList();
}

class MailMonitorSummary {
  const MailMonitorSummary({
    required this.totalUnread,
    required this.withUnread,
    required this.overdue,
    required this.errors,
    required this.mailboxes,
    required this.lastFullCheckAt,
  });

  factory MailMonitorSummary.fromJava(Map<String, dynamic> m) => MailMonitorSummary(
        totalUnread: JsonRead.integer(m['totalUnread']),
        withUnread: JsonRead.integer(m['withUnread']),
        overdue: JsonRead.integer(m['overdue']),
        errors: JsonRead.integer(m['errors']),
        mailboxes: JsonRead.integer(m['mailboxes']),
        lastFullCheckAt: _time(m['lastFullCheckAt']),
      );

  final int totalUnread;
  final int withUnread;
  final int overdue;
  final int errors;
  final int mailboxes;
  final DateTime? lastFullCheckAt;
}

class MailboxList {
  const MailboxList({required this.summary, required this.mailboxes});

  factory MailboxList.fromJava(Map<String, dynamic> m) => MailboxList(
        summary: MailMonitorSummary.fromJava(JsonRead.map(m['summary'])),
        mailboxes: JsonRead.listOfMaps(m['mailboxes']).map(MailboxRow.fromJava).toList(),
      );

  final MailMonitorSummary summary;
  final List<MailboxRow> mailboxes;
}

/// Sender, subject and time of one unread mail; [uid] opens it (0 when the server gave none).
class PreviewItem {
  const PreviewItem({required this.uid, required this.sender, required this.subject, required this.receivedAt});

  factory PreviewItem.fromJava(Map<String, dynamic> m) => PreviewItem(
        uid: JsonRead.integer(m['uid']),
        sender: JsonRead.string(m['sender']),
        subject: JsonRead.string(m['subject']),
        receivedAt: _time(m['receivedAt']),
      );

  final int uid;
  final String sender;
  final String subject;
  final DateTime? receivedAt;
}

class UnreadPage {
  const UnreadPage({required this.total, required this.page, required this.size, required this.items});

  factory UnreadPage.fromJava(Map<String, dynamic> m) => UnreadPage(
        total: JsonRead.integer(m['total']),
        page: JsonRead.integer(m['page']),
        size: JsonRead.integer(m['size'], fallback: 50),
        items: JsonRead.listOfMaps(m['items']).map(PreviewItem.fromJava).toList(),
      );

  final int total;
  final int page;
  final int size;
  final List<PreviewItem> items;
}

class MailAttachment {
  const MailAttachment({required this.name, required this.contentType, required this.size});

  factory MailAttachment.fromJava(Map<String, dynamic> m) => MailAttachment(
        name: JsonRead.string(m['name']),
        contentType: JsonRead.string(m['contentType']),
        size: JsonRead.integer(m['size']),
      );

  final String name;
  final String contentType;
  final int size;
}

/// One opened mail. It stays unread in the mailbox; the server records that it was opened.
class MailMessage {
  const MailMessage({
    required this.uid,
    required this.from,
    required this.to,
    required this.cc,
    required this.subject,
    required this.sentAt,
    required this.receivedAt,
    required this.html,
    required this.text,
    required this.truncated,
    required this.attachments,
  });

  factory MailMessage.fromJava(Map<String, dynamic> m) => MailMessage(
        uid: JsonRead.integer(m['uid']),
        from: JsonRead.string(m['from']),
        to: JsonRead.string(m['to']),
        cc: JsonRead.string(m['cc']),
        subject: JsonRead.string(m['subject']),
        sentAt: _time(m['sentAt']),
        receivedAt: _time(m['receivedAt']),
        html: JsonRead.stringOrNull(m['html']),
        text: JsonRead.stringOrNull(m['text']),
        truncated: JsonRead.boolean(m['truncated']),
        attachments: JsonRead.listOfMaps(m['attachments']).map(MailAttachment.fromJava).toList(),
      );

  final int uid;
  final String from;
  final String to;
  final String cc;
  final String subject;
  final DateTime? sentAt;
  final DateTime? receivedAt;
  final String? html;
  final String? text;
  final bool truncated;
  final List<MailAttachment> attachments;
}

class ReminderResult {
  const ReminderResult({required this.sentTo, required this.nextAllowedAt});

  factory ReminderResult.fromJava(Map<String, dynamic> m) => ReminderResult(
        sentTo: (m['sentTo'] is List ? m['sentTo'] as List : const []).map((e) => '$e').toList(),
        nextAllowedAt: _time(m['nextAllowedAt']),
      );

  final List<String> sentTo;
  final DateTime? nextAllowedAt;
}
