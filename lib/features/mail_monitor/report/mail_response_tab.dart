import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/mailmonitor/mail_monitor_api.dart';
import 'package:maleva/core/mailmonitor/response_report_models.dart';
import 'package:maleva/core/theme/app_theme.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/theme/status_tone.dart';
import 'package:maleva/core/theme/tokens.dart';
import 'package:maleva/core/widgets/ui/feedback.dart';
import 'package:maleva/core/widgets/ui/states.dart';
import 'package:maleva/core/widgets/ui/status_pill.dart';
import 'package:maleva/features/mail_monitor/view/mail_message_page.dart';

import 'booking_speed_page.dart';
import 'response_pdf.dart';
import 'response_report_cubit.dart';
import 'response_rules.dart';
import 'response_widgets.dart';
import 'summary_language.dart';
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
                if (report.office != null) ...[
                  const SizedBox(height: 10),
                  _OfficeLine(office: report.office!),
                ],
                const SizedBox(height: 12),
                _SpotlightRow(report: report, isTablet: isTablet, range: s.range),
                const SizedBox(height: 10),
                _Numbers(
                  company: report.company,
                  isTablet: isTablet,
                  opening: report.office == null ? null : clockText(report.office!.open),
                ),
                const SizedBox(height: 10),
                _DailyCard(company: report.company),
                const SizedBox(height: 10),
                _AiCard(state: s),
                if (report.judged) ...[
                  const SizedBox(height: 6),
                  Text(
                    'On track, Watch, Needs support and Not enough data are decided by fixed rules on the numbers, not by '
                    'the AI. A mailbox with a failed scan, no Sent folder or fewer than 20 mails is not judged.',
                    style: AppTypography.bodySmall(color: AppTokens.textMuted),
                  ),
                ],
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
          HeaderPill(
            label: 'Booking speed',
            icon: Icons.speed_outlined,
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => BookingSpeedPage(
                api: context.read<ResponseReportCubit>().api,
                clock: clock,
                range: state.range,
                preset: state.preset,
              ),
            )),
          ),
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
    final s = spotlightOf(report);
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
        line: report.judged
            ? '${s.onTarget} of ${s.counted} mailboxes with enough data on track'
            : '${s.onTarget} of ${s.counted} mailboxes on target',
      ),
    ];
    return TileColumns(columns: isTablet ? 3 : 1, children: cards);
  }
}

class _Numbers extends StatelessWidget {
  const _Numbers({required this.company, required this.isTablet, this.opening});

  final ResponseNumbers company;
  final bool isTablet;

  /// "8:30 am": the office opening, for the after-hours tile.
  final String? opening;

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
    return TileColumns(columns: isTablet ? (c.afterHoursReceived != null ? 5 : 4) : 2, minCellHeight: 124, children: [
      if (c.sorting?.sorted ?? false)
        NumberTile(
            label: 'Needed a reply',
            icon: Icons.mail_outline,
            value: '${c.received}',
            note: 'of ${c.sorting!.customerMails} customer mails · ${c.replied} replied')
      else
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
        note: (c.waitingOverDay ?? 0) > 0 ? '${c.waitingOverDay} over one office day' : null,
      ),
      if (c.afterHoursReceived != null)
        NumberTile(
          label: 'Arrived after office hours',
          icon: Icons.nightlight_outlined,
          value: '${c.afterHoursReceived}',
          note: '${c.afterHoursAnsweredBeforeOpen ?? 0} answered before ${opening ?? '8:30 am'}',
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
/// "Office hours Mon–Sat 8:30 am – 8:00 pm (Malaysia), public holidays closed" and the holidays in the range.
class _OfficeLine extends StatelessWidget {
  const _OfficeLine({required this.office});

  final OfficeHours office;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: cardBox(color: AppTokens.brandLight, border: AppTokens.brandMid.withValues(alpha: 0.3)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.schedule, size: 16, color: AppTokens.brandGradientStart),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '${officeText(office)}. Reply times count office time only; mail that arrives when the office is closed '
            'starts counting at the next opening.'
            '${office.holidays.isEmpty ? '' : ' Holidays in these dates: ${office.holidays.join(', ')}.'}',
            style: AppTypography.bodySmall(color: AppTokens.brandDark, fontWeight: FontWeight.w600),
          ),
        ),
      ]),
    );
  }
}

/// One AI point, coloured by the rule category it is about; the mailbox opens its late mail.
class _PointCard extends StatelessWidget {
  const _PointCard({required this.point, required this.onOpen});

  final SummaryPoint point;
  final void Function(int mailboxId) onOpen;

  @override
  Widget build(BuildContext context) {
    final category = point.category;
    final tone = category == null ? null : categoryTone(category);
    final mc = context.mc;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: cardBox(
        color: tone == null ? AppTokens.surfaceCard : mc.toneBg(tone),
        border: tone == null ? AppTokens.surfaceBorder : mc.toneFg(tone).withValues(alpha: 0.3),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 8, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
          if (category != null) StatusPill(categoryLabel(category), tone: tone),
          if (point.mailboxId != null && point.mailbox != null)
            InkWell(
              onTap: () => onOpen(point.mailboxId!),
              child: Text(point.mailbox!,
                  style: AppTypography.bodySmall(color: AppTokens.brandGradientStart, fontWeight: FontWeight.w700)
                      .copyWith(decoration: TextDecoration.underline)),
            ),
          if (!point.checked) Text('plain figures', style: AppTypography.bodySmall(color: AppTokens.textMuted)),
        ]),
        const SizedBox(height: 4),
        Text(point.text, style: AppTypography.bodyMedium(color: AppTokens.textPrimary)),
        if (point.why != null) ...[
          const SizedBox(height: 4),
          Text.rich(TextSpan(children: [
            const TextSpan(text: 'Why: ', style: TextStyle(fontWeight: FontWeight.w700)),
            TextSpan(text: point.why),
          ]), style: AppTypography.bodySmall(color: AppTokens.textSecondary)),
        ],
        if (point.suggestion != null) ...[
          const SizedBox(height: 4),
          Text('→ ${point.suggestion}',
              style: AppTypography.bodySmall(color: AppTokens.brandDark, fontWeight: FontWeight.w600)),
        ],
      ]),
    );
  }
}

class _AiCard extends StatelessWidget {
  const _AiCard({required this.state});

  final ResponseReportState state;

  /// The point's mailbox opens its late mail, as tapping its card does.
  void _openMailbox(BuildContext context, int mailboxId) {
    final row = state.report?.mailboxes.where((r) => r.mailboxId == mailboxId).firstOrNull;
    if (row != null) showLateSheet(context, row, state.range);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ResponseReportCubit>();
    final points = state.summary?.points ?? const <String>[];
    final items = state.summary?.items ?? const <SummaryPoint>[];
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
        Row(children: [
          const Icon(Icons.translate, size: 16, color: AppTokens.brandGradientStart),
          const SizedBox(width: 6),
          Text('Language', style: AppTypography.bodySmall(color: AppTokens.brandDark, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 6),
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final l in SummaryLanguage.all)
            ChoiceChip(
              label: Text(l.label),
              selected: state.language == l,
              onSelected: state.summaryLoading ? null : (_) => cubit.chooseLanguage(l),
              showCheckmark: false,
              selectedColor: AppTokens.brandGradientStart,
              backgroundColor: AppTokens.surfaceCard,
              side: BorderSide(
                  color:
                      state.language == l ? AppTokens.brandGradientStart : AppTokens.brandMid.withValues(alpha: 0.3)),
              labelStyle: AppTypography.bodySmall(
                color: state.language == l ? AppTokens.textOnDark : AppTokens.brandDark,
                fontWeight: FontWeight.w600,
              ),
              visualDensity: VisualDensity.compact,
            ),
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
        if (state.speechProblem != null) ...[
          const SizedBox(height: 8),
          Text(state.speechProblem!, style: AppTypography.bodySmall(color: Palette.rose)),
        ],
        if (items.isNotEmpty) ...[
          const SizedBox(height: 10),
          for (final p in items) _PointCard(point: p, onOpen: (id) => _openMailbox(context, id)),
        ] else if (points.isNotEmpty) ...[
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
        Text(
            'AI summary of the numbers, written in ${state.language.name}. No mail content and no names were sent; '
            'every figure is checked against the report. Based on mail reply times only - check with the person '
            'before acting.',
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
        TileColumns(columns: isTablet ? 2 : 1, children: [
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
    final (label, tone) = statusOf(row);
    final reasons = reasonTexts(row);
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
            Align(alignment: Alignment.centerLeft, child: StatusPill(label, tone: tone)),
            if (reasons.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(reasons.join(' · '), style: AppTypography.bodySmall(color: AppTokens.textMuted)),
            ],
            if (readingText(row) != null) ...[
              const SizedBox(height: 2),
              Text(readingText(row)!, style: AppTypography.bodySmall(color: AppTokens.textMuted)),
            ],
            if (sortingText(row.numbers.sorting) != null) ...[
              const SizedBox(height: 2),
              Text(sortingText(row.numbers.sorting)!,
                  style: AppTypography.bodySmall(color: AppTokens.brandGradientStart, fontWeight: FontWeight.w600)),
            ],
            if (row.numbers.sorting?.sorted ?? false) ...[
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 6, children: [
                for (final (tab, text) in [
                  (SheetTab.late, 'Late'),
                  (SheetTab.counted, 'Needed a reply (${row.numbers.sorting!.needReply})'),
                  (SheetTab.notTheirs, 'Not theirs (${row.numbers.sorting!.notTheirs})'),
                ])
                  ChoiceChip(
                    label: Text(text),
                    selected: s.tab == tab,
                    onSelected: (_) => context.read<LateMailCubit>().choose(tab),
                    selectedColor: AppTokens.brandLight,
                  ),
              ]),
            ],
            const SizedBox(height: 12),
            if (s.tab != SheetTab.late)
              if (s.mailsLoading)
                const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator(color: AppTokens.brandGradientStart)))
              else if (s.mailsError != null)
                ErrorState(
                    title: 'Could not load the mails',
                    message: s.mailsError,
                    onRetry: () => context.read<LateMailCubit>().choose(s.tab))
              else
                _LateSection(
                  title: s.tab == SheetTab.counted
                      ? 'Mails that needed this mailbox\'s reply'
                      : 'Mails that did not need its reply, with the reason',
                  items: s.mails[s.tab]?.items ?? const [],
                  empty: s.tab == SheetTab.counted ? 'No mail needed a reply in this range.' : 'Every mail needed its reply.',
                  onOpen: (uid) => _open(context, uid),
                  onWrong: (item) => _wrong(context, item),
                  showReason: true,
                )
            else if (s.loading)
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
                onWrong: (item) => _wrong(context, item),
              ),
              const SizedBox(height: 12),
              _LateSection(
                title: 'Still waiting for a reply (oldest first)',
                items: s.list!.waiting,
                empty: 'Nothing waiting.',
                onOpen: (uid) => _open(context, uid),
                onWrong: (item) => _wrong(context, item),
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

  /// "Wrong?": the Super Admin says whether the mail needed this mailbox's reply (mail-team-credit-and-corrections).
  Future<void> _wrong(BuildContext context, LateItem item) async {
    final cubit = context.read<LateMailCubit>();
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppTokens.surfaceCard,
      builder: (sheet) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            title: Text('Is this right?', style: AppTypography.heading3(color: AppTokens.brandDark)),
            subtitle: Text('Now: ${relevanceText(item.relevance)}${item.correction != null ? ' (corrected)' : ''}'),
          ),
          if (!item.counted)
            ListTile(
              leading: const Icon(Icons.mark_email_unread_outlined),
              title: const Text('It needed this mailbox\'s reply'),
              onTap: () => Navigator.pop(sheet, 'MINE'),
            ),
          if (item.counted)
            ListTile(
              leading: const Icon(Icons.do_not_disturb_on_outlined),
              title: const Text('It did not need its reply'),
              onTap: () => Navigator.pop(sheet, 'NOT_MINE'),
            ),
          if (item.correction != null)
            ListTile(
              leading: const Icon(Icons.undo),
              title: const Text('Back to the rule'),
              onTap: () => Navigator.pop(sheet, ''),
            ),
        ]),
      ),
    );
    if (choice == null) return;
    final error = await cubit.correct(item.id, choice.isEmpty ? null : choice);
    if (context.mounted) {
      showSnack(context, error ?? (choice.isEmpty ? 'Back to the rule' : 'Correction saved'),
          kind: error == null ? SnackKind.success : SnackKind.error);
    }
  }
}

class _LateSection extends StatelessWidget {
  const _LateSection(
      {required this.title,
      required this.items,
      required this.empty,
      required this.onOpen,
      this.onWrong,
      this.showReason = false});

  final String title;
  final List<LateItem> items;
  final String empty;
  final void Function(int uid) onOpen;

  /// Shows who each mail was for (the proof lists).
  final bool showReason;

  /// "Wrong?" on a mail; null hides it.
  final void Function(LateItem item)? onWrong;

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
                    '${i.firstReplyAt == null ? '' : ' · replied ${_when.format(i.firstReplyAt!)}'}'
                    '${i.afterHours ? ' · arrived after office hours' : ''}'
                    '${i.repliedBy == null ? '' : ' · replied by ${i.repliedBy}'}'
                    '${i.handledFor == null ? '' : ' · handled for ${i.handledFor}'}',
                    style: AppTypography.bodySmall(color: AppTokens.textMuted),
                  ),
                  if (showReason || i.correction != null || (onWrong != null && i.id > 0)) ...[
                    const SizedBox(height: 3),
                    Wrap(spacing: 6, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
                      if (showReason)
                        StatusPill(relevanceText(i.relevance),
                            tone: i.relevance == 'MINE' ? StatusTone.primary : StatusTone.neutral),
                      if (i.correction != null) const StatusPill('Corrected', tone: StatusTone.warning),
                      if (onWrong != null && i.id > 0)
                        InkWell(
                          onTap: () => onWrong!(i),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            child: Text('Wrong?',
                                style: AppTypography.bodySmall(color: AppTokens.brandGradientStart, fontWeight: FontWeight.w700)
                                    .copyWith(decoration: TextDecoration.underline)),
                          ),
                        ),
                    ]),
                  ],
                ]),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(i.waiting ? 'No reply' : minutesText(i.minutes),
                    style: AppTypography.heading3(
                        color: i.waiting ? Palette.rose : AppTokens.brandDark, fontWeight: FontWeight.w700)),
                if (!i.waiting && i.clockMinutes != null && i.clockMinutes!.round() != i.minutes?.round())
                  Text('office time · clock ${minutesText(i.clockMinutes)}',
                      style: AppTypography.bodySmall(color: AppTokens.textMuted)),
              ]),
              if (i.uid > 0) const Icon(Icons.chevron_right, color: AppTokens.textMuted),
            ]),
          ),
        ),
    ]);
  }
}
