import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/network/java_api_client.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/theme/tokens.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/widgets/ui/formats.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import '../records/data/payable_record.dart';
import '../records/data/payable_records_api.dart';
import '../records/view/record_detail_page.dart';
import '../records/view/record_style.dart';
import 'completed_api.dart';

/// Opens PDF bytes on the phone (tests give their own).
typedef PdfOpener = Future<void> Function(List<int> bytes, String name);

Future<void> _openPdf(List<int> bytes, String name) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$name');
  await file.writeAsBytes(bytes);
  final r = await OpenFile.open(file.path);
  if (r.type != ResultType.done) throw Exception(r.message);
}

/// The payable team's Completed list (scan items 8 and 9; owner: "a Completed list" with the monthly report;
/// change `payable-completed-list`): the month's payment vouchers and supplier payments (REJECTED left out by the
/// server), the total, approved vs waiting, the sum per expense head, and the printed monthly report.
class CompletedTab extends StatefulWidget {
  const CompletedTab({super.key, this.api, this.records, this.openPdf, this.clock});

  final CompletedApi? api;
  final PayableRecordsApi? records;
  final PdfOpener? openPdf;
  final DateTime Function()? clock;

  @override
  State<CompletedTab> createState() => _CompletedTabState();
}

class _CompletedTabState extends State<CompletedTab> {
  late final CompletedApi _api = widget.api ?? CompletedApi(sl<JavaApiClient>().dio, companyId: AppPreferences.getComid);
  late final PayableRecordsApi _records =
      widget.records ?? PayableRecordsApi(sl<JavaApiClient>().dio, companyId: AppPreferences.getComid);
  late DateTime _month;
  late Future<CompletedMonth> _data;
  String _search = '';
  String? _head;
  bool _printing = false;

  DateTime get _now => (widget.clock ?? DateTime.now)();
  DateTime get _from => DateTime(_month.year, _month.month, 1);
  DateTime get _to {
    final end = DateTime(_month.year, _month.month + 1, 0);
    final today = DateTime(_now.year, _now.month, _now.day);
    return end.isAfter(today) ? today : end;
  }

  bool get _isThisMonth => _month.year == _now.year && _month.month == _now.month;

  @override
  void initState() {
    super.initState();
    _month = DateTime(_now.year, _now.month);
    _data = Future.sync(() => _api.load(_from, _to));
  }

  void _shift(int months) {
    setState(() {
      _month = DateTime(_month.year, _month.month + months);
      _head = null;
      _data = Future.sync(() => _api.load(_from, _to));
    });
  }

  Future<void> _print() async {
    setState(() => _printing = true);
    try {
      final bytes = await _api.reportPdf(_from, _to);
      await (widget.openPdf ?? _openPdf)(bytes, 'payments_${DateFormat('yyyy_MM').format(_month)}.pdf');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Report not opened: $e')));
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.sizeOf(context).width >= 600 ? 20.0 : 12.0;
    return Container(
      color: AppTokens.surfacePage,
      child: RefreshIndicator(
        onRefresh: () async {
          setState(() => _data = Future.sync(() => _api.load(_from, _to)));
          try {
            await _data;
          } catch (_) {}
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(pad, 8, pad, 24),
          children: [
            // ── month switcher ──
            Row(children: [
              IconButton(key: const ValueKey('month-prev'), onPressed: () => _shift(-1), icon: const Icon(Icons.chevron_left)),
              Expanded(
                child: Column(children: [
                  Text(DateFormat('MMMM yyyy').format(_month),
                      key: const ValueKey('month-name'), style: AppTypography.heading3(color: AppTokens.textPrimary)),
                  Text('${Fmt.ddMMyyyy(_from)} – ${Fmt.ddMMyyyy(_to)}', style: AppTypography.bodySmall(color: AppTokens.textMuted)),
                ]),
              ),
              IconButton(
                  key: const ValueKey('month-next'),
                  onPressed: _isThisMonth ? null : () => _shift(1),
                  icon: const Icon(Icons.chevron_right)),
            ]),
            const SizedBox(height: 8),
            FutureBuilder<CompletedMonth>(
              future: _data,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()));
                }
                if (snap.hasError) {
                  return Panel(
                    child: Row(children: [
                      Expanded(child: Text('${snap.error}', style: AppTypography.bodySmall(color: Palette.redDanger))),
                      TextButton(onPressed: () => _shift(0), child: const Text('Retry')),
                    ]),
                  );
                }
                return _body(snap.data!);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(CompletedMonth m) {
    final heads = m.byHead;
    final shown = m.rows.where((r) => r.matches(_search) && (_head == null || r.head.trim() == _head)).toList()
      ..sort((a, b) => (b.date ?? DateTime(1900)).compareTo(a.date ?? DateTime(1900)));
    final approved = m.approved;
    final hasStatus = m.rows.any((r) => r.status.isNotEmpty);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // ── total ──
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppTokens.brandGradientStart, AppTokens.brandGradientEnd]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Paid out', style: AppTypography.bodySmall(color: AppTokens.textOnDark)),
          Text(Fmt.rm(m.total),
              key: const ValueKey('completed-total'),
              style: AppTypography.display(color: AppTokens.textOnDark, fontWeight: FontWeight.w800)),
          Text('${m.count} payments · ${heads.length} expense heads',
              style: AppTypography.bodySmall(color: AppTokens.textOnDark.withValues(alpha: 0.85))),
          if (hasStatus) ...[
            const SizedBox(height: 6),
            Text('Approved ${Fmt.rm(approved)} · Waiting ${Fmt.rm((m.total - approved).clamp(0, double.infinity))}',
                style: AppTypography.bodySmall(color: AppTokens.textOnDark, fontWeight: FontWeight.w600)),
          ],
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            key: const ValueKey('completed-report'),
            onPressed: _printing || m.count == 0 ? null : _print,
            icon: _printing
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('Monthly report (PDF)'),
          ),
        ]),
      ),
      const SizedBox(height: 12),
      // ── by expense head ──
      if (heads.isNotEmpty)
        Panel(
          title: 'By expense',
          icon: Icons.pie_chart_outline,
          trailing: _head == null
              ? null
              : TextButton(onPressed: () => setState(() => _head = null), child: const Text('Show all')),
          child: Material(
            type: MaterialType.transparency,
            child: Column(children: [
              for (final h in heads)
                InkWell(
                  key: ValueKey('completed-head-${h.head}'),
                  onTap: () => setState(() => _head = _head == h.head ? null : h.head),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(children: [
                      Icon(_head == h.head ? Icons.radio_button_checked : Icons.circle, size: _head == h.head ? 16 : 8,
                          color: AppTokens.brandPrimary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(h.head.isEmpty ? '(no expense head)' : h.head,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyMedium(
                                color: AppTokens.textPrimary, fontWeight: _head == h.head ? FontWeight.w800 : FontWeight.w600)),
                      ),
                      SizedBox(width: 36, child: Text('${h.count}', textAlign: TextAlign.right, style: AppTypography.bodySmall(color: AppTokens.textMuted))),
                      SizedBox(
                          width: 112,
                          child: Text(Fmt.rm(h.amount),
                              textAlign: TextAlign.right,
                              style: AppTypography.bodyMedium(color: AppTokens.textPrimary, fontWeight: FontWeight.w700))),
                    ]),
                  ),
                ),
              const Divider(height: 14),
              Row(children: [
                Expanded(child: Text('Total', style: AppTypography.bodyLarge(color: AppTokens.textPrimary, fontWeight: FontWeight.w800))),
                SizedBox(width: 36, child: Text('${m.count}', textAlign: TextAlign.right, style: AppTypography.bodySmall(color: AppTokens.textMuted))),
                SizedBox(
                    width: 112,
                    child: Text(Fmt.rm(m.total),
                        textAlign: TextAlign.right,
                        style: AppTypography.bodyMedium(color: AppTokens.textPrimary, fontWeight: FontWeight.w800))),
              ]),
            ]),
          ),
        ),
      const SizedBox(height: 12),
      // ── list ──
      TextField(
        key: const ValueKey('completed-search'),
        onChanged: (v) => setState(() => _search = v),
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Search number, paid to, reference',
          prefixIcon: const Icon(Icons.search, size: 20),
          filled: true,
          fillColor: AppTokens.surfaceCard,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTokens.surfaceBorder)),
        ),
      ),
      const SizedBox(height: 8),
      if (shown.isEmpty)
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text(m.rows.isEmpty ? 'No payment this month' : 'Nothing matches',
              textAlign: TextAlign.center, style: AppTypography.bodyMedium(color: AppTokens.textMuted)),
        ),
      for (final r in shown) _row(r),
    ]);
  }

  Widget _row(CompletedRow r) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: AppTokens.surfaceCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppTokens.surfaceBorder)),
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            key: ValueKey('completed-row-${r.isSupplier ? 'p' : 'v'}${r.id}'),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute<void>(builder: (_) => RecordDetailPage(record: r.record, api: _records))),
            leading: CircleAvatar(
              backgroundColor: toneColor(statusTone(r.status)).withValues(alpha: 0.12),
              child: Icon(r.isSupplier ? Icons.payments_outlined : Icons.request_quote_outlined,
                  size: 18, color: toneColor(statusTone(r.status))),
            ),
            title: Text(r.paidTo.isEmpty ? r.number : r.paidTo,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMedium(color: AppTokens.textPrimary, fontWeight: FontWeight.w600)),
            subtitle: Text(
                [
                  r.number,
                  if (r.date != null) Fmt.ddMMyyyy(r.date),
                  if (r.head.isNotEmpty) r.head,
                  if (r.status.isNotEmpty) statusLabel(r.status),
                ].join(' · '),
                maxLines: 2,
                style: AppTypography.bodySmall(color: AppTokens.textMuted)),
            trailing: Text(Fmt.rm(r.amount), style: AppTypography.bodyMedium(color: AppTokens.textPrimary, fontWeight: FontWeight.w800)),
          ),
        ),
      );
}
