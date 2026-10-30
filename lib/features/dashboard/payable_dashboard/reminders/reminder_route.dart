/// Where a payable reminder notice opens (change `payable-reminders`): the Reminders page on the notice's day.
/// The server's notice links `/payable/reminders?day=yyyy-MM-dd`; a local notification carries only the type.
const String payableRemindersPath = '/payable/reminders';

const String payableReminderPrefix = 'PAYABLE_REMINDER';

/// The route of a reminder notice ([type] `PAYABLE_REMINDER` / `PAYABLE_REMINDER_FOLLOWUP`), or null for other notices.
String? payableReminderRoute(String? type, String? link) {
  if (type == null || !type.startsWith(payableReminderPrefix)) return null;
  final l = link?.trim() ?? '';
  return l.startsWith(payableRemindersPath) ? l : payableRemindersPath;
}

/// The day of a `?day=` query, or null.
DateTime? reminderDayOf(String? text) {
  final d = DateTime.tryParse(text ?? '');
  return d == null ? null : DateTime(d.year, d.month, d.day);
}
