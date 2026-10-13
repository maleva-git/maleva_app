import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/features/notifications/notification_routes.dart';

/// Colours of the notifications page, the bell and the banner.
class NoticeColors {
  NoticeColors._();

  /// The caller's own open vessel alert, "Not handled" notices, the bell's alert badge.
  static const Color alert = Color(0xFFD32F2F);

  /// A team member's escalated alert and the team banner.
  static const Color team = Color(0xFFE65100);

  static const Color reminder = Color(0xFFB26A00);
  static const Color reminderSurface = Color(0xFFFFF4D6);
  static const Color amberBanner = Color(0xFFFFC107);
  static const Color allClear = Color(0xFF2E7D32);
  static const Color forwarding = Color(0xFF00897B);
  static const Color vessel = Palette.blue700;
}

IconData iconForTone(NoticeTone tone) {
  switch (tone) {
    case NoticeTone.notHandled:
    case NoticeTone.reminder:
    case NoticeTone.vessel:
      return Icons.directions_boat_filled_rounded;
    case NoticeTone.linkNeeded:
      return Icons.link_rounded;
    case NoticeTone.ptpStale:
      return Icons.sync_problem_rounded;
    case NoticeTone.forwarding:
      return Icons.description_outlined;
    case NoticeTone.other:
      return Icons.notifications_none_rounded;
  }
}

Color colorForTone(NoticeTone tone, ColorScheme scheme) {
  switch (tone) {
    case NoticeTone.notHandled:
      return NoticeColors.alert;
    case NoticeTone.reminder:
      return NoticeColors.reminder;
    case NoticeTone.vessel:
    case NoticeTone.linkNeeded:
      return NoticeColors.vessel;
    case NoticeTone.ptpStale:
      return NoticeColors.alert;
    case NoticeTone.forwarding:
      return NoticeColors.forwarding;
    case NoticeTone.other:
      return scheme.onSurfaceVariant;
  }
}

bool sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

/// "just now", "5 min ago", "3 h ago", "Yesterday 14:20", "Mon 09:10", "12 Oct", "12 Oct 2025".
String relativeTime(DateTime? at, DateTime now) {
  if (at == null) return '';
  final d = now.difference(at);
  if (d.inMinutes < 1) return 'just now';
  if (d.inMinutes < 60 && sameDay(at, now)) return '${d.inMinutes} min ago';
  if (sameDay(at, now)) return '${d.inHours} h ago';
  if (sameDay(at, now.subtract(const Duration(days: 1)))) return 'Yesterday ${DateFormat('HH:mm').format(at)}';
  if (d.inDays < 7) return DateFormat('EEE HH:mm').format(at);
  return DateFormat(at.year == now.year ? 'd MMM' : 'd MMM yyyy').format(at);
}

/// A vessel alert's start: "09:29" today, else "13 Oct 09:29".
String sinceText(String? value, DateTime now) {
  final at = value == null ? null : DateTime.tryParse(value);
  if (at == null) return '-';
  return DateFormat(sameDay(at, now) ? 'HH:mm' : 'd MMM HH:mm').format(at);
}

String plural(int n, String one, [String? many]) => n == 1 ? '$n $one' : '$n ${many ?? '${one}s'}';
