import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/mailmonitor/mail_monitor_models.dart';
import 'package:maleva/core/theme/status_tone.dart';

/// How a mailbox's state looks: colour tone AND words AND icon, never colour alone.
class LevelLook {
  const LevelLook(this.label, this.tone, this.icon, {this.hint});

  final String label;
  final StatusTone tone;
  final IconData icon;
  final String? hint;
}

LevelLook lookOf(MailboxRow row) {
  if (row.status == 'OK') {
    switch (row.level) {
      case 'CLEAR':
        return const LevelLook('Clear', StatusTone.success, Icons.check_circle_outline);
      case 'NEW':
        return const LevelLook('New mail', StatusTone.info, Icons.mail_outline);
      case 'AGEING':
        return const LevelLook('Ageing', StatusTone.warning, Icons.schedule);
      case 'OVERDUE':
        return const LevelLook('Overdue', StatusTone.danger, Icons.warning_amber_rounded);
    }
  }
  switch (row.status) {
    case 'AUTH_FAILED':
      return const LevelLook('Login failed', StatusTone.neutral, Icons.lock_outline,
          hint: 'Password changed? Replace it in Mailbox Monitor settings on the web.');
    case 'ERROR':
      return const LevelLook('Check failed', StatusTone.neutral, Icons.error_outline);
    case 'NO_SECRET':
      return const LevelLook('No password', StatusTone.neutral, Icons.key_outlined,
          hint: 'Set the mailbox password in Mailbox Monitor settings on the web.');
    case 'DISABLED':
      return const LevelLook('Off', StatusTone.neutral, Icons.power_settings_new);
    default:
      return const LevelLook('Waiting for first check', StatusTone.neutral, Icons.hourglass_empty);
  }
}

const _rank = {'Overdue': 0, 'Login failed': 1, 'Check failed': 1, 'Ageing': 2, 'New mail': 3, 'No password': 4};

/// Overdue and broken mailboxes first, then the oldest unread, then the most unread.
List<MailboxRow> attentionFirst(List<MailboxRow> rows) {
  final copy = [...rows];
  int rank(MailboxRow r) => _rank[lookOf(r).label] ?? 9;
  int oldest(MailboxRow r) => r.oldestUnreadAt?.millisecondsSinceEpoch ?? 1 << 62;
  copy.sort((a, b) {
    final byRank = rank(a).compareTo(rank(b));
    if (byRank != 0) return byRank;
    final byOldest = oldest(a).compareTo(oldest(b));
    if (byOldest != 0) return byOldest;
    final byUnread = (b.unread ?? 0).compareTo(a.unread ?? 0);
    return byUnread != 0 ? byUnread : a.address.compareTo(b.address);
  });
  return copy;
}

/// "6 h 32 m", "45 m", "99 d 18 h"; "—" when unknown.
String ageText(DateTime? since, DateTime now) {
  if (since == null) return '—';
  final m = now.difference(since).inMinutes;
  if (m < 1) return 'just now';
  if (m < 60) return '$m m';
  if (m < 24 * 60) return '${m ~/ 60} h ${m % 60} m';
  return '${m ~/ (24 * 60)} d ${(m ~/ 60) % 24} h';
}

/// "6 Oct 2026, 11:26" in the phone's time zone; "—" when unknown.
String dateTimeText(DateTime? t) => t == null ? '—' : DateFormat('d MMM yyyy, HH:mm').format(t);

/// "1.2 MB", "340 KB", "900 B".
String sizeText(int bytes) {
  if (bytes <= 0) return '';
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).round()} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

String countText(int n) => NumberFormat.decimalPattern().format(n);
