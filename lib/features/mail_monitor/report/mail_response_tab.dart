import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/mailmonitor/mail_monitor_api.dart';
import 'package:maleva/core/mailmonitor/response_report_models.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/theme/tokens.dart';
import 'package:maleva/core/widgets/ui/feedback.dart';
import 'package:maleva/core/widgets/ui/states.dart';
import 'package:maleva/core/widgets/ui/status_pill.dart';
import 'package:maleva/features/mail_monitor/view/mail_message_page.dart';

import 'response_pdf.dart';
import 'response_report_cubit.dart';
import 'response_rules.dart';
import 'response_widgets.dart';
import 'summary_speaker.dart';

/// The Super Admin's Mail Response tab: the web's Mail response report
/// (`/mail-monitor/response-report`) on the same Java API, in the app's design, with the AI summary
/// read aloud (change `mail-response-report-tab`).
class MailResponseTab extends StatefulWidget {
  const MailResponseTab({super.key, this.api, this.speaker, this.clock, this.pdf});

  /// For tests; the app uses the registered [MailMonitorApi], the device voice and the real PDF.
  final MailMonitorApi? api;
  final SummarySpeaker? speaker;
  final DateTime Function()? clock;
  final ResponsePdf? pdf;

  @override
  State<MailResponseTab> createState() => _MailResponseTabState();
}

class _MailResponseTabState extends State<MailResponseTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final api = widget.api ?? sl<MailMonitorApi>();
    return BlocProvider(
      create: (_) => ResponseReportCubit(api, widget.speaker ?? TtsSummarySpeaker(), clock: widget.clock)..load(),
      child: _ReportView(pdf: widget.pdf ?? ResponsePdf(api), clock: widget.clock ?? DateTime.now),
    );
  }
}

class _ReportView extends StatelessWidget {
  const _ReportView({required this.pdf, required this.clock});

  final ResponsePdf pdf;
  final DateTime Function() clock;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTokens.surfacePage,
      child: LayoutBuilder(builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;
        return BlocBuilder<ResponseReportCubit, ResponseReportState>(builder: (context, s) {
          final cubit = context.read<ResponseReportCubit>();
          final report = s.report;
          final pad = EdgeInsets.fromLTRB(isTablet ? 20 : 12, 4, isTablet ? 20 : 12, 24);
          final header = _Header(state: s, pdf: pdf, clock: clock);

          if (report == null) {
            return ListView(padding: pad, children: [
              header,
              const SizedBox(height: 12),
              if (s.loading)
                const SizedBox(height: 420, child: SkeletonList(count: 4, padding: EdgeInsets.zero))
              else
                ErrorState(title: _errorTitle(s.errorCode), message: s.error, onRetry: cubit.load),
            ]);
          }

          return RefreshIndicator(
            color: AppTokens.brandGradientStart,
            onRefresh: cubit.load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: pad,
              children: [
                header,
                if (s.loading) const LinearProgressIndicator(minHeight: 2, color: AppTokens.brandGradientStart),
                if (s.error != null) ...[
                  const SizedBox(height: 8),
                  _InlineError(message: s.error!, onRetry: cubit.load),
                ],
                const SizedBox(height: 12),
                _SpotlightRow(report: report, isTablet: isTablet, range: s.range),
                const SizedBox(height: 10),
                _Numbers(company: report.company, isTablet: isTablet),
                const SizedBox(height: 10),
                _DailyCard(company: report.company),
                const SizedBox(height: 10),
                _AiCard(state: s),
                const SizedBox(height: 14),
                _MailboxList(state: s, report: report, isTablet: isTablet),
                const SizedBox(height: 10),
                Text(
                  'Only customer mail counts (not internal, no-reply, newsletters or auto-replies). Reply time runs '
                  '24 hours a day. Shared mailboxes are measured as a team and shown under their responsible '
                  'employee. The numbers update every 15 minutes.',
                  style: AppTypography.bodySmall(color: AppTokens.textMuted),
                ),
              ],
            ),
          );
        });
      }),
    );
  }

  static String _errorTitle(int? code) => switch (code) {
        403 => 'Only the Super Admin can see the mail response report',
        503 => 'The mail monitor is not set up yet',
        _ => 'The mail response report could not be loaded',
      };
}

/// The blue header: title, range presets and dates, the range shown, PDF buttons.
class _Header extends StatelessWidget {
  const _Header({required this.state, required this.pdf, required this.clock});

  final ResponseReportState state;
  final ResponsePdf pdf;
  final DateTime Function() clock;

  Future<void> _pickDates(BuildContext context) async {
    final cubit = context.read<ResponseReportCubit>();
    final today = malaysiaDay(clock());
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(today.year - 2),
      lastDate: today,
      initialDateRange: DateTimeRange(start: DateTime.parse(state.range.from), end: DateTime.parse(state.range.to)),
      helpText: 'Report dates',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppTokens.brandGradientStart),
        ),
        child: child!,
      ),
    );
    if (picked != null) await cubit.chooseDates(picked.start, picked.end);
  }

  Future<void> _pdf(BuildContext context, {required bool share}) async {
    final range = state.report == null ? state.range : ReportRange(state.report!.from, state.report!.to);
    try {
      showSnack(context, share ? 'Preparing the PDF…' : 'Opening the PDF…', kind: SnackKind.info);
      await (share ? pdf.share(range) : pdf.view(range));
    } catch (e) {
      if (context.mounted) showSnack(context, '$e', kind: SnackKind.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ResponseReportCubit>();
    final shown = state.report == null ? state.range : ReportRange(state.report!.from, state.report!.to);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTokens.brandGradientStart, AppTokens.brandGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(reportRadius),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: AppTokens.textOnDark.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.timer_outlined, color: AppTokens.textOnDark, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Mail response report',
                  style: AppTypography.heading1(color: AppTokens.textOnDark, fontWeight: FontWeight.w700)),
              Text('How fast each mailbox replies to customers, against its target (15 minutes unless changed).',
                  style: AppTypography.bodySmall(color: AppTokens.textOnDark.withValues(alpha: 0.8))),
            ]),
          ),
        ]),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final p in RangePreset.values)
            HeaderPill(label: presetLabel(p), selected: state.preset == p, onTap: () => cubit.choosePreset(p)),
          HeaderPill(
            label: state.preset == null ? 'Custom dates' : 'Pick dates',
            icon: Icons.date_range_outlined,
            selected: state.preset == null,
            onTap: () => _pickDates(context),
          ),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          const Icon(Icons.event_outlined, size: 15, color: AppTokens.textOnDark),
          const SizedBox(width: 6),
          Expanded(
            child: Text('Showing ${rangeText(shown)}',
                style: AppTypography.bodySmall(color: AppTokens.textOnDark, fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: [
          HeaderPill(label: 'View PDF', icon: Icons.picture_as_pdf_outlined, onTap: () => _pdf(context, share: false)),
          HeaderPill(label: 'Share PDF', icon: Icons.share_outlined, onTap: () => _pdf(context, share: true)),
        ]),
      ]),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
        decoration: cardBox(color: Palette.rose.withValues(alpha: 0.06), border: Palette.rose.withValues(alpha: 0.3)),
        child: Row(children: [
          const Icon(Icons.error_outline, size: 16, color: Palette.rose),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: AppTypography.bodySmall(color: Palette.rose))),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ]),
      );
}

/// Fastest replier, needs attention, whole company.
class _SpotlightRow extends StatelessWidget {
  const _SpotlightRow({required this.report, required this.isTablet, required this.range});

  final ResponseReport report;
  final bool isTablet;
  final ReportRange range;

  @override
  Widget build(BuildContext context) {
    final s = spotlight(report.mailboxes);
    final c = report.company;
    void open(ResponseRow r) => showLateSheet(context, r, range);
    String line(ResponseRow r) =>
        '${pctText(r.withinTargetPct)} within ${r.targetMinutes} min · average ${minutesText(r.numbers.avgMinutes)}';

    final cards = <Widget>[
      if (s.best != null)
        SpotlightCard(
          label: 'Fastest replier',
          icon: Icons.emoji_events_outlined,
          color: AppTokens.statusSuccess,
          title: ownerText(s.best!),
          subtitle: s.best!.address,
          line: line(s.best!),
          onTap: () => open(s.best!),
        )
      else
        const SpotlightCard(
          label: 'Fastest replier',
          icon: Icons.emoji_events_outlined,
          title: 'No customer mail yet',
          line: 'Nothing in these dates.',
        ),
      if (s.worst != null)
        SpotlightCard(
          label: 'Needs attention',
          icon: Icons.warning_amber_rounded,
          color: Palette.rose,
          title: ownerText(s.worst!),
          subtitle: s.worst!.address,
          line: '${line(s.worst!)}${s.worst!.numbers.waiting > 0 ? ' · ${s.worst!.numbers.waiting} waiting' : ''}',
          onTap: () => open(s.worst!),
        )
      else
        SpotlightCard(
          label: 'Needs attention',
          icon: Icons.celebration_outlined,
          color: AppTokens.statusSuccess,
          title: s.counted > 0 ? 'Everyone on target' : 'Nothing to flag',
          line: s.counted > 0 ? 'Every counted mailbox replied in time.' : 'No mailbox has customer mail yet.',
        ),
      SpotlightCard(
        label: 'Whole company',
        icon: Icons.groups_outlined,
        title: 'Average ${minutesText(c.avgMinutes)}',
        subtitle: '${pctText(c.withinTargetPct)} replied on time · median ${minutesText(c.medianMinutes)}',
        line: '${s.onTarget} of ${s.counted} mailboxes on target',
      ),
    ];
    return _Columns(columns: isTablet ? 3 : 1, children: cards);
  }
}

class _Numbers extends StatelessWidget {
  const _Numbers({required this.company, required this.isTablet});

  final ResponseNumbers company;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final c = company;
    final pct = c.withinTargetPct;
    final pctColor = pct == null
        ? AppTokens.brandDark
        : pct >= 90
            ? AppTokens.statusSuccess
            : pct >= 70
                ? AppTokens.statusWarning
                : Palette.rose;
    return _Columns(columns: isTablet ? 4 : 2, children: [
      NumberTile(
          label: 'Customer mails', icon: Icons.mail_outline, value: '${c.received}', note: '${c.replied} replied'),
      NumberTile(
        label: 'Replied within target',
        icon: Icons.verified_outlined,
        value: pctText(pct),
        valueColor: pctColor,
        note: '${c.withinTarget} of ${c.received}',
      ),
      NumberTile(
        label: 'Average reply time',
        icon: Icons.timer_outlined,
        value: minutesText(c.avgMinutes),
        note: 'median ${minutesText(c.medianMinutes)} · slowest ${minutesText(c.maxMinutes)}',
      ),
      NumberTile(
        label: 'Still waiting',
        icon: Icons.hourglass_bottom_outlined,
        value: '${c.waiting}',
        valueColor: c.waiting > 0 ? Palette.rose : AppTokens.statusSuccess,
      ),
    ]);
  }
}

class _DailyCard extends StatelessWidget {
  const _DailyCard({required this.company});

  final ResponseNumbers company;

  @override
  Widget build(BuildContext context) {
    Widget key(Color c, String t) => Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 4),
          Text(t, style: AppTypography.bodySmall(color: AppTokens.textMuted)),
        ]);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: cardBox(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text('All mailboxes per day', style: AppTypography.heading3(color: AppTokens.brandDark))),
          key(AppTokens.surfaceBorder, 'received'),
          const SizedBox(width: 10),
          key(AppTokens.statusSuccess, 'within target'),
        ]),
        const SizedBox(height: 10),
        DailyBarsView(daily: company.daily, height: 56),
      ]),
    );
  }
}

/// The AI summary: written only on tap, shown as points, read aloud on tap.
class _AiCard extends StatelessWidget {
  const _AiCard({required this.state});

  final ResponseReportState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ResponseReportCubit>();
    final points = state.summary?.points ?? const <String>[];
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: cardBox(color: AppTokens.brandLight, border: AppTokens.brandMid.withValues(alpha: 0.3)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.auto_awesome_outlined, size: 18, color: AppTokens.brandGradientStart),
          const SizedBox(width: 8),
          Expanded(child: Text('AI summary', style: AppTypography.heading3(color: AppTokens.brandDark))),
        ]),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: [
          FilledButton.icon(
            onPressed: state.summaryLoading ? null : cubit.writeSummary,
            style: FilledButton.styleFrom(backgroundColor: AppTokens.brandGradientStart),
            icon: state.summaryLoading
                ? const SizedBox(
                    width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.edit_note, size: 18),
            label: Text(state.summaryLoading
                ? 'Writing…'
                : state.summary == null
                    ? 'Write summary'
                    : 'Write again'),
          ),
          if (points.isNotEmpty)
            OutlinedButton.icon(
              onPressed: cubit.toggleSpeech,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTokens.brandGradientStart,
                side: const BorderSide(color: AppTokens.brandGradientStart),
                backgroundColor: AppTokens.surfaceCard,
              ),
              icon: Icon(state.speaking ? Icons.stop_circle_outlined : Icons.volume_up_outlined, size: 18),
              label: Text(state.speaking ? 'Stop' : 'Read aloud'),
            ),
        ]),
        if (state.summaryError != null) ...[
          const SizedBox(height: 8),
          Text(state.summaryError!, style: AppTypography.bodySmall(color: Palette.rose)),
        ],
        if (state.speechUnavailable) ...[
          const SizedBox(height: 8),
          Text('Read aloud is not available on this device.', style: AppTypography.bodySmall(color: Palette.rose)),
        ],
        if (points.isNotEmpty) ...[
          const SizedBox(height: 10),
          for (final p in points)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  margin: const EdgeInsets.only(top: 7, right: 8),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: AppTokens.brandGradientStart, shape: BoxShape.circle),
                ),
                Expanded(child: Text(p, style: AppTypography.bodyMedium(color: AppTokens.textPrimary))),
              ]),
            ),
        ],
        const SizedBox(height: 4),
        Text('AI summary of the numbers. No mail content was sent.',
            style: AppTypography.bodySmall(color: AppTokens.textMuted)),
      ]),
    );
  }
}

class _MailboxList extends StatelessWidget {
  const _MailboxList({required this.state, required this.report, required this.isTablet});

  final ResponseReportState state;
  final ResponseReport report;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ResponseReportCubit>();
    final rows = ranked(report.mailboxes, fastest: state.fastestFirst);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            Text('All employees', style: AppTypography.heading2(color: AppTokens.brandDark)),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Slowest first')),
                ButtonSegment(value: true, label: Text('Fastest first')),
              ],
              selected: {state.fastestFirst},
              showSelectedIcon: false,
              onSelectionChanged: (v) => cubit.setFastestFirst(v.first),
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: AppTokens.brandGradientStart,
                selectedForegroundColor: AppTokens.textOnDark,
                foregroundColor: AppTokens.brandDark,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ]),
      const SizedBox(height: 10),
      if (rows.isEmpty)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: cardBox(),
          alignment: Alignment.center,
          child: Text('No mailboxes are monitored yet.', style: AppTypography.bodySmall(color: AppTokens.textMuted)),
        )
      else
        _Columns(columns: isTablet ? 2 : 1, children: [
          for (var i = 0; i < rows.length; i++)
            MailboxResponseCard(
              rank: i + 1,
              row: rows[i],
              onTap: () => showLateSheet(context, rows[i], state.range),
            ),
        ]),
    ]);
  }
}

/// Rows of [columns] equal cells, the same height per row.
class _Columns extends StatelessWidget {
  const _Columns({required this.columns, required this.children});

  final int columns;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      for (var i = 0; i < children.length; i += columns)
        Padding(
          padding: EdgeInsets.only(bottom: i + columns < children.length ? 10 : 0),
          child: IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              for (var c = 0; c < columns; c++) ...[
                if (c > 0) const SizedBox(width: 10),
                Expanded(child: i + c < children.length ? children[i + c] : const SizedBox.shrink()),
              ],
            ]),
          ),
        ),
    ]);
  }
}

/// One mailbox's slowest replies and mails still waiting; tapping one opens it read-only.
Future<void> showLateSheet(BuildContext context, ResponseRow row, ReportRange range) {
  final api = context.read<ResponseReportCubit>().api;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTokens.surfaceCard,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => BlocProvider(
      create: (_) => LateMailCubit(api, row.mailboxId, range)..load(),
      child: _LateSheet(row: row, range: range, api: api),
    ),
  );
}

class _LateSheet extends StatelessWidget {
  const _LateSheet({required this.row, required this.range, required this.api});

  final ResponseRow row;
  final ReportRange range;
  final MailMonitorApi api;

  @override
  Widget build(BuildContext context) {
    final band = bandOf(row);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (context, controller) => BlocBuilder<LateMailCubit, LateMailState>(
        builder: (context, s) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: AppTokens.surfaceBorder, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text(ownerText(row), style: AppTypography.heading2(color: AppTokens.brandDark)),
            Text(row.address, style: AppTypography.bodySmall(color: AppTokens.textMuted)),
            const SizedBox(height: 4),
            Text('${rangeText(range)} · target ${row.targetMinutes} min',
                style: AppTypography.bodySmall(color: AppTokens.textMuted)),
            const SizedBox(height: 8),
            Align(alignment: Alignment.centerLeft, child: StatusPill(bandLabel(band), tone: bandTone(band))),
            const SizedBox(height: 12),
            if (s.loading)
              const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator(color: AppTokens.brandGradientStart)))
            else if (s.error != null)
              ErrorState(
                  title: 'Could not load the late list',
                  message: s.error,
                  onRetry: () => context.read<LateMailCubit>().load())
            else ...[
              _LateSection(
                title: 'Slowest replies',
                items: s.list!.slowest,
                empty: 'No replies in this range.',
                onOpen: (uid) => _open(context, uid),
              ),
              const SizedBox(height: 12),
              _LateSection(
                title: 'Still waiting for a reply (oldest first)',
                items: s.list!.waiting,
                empty: 'Nothing waiting.',
                onOpen: (uid) => _open(context, uid),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, int uid) => Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => MailMessagePage(api: api, mailboxId: row.mailboxId, uid: uid),
      ));
}

class _LateSection extends StatelessWidget {
  const _LateSection({required this.title, required this.items, required this.empty, required this.onOpen});

  final String title;
  final List<LateItem> items;
  final String empty;
  final void Function(int uid) onOpen;

  static final _when = DateFormat('d MMM, h:mm a');

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: AppTypography.heading3(color: AppTokens.brandDark)),
      const SizedBox(height: 6),
      if (items.isEmpty) Text(empty, style: AppTypography.bodySmall(color: AppTokens.textMuted)),
      for (final i in items)
        InkWell(
          onTap: i.uid > 0 ? () => onOpen(i.uid) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppTokens.surfaceBorder))),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Arrived ${i.receivedAt == null ? '—' : _when.format(i.receivedAt!)}',
                      style: AppTypography.bodyMedium(color: AppTokens.textPrimary)),
                  Text(
                    '${i.senderDomain == null ? 'sender unknown' : 'from ${i.senderDomain}'}'
                    '${i.firstReplyAt == null ? '' : ' · replied ${_when.format(i.firstReplyAt!)}'}',
                    style: AppTypography.bodySmall(color: AppTokens.textMuted),
                  ),
                ]),
              ),
              Text(i.waiting ? 'No reply' : minutesText(i.minutes),
                  style: AppTypography.heading3(
                      color: i.waiting ? Palette.rose : AppTokens.brandDark, fontWeight: FontWeight.w700)),
              if (i.uid > 0) const Icon(Icons.chevron_right, color: AppTokens.textMuted),
            ]),
          ),
        ),
    ]);
  }
}
