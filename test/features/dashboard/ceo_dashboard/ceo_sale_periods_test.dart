import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/features/dashboard/ceo_dashboard/data/ceo_analytics_models.dart';
import 'package:maleva/features/dashboard/ceo_dashboard/data/ceo_period.dart';

import 'package:maleva/features/dashboard/ceo_dashboard/view/ceo_widgets.dart';

import 'ceo_fixtures.dart';

/// The Sale orders cards' days, exactly as the web `model/salePeriods.ts`.
void main() {
  Map<String, (String, String)> ranges(DateTime today) =>
      {for (final p in CeoSalePeriod.of(today)) p.key: p.range};

  test('today, yesterday, week Sunday to Saturday, whole month (Friday 16 Oct 2026)', () {
    final r = ranges(DateTime(2026, 10, 16, 9, 30));
    expect(r.keys, ['TODAY', 'YESTERDAY', 'WEEK', 'MONTH']);
    expect(r['TODAY'], ('2026-10-16', '2026-10-16'));
    expect(r['YESTERDAY'], ('2026-10-15', '2026-10-15'));
    expect(r['WEEK'], ('2026-10-11', '2026-10-17'));
    expect(r['MONTH'], ('2026-10-01', '2026-10-31'));
    expect([for (final p in CeoSalePeriod.of(DateTime(2026, 10, 16))) p.label],
        ['Today', 'Yesterday', 'This week', 'This month']);
  });

  test('a Sunday starts its own week', () {
    expect(ranges(DateTime(2026, 10, 18))['WEEK'], ('2026-10-18', '2026-10-24'));
  });

  test('a Saturday ends its week', () {
    expect(ranges(DateTime(2026, 10, 17))['WEEK'], ('2026-10-11', '2026-10-17'));
  });

  test('the first of a month: yesterday is last month, the week crosses months', () {
    final r = ranges(DateTime(2026, 3, 1)); // a Sunday
    expect(r['YESTERDAY'], ('2026-02-28', '2026-02-28'));
    expect(r['WEEK'], ('2026-03-01', '2026-03-07'));
    expect(r['MONTH'], ('2026-03-01', '2026-03-31'));
    // Thursday 1 Jan 2026: the week starts in December of the year before
    final jan = ranges(DateTime(2026, 1, 1));
    expect(jan['YESTERDAY'], ('2025-12-31', '2025-12-31'));
    expect(jan['WEEK'], ('2025-12-28', '2026-01-03'));
  });

  test('February in a leap year runs to the 29th', () {
    expect(ranges(DateTime(2028, 2, 10))['MONTH'], ('2028-02-01', '2028-02-29'));
  });

  test('a revenue month is the whole month', () {
    expect(ceoMonthRange('2026-10'), ('2026-10-01', '2026-10-31'));
    expect(ceoMonthRange('2025-11'), ('2025-11-01', '2025-11-30'));
    expect(ceoMonthRange('2024-02'), ('2024-02-01', '2024-02-29'));
    expect(ceoMonthRange('2026-12'), ('2026-12-01', '2026-12-31'));
    expect(ceoMonthRange(''), isNull);
    expect(ceoMonthRange('Oct 2026'), isNull);
    expect(ceoMonthRange('2026-13'), isNull);
  });

  group('details models', () {
    test('SALE_ORDERS reads count, total and rows', () {
      final d = CeoDetails.fromJava(saleOrdersJson(count: 120, rows: 100, total: 98450));
      expect((d.kind, d.count, d.total, d.truncated, d.rows.length), ('SALE_ORDERS', 120, 98450.0, true, 100));
      final row = d.rows.first;
      expect((row.id, row.reference, row.date, row.title, row.subtitle, row.amount, row.status),
          (500, 'SO20261000', '2026-10-16', 'GAMMA LOGISTICS', 'ALI · MV OCEAN 0 · PORT KLANG', 500.0, 'IN PROGRESS'));
    });

    test('CUSTOMERS: rank in reference, null date as empty, jobs in subtitle', () {
      final d = CeoDetails.fromJava(customersJson(rows: 2));
      expect((d.kind, d.count, d.total), ('CUSTOMERS', 2, 2000.0));
      final row = d.rows.first;
      expect((row.id, row.reference, row.date, row.title, row.subtitle, row.amount, row.status),
          (100, '1', '', 'CUSTOMER 1', '30 jobs', 2000.0, ''));
    });

    test('kinds are spelled as the server has them', () {
      expect((CeoDetailKind.saleOrders, CeoDetailKind.customers, CeoDetailKind.saleOrderEmployees),
          ('SALE_ORDERS', 'CUSTOMERS', 'SALE_ORDER_EMPLOYEES'));
    });

    test('SALE_ORDER_EMPLOYEES: id = employee (0 = none), rank, name, N jobs, amount', () {
      final d = CeoDetails.fromJava(saleOrderEmployeesJson());
      expect((d.kind, d.count, d.total, d.rows.length), ('SALE_ORDER_EMPLOYEES', 3, 1500.0, 3));
      final first = d.rows.first;
      expect((first.id, first.reference, first.date, first.title, first.subtitle, first.amount),
          (7, '1', '', 'ALI', '40 jobs', 900.0));
      expect((d.rows.last.id, d.rows.last.title), (0, 'NO EMPLOYEE'));
      expect([for (final r in d.rows) ceoJobsOf(r)], [40, 20, 6]);
      expect(ceoJobsOf(const CeoDetailRow(subtitle: '1,234 jobs')), 1234);
      expect(ceoJobsOf(const CeoDetailRow()), 0);
    });
  });
}
