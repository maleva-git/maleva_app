import 'package:flutter/material.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/theme/tokens.dart';
import 'package:maleva/core/widgets/ui/formats.dart';

import '../data/payable_record.dart';
import '../data/payable_records_api.dart';
import 'record_files.dart';
import 'record_style.dart';

/// One record: amount and status first, the facts, the lines with the total, and the files (change
/// `payable-records`). Read only. Details and files load on their own; one failing leaves the other.
/// A button on a record's page (Edit, Push to Bill…): opens a form and answers whether something was saved.
class RecordAction {
  const RecordAction(this.label, this.icon, this.run);

  final String label;
  final IconData icon;
  final Future<bool> Function(BuildContext context) run;
}

class RecordDetailPage extends StatefulWidget {
  const RecordDetailPage({super.key, required this.record, required this.api, this.actions = const []});

  final PayableRecord record;
  final PayableRecordsApi api;

  /// Edit / Push to Bill (changes `payable-po-create`, `payable-bill-form`). Saved → this page closes answering
  /// `true`, so the list reloads.
  final List<RecordAction> actions;

  @override
  State<RecordDetailPage> createState() => _RecordDetailPageState();
}

class _RecordDetailPageState extends State<RecordDetailPage> {
  late Future<RecordDetail> _detail = Future.sync(() => widget.api.detail(widget.record));
  late Future<List<RecordFile>> _files = Future.sync(() => widget.api.files(widget.record));

  @override
  Widget build(BuildContext context) {
    final r = widget.record;
    final tone = toneColor(statusTone(r.status));
    return Scaffold(
      backgroundColor: AppTokens.surfacePage,
      appBar: AppBar(
        backgroundColor: AppTokens.brandGradientStart,
        foregroundColor: AppTokens.textOnDark,
        title: Text('${r.kind.title} ${r.number}', style: AppTypography.bodyLarge(color: AppTokens.textOnDark, fontWeight: FontWeight.w700)),
      ),
      bottomNavigationBar: widget.actions.isEmpty
          ? null
          : SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                decoration: const BoxDecoration(
                    color: AppTokens.surfaceCard, border: Border(top: BorderSide(color: AppTokens.surfaceBorder))),
                child: Row(children: [
                  for (var i = 0; i < widget.actions.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(
                      child: (i == widget.actions.length - 1 ? FilledButton.icon : OutlinedButton.icon)(
                        key: ValueKey('record-action-${widget.actions[i].label}'),
                        onPressed: () async {
                          if (await widget.actions[i].run(context) && context.mounted) Navigator.pop(context, true);
                        },
                        icon: Icon(widget.actions[i].icon, size: 18),
                        label: Text(widget.actions[i].label),
                      ),
                    ),
                  ],
                ]),
              ),
            ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {
          _detail = Future.sync(() => widget.api.detail(r));
          _files = Future.sync(() => widget.api.files(r));
        }),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
          children: [
            // ── hero ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppTokens.brandGradientStart, AppTokens.brandGradientEnd]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(r.kind.icon, color: AppTokens.textOnDark, size: 18),
                  const SizedBox(width: 6),
                  Text(r.kind.title, style: AppTypography.bodySmall(color: AppTokens.textOnDark)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Text(statusLabel(r.status),
                        style: AppTypography.badgeText(color: tone, fontWeight: FontWeight.w800)),
                  ),
                ]),
                const SizedBox(height: 10),
                Text(Fmt.rm(r.amount),
                    style: AppTypography.display(color: AppTokens.textOnDark, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(r.party.isEmpty ? r.number : r.party,
                    style: AppTypography.bodyLarge(color: AppTokens.textOnDark, fontWeight: FontWeight.w600)),
                Text([r.number, if (r.date != null) Fmt.ddMMyyyy(r.date), if (r.tag.isNotEmpty) r.tag].join(' · '),
                    style: AppTypography.bodySmall(color: AppTokens.textOnDark.withValues(alpha: 0.85))),
              ]),
            ),
            const SizedBox(height: 12),
            FutureBuilder<RecordDetail>(
              future: _detail,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Panel(child: Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())));
                }
                if (snap.hasError) {
                  return Panel(
                    child: _Failed(
                        message: '${snap.error}', onRetry: () => setState(() => _detail = Future.sync(() => widget.api.detail(r)))),
                  );
                }
                final d = snap.data!;
                final facts = d.facts.where((f) => f.$2.trim().isNotEmpty).toList();
                return Column(children: [
                  Panel(
                    title: 'Details',
                    icon: Icons.info_outline,
                    child: Column(children: [
                      for (final f in facts) _Fact(label: f.$1, value: f.$2),
                      if (facts.isEmpty)
                        Text('No more details', style: AppTypography.bodySmall(color: AppTokens.textMuted)),
                    ]),
                  ),
                  if (d.lines.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Panel(
                      title: d.lineTitle,
                      icon: Icons.list_alt_outlined,
                      trailing: SoftChip(text: '${d.lines.length}'),
                      child: Column(children: [
                        for (final l in d.lines) _Line(line: l),
                        const Divider(height: 18),
                        Row(children: [
                          Expanded(
                              child: Text('Total',
                                  style: AppTypography.bodyLarge(color: AppTokens.textPrimary, fontWeight: FontWeight.w700))),
                          Text(Fmt.rm(d.total),
                              style: AppTypography.bodyLarge(color: AppTokens.textPrimary, fontWeight: FontWeight.w800)),
                        ]),
                      ]),
                    ),
                  ],
                ]);
              },
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<RecordFile>>(
              future: _files,
              builder: (context, snap) {
                Widget body;
                String? count;
                if (snap.connectionState != ConnectionState.done) {
                  body = const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()));
                } else if (snap.hasError) {
                  body = _Failed(message: '${snap.error}', onRetry: () => setState(() => _files = Future.sync(() => widget.api.files(r))));
                } else if (snap.data!.isEmpty) {
                  body = Row(children: [
                    const Icon(Icons.warning_amber_rounded, size: 18, color: Palette.amberGold),
                    const SizedBox(width: 6),
                    Expanded(
                        child: Text('No file attached to this ${r.kind.title.toLowerCase()}.',
                            style: AppTypography.bodySmall(color: AppTokens.textMuted))),
                  ]);
                } else {
                  count = '${snap.data!.length}';
                  body = RecordFilesGrid(files: snap.data!);
                }
                return Panel(
                  title: 'Files',
                  icon: Icons.attach_file,
                  trailing: count == null ? null : SoftChip(text: count),
                  child: body,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 110, child: Text(label, style: AppTypography.bodySmall(color: AppTokens.textMuted))),
        Expanded(
          child: SelectableText(value,
              style: AppTypography.bodyMedium(color: AppTokens.textPrimary, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.line});

  final RecordLine line;

  @override
  Widget build(BuildContext context) {
    final qty = line.quantity;
    final rate = line.rate;
    final math = qty != null && qty != 0 && rate != null && rate != 0
        ? '${qty % 1 == 0 ? qty.toStringAsFixed(0) : qty} × ${Fmt.rm(rate)}'
        : '';
    final sub = [line.subtitle, math].where((t) => t.isNotEmpty).join(' · ');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(line.title,
                style: AppTypography.bodyMedium(color: AppTokens.textPrimary, fontWeight: FontWeight.w600)),
            if (sub.isNotEmpty) Text(sub, style: AppTypography.bodySmall(color: AppTokens.textMuted)),
          ]),
        ),
        const SizedBox(width: 8),
        Text(Fmt.rm(line.amount), style: AppTypography.bodyMedium(color: AppTokens.textPrimary, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class _Failed extends StatelessWidget {
  const _Failed({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Icon(Icons.error_outline, size: 16, color: Palette.redDanger),
      const SizedBox(width: 6),
      Expanded(child: Text(message, maxLines: 3, style: AppTypography.bodySmall(color: Palette.redDanger))),
      TextButton(onPressed: onRetry, child: const Text('Retry')),
    ]);
  }
}
