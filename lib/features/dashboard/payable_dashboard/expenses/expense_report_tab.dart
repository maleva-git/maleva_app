import 'package:flutter/material.dart';
import 'package:maleva/core/dashboard/dashboard_api.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/network/java_api_client.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/theme/tokens.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/widgets/ui/formats.dart';

import '../records/data/payable_record.dart';
import '../records/data/payable_records_api.dart';
import '../records/view/record_detail_page.dart';
import '../records/view/record_style.dart';
import '../today/data/payable_today_models.dart';

/// The payable team's expense report (scan item 4, change `payable-expense-report`): for a period, every expense head
/// with how many and how much, its share, the approved and waiting parts, and a Total row; REJECTED is left out by the
/// server and said apart. A head opens its payment vouchers and pay bills. From the shared
/// `GET /api/dashboard/expense/{comId}` (vouchers + pay bills grouped by Description).
class ExpenseReportTab extends StatefulWidget {
  const ExpenseReportTab({super.key, this.load, this.records, this.clock});

  /// Tests give their own.
  final Future<ExpenseSummary> Function(DateTime from, DateTime to)? load;
  final PayableRecordsApi? records;
  final DateTime Function()? clock;

  @override
  State<ExpenseReportTab> createState() => _ExpenseReportTabState();
}

enum _Period { thisMonth, lastMonth, custom }

class _ExpenseReportTabState extends State<ExpenseReportTab> {
  late final DateTime Function() _clock = widget.clock ?? DateTime.now;
  late final PayableRecordsApi _records =
      widget.records ?? PayableRecordsApi(sl<JavaApiClient>().dio, companyId: AppPreferences.getComid);
  _Period _period = _Period.thisMonth;
  late DateTime _from;
  late DateTime _to;
  late Future<ExpenseSummary> _data;

  @override
  void initState() {
    super.initState();
    _setPeriod(_Period.thisMonth);
  }

  Future<ExpenseSummary> _fetch(DateTime from, DateTime to) {
    final custom = widget.load;
    if (custom != null) return Future.sync(() => custom(from, to));
    return Future.sync(() async => ExpenseSummary.fromJava(
        await sl<DashboardApi>().expenses(AppPreferences.getComid(), Fmt.ymd(from), Fmt.ymd(to))));
  }

  void _setPeriod(_Period p, {DateTime? from, DateTime? to}) {
    final now = _clock();
    _period = p;
    switch (p) {
      case _Period.thisMonth:
        _from = DateTime(now.year, now.month, 1);
        _to = DateTime(now.year, now.month, now.day);
      case _Period.lastMonth:
        _from = DateTime(now.year, now.month - 1, 1);
        _to = DateTime(now.year, now.month, 0);
      case _Period.custom:
        _from = from!;
        _to = to!;
    }
    _data = _fetch(_from, _to);
  }

  Future<void> _pickDates() async {
    final now = _clock();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year, now.month, now.day),
      initialDateRange: DateTimeRange(start: _from, end: _to),
    );
    if (picked != null) setState(() => _setPeriod(_Period.custom, from: picked.start, to: picked.end));
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.sizeOf(context).width >= 600 ? 20.0 : 12.0;
    return Container(
      color: AppTokens.surfacePage,
      child: RefreshIndicator(
        onRefresh: () async {
          setState(() => _data = _fetch(_from, _to));
          await _data.catchError((_) => const ExpenseSummary(
              today: CountAmount(0, 0), yesterday: CountAmount(0, 0), week: CountAmount(0, 0), month: CountAmount(0, 0), heads: []));
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(pad, 10, pad, 24),
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                _Chip(
                    text: 'This month',
                    selected: _period == _Period.thisMonth,
                    onTap: () => setState(() => _setPeriod(_Period.thisMonth))),
                const SizedBox(width: 6),
                _Chip(
                    text: 'Last month',
                    selected: _period == _Period.lastMonth,
                    onTap: () => setState(() => _setPeriod(_Period.lastMonth))),
                const SizedBox(width: 6),
                _Chip(
                    key: const ValueKey('expense-dates'),
                    text: _period == _Period.custom ? '${Fmt.ddMMyyyy(_from)} – ${Fmt.ddMMyyyy(_to)}' : 'Dates…',
                    icon: Icons.date_range,
                    selected: _period == _Period.custom,
                    onTap: _pickDates),
              ]),
            ),
            const SizedBox(height: 4),
            Text('${Fmt.dMonY(_from)} – ${Fmt.dMonY(_to)}', style: AppTypography.bodySmall(color: AppTokens.textMuted)),
            const SizedBox(height: 10),
            FutureBuilder<ExpenseSummary>(
              future: _data,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()));
                }
                if (snap.hasError) {
                  return Panel(
                    child: Row(children: [
                      const Icon(Icons.error_outline, size: 16, color: Palette.redDanger),
                      const SizedBox(width: 6),
                      Expanded(child: Text('${snap.error}', style: AppTypography.bodySmall(color: Palette.redDanger))),
                      TextButton(onPressed: () => setState(() => _data = _fetch(_from, _to)), child: const Text('Retry')),
                    ]),
                  );
                }
                return _Report(summary: snap.data!, onHead: (h) => _openHead(h));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openHead(ExpenseHead head) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppTokens.surfaceCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, controller) =>
            _HeadSheet(head: head, from: _from, to: _to, api: _records, controller: controller),
      ),
    );
  }
}

/// The records behind one head: the period's payment vouchers and pay bills whose Description is the head,
/// REJECTED left out (as the report).
List<PayableRecord> recordsOfHead(Iterable<PayableRecord> rows, String head) {
  final h = head.trim().toLowerCase();
  return rows
      .where((r) => r.head.trim().toLowerCase() == h && statusTone(r.status) != StatusTone.rejected)
      .toList()
    ..sort((a, b) => b.amount.compareTo(a.amount));
}

class _Report extends StatelessWidget {
  const _Report({required this.summary, required this.onHead});

  final ExpenseSummary summary;
  final ValueChanged<ExpenseHead> onHead;

  @override
  Widget build(BuildContext context) {
    final heads = [...summary.heads]..sort((a, b) => b.amount.compareTo(a.amount));
    final total = summary.headsTotal;
    final approved = summary.headsApproved;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // ── total card ──
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppTokens.brandGradientStart, AppTokens.brandGradientEnd]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Total spent', style: AppTypography.bodySmall(color: AppTokens.textOnDark)),
          const SizedBox(height: 4),
          Text(Fmt.rm(total),
              key: const ValueKey('expense-total'),
              style: AppTypography.display(color: AppTokens.textOnDark, fontWeight: FontWeight.w800)),
          Text('${summary.headsCount} payments · ${heads.length} expense heads',
              style: AppTypography.bodySmall(color: AppTokens.textOnDark.withValues(alpha: 0.85))),
          const SizedBox(height: 12),
          _SplitBar(approved: approved, total: total, height: 8, onDark: true),
          const SizedBox(height: 8),
          Wrap(spacing: 14, runSpacing: 4, children: [
            _Legend(color: const Color(0xFF34D399), text: 'Approved ${Fmt.rm(approved)}', onDark: true),
            _Legend(color: const Color(0xFFFBBF24), text: 'Waiting ${Fmt.rm((total - approved).clamp(0, double.infinity))}', onDark: true),
          ]),
        ]),
      ),
      if (summary.rejected.count > 0) ...[
        const SizedBox(height: 8),
        Container(
          key: const ValueKey('expense-rejected'),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
              color: Palette.redDanger.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            const Icon(Icons.block, size: 16, color: Palette.redDanger),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                  'Left out: ${summary.rejected.count} rejected (${Fmt.rm(summary.rejected.amount)})',
                  style: AppTypography.bodySmall(color: Palette.redDanger, fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
      ],
      const SizedBox(height: 12),
      // ── heads table ──
      Panel(
        title: 'By expense',
        icon: Icons.pie_chart_outline,
        trailing: Text('tap a row', style: AppTypography.badgeText(color: AppTokens.textMuted)),
        child: heads.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text('No payments in these dates', style: AppTypography.bodySmall(color: AppTokens.textMuted)))
            : Column(children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(children: [
                    Expanded(child: Text('Expense', style: AppTypography.badgeText(color: AppTokens.textMuted))),
                    SizedBox(width: 44, child: Text('No.', textAlign: TextAlign.right, style: AppTypography.badgeText(color: AppTokens.textMuted))),
                    SizedBox(width: 120, child: Text('Amount', textAlign: TextAlign.right, style: AppTypography.badgeText(color: AppTokens.textMuted))),
                  ]),
                ),
                const Divider(height: 8),
                for (final h in heads) _HeadRow(head: h, total: total, onTap: () => onHead(h)),
                const Divider(height: 14, thickness: 1.2),
                Row(key: const ValueKey('expense-total-row'), children: [
                  Expanded(
                      child: Text('Total',
                          style: AppTypography.bodyLarge(color: AppTokens.textPrimary, fontWeight: FontWeight.w800))),
                  SizedBox(
                      width: 44,
                      child: Text('${summary.headsCount}',
                          textAlign: TextAlign.right,
                          style: AppTypography.bodyMedium(color: AppTokens.textPrimary, fontWeight: FontWeight.w700))),
                  SizedBox(
                      width: 120,
                      child: Text(Fmt.rm(total),
                          textAlign: TextAlign.right,
                          style: AppTypography.bodyMedium(color: AppTokens.textPrimary, fontWeight: FontWeight.w800))),
                ]),
              ]),
      ),
      const SizedBox(height: 8),
      Text('Payment vouchers and pay bills by expense head. Rejected ones are not counted.',
          style: AppTypography.badgeText(color: AppTokens.textMuted)),
    ]);
  }
}

class _HeadRow extends StatelessWidget {
  const _HeadRow({required this.head, required this.total, required this.onTap});

  final ExpenseHead head;
  final double total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final share = total <= 0 ? 0.0 : head.amount / total;
    return InkWell(
      key: ValueKey('head-${head.name}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(
              child: Text(head.name.isEmpty ? '(no expense head)' : head.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMedium(color: AppTokens.textPrimary, fontWeight: FontWeight.w600)),
            ),
            SizedBox(
                width: 44,
                child: Text('${head.count}',
                    textAlign: TextAlign.right, style: AppTypography.bodyMedium(color: AppTokens.textPrimary))),
            SizedBox(
                width: 120,
                child: Text(Fmt.rm(head.amount),
                    textAlign: TextAlign.right,
                    style: AppTypography.bodyMedium(color: AppTokens.textPrimary, fontWeight: FontWeight.w700))),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            Expanded(child: _SplitBar(approved: head.approved, total: head.amount, height: 5)),
            const SizedBox(width: 8),
            Text('${(share * 100).toStringAsFixed(share < 0.1 ? 1 : 0)}%',
                style: AppTypography.badgeText(color: AppTokens.textMuted, fontWeight: FontWeight.w600)),
          ]),
        ]),
      ),
    );
  }
}

/// Approved (green) and waiting (amber) parts of a total.
class _SplitBar extends StatelessWidget {
  const _SplitBar({required this.approved, required this.total, required this.height, this.onDark = false});

  final double approved;
  final double total;
  final double height;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final a = total <= 0 ? 0.0 : (approved / total).clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        height: height,
        child: Row(children: [
          if (a > 0) Expanded(flex: (a * 1000).round(), child: Container(color: const Color(0xFF10B981))),
          if (a < 1)
            Expanded(
                flex: ((1 - a) * 1000).round(),
                child: Container(color: total <= 0 ? AppTokens.surfaceBorder : const Color(0xFFF59E0B))),
        ]),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.text, this.onDark = false});

  final Color color;
  final String text;
  final bool onDark;

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(text,
            style: AppTypography.bodySmall(color: onDark ? AppTokens.textOnDark : AppTokens.textPrimary, fontWeight: FontWeight.w600)),
      ]);
}

class _Chip extends StatelessWidget {
  const _Chip({super.key, required this.text, required this.selected, required this.onTap, this.icon});

  final String text;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppTokens.brandLight : AppTokens.surfaceCard,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? AppTokens.brandPrimary : AppTokens.surfaceBorder),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[Icon(icon, size: 14, color: AppTokens.brandPrimary), const SizedBox(width: 4)],
            Text(text,
                style: AppTypography.bodySmall(
                    color: selected ? AppTokens.brandPrimary : AppTokens.textPrimary, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}

/// One head's payment vouchers and pay bills of the period; a row opens the record.
class _HeadSheet extends StatefulWidget {
  const _HeadSheet({required this.head, required this.from, required this.to, required this.api, required this.controller});

  final ExpenseHead head;
  final DateTime from;
  final DateTime to;
  final PayableRecordsApi api;
  final ScrollController controller;

  @override
  State<_HeadSheet> createState() => _HeadSheetState();
}

class _HeadSheetState extends State<_HeadSheet> {
  late Future<List<PayableRecord>> _rows = _load();

  Future<List<PayableRecord>> _load() => Future.sync(() async {
        final r = await Future.wait([
          widget.api.list(RecordKind.voucher, widget.from, widget.to),
          widget.api.list(RecordKind.payBill, widget.from, widget.to),
        ]);
        return recordsOfHead([...r[0], ...r[1]], widget.head.name);
      });

  @override
  Widget build(BuildContext context) {
    final h = widget.head;
    return ListView(controller: widget.controller, padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      Center(
        child: Container(
            width: 40, height: 4, decoration: BoxDecoration(color: AppTokens.surfaceBorder, borderRadius: BorderRadius.circular(2))),
      ),
      const SizedBox(height: 12),
      Text(h.name.isEmpty ? '(no expense head)' : h.name,
          style: AppTypography.heading3(color: AppTokens.textPrimary)),
      Text('${h.count} payments · ${Fmt.rm(h.amount)} · ${Fmt.ddMMyyyy(widget.from)} – ${Fmt.ddMMyyyy(widget.to)}',
          style: AppTypography.bodySmall(color: AppTokens.textMuted)),
      const SizedBox(height: 12),
      FutureBuilder<List<PayableRecord>>(
        future: _rows,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Padding(padding: EdgeInsets.all(30), child: Center(child: CircularProgressIndicator()));
          }
          if (snap.hasError) {
            return Row(children: [
              Expanded(child: Text('${snap.error}', style: AppTypography.bodySmall(color: Palette.redDanger))),
              TextButton(onPressed: () => setState(() => _rows = _load()), child: const Text('Retry')),
            ]);
          }
          final rows = snap.data!;
          if (rows.isEmpty) {
            return Text('No voucher or pay bill found for this head.',
                style: AppTypography.bodySmall(color: AppTokens.textMuted));
          }
          return Column(children: [
            for (final r in rows)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: toneColor(statusTone(r.status)).withValues(alpha: 0.12),
                  child: Icon(r.kind.icon, size: 18, color: toneColor(statusTone(r.status))),
                ),
                title: Text(r.party.isEmpty ? r.number : r.party,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMedium(color: AppTokens.textPrimary, fontWeight: FontWeight.w600)),
                subtitle: Text(
                    [r.kind.label, r.number, if (r.date != null) Fmt.ddMMyyyy(r.date), statusLabel(r.status)].join(' · '),
                    style: AppTypography.bodySmall(color: AppTokens.textMuted)),
                trailing: Text(Fmt.rm(r.amount),
                    style: AppTypography.bodyMedium(color: AppTokens.textPrimary, fontWeight: FontWeight.w700)),
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => RecordDetailPage(record: r, api: widget.api))),
              ),
          ]);
        },
      ),
    ]);
  }
}
