import 'package:maleva/core/utils/json_read.dart';

/// The shared Java `/api/mail-monitor/response-report` shapes (backend change add-mail-response-report,
/// the same answers the web reads), read as the server sends them. Days are Malaysia dates
/// ("2026-10-07"); times are ISO-8601 UTC. No subject, body or address of a mail.

double? _dbl(dynamic v) => v == null ? null : JsonRead.number(v);

DateTime? _time(dynamic v) {
  final s = JsonRead.stringOrNull(v);
  return s == null ? null : DateTime.tryParse(s)?.toLocal();
}

class DayStats {
  const DayStats({required this.day, required this.received, required this.withinTarget, this.medianMinutes});

  factory DayStats.fromJava(Map<String, dynamic> m) => DayStats(
        day: JsonRead.string(m['day']),
        received: JsonRead.integer(m['received']),
        withinTarget: JsonRead.integer(m['withinTarget']),
        medianMinutes: _dbl(m['medianMinutes']),
      );

  final String day;
  final int received;
  final int withinTarget;
  final double? medianMinutes;
}

/// The numbers of one mailbox or of the whole company.
class ResponseNumbers {
  const ResponseNumbers({
    required this.received,
    required this.replied,
    required this.withinTarget,
    required this.withinTargetPct,
    required this.avgMinutes,
    required this.medianMinutes,
    required this.p90Minutes,
    required this.maxMinutes,
    required this.waiting,
    required this.daily,
    this.afterHoursReceived,
    this.afterHoursAnsweredBeforeOpen,
    this.waitingOverDay,
    this.sorting,
  });

  factory ResponseNumbers.fromJava(Map<String, dynamic> m) => ResponseNumbers(
        received: JsonRead.integer(m['received']),
        replied: JsonRead.integer(m['replied']),
        withinTarget: JsonRead.integer(m['withinTarget']),
        withinTargetPct: _dbl(m['withinTargetPct']),
        avgMinutes: _dbl(m['avgMinutes']),
        medianMinutes: _dbl(m['medianMinutes']),
        p90Minutes: _dbl(m['p90Minutes']),
        maxMinutes: _dbl(m['maxMinutes']),
        waiting: JsonRead.integer(m['waiting']),
        daily: JsonRead.listOfMaps(m['daily']).map(DayStats.fromJava).toList(),
        afterHoursReceived: JsonRead.intOrNull(m['afterHoursReceived']),
        afterHoursAnsweredBeforeOpen: JsonRead.intOrNull(m['afterHoursAnsweredBeforeOpen']),
        waitingOverDay: JsonRead.intOrNull(m['waitingOverDay']),
        sorting: m['sorting'] is Map ? Sorting.fromJava(JsonRead.map(m['sorting'])) : null,
      );

  final int received;
  final int replied;
  final int withinTarget;

  /// Null when nothing was received.
  final double? withinTargetPct;
  final double? avgMinutes;
  final double? medianMinutes;
  final double? p90Minutes;
  final double? maxMinutes;
  final int waiting;
  final List<DayStats> daily;

  // Since backend change mail-report-office-hours-fair-ranking; null from an older server.
  /// Customer mails that arrived while the office was closed.
  final int? afterHoursReceived;

  /// Of those, answered before the next opening.
  final int? afterHoursAnsweredBeforeOpen;

  /// Still waiting after more than one office day.
  final int? waitingOverDay;

  /// Who the customer mail was for (mail-count-own-mail); the numbers above count only [Sorting.needReply].
  final Sorting? sorting;
}

/// The server's fair judgement of a mailbox (decided by rules, never by the AI).
enum Category { onTrack, watch, needsSupport, notEnoughData }

Category? categoryOf(String? code) => switch (code) {
      'ON_TRACK' => Category.onTrack,
      'WATCH' => Category.watch,
      'NEEDS_SUPPORT' => Category.needsSupport,
      'NOT_ENOUGH_DATA' => Category.notEnoughData,
      _ => null,
    };

/// One mailbox, named by its owner employees; a shared mailbox is measured as a team.
class ResponseRow {
  const ResponseRow({
    required this.mailboxId,
    required this.address,
    required this.displayName,
    required this.kind,
    required this.department,
    required this.owners,
    required this.targetMinutes,
    required this.sentFolderFound,
    required this.scanError,
    required this.numbers,
    this.category,
    this.reasons = const [],
    this.withinTargetLow,
    this.previousWithinTargetPct,
    this.reading,
    this.workload,
  });

  factory ResponseRow.fromJava(Map<String, dynamic> m) => ResponseRow(
        mailboxId: JsonRead.integer(m['mailboxId']),
        address: JsonRead.string(m['address']),
        displayName: JsonRead.string(m['displayName']),
        kind: JsonRead.string(m['kind']),
        department: JsonRead.stringOrNull(m['department']),
        owners: [
          for (final o in (m['owners'] is List ? m['owners'] as List : const []))
            if (JsonRead.stringOrNull(o) != null) JsonRead.string(o),
        ],
        targetMinutes: JsonRead.integer(m['targetMinutes'], fallback: 15),
        sentFolderFound: JsonRead.boolean(m['sentFolderFound']),
        scanError: JsonRead.stringOrNull(m['scanError']),
        numbers: ResponseNumbers.fromJava(m),
        category: categoryOf(JsonRead.stringOrNull(m['category'])),
        reasons: [
          for (final r in (m['reasons'] is List ? m['reasons'] as List : const []))
            if (JsonRead.stringOrNull(r) != null) JsonRead.string(r),
        ],
        withinTargetLow: _dbl(m['withinTargetLow']),
        previousWithinTargetPct: _dbl(m['previousWithinTargetPct']),
        reading: m['reading'] is Map ? Reading.fromJava(JsonRead.map(m['reading'])) : null,
        workload: m['workload'] is Map ? Workload.fromJava(JsonRead.map(m['workload'])) : null,
      );

  final int mailboxId;
  final String address;
  final String displayName;

  /// SHARED or PERSONAL.
  final String kind;
  final String? department;
  final List<String> owners;
  final int targetMinutes;
  final bool sentFolderFound;
  final String? scanError;
  final ResponseNumbers numbers;

  /// The server's category; null from an older server.
  final Category? category;

  /// Reason codes (SCAN_FAILED, TOO_FEW_MAILS, LOW_WITHIN_TARGET, ...), in the server's order.
  final List<String> reasons;
  final double? withinTargetLow;
  final double? previousWithinTargetPct;

  /// How often the inbox was read in office hours (mail-reading-and-booking-speed); null without snapshots.
  final Reading? reading;

  /// Load and leave (mail-leave-and-workload); null from an older server.
  final Workload? workload;

  double? get withinTargetPct => numbers.withinTargetPct;
}

/// Of [customerMails], [needReply] needed this mailbox's reply; the others did not: only copied in ([ccOnly]), written
/// to a colleague by name ([otherName]), answered by a colleague ([team]). [sorted] is false until the server's script ran.
class Sorting {
  const Sorting({
    required this.customerMails,
    required this.needReply,
    required this.ccOnly,
    required this.otherName,
    required this.team,
    required this.sorted,
    this.marked = 0,
    this.helped = 0,
    this.helpedMedianMinutes,
    this.corrected = 0,
  });

  factory Sorting.fromJava(Map<String, dynamic> m) => Sorting(
        customerMails: JsonRead.integer(m['customerMails']),
        needReply: JsonRead.integer(m['needReply']),
        ccOnly: JsonRead.integer(m['ccOnly']),
        otherName: JsonRead.integer(m['otherName']),
        team: JsonRead.integer(m['team']),
        sorted: JsonRead.boolean(m['sorted']),
        marked: JsonRead.integer(m['marked']),
        helped: JsonRead.integer(m['helped']),
        helpedMedianMinutes: _dbl(m['helpedMedianMinutes']),
        corrected: JsonRead.integer(m['corrected']),
      );

  final int customerMails;
  final int needReply;
  final int ccOnly;
  final int otherName;
  final int team;
  final bool sorted;

  /// Marked not needed by the Super Admin (mail-team-credit-and-corrections).
  final int marked;

  /// Mails of other mailboxes this mailbox answered (included in its numbers: it handled them), and their median.
  final int helped;
  final double? helpedMedianMinutes;

  /// Mails whose decision the Super Admin corrected.
  final int corrected;

  int get notTheirs => ccOnly + otherName + team + marked;
}

/// [officeDays] of the range the mailbox was open (its owners' leave days not counted), [leaveDays] those days
/// (yyyy-MM-dd), [perDay] mails that needed its reply per office day, before and the team median.
class Workload {
  const Workload({
    required this.officeDays,
    required this.leaveDays,
    this.perDay,
    this.previousPerDay,
    this.teamMedianPerDay,
  });

  factory Workload.fromJava(Map<String, dynamic> m) => Workload(
        officeDays: JsonRead.integer(m['officeDays']),
        leaveDays: [for (final d in (m['leaveDays'] is List ? m['leaveDays'] as List : const [])) JsonRead.string(d)],
        perDay: _dbl(m['perDay']),
        previousPerDay: _dbl(m['previousPerDay']),
        teamMedianPerDay: _dbl(m['teamMedianPerDay']),
      );

  final int officeDays;
  final List<String> leaveDays;
  final double? perDay;
  final double? previousPerDay;
  final double? teamMedianPerDay;
}

/// Read days = office days on which the unread count went down (or reached 0) in office hours.
class Reading {
  const Reading({required this.officeDays, required this.readDays, required this.unreadNow, this.oldestUnreadOfficeDays});

  factory Reading.fromJava(Map<String, dynamic> m) => Reading(
        officeDays: JsonRead.integer(m['officeDays']),
        readDays: JsonRead.integer(m['readDays']),
        unreadNow: JsonRead.integer(m['unreadNow']),
        oldestUnreadOfficeDays: JsonRead.intOrNull(m['oldestUnreadOfficeDays']),
      );

  final int officeDays;
  final int readDays;
  final int unreadNow;

  /// Office days since the oldest unread mail arrived; null when nothing is unread.
  final int? oldestUnreadOfficeDays;
}

/// The office calendar the minutes were counted with ("08:30" / "20:00", "MON".."SAT").
class OfficeHours {
  const OfficeHours({required this.open, required this.close, required this.days, required this.holidays});

  factory OfficeHours.fromJava(Map<String, dynamic> m) => OfficeHours(
        open: JsonRead.string(m['open']),
        close: JsonRead.string(m['close']),
        days: [for (final d in (m['days'] is List ? m['days'] as List : const [])) JsonRead.string(d)],
        holidays: [for (final d in (m['holidays'] is List ? m['holidays'] as List : const [])) JsonRead.string(d)],
      );

  final String open;
  final String close;
  final List<String> days;

  /// Holidays inside the range.
  final List<String> holidays;
}

class ResponseReport {
  const ResponseReport({
    required this.from,
    required this.to,
    required this.company,
    required this.mailboxes,
    this.officeClock = false,
    this.office,
    this.fastestMailboxId,
    this.attentionMailboxId,
    this.onTarget = 0,
    this.counted = 0,
  });

  factory ResponseReport.fromJava(Map<String, dynamic> m) => ResponseReport(
        from: JsonRead.string(m['from']),
        to: JsonRead.string(m['to']),
        company: ResponseNumbers.fromJava(JsonRead.map(m['company'])),
        mailboxes: JsonRead.listOfMaps(m['mailboxes']).map(ResponseRow.fromJava).toList(),
        officeClock: JsonRead.string(m['clock']) == 'OFFICE',
        office: m['office'] is Map ? OfficeHours.fromJava(JsonRead.map(m['office'])) : null,
        fastestMailboxId: JsonRead.intOrNull(m['fastestMailboxId']),
        attentionMailboxId: JsonRead.intOrNull(m['attentionMailboxId']),
        onTarget: JsonRead.integer(m['onTarget']),
        counted: JsonRead.integer(m['counted']),
      );

  final String from;
  final String to;
  final ResponseNumbers company;
  final List<ResponseRow> mailboxes;

  /// True when minutes count office hours only (clock "OFFICE").
  final bool officeClock;
  final OfficeHours? office;

  /// The spotlight decided by the server's rules; null when there is none.
  final int? fastestMailboxId;
  final int? attentionMailboxId;
  final int onTarget;

  /// Mailboxes with enough data to judge.
  final int counted;

  /// True when the server judged the rows (a newer server).
  bool get judged => mailboxes.any((r) => r.category != null);
}

class LateItem {
  const LateItem({
    required this.uid,
    required this.receivedAt,
    required this.firstReplyAt,
    required this.minutes,
    required this.waiting,
    required this.senderDomain,
    this.clockMinutes,
    this.afterHours = false,
    this.relevance = 'MINE',
    this.id = 0,
    this.repliedBy,
    this.correction,
    this.handledFor,
  });

  factory LateItem.fromJava(Map<String, dynamic> m) => LateItem(
        uid: JsonRead.integer(m['uid']),
        receivedAt: _time(m['receivedAt']),
        firstReplyAt: _time(m['firstReplyAt']),
        minutes: _dbl(m['minutes']),
        waiting: JsonRead.string(m['status']) == 'WAITING',
        senderDomain: JsonRead.stringOrNull(m['senderDomain']),
        clockMinutes: _dbl(m['clockMinutes']),
        afterHours: JsonRead.boolean(m['afterHours']),
        relevance: JsonRead.stringOrNull(m['relevance']) ?? 'MINE',
        id: JsonRead.integer(m['id']),
        repliedBy: JsonRead.stringOrNull(m['repliedBy']),
        correction: JsonRead.stringOrNull(m['correction']),
        handledFor: JsonRead.stringOrNull(m['handledFor']),
      );

  /// 0 when the mail can no longer be opened.
  final int uid;
  final DateTime? receivedAt;
  final DateTime? firstReplyAt;
  final double? minutes;

  /// No reply yet (status WAITING); otherwise REPLIED.
  final bool waiting;
  final String? senderDomain;

  /// The 24/7 time it really took; [minutes] is office time (newer server).
  final double? clockMinutes;

  /// Arrived while the office was closed.
  final bool afterHours;

  /// Who the mail was for: MINE, CC_ONLY, OTHER_NAME, TEAM or MARKED (mail-count-own-mail).
  final String relevance;

  /// The stored mail's id, for a correction (0 from an older server).
  final int id;

  /// The colleague's mailbox whose reply counted for this one.
  final String? repliedBy;

  /// The Super Admin's correction: MINE, NOT_MINE or null.
  final String? correction;

  /// On a mail this mailbox answered for another mailbox: that mailbox (owner, 2026-10-12: whoever replied handled it).
  final String? handledFor;

  bool get counted => relevance == 'MINE';
}

/// The mails behind a mailbox's numbers: COUNTED (needed its reply) or NOT_THEIRS, newest first.
class MailList {
  const MailList({required this.group, required this.items, required this.limit, required this.sorted});

  factory MailList.fromJava(Map<String, dynamic> m) => MailList(
        group: JsonRead.string(m['group']),
        items: JsonRead.listOfMaps(m['items']).map(LateItem.fromJava).toList(),
        limit: JsonRead.integer(m['limit'], fallback: 200),
        sorted: JsonRead.boolean(m['sorted']),
      );

  final String group;
  final List<LateItem> items;
  final int limit;
  final bool sorted;
}

class LateList {
  const LateList({required this.slowest, required this.waiting});

  factory LateList.fromJava(Map<String, dynamic> m) => LateList(
        slowest: JsonRead.listOfMaps(m['slowest']).map(LateItem.fromJava).toList(),
        waiting: JsonRead.listOfMaps(m['waiting']).map(LateItem.fromJava).toList(),
      );

  final List<LateItem> slowest;
  final List<LateItem> waiting;
}

/// The AI's statement on the numbers (no mail content is sent to it).
class ResponseSummary {
  const ResponseSummary({required this.text, required this.generatedAt, this.items = const []});

  factory ResponseSummary.fromJava(Map<String, dynamic> m) => ResponseSummary(
        text: JsonRead.string(m['text']),
        generatedAt: _time(m['generatedAt']),
        items: JsonRead.listOfMaps(m['points']).map(SummaryPoint.fromJava).toList(),
      );

  final String text;
  final DateTime? generatedAt;

  /// The checked points (newer server); empty from an older one, which sends [text] only.
  final List<SummaryPoint> items;

  /// The points as one text to speak: each ends with its own stop (., !, ?, Chinese 。 or Hindi ।).
  String get speechText => points.map((p) => RegExp(r'[.!?。！？।]$').hasMatch(p) ? p : '$p.').join(' ');

  /// The points as sentences: the checked points with their suggestion, or the text's lines, bullets stripped.
  List<String> get points => items.isNotEmpty
      ? [
          for (final p in items)
            [p.text, if (p.why != null) 'Why: ${p.why}.', if (p.suggestion != null) p.suggestion!].join(' '),
        ]
      : [
          for (final l in text.split('\n'))
            if (l.replaceFirst(RegExp(r'^\s*[-*•]\s*'), '').trim().isNotEmpty)
              l.replaceFirst(RegExp(r'^\s*[-*•]\s*'), '').trim(),
        ];
}

/// One point of the AI summary about a mailbox ([mailboxId] null = the whole company), with the rule category it is
/// about; [checked] false = the plain fact replaced the AI's words.
class SummaryPoint {
  const SummaryPoint({
    required this.mailboxId,
    required this.mailbox,
    required this.category,
    required this.text,
    required this.suggestion,
    required this.checked,
    this.why,
  });

  factory SummaryPoint.fromJava(Map<String, dynamic> m) => SummaryPoint(
        mailboxId: JsonRead.intOrNull(m['mailboxId']),
        mailbox: JsonRead.stringOrNull(m['mailbox']),
        category: categoryOf(JsonRead.stringOrNull(m['category'])),
        text: JsonRead.string(m['text']),
        suggestion: JsonRead.stringOrNull(m['suggestion']),
        checked: JsonRead.boolean(m['checked']),
        why: JsonRead.stringOrNull(m['why']),
      );

  final int? mailboxId;
  final String? mailbox;

  /// Null for a company point.
  final Category? category;
  final String text;
  final String? suggestion;
  final bool checked;

  /// The reason with its number, e.g. "mail read on 2 of 6 office days" (prompt v3).
  final String? why;
}

/// A report range in Malaysia dates (yyyy-MM-dd), both ends included.
class ReportRange {
  const ReportRange(this.from, this.to);

  final String from;
  final String to;

  @override
  bool operator ==(Object other) => other is ReportRange && other.from == from && other.to == to;

  @override
  int get hashCode => Object.hash(from, to);
}

// ── Booking speed (mail-reading-and-booking-speed): booking mail -> sale order -> job-number reply.
// The Java `/api/mail-monitor/booking-speed` answer, read as sent. Minutes are office minutes.

/// BOOKED: counted; EXISTING_JOB: the sale order was made before the mail; NO_SALE_ORDER: none with that number.
enum BookingStatus { booked, existingJob, noSaleOrder }

BookingStatus bookingStatusOf(String? code) => switch (code) {
      'EXISTING_JOB' => BookingStatus.existingJob,
      'NO_SALE_ORDER' => BookingStatus.noSaleOrder,
      _ => BookingStatus.booked,
    };

class BookingJob {
  const BookingJob({
    required this.jobNumber,
    required this.mailbox,
    required this.employee,
    required this.bookingReceivedAt,
    required this.saleOrderCreatedAt,
    required this.jobReplyAt,
    required this.minutesToSaleOrder,
    required this.minutesToReply,
    required this.status,
    required this.afterHours,
    this.senderDomain,
  });

  factory BookingJob.fromJava(Map<String, dynamic> m) => BookingJob(
        jobNumber: JsonRead.string(m['jobNumber']),
        mailbox: JsonRead.stringOrNull(m['mailbox']),
        employee: JsonRead.string(m['employee']),
        bookingReceivedAt: _time(m['bookingReceivedAt']),
        saleOrderCreatedAt: _time(m['saleOrderCreatedAt']),
        jobReplyAt: _time(m['jobReplyAt']),
        minutesToSaleOrder: JsonRead.intOrNull(m['minutesToSaleOrder']),
        minutesToReply: JsonRead.intOrNull(m['minutesToReply']),
        status: bookingStatusOf(JsonRead.stringOrNull(m['status'])),
        afterHours: JsonRead.boolean(m['afterHours']),
        senderDomain: JsonRead.stringOrNull(m['senderDomain']),
      );

  final String jobNumber;
  final String? mailbox;

  /// The sale order's Created_By; "Unknown" when there is none.
  final String employee;
  final DateTime? bookingReceivedAt;
  final DateTime? saleOrderCreatedAt;
  final DateTime? jobReplyAt;
  final int? minutesToSaleOrder;
  final int? minutesToReply;
  final BookingStatus status;
  final bool afterHours;

  /// The booking mail's sender domain (booking-speed-insights).
  final String? senderDomain;
}

class EmployeeSpeed {
  const EmployeeSpeed({
    required this.employee,
    required this.bookings,
    required this.ranked,
    this.medianToSaleOrder,
    this.avgToSaleOrder,
    this.medianToReply,
    this.avgToReply,
    this.fastestToSaleOrder,
    this.slowestToSaleOrder,
  });

  factory EmployeeSpeed.fromJava(Map<String, dynamic> m) => EmployeeSpeed(
        employee: JsonRead.string(m['employee']),
        bookings: JsonRead.integer(m['bookings']),
        ranked: JsonRead.boolean(m['ranked']),
        medianToSaleOrder: _dbl(m['medianToSaleOrder']),
        avgToSaleOrder: _dbl(m['avgToSaleOrder']),
        medianToReply: _dbl(m['medianToReply']),
        avgToReply: _dbl(m['avgToReply']),
        fastestToSaleOrder: JsonRead.intOrNull(m['fastestToSaleOrder']),
        slowestToSaleOrder: JsonRead.intOrNull(m['slowestToSaleOrder']),
      );

  final String employee;
  final int bookings;

  /// False below the server's minimum bookings: shown, not ranked.
  final bool ranked;
  final double? medianToSaleOrder;
  final double? avgToSaleOrder;
  final double? medianToReply;
  final double? avgToReply;
  final int? fastestToSaleOrder;
  final int? slowestToSaleOrder;
}

class BookingTotals {
  const BookingTotals({
    required this.bookings,
    required this.existingJobs,
    required this.withoutSaleOrder,
    this.medianToSaleOrder,
    this.avgToSaleOrder,
    this.medianToReply,
    this.avgToReply,
  });

  factory BookingTotals.fromJava(Map<String, dynamic> m) => BookingTotals(
        bookings: JsonRead.integer(m['bookings']),
        existingJobs: JsonRead.integer(m['existingJobs']),
        withoutSaleOrder: JsonRead.integer(m['withoutSaleOrder']),
        medianToSaleOrder: _dbl(m['medianToSaleOrder']),
        avgToSaleOrder: _dbl(m['avgToSaleOrder']),
        medianToReply: _dbl(m['medianToReply']),
        avgToReply: _dbl(m['avgToReply']),
      );

  final int bookings;
  final int existingJobs;
  final int withoutSaleOrder;
  final double? medianToSaleOrder;
  final double? avgToSaleOrder;
  final double? medianToReply;
  final double? avgToReply;
}

class BookingSpeedReport {
  const BookingSpeedReport({
    required this.from,
    required this.to,
    required this.company,
    required this.employees,
    required this.jobs,
    required this.minBookingsToRank,
    this.insights,
    this.waiting = const [],
    this.waitingReady = false,
    this.alertMinutes = 60,
    this.notBookings = const [],
    this.bookingMails,
    this.checkReady = false,
    this.pendingSaleOrders = const [],
    this.pendingByPerson = const [],
    this.saleOrderAlertMinutes = 120,
  });

  factory BookingSpeedReport.fromJava(Map<String, dynamic> m) => BookingSpeedReport(
        from: JsonRead.string(m['from']),
        to: JsonRead.string(m['to']),
        company: BookingTotals.fromJava(JsonRead.map(m['company'])),
        employees: JsonRead.listOfMaps(m['employees']).map(EmployeeSpeed.fromJava).toList(),
        jobs: JsonRead.listOfMaps(m['jobs']).map(BookingJob.fromJava).toList(),
        minBookingsToRank: JsonRead.integer(m['minBookingsToRank'], fallback: 5),
        insights: m['insights'] is Map ? BookingInsights.fromJava(JsonRead.map(m['insights'])) : null,
        waiting: JsonRead.listOfMaps(m['waiting']).map(WaitingBooking.fromJava).toList(),
        waitingReady: JsonRead.boolean(m['waitingReady']),
        alertMinutes: JsonRead.integer(m['alertMinutes'], fallback: 60),
        notBookings: JsonRead.listOfMaps(m['notBookings']).map(WaitingBooking.fromJava).toList(),
        bookingMails: m['bookingMails'] is Map ? BookingMailStats.fromJava(JsonRead.map(m['bookingMails'])) : null,
        checkReady: JsonRead.boolean(m['checkReady']),
        pendingSaleOrders: JsonRead.listOfMaps(m['pendingSaleOrders']).map(PendingSaleOrder.fromJava).toList(),
        pendingByPerson: JsonRead.listOfMaps(m['pendingByPerson']).map(PendingByPerson.fromJava).toList(),
        saleOrderAlertMinutes: JsonRead.integer(m['saleOrderAlertMinutes'], fallback: 120),
      );

  final String from;
  final String to;
  final BookingTotals company;

  /// Ranked employees first, fastest median to sale order first (the server's order).
  final List<EmployeeSpeed> employees;
  final List<BookingJob> jobs;
  final int minBookingsToRank;

  /// The statistics of the counted bookings (booking-speed-insights); null from an older server.
  final BookingInsights? insights;

  /// Booking-like mails still waiting for the mailbox's reply, longest first.
  final List<WaitingBooking> waiting;

  /// False until the server's db/mail-booking-insights.sql has been run.
  final bool waitingReady;
  final int alertMinutes;

  /// Waiting mails the Super Admin marked "not a booking" (to undo).
  final List<WaitingBooking> notBookings;
  final BookingMailStats? bookingMails;

  /// False until the subject and check columns exist on the server.
  final bool checkReady;

  /// Confirmed booking mails with no job-number reply yet: the sale order is still to be opened.
  final List<PendingSaleOrder> pendingSaleOrders;
  final List<PendingByPerson> pendingByPerson;

  /// Office minutes after which a pending confirmed booking alerts its owners' phones.
  final int saleOrderAlertMinutes;

  List<EmployeeSpeed> get ranked => [for (final e in employees) if (e.ranked) e];
  List<EmployeeSpeed> get unranked => [for (final e in employees) if (!e.ranked) e];

  /// Newest booking first.
  List<BookingJob> get newestJobs => [...jobs]..sort((a, b) =>
      (b.bookingReceivedAt ?? DateTime(0)).compareTo(a.bookingReceivedAt ?? DateTime(0)));
}

// ── Booking insights and AI summary (booking-speed-insights). Office minutes; read as the Java API sends them.

/// One group of counted bookings: count and median to sale order.
class StatGroup {
  const StatGroup({required this.key, required this.label, required this.bookings, this.medianToSaleOrder});

  factory StatGroup.fromJava(Map<String, dynamic> m) => StatGroup(
        key: JsonRead.string(m['key']),
        label: JsonRead.string(m['label']),
        bookings: JsonRead.integer(m['bookings']),
        medianToSaleOrder: _dbl(m['medianToSaleOrder']),
      );

  final String key;
  final String label;
  final int bookings;
  final double? medianToSaleOrder;
}

class SpreadBand {
  const SpreadBand({required this.key, required this.label, required this.bookings});

  factory SpreadBand.fromJava(Map<String, dynamic> m) => SpreadBand(
        key: JsonRead.string(m['key']),
        label: JsonRead.string(m['label']),
        bookings: JsonRead.integer(m['bookings']),
      );

  final String key;
  final String label;
  final int bookings;
}

class DayPoint {
  const DayPoint({required this.day, required this.bookings, this.medianToSaleOrder});

  factory DayPoint.fromJava(Map<String, dynamic> m) => DayPoint(
        day: JsonRead.string(m['day']),
        bookings: JsonRead.integer(m['bookings']),
        medianToSaleOrder: _dbl(m['medianToSaleOrder']),
      );

  final String day;
  final int bookings;
  final double? medianToSaleOrder;
}

/// A group with at least 3 bookings and a median at least 1.5x the company's; [times] = its median / the company's.
class SlowSpot {
  const SlowSpot({required this.kind, required this.label, required this.bookings, this.medianToSaleOrder, this.times});

  factory SlowSpot.fromJava(Map<String, dynamic> m) => SlowSpot(
        kind: JsonRead.string(m['kind']),
        label: JsonRead.string(m['label']),
        bookings: JsonRead.integer(m['bookings']),
        medianToSaleOrder: _dbl(m['medianToSaleOrder']),
        times: _dbl(m['times']),
      );

  /// ARRIVAL, WEEKDAY, DOMAIN or MAILBOX.
  final String kind;
  final String label;
  final int bookings;
  final double? medianToSaleOrder;
  final double? times;
}

class BookingInsights {
  const BookingInsights({
    required this.spread,
    required this.byArrival,
    required this.byWeekday,
    required this.byDomain,
    required this.byMailbox,
    required this.daily,
    required this.slowSpots,
    this.officeHoursMedian,
    this.afterHoursMedian,
  });

  factory BookingInsights.fromJava(Map<String, dynamic> m) => BookingInsights(
        spread: JsonRead.listOfMaps(m['spread']).map(SpreadBand.fromJava).toList(),
        byArrival: JsonRead.listOfMaps(m['byArrival']).map(StatGroup.fromJava).toList(),
        byWeekday: JsonRead.listOfMaps(m['byWeekday']).map(StatGroup.fromJava).toList(),
        byDomain: JsonRead.listOfMaps(m['byDomain']).map(StatGroup.fromJava).toList(),
        byMailbox: JsonRead.listOfMaps(m['byMailbox']).map(StatGroup.fromJava).toList(),
        daily: JsonRead.listOfMaps(m['daily']).map(DayPoint.fromJava).toList(),
        slowSpots: JsonRead.listOfMaps(m['slowSpots']).map(SlowSpot.fromJava).toList(),
        officeHoursMedian: _dbl(m['officeHoursMedian']),
        afterHoursMedian: _dbl(m['afterHoursMedian']),
      );

  final List<SpreadBand> spread;
  final List<StatGroup> byArrival;
  final List<StatGroup> byWeekday;
  final List<StatGroup> byDomain;
  final List<StatGroup> byMailbox;
  final List<DayPoint> daily;
  final List<SlowSpot> slowSpots;
  final double? officeHoursMedian;
  final double? afterHoursMedian;

  int get counted => spread.fold(0, (n, b) => n + b.bookings);
}

/// A booking-like mail still waiting for the mailbox's reply (office minutes); never its subject.
class WaitingBooking {
  const WaitingBooking({
    required this.id,
    required this.mailbox,
    required this.receivedAt,
    required this.waitingMinutes,
    required this.alerted,
    this.senderDomain,
    this.sender,
    this.mailboxId = 0,
    this.uid = 0,
    this.mailboxes = const [],
    this.subject,
    this.confirmed,
  });

  factory WaitingBooking.fromJava(Map<String, dynamic> m) => WaitingBooking(
        id: JsonRead.integer(m['id']),
        mailbox: JsonRead.string(m['mailbox']),
        senderDomain: JsonRead.stringOrNull(m['senderDomain']),
        receivedAt: _time(m['receivedAt']),
        waitingMinutes: JsonRead.integer(m['waitingMinutes']),
        alerted: JsonRead.boolean(m['alerted']),
        sender: JsonRead.stringOrNull(m['sender']),
        mailboxId: JsonRead.integer(m['mailboxId']),
        uid: JsonRead.integer(m['uid']),
        mailboxes: [for (final a in (m['mailboxes'] is List ? m['mailboxes'] as List : const [])) JsonRead.string(a)],
        subject: JsonRead.stringOrNull(m['subject']),
        confirmed: m['confirmed'] is bool ? m['confirmed'] as bool : null,
      );

  final int id;
  final String mailbox;
  final String? senderDomain;
  final DateTime? receivedAt;
  final int waitingMinutes;
  final bool alerted;

  /// The sender's full address (newer server); the domain otherwise.
  final String? sender;

  /// To open the mail read-only.
  final int mailboxId;
  final int uid;

  /// Every mailbox the same mail reached.
  final List<String> mailboxes;

  /// The subject (booking-like mails only), so the Super Admin can check it.
  final String? subject;

  /// The Super Admin's check: true = a booking, false = not a booking, null = not checked.
  final bool? confirmed;

  List<String> get to => mailboxes.isNotEmpty ? mailboxes : [mailbox];
}

/// Booking-like mails of the range, once per mail; "not a booking" ones are left out of everything but [rejected].
class BookingMailStats {
  const BookingMailStats({
    required this.mails,
    required this.confirmed,
    required this.unchecked,
    required this.rejected,
    required this.replied,
    this.medianFirstReply,
    this.ruleRightPct,
  });

  factory BookingMailStats.fromJava(Map<String, dynamic> m) => BookingMailStats(
        mails: JsonRead.integer(m['mails']),
        confirmed: JsonRead.integer(m['confirmed']),
        unchecked: JsonRead.integer(m['unchecked']),
        rejected: JsonRead.integer(m['rejected']),
        replied: JsonRead.integer(m['replied']),
        medianFirstReply: _dbl(m['medianFirstReply']),
        ruleRightPct: _dbl(m['ruleRightPct']),
      );

  final int mails;
  final int confirmed;
  final int unchecked;
  final int rejected;
  final int replied;
  final double? medianFirstReply;
  final double? ruleRightPct;
}

/// One checked point of the booking AI summary; [checked] false = the plain fact replaced the AI's words.
class BookingSummaryPoint {
  const BookingSummaryPoint({
    required this.about,
    required this.text,
    required this.checked,
    this.employee,
    this.why,
    this.suggestion,
  });

  factory BookingSummaryPoint.fromJava(Map<String, dynamic> m) => BookingSummaryPoint(
        about: JsonRead.stringOrNull(m['about']) ?? 'COMPANY',
        employee: JsonRead.stringOrNull(m['employee']),
        text: JsonRead.string(m['text']),
        why: JsonRead.stringOrNull(m['why']),
        suggestion: JsonRead.stringOrNull(m['suggestion']),
        checked: JsonRead.boolean(m['checked']),
      );

  /// COMPANY, EMPLOYEE, SLOW_SPOT, DATA or WAITING.
  final String about;
  final String? employee;
  final String text;
  final String? why;
  final String? suggestion;
  final bool checked;

  String get sentence => [text, if (why != null) 'Why: $why.', if (suggestion != null) suggestion!].join(' ');
}

class BookingSummary {
  const BookingSummary({required this.points, required this.provider, required this.model});

  factory BookingSummary.fromJava(Map<String, dynamic> m) => BookingSummary(
        points: JsonRead.listOfMaps(m['points']).map(BookingSummaryPoint.fromJava).toList(),
        provider: JsonRead.string(m['provider']),
        model: JsonRead.string(m['model']),
      );

  final List<BookingSummaryPoint> points;
  final String provider;
  final String model;

  /// The points as one text to speak, each ending with its own stop.
  String get speechText =>
      points.map((p) => p.sentence).map((s) => RegExp(r'[.!?。！？।]$').hasMatch(s) ? s : '$s.').join(' ');
}

/// A confirmed booking mail without a job-number reply yet; [replied] = it got a reply without a job number.
class PendingSaleOrder {
  const PendingSaleOrder({
    required this.id,
    required this.mailboxId,
    required this.uid,
    required this.receivedAt,
    required this.waitingMinutes,
    required this.replied,
    required this.mailboxes,
    required this.owners,
    this.subject,
    this.sender,
    this.alerted = false,
  });

  factory PendingSaleOrder.fromJava(Map<String, dynamic> m) => PendingSaleOrder(
        id: JsonRead.integer(m['id']),
        mailboxId: JsonRead.integer(m['mailboxId']),
        uid: JsonRead.integer(m['uid']),
        subject: JsonRead.stringOrNull(m['subject']),
        sender: JsonRead.stringOrNull(m['sender']),
        receivedAt: _time(m['receivedAt']),
        waitingMinutes: JsonRead.integer(m['waitingMinutes']),
        replied: JsonRead.boolean(m['replied']),
        mailboxes: [for (final a in (m['mailboxes'] is List ? m['mailboxes'] as List : const [])) JsonRead.string(a)],
        owners: [for (final a in (m['owners'] is List ? m['owners'] as List : const [])) JsonRead.string(a)],
        alerted: JsonRead.boolean(m['alerted']),
      );

  final int id;
  final int mailboxId;
  final int uid;
  final String? subject;
  final String? sender;
  final DateTime? receivedAt;
  final int waitingMinutes;
  final bool replied;
  final List<String> mailboxes;
  final List<String> owners;

  /// The owners got the "sale order pending" phone alert.
  final bool alerted;
}

/// One person's confirmed bookings still without a sale order: how many and the oldest (office minutes).
class PendingByPerson {
  const PendingByPerson({required this.employee, required this.mails, required this.oldestMinutes});

  factory PendingByPerson.fromJava(Map<String, dynamic> m) => PendingByPerson(
        employee: JsonRead.string(m['employee']),
        mails: JsonRead.integer(m['mails']),
        oldestMinutes: JsonRead.integer(m['oldestMinutes']),
      );

  final String employee;
  final int mails;
  final int oldestMinutes;
}
