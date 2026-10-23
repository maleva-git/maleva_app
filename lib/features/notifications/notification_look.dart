import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/employee_notifications/employee_notifications_models.dart';
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/vessel_changes/vessel_changes_models.dart';
import 'package:maleva/features/notifications/notification_routes.dart';

/// Colours of the notifications page and the bell. The Vessel tab is calm (owner, 2026-10-13, "not
/// make noise"): an alert row's only colour is a thin left border ([alertToneOf]).
class NoticeColors {
  NoticeColors._();

  /// The caller's own open vessel alert, system problem notices, the ship's alert badge, the bell's badge.
  static const Color alert = Color(0xFFD32F2F);

  /// Amber: a team member's escalated alert (its row's border), unread vessel notices (the ship's badge).
  static const Color reminder = Color(0xFFB26A00);
  static const Color forwarding = Color(0xFF00897B);

  /// Purple, as a driver on leave shows in the Planning and RTI pickers.
  static const Color leave = Color(0xFF7B1FA2);

  /// Blue: a LINK alert's border, the unread dot.
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
    case NoticeTone.leave:
      return Icons.event_busy_rounded;
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
    case NoticeTone.leave:
      return NoticeColors.leave;
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

String plural(int n, String one, [String? many]) => n == 1 ? '$n $one' : '$n ${many ?? '${one}s'}';

/// Alert rows shown before "Show all N" and vessel notices before "Show all" (as on the web).
const int firstVesselRows = 5;

/// A vessel alert row's only colour, its thin left border (web `vesselAlertTone`): blue for a job to
/// link, red for the caller's own alert, amber for a team member's escalated one.
Color alertToneOf(VesselAlert alert) {
  if (alert.isLink) return NoticeColors.vessel;
  // omitted: the caller's own is red like an ETA alert (pinned, needs action), a team member's amber
  return alert.mine ? NoticeColors.alert : NoticeColors.reminder;
}

/// A team member's name for an escalated alert (web `vesselAlertTeamName`); null for the caller's own,
/// for "No employee" and when the server sent none.
String? alertTeamName(VesselAlert alert) {
  if (alert.mine || alert.unassigned) return null;
  final name = alert.employeeName?.trim() ?? '';
  return name.isEmpty ? null : name;
}

/// A PTP time (`yyyy-MM-dd'T'HH:mm`) as "19 Oct 00:00" (web `formatPtpTime`); '' for none, the value
/// as it is when unreadable.
String ptpTimeText(String? value) {
  if (value == null || value.trim().isEmpty) return '';
  final at = DateTime.tryParse(value.trim());
  if (at == null) return value;
  return DateFormat(value.contains(RegExp('[T ]')) ? 'd MMM HH:mm' : 'd MMM').format(at);
}

/// "21 Oct 16:00 (est.)" (web `vesselAlertArrival`); '' when PTP gave no arrival.
String alertArrival(VesselAlert alert) {
  final arrival = ptpTimeText(alert.arriveAt);
  if (arrival.isEmpty) return '';
  return alert.arriveEstimated ? '$arrival (est.)' : arrival;
}

/// "Terminal B18, LBT B7X" for an alert on Westports terminals, "MMSW · Northport KCT" for an MMSW one;
/// '' for none.
String alertTerminalText(VesselAlert alert) {
  final terminal = alert.terminal?.trim() ?? '';
  if (terminal.isEmpty) return '';
  return alert.isMmsw ? alert.sourceText : 'Terminal $terminal';
}

/// "Omitted at Westports".
String omittedAlertText(VesselAlert alert) => 'Omitted at ${alert.sourceLabel}';

/// Line 2 of an ETA or OMITTED alert row: "PTP ETA 21 Oct 16:00 (est.) · 2 jobs not updated", for a
/// Westports call "Westports ETA ... · Terminal B18"; an omitted call "Omitted at Westports · ETA ... ·
/// 2 jobs to rearrange · Terminal B18"; an MMSW call "MMSW · Northport KCT · ETA ... · 2 jobs not updated".
List<String> alertDetailParts(VesselAlert alert) {
  final arrival = alertArrival(alert);
  if (alert.isMmsw && !alert.isOmitted) {
    return [
      alert.sourceText,
      'ETA ${arrival.isEmpty ? 'not given' : arrival}',
      '${plural(alert.jobs, 'job')} not updated',
    ];
  }
  if (alert.isOmitted) {
    return [
      omittedAlertText(alert),
      if (arrival.isNotEmpty) 'ETA $arrival',
      '${plural(alert.jobs, 'job')} to rearrange',
      alertTerminalText(alert),
    ];
  }
  return [
    '${alert.sourceLabel} ETA ${arrival.isEmpty ? 'not given' : arrival}',
    '${plural(alert.jobs, 'job')} not updated',
    alertTerminalText(alert),
  ];
}

/// A LINK alert's title: "Pick PTP voyage · job MY002605357" ("Pick Westports voyage · ...").
String linkAlertTitle(VesselAlert alert) => 'Pick ${alert.sourceLabel} voyage · job ${alert.jobNo ?? ''}'.trim();

/// When a vessel alert was sent (web `vesselAlertSentLabel`): "15:42" today, else "13 Oct 15:42"; '' for none.
String alertSentLabel(String? sentAt, DateTime now) {
  final at = sentAt == null ? null : DateTime.tryParse(sentAt);
  if (at == null) return sentAt ?? '';
  return DateFormat(sameDay(at, now) ? 'HH:mm' : 'd MMM HH:mm').format(at);
}

/// System problems (PTP's or MMSW's schedule not updating, phone alerts not working): the only vessel
/// notices with a red ship (web `isSystemNotice`).
bool isSystemNotice(EmployeeNotification n) =>
    n.kind == NoticeKind.ptpScheduleStale ||
    n.kind == NoticeKind.mmswScheduleStale ||
    n.kind == NoticeKind.phonePushDown;

/// The leader's escalation: "Not handled: …" or "Still not handled: …" (web `isEscalationNotice`).
bool isEscalationNotice(EmployeeNotification n) =>
    n.title.startsWith('Not handled:') || n.title.startsWith('Still not handled:');

/// Leaves out an escalation notice while a team alert row for the same vessel is shown above it (the
/// row says the same; web `withoutShownEscalations`). The unread count stays the server's.
List<EmployeeNotification> withoutShownEscalations(List<EmployeeNotification> items, Iterable<String> teamVessels) {
  final names = [
    for (final name in teamVessels)
      if (name.trim().isNotEmpty) name.trim().toUpperCase()
  ];
  if (names.isEmpty) return items;
  return [
    for (final n in items)
      if (!(isEscalationNotice(n) && names.any((name) => n.title.toUpperCase().contains(name)))) n
  ];
}

/// Collapsed: the first [firstVesselRows] unread notices; every notice once "Show all" is on (web `noticesToShow`).
List<EmployeeNotification> noticesToShow(List<EmployeeNotification> items, {required bool showAll}) => showAll
    ? items
    : [
        for (final n in items)
          if (!n.read) n
      ].take(firstVesselRows).toList();
