import 'package:maleva/core/utils/json_read.dart';

import '../../records/data/payable_record.dart';

/// The payable reminders as the shared Java `/api/payable-reminders` sends them (change `payable-reminders`).

/// A reminder (ReminderDto).
class ReminderItem {
  const ReminderItem({
    required this.id,
    required this.title,
    required this.notes,
    required this.repeat,
    required this.dayOfMonth,
    required this.onDate,
    required this.time,
    required this.whenOffDay,
    required this.audience,
    required this.people,
    required this.fromMonth,
    required this.toMonth,
    required this.paused,
    required this.followUp,
    required this.nextDue,
    required this.nextPlanned,
  });

  factory ReminderItem.fromJava(Map<String, dynamic> m) => ReminderItem(
        id: JsonRead.integer(JsonRead.field(m, 'id')),
        title: pick(m, const ['title']),
        notes: pick(m, const ['notes']),
        repeat: pick(m, const ['repeat']).isEmpty ? 'MONTHLY' : pick(m, const ['repeat']),
        dayOfMonth: JsonRead.intOrNull(JsonRead.field(m, 'dayOfMonth')),
        onDate: readDate(pick(m, const ['onDate'])),
        time: pick(m, const ['time']).isEmpty ? '09:00' : pick(m, const ['time']),
        whenOffDay: pick(m, const ['whenOffDay']).isEmpty ? 'BEFORE' : pick(m, const ['whenOffDay']),
        audience: pick(m, const ['audience']).isEmpty ? 'TEAM' : pick(m, const ['audience']),
        people: [
          for (final v in (JsonRead.field(m, 'people') as List? ?? const [])) JsonRead.integer(v),
        ],
        fromMonth: pick(m, const ['fromMonth']),
        toMonth: pick(m, const ['toMonth']),
        paused: JsonRead.boolean(JsonRead.field(m, 'paused')),
        followUp: JsonRead.field(m, 'followUp') == null || JsonRead.boolean(JsonRead.field(m, 'followUp')),
        nextDue: readDate(pick(m, const ['nextDue'])),
        nextPlanned: readDate(pick(m, const ['nextPlanned'])),
      );

  final int id;
  final String title;
  final String notes;

  /// MONTHLY or ONCE.
  final String repeat;
  final int? dayOfMonth;
  final DateTime? onDate;

  /// "HH:mm".
  final String time;

  /// BEFORE, SAME or AFTER.
  final String whenOffDay;

  /// TEAM or PEOPLE.
  final String audience;
  final List<int> people;

  /// "yyyy-MM".
  final String fromMonth;
  final String toMonth;
  final bool paused;
  final bool followUp;
  final DateTime? nextDue;
  final DateTime? nextPlanned;
}

/// The state of one reminder on one day.
enum DayState { done, missed, overdue, sent, due, upcoming, paused }

DayState dayStateOf(String s) => switch (s.toUpperCase()) {
      'DONE' => DayState.done,
      'MISSED' => DayState.missed,
      'OVERDUE' => DayState.overdue,
      'SENT' => DayState.sent,
      'DUE' => DayState.due,
      'PAUSED' => DayState.paused,
      _ => DayState.upcoming,
    };

/// One reminder on one day (DayItem).
class ReminderDay {
  const ReminderDay({
    required this.reminderId,
    required this.title,
    required this.notes,
    required this.time,
    required this.dueOn,
    required this.planned,
    required this.state,
    required this.doneBy,
    required this.doneAt,
    required this.followUps,
    required this.audience,
  });

  factory ReminderDay.fromJava(Map<String, dynamic> m) => ReminderDay(
        reminderId: JsonRead.integer(JsonRead.field(m, 'reminderId')),
        title: pick(m, const ['title']),
        notes: pick(m, const ['notes']),
        time: pick(m, const ['time']),
        dueOn: readDate(pick(m, const ['dueOn'])) ?? DateTime(1900),
        planned: readDate(pick(m, const ['planned'])),
        state: dayStateOf(pick(m, const ['state'])),
        doneBy: pick(m, const ['doneBy']),
        doneAt: JsonRead.date(JsonRead.field(m, 'doneAt')),
        followUps: JsonRead.integer(JsonRead.field(m, 'followUps')),
        audience: pick(m, const ['audience']),
      );

  final int reminderId;
  final String title;
  final String notes;
  final String time;
  final DateTime dueOn;

  /// The day before a weekend / holiday move.
  final DateTime? planned;
  final DayState state;
  final String doneBy;
  final DateTime? doneAt;
  final int followUps;
  final String audience;

  bool get moved => planned != null && !_sameDay(planned!, dueOn);
}

bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

/// A month of the calendar: day → its reminders.
class ReminderMonth {
  const ReminderMonth({required this.month, required this.today, required this.days});

  factory ReminderMonth.fromJava(Map<String, dynamic> m) {
    final days = <DateTime, List<ReminderDay>>{};
    for (final d in JsonRead.listOfMaps(JsonRead.field(m, 'days'))) {
      final date = readDate(pick(d, const ['date']));
      if (date == null) continue;
      days[DateTime(date.year, date.month, date.day)] = [
        for (final i in JsonRead.listOfMaps(JsonRead.field(d, 'items'))) ReminderDay.fromJava(i),
      ];
    }
    return ReminderMonth(
      month: pick(m, const ['month']),
      today: readDate(pick(m, const ['today'])) ?? DateTime.now(),
      days: days,
    );
  }

  final String month;
  final DateTime today;
  final Map<DateTime, List<ReminderDay>> days;

  List<ReminderDay> on(DateTime d) => days[DateTime(d.year, d.month, d.day)] ?? const [];
}

/// What is due today and what is still open from earlier days.
class ReminderToday {
  const ReminderToday({required this.due, required this.open});

  factory ReminderToday.fromJava(Map<String, dynamic> m) => ReminderToday(
        due: [for (final i in JsonRead.listOfMaps(JsonRead.field(m, 'due'))) ReminderDay.fromJava(i)],
        open: [for (final i in JsonRead.listOfMaps(JsonRead.field(m, 'open'))) ReminderDay.fromJava(i)],
      );

  final List<ReminderDay> due;
  final List<ReminderDay> open;

  /// Not done yet (today's not done + earlier open).
  int get toDo => due.where((d) => d.state != DayState.done).length + open.length;
}

/// A person who can be chosen.
class ReminderPerson {
  const ReminderPerson(this.id, this.name, this.roleId);

  final int id;
  final String name;
  final int roleId;
}

/// What the add / edit form sends (ReminderRequest).
class ReminderForm {
  ReminderForm({
    this.title = '',
    this.notes = '',
    this.repeat = 'MONTHLY',
    this.dayOfMonth,
    this.onDate,
    this.time = '09:00',
    this.whenOffDay = 'BEFORE',
    this.audience = 'TEAM',
    List<int>? people,
    this.fromMonth,
    this.toMonth,
    this.paused = false,
    this.followUp = true,
  }) : people = people ?? [];

  factory ReminderForm.of(ReminderItem r) => ReminderForm(
        title: r.title,
        notes: r.notes,
        repeat: r.repeat,
        dayOfMonth: r.dayOfMonth,
        onDate: r.onDate,
        time: r.time,
        whenOffDay: r.whenOffDay,
        audience: r.audience,
        people: [...r.people],
        fromMonth: r.fromMonth.isEmpty ? null : r.fromMonth,
        toMonth: r.toMonth.isEmpty ? null : r.toMonth,
        paused: r.paused,
        followUp: r.followUp,
      );

  String title;
  String notes;
  String repeat;
  int? dayOfMonth;
  DateTime? onDate;
  String time;
  String whenOffDay;
  String audience;
  List<int> people;
  String? fromMonth;
  String? toMonth;
  bool paused;
  bool followUp;

  static String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// The form's own checks before asking the server (the server checks again).
  List<String> problems() => [
        if (title.trim().isEmpty) 'Type what to remember',
        if (title.trim().length > 120) 'The title is too long (120 letters at most)',
        if (repeat == 'MONTHLY' && (dayOfMonth == null || dayOfMonth! < 1 || dayOfMonth! > 31)) 'Choose the day of the month',
        if (repeat == 'ONCE' && onDate == null) 'Choose the date',
        if (audience == 'PEOPLE' && people.isEmpty) 'Choose at least one person',
      ];

  Map<String, dynamic> toJson() => {
        'title': title.trim(),
        'notes': notes.trim().isEmpty ? null : notes.trim(),
        'repeat': repeat,
        'dayOfMonth': repeat == 'MONTHLY' ? dayOfMonth : null,
        'onDate': repeat == 'ONCE' && onDate != null ? _ymd(onDate!) : null,
        'time': time,
        'whenOffDay': whenOffDay,
        'audience': audience,
        'people': audience == 'PEOPLE' ? people : <int>[],
        'fromMonth': repeat == 'MONTHLY' ? fromMonth : null,
        'toMonth': repeat == 'MONTHLY' ? toMonth : null,
        'paused': paused,
        'followUp': followUp,
      };
}
