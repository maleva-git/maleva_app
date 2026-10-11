import 'package:maleva/core/mailmonitor/mail_monitor_models.dart';
import 'package:maleva/core/utils/json_read.dart';
import 'package:maleva/features/ir_report/domain/entities/ir_list_result.dart';
import 'package:maleva/features/ir_report/domain/entities/ir_report.dart';
import 'package:maleva/features/truck_location/domain/entities/truck_location_week.dart';

/// The small numbers the Overview tab shows, each read from the Java answer as it is
/// (change `super-admin-overview-tab`).

/// `/api/dashboard/sales/{comId}?type=1`: `TodaySales`, `MonthSales`, `MonthAmount`.
class SalesSummary {
  const SalesSummary({required this.today, required this.month, required this.monthAmount});

  factory SalesSummary.fromJava(Map<String, dynamic> m) => SalesSummary(
        today: JsonRead.integer(m['TodaySales']),
        month: JsonRead.integer(m['MonthSales']),
        monthAmount: JsonRead.number(m['MonthAmount']),
      );

  final int today;
  final int month;
  final double monthAmount;
}

/// `/api/job-orders/list` with any status: the job orders not yet finished, counted by status.
class JobOrderSummary {
  const JobOrderSummary({required this.open, required this.byStatus});

  /// Completed is status 3 (the JO tab's green); a status named completed, cancelled or closed
  /// is finished too.
  static bool isFinished(int statusRefId, String statusName) =>
      statusRefId == 3 || RegExp(r'complet|cancel|close').hasMatch(statusName.toLowerCase());

  factory JobOrderSummary.fromRows(List<Map<String, dynamic>> rows) {
    final byStatus = <String, int>{};
    for (final r in rows) {
      final name = JsonRead.string(r['statusName']).trim();
      if (isFinished(JsonRead.integer(r['statusRefId']), name)) continue;
      final key = name.isEmpty ? 'No status' : name;
      byStatus[key] = (byStatus[key] ?? 0) + 1;
    }
    return JobOrderSummary(open: byStatus.values.fold(0, (a, b) => a + b), byStatus: byStatus);
  }

  final int open;

  /// Status name to count, in the order the rows came.
  final Map<String, int> byStatus;
}

/// `/api/mail-monitor/mailboxes`: the summary and the mailboxes, as the Mailbox Monitor tab has them.
class MailSummary {
  const MailSummary({required this.summary, required this.mailboxes});

  factory MailSummary.of(MailboxList list) => MailSummary(summary: list.summary, mailboxes: list.mailboxes);

  final MailMonitorSummary summary;
  final List<MailboxRow> mailboxes;
}

/// `/api/ir` with `openOnly` over the last 30 days: the server's count and amount, and its rows.
class IrSummary {
  const IrSummary({required this.open, required this.totalAmount, required this.latest});

  factory IrSummary.of(IrListResult result) {
    final rows = [...result.items]..sort((a, b) => b.irDate.compareTo(a.irDate));
    return IrSummary(open: result.count, totalAmount: result.totalAmount, latest: rows.take(3).toList());
  }

  final int open;
  final int totalAmount;
  final List<IrReport> latest;
}

/// This week's truck-location board, counted for [today].
class TruckLocationSummary {
  const TruckLocationSummary({required this.filled, required this.notFilled, required this.workshop});

  /// Sold trucks are left out; a truck in workshop counts as workshop only; a row ticked Done is
  /// finished for the week, so it is never "not filled".
  factory TruckLocationSummary.of(TruckLocationWeek week, String today) {
    final day = week.days.indexOf(today);
    var filled = 0, notFilled = 0, workshop = 0;
    for (final r in week.rows) {
      final status = r.truckStatus.toUpperCase();
      if (status == 'SOLD') continue;
      if (status == 'WORKSHOP') {
        workshop++;
        continue;
      }
      final cell = day >= 0 && day < r.locations.length ? r.locations[day].trim() : '';
      if (cell.isNotEmpty) {
        filled++;
      } else if (!r.done) {
        notFilled++;
      }
    }
    return TruckLocationSummary(filled: filled, notFilled: notFilled, workshop: workshop);
  }

  final int filled;
  final int notFilled;
  final int workshop;
}
