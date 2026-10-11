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
}

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

  double? get withinTargetPct => numbers.withinTargetPct;
}

class ResponseReport {
  const ResponseReport({required this.from, required this.to, required this.company, required this.mailboxes});

  factory ResponseReport.fromJava(Map<String, dynamic> m) => ResponseReport(
        from: JsonRead.string(m['from']),
        to: JsonRead.string(m['to']),
        company: ResponseNumbers.fromJava(JsonRead.map(m['company'])),
        mailboxes: JsonRead.listOfMaps(m['mailboxes']).map(ResponseRow.fromJava).toList(),
      );

  final String from;
  final String to;
  final ResponseNumbers company;
  final List<ResponseRow> mailboxes;
}

class LateItem {
  const LateItem({
    required this.uid,
    required this.receivedAt,
    required this.firstReplyAt,
    required this.minutes,
    required this.waiting,
    required this.senderDomain,
  });

  factory LateItem.fromJava(Map<String, dynamic> m) => LateItem(
        uid: JsonRead.integer(m['uid']),
        receivedAt: _time(m['receivedAt']),
        firstReplyAt: _time(m['firstReplyAt']),
        minutes: _dbl(m['minutes']),
        waiting: JsonRead.string(m['status']) == 'WAITING',
        senderDomain: JsonRead.stringOrNull(m['senderDomain']),
      );

  /// 0 when the mail can no longer be opened.
  final int uid;
  final DateTime? receivedAt;
  final DateTime? firstReplyAt;
  final double? minutes;

  /// No reply yet (status WAITING); otherwise REPLIED.
  final bool waiting;
  final String? senderDomain;
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
  const ResponseSummary({required this.text, required this.generatedAt});

  factory ResponseSummary.fromJava(Map<String, dynamic> m) =>
      ResponseSummary(text: JsonRead.string(m['text']), generatedAt: _time(m['generatedAt']));

  final String text;
  final DateTime? generatedAt;

  /// The text as points, bullets stripped, as the web shows them.
  List<String> get points => [
        for (final l in text.split('\n'))
          if (l.replaceFirst(RegExp(r'^\s*[-*•]\s*'), '').trim().isNotEmpty)
            l.replaceFirst(RegExp(r'^\s*[-*•]\s*'), '').trim(),
      ];
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
