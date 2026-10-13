import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/mailmonitor/mail_monitor_api.dart';
import 'package:maleva/core/mailmonitor/response_report_models.dart';
import 'package:maleva/features/mail_monitor/view/mail_message_page.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/theme/tokens.dart';

import 'package:maleva/core/widgets/ui/feedback.dart';

import 'booking_rules.dart';
import 'booking_speed_cubit.dart';
import 'booking_summary_cubit.dart';
import 'response_rules.dart';
import 'response_widgets.dart';
import 'summary_language.dart';

/// The Booking speed page's insight sections (change booking-speed-insights), the web's BookingInsightsPanel,
/// WaitingBookings and BookingSummaryCard in the app's design. Every number comes from the server.

String _m(num? v) => minutesText(v);

final _when = DateFormat('d MMM, HH:mm');

/// Malaysia time of an instant.
String _myTime(DateTime? t) =>
    t == null ? '—' : _when.format(t.toUtc().add(const Duration(hours: 8)));

class _SectionCard extends StatelessWidget {
  const _SectionCard(
      {required this.title,
      required this.icon,
      required this.child,
      this.note,
      this.color,
      this.border});

  final String title;
  final IconData icon;
  final Widget child;
  final String? note;
  final Color? color;
  final Color? border;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: cardBox(color: color, border: border),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, size: 16, color: AppTokens.brandGradientStart),
            const SizedBox(width: 6),
            Expanded(
                child: Text(title,
                    style: AppTypography.heading3(color: AppTokens.brandDark))),
          ]),
          const SizedBox(height: 8),
          child,
          if (note != null) ...[
            const SizedBox(height: 6),
            Text(note!,
                style: AppTypography.bodySmall(color: AppTokens.textMuted)),
          ],
        ]),
      );
}

class _Bar extends StatelessWidget {
  const _Bar({required this.share, required this.color});

  final double share;
  final Color color;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          height: 8,
          child: Stack(children: [
            const Positioned.fill(
                child: ColoredBox(color: AppTokens.surfaceBorder)),
            FractionallySizedBox(
                widthFactor: share, child: ColoredBox(color: color)),
          ]),
        ),
      );
}

// ── Waiting bookings ─────────────────────────────────────────────────────────

class WaitingBookingsCard extends StatefulWidget {
  const WaitingBookingsCard({super.key, required this.report, this.api});

  final BookingSpeedReport report;

  /// Opens a mail read-only and saves the Super Admin's check when given.
  final MailMonitorApi? api;

  @override
  State<WaitingBookingsCard> createState() => _WaitingBookingsCardState();
}

class _WaitingBookingsCardState extends State<WaitingBookingsCard> {
  bool _busy = false;

  /// A booking (true), not a booking (false) or undo (null); the page reloads its numbers.
  Future<void> _check(WaitingBooking w, bool? booking) async {
    final api = widget.api;
    if (api == null || _busy) return;
    setState(() => _busy = true);
    try {
      await api.checkBooking(w.id, booking);
      if (!mounted) return;
      showSnack(
          context,
          booking == null
              ? 'Back to not checked'
              : (booking ? 'Marked as a booking' : 'Marked as not a booking'));
      await context.read<BookingSpeedCubit>().load();
    } catch (e) {
      if (mounted) showSnack(context, '$e', kind: SnackKind.error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _open(WaitingBooking w) =>
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => MailMessagePage(
            api: widget.api!, mailboxId: w.mailboxId, uid: w.uid),
      ));

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    if (!report.waitingReady) {
      return Text(
          'Waiting bookings and their alert start after db/mail-booking-insights.sql has been run.',
          style: AppTypography.bodySmall(color: AppTokens.textMuted));
    }
    final waiting = report.waiting;
    return _SectionCard(
      title: 'Booking mails waiting now (${waiting.length})',
      icon: Icons.hourglass_top_outlined,
      color: waiting.isEmpty ? null : AppTokens.brandLight,
      note:
          'Mails whose subject looks like a booking and still need a reply. After ${report.alertMinutes} office '
          'minutes the mailbox\'s owners get a phone alert. Check each one: Booking keeps it, Not a booking removes it '
          'from this list, the alert and the booking numbers. Tap a mail to read it (it stays unread).',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (waiting.isEmpty)
          Text('No booking mail is waiting.',
              style: AppTypography.bodySmall(
                  color: AppTokens.statusSuccess, fontWeight: FontWeight.w700)),
        for (final w in waiting) _row(w, report),
        if (report.notBookings.isNotEmpty)
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text('Marked not a booking (${report.notBookings.length})',
                  style: AppTypography.bodySmall(
                      color: AppTokens.textSecondary,
                      fontWeight: FontWeight.w700)),
              children: [
                for (final w in report.notBookings)
                  Row(children: [
                    Expanded(
                      child: Text(
                          '${w.subject ?? w.senderDomain ?? ''} · from ${w.sender ?? w.senderDomain ?? 'a customer'}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall(
                              color: AppTokens.textMuted)),
                    ),
                    TextButton.icon(
                      onPressed: _busy ? null : () => _check(w, null),
                      icon: const Icon(Icons.undo, size: 16),
                      label: const Text('Undo'),
                    ),
                  ]),
              ],
            ),
          ),
      ]),
    );
  }

  Widget _row(WaitingBooking w, BookingSpeedReport report) {
    final canOpen = w.uid > 0 && widget.api != null;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: cardBox(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        InkWell(
          onTap: canOpen ? () => _open(w) : null,
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(w.subject ?? '(subject not stored yet)',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyMedium(
                            color: AppTokens.brandDark,
                            fontWeight: FontWeight.w700)),
                    Text('from ${w.sender ?? w.senderDomain ?? 'a customer'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall(
                            color: AppTokens.textPrimary)),
                    Text('to ${w.to.join(', ')}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall(
                            color: AppTokens.textMuted)),
                    Text('arrived ${_myTime(w.receivedAt)}',
                        style: AppTypography.bodySmall(
                            color: AppTokens.textMuted)),
                  ]),
            ),
            const SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(_m(w.waitingMinutes),
                  style: AppTypography.heading3(
                      color: w.waitingMinutes >= report.alertMinutes
                          ? Palette.rose
                          : AppTokens.brandDark)),
              if (w.alerted)
                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.notifications_active_outlined,
                      size: 13, color: AppTokens.brandGradientStart),
                  const SizedBox(width: 2),
                  Text('alerted',
                      style: AppTypography.bodySmall(
                          color: AppTokens.brandGradientStart)),
                ]),
              if (canOpen)
                const Icon(Icons.chevron_right, color: AppTokens.textMuted),
            ]),
          ]),
        ),
        if (report.checkReady && widget.api != null) ...[
          const SizedBox(height: 8),
          if (w.confirmed == true)
            Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: AppTokens.statusSuccess.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.check,
                          size: 14, color: AppTokens.statusSuccess),
                      const SizedBox(width: 3),
                      Text('Booking',
                          style: AppTypography.bodySmall(
                              color: AppTokens.statusSuccess,
                              fontWeight: FontWeight.w700)),
                    ]),
                  ),
                  TextButton(
                      onPressed: _busy ? null : () => _check(w, null),
                      child: const Text('Undo')),
                ])
          else
            Wrap(spacing: 8, runSpacing: 6, children: [
              FilledButton.icon(
                onPressed: _busy ? null : () => _check(w, true),
                style: FilledButton.styleFrom(
                    backgroundColor: AppTokens.statusSuccess,
                    visualDensity: VisualDensity.compact),
                icon: const Icon(Icons.check, size: 16),
                label: const Text('Booking'),
              ),
              OutlinedButton(
                onPressed: _busy ? null : () => _check(w, false),
                style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact),
                child: const Text('Not a booking'),
              ),
            ]),
        ],
      ]),
    );
  }
}

/// Confirmed booking mails whose sale order is not opened yet (no job-number reply), per person and mail by mail.
class PendingSaleOrdersCard extends StatefulWidget {
  const PendingSaleOrdersCard({super.key, required this.report, this.api});

  final BookingSpeedReport report;
  final MailMonitorApi? api;

  @override
  State<PendingSaleOrdersCard> createState() => _PendingSaleOrdersCardState();
}

class _PendingSaleOrdersCardState extends State<PendingSaleOrdersCard> {
  String? _person;

  @override
  Widget build(BuildContext context) {
    final pending = widget.report.pendingSaleOrders;
    final shown = _person == null
        ? pending
        : [
            for (final p in pending)
              if ((p.owners.isEmpty ? const ['No owner linked'] : p.owners)
                  .contains(_person))
                p
          ];
    return _SectionCard(
      title: 'Confirmed bookings without a sale order (${pending.length})',
      icon: Icons.assignment_late_outlined,
      color: pending.isEmpty ? null : Palette.amberWarn.withValues(alpha: 0.08),
      border:
          pending.isEmpty ? null : Palette.amberWarn.withValues(alpha: 0.45),
      note:
          'Booking mails you confirmed that have no reply with a job number (MY / TR) yet, so no sale order is known. '
          'A sale order opened without replying the job number still shows here until the reply goes out. After '
          '${_m(widget.report.saleOrderAlertMinutes)} of office time the mailbox\'s owners get a phone alert. Last 30 days.',
      child: pending.isEmpty
          ? Text('Every confirmed booking has its sale order.',
              style: AppTypography.bodySmall(
                  color: AppTokens.statusSuccess, fontWeight: FontWeight.w700))
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(spacing: 6, runSpacing: 6, children: [
                for (final b in widget.report.pendingByPerson)
                  ChoiceChip(
                    label: Text(
                        '${b.employee} · ${b.mails} pending · oldest ${_m(b.oldestMinutes)}'),
                    selected: _person == b.employee,
                    onSelected: (_) => setState(() =>
                        _person = _person == b.employee ? null : b.employee),
                    selectedColor: Palette.amberWarn.withValues(alpha: 0.35),
                    visualDensity: VisualDensity.compact,
                  ),
              ]),
              for (final p in shown)
                InkWell(
                  onTap: p.uid > 0 && widget.api != null
                      ? () =>
                          Navigator.of(context).push(MaterialPageRoute<void>(
                            builder: (_) => MailMessagePage(
                                api: widget.api!,
                                mailboxId: p.mailboxId,
                                uid: p.uid),
                          ))
                      : null,
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    decoration: cardBox(),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.subject ?? '(no subject stored)',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.bodyMedium(
                                          color: AppTokens.brandDark,
                                          fontWeight: FontWeight.w700)),
                                  Text(
                                      'from ${p.sender ?? 'a customer'} · arrived ${_myTime(p.receivedAt)}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.bodySmall(
                                          color: AppTokens.textPrimary)),
                                  Text(
                                      '${p.owners.isEmpty ? 'No owner linked' : p.owners.join(', ')} · ${p.mailboxes.join(', ')}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.bodySmall(
                                          color: AppTokens.textMuted)),
                                ]),
                          ),
                          const SizedBox(width: 8),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (p.alerted)
                                  Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                            Icons.notifications_active_outlined,
                                            size: 13,
                                            color: Palette.amberGold),
                                        const SizedBox(width: 2),
                                        Text('alerted',
                                            style: AppTypography.bodySmall(
                                                color: Palette.amberGold)),
                                      ]),
                                Text(_m(p.waitingMinutes),
                                    style: AppTypography.heading3(
                                        color: Palette.amberGold)),
                                Text(
                                    p.replied
                                        ? 'replied, no job no.'
                                        : 'no reply yet',
                                    style: AppTypography.bodySmall(
                                        color: p.replied
                                            ? AppTokens.brandGradientStart
                                            : Palette.rose,
                                        fontWeight: FontWeight.w600)),
                              ]),
                        ]),
                  ),
                ),
            ]),
    );
  }
}

/// Booking mails by subject words, once per mail: checked, first reply, how often the word rule was right.
class BookingMailsCard extends StatelessWidget {
  const BookingMailsCard(
      {super.key, required this.stats, required this.isTablet});

  final BookingMailStats stats;
  final bool isTablet;

  @override
  Widget build(BuildContext context) =>
      TileColumns(columns: isTablet ? 4 : 2, minCellHeight: 110, children: [
        NumberTile(
          label: 'Booking mails',
          value: '${stats.mails}',
          note: '${stats.confirmed} confirmed · ${stats.unchecked} not checked',
          icon: Icons.mark_email_unread_outlined,
        ),
        NumberTile(
          label: 'Mail → first reply',
          value: _m(stats.medianFirstReply),
          note: 'median · ${stats.replied} replied',
          icon: Icons.reply_outlined,
          valueColor: AppTokens.statusSuccess,
        ),
        NumberTile(
          label: 'Not a booking',
          value: '${stats.rejected}',
          note: 'left out of the numbers',
          icon: Icons.do_not_disturb_on_outlined,
        ),
        NumberTile(
          label: 'Word rule right',
          value: stats.ruleRightPct == null
              ? '—'
              : '${stats.ruleRightPct!.round()}%',
          note: 'of the mails you checked',
          icon: Icons.rule,
        ),
      ]);
}

// ── AI summary ───────────────────────────────────────────────────────────────

const _aboutLabel = {
  'COMPANY': 'Team',
  'EMPLOYEE': 'Employee',
  'SLOW_SPOT': 'Slow spot',
  'DATA': 'Data to fix',
  'WAITING': 'Waiting now',
};

Color _aboutColor(String about) => switch (about) {
      'EMPLOYEE' => AppTokens.statusSuccess,
      'SLOW_SPOT' => Palette.rose,
      'DATA' => Palette.amberGold,
      'WAITING' => AppTokens.brandGradientEnd,
      _ => AppTokens.brandGradientStart,
    };

class BookingSummaryCard extends StatelessWidget {
  const BookingSummaryCard({super.key, required this.range});

  final ReportRange range;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<BookingSummaryCubit, BookingSummaryState>(
          builder: (context, s) {
        final cubit = context.read<BookingSummaryCubit>();
        final points = s.summary?.points ?? const <BookingSummaryPoint>[];
        return Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: cardBox(
              color: AppTokens.brandLight,
              border: AppTokens.brandMid.withValues(alpha: 0.3)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.auto_awesome_outlined,
                  size: 18, color: AppTokens.brandGradientStart),
              const SizedBox(width: 8),
              Expanded(
                  child: Text('AI summary of booking speed',
                      style:
                          AppTypography.heading3(color: AppTokens.brandDark))),
            ]),
            const SizedBox(height: 4),
            Text(
                'Only the numbers on this page go to the AI - no names, no mail. Every number is checked.',
                style: AppTypography.bodySmall(color: AppTokens.textMuted)),
            const SizedBox(height: 10),
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final l in SummaryLanguage.all)
                ChoiceChip(
                  label: Text(l.label),
                  selected: s.language == l,
                  onSelected:
                      s.loading ? null : (_) => cubit.chooseLanguage(l, range),
                  showCheckmark: false,
                  selectedColor: AppTokens.brandGradientStart,
                  backgroundColor: AppTokens.surfaceCard,
                  side: BorderSide(
                      color: s.language == l
                          ? AppTokens.brandGradientStart
                          : AppTokens.brandMid.withValues(alpha: 0.3)),
                  labelStyle: AppTypography.bodySmall(
                      color: s.language == l
                          ? AppTokens.textOnDark
                          : AppTokens.brandDark,
                      fontWeight: FontWeight.w600),
                  visualDensity: VisualDensity.compact,
                ),
            ]),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: [
              FilledButton.icon(
                onPressed: s.loading ? null : () => cubit.write(range),
                style: FilledButton.styleFrom(
                    backgroundColor: AppTokens.brandGradientStart),
                icon: s.loading
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.edit_note, size: 18),
                label: Text(s.loading
                    ? 'Writing…'
                    : s.summary == null
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
                  icon: Icon(
                      s.speaking
                          ? Icons.stop_circle_outlined
                          : Icons.volume_up_outlined,
                      size: 18),
                  label: Text(s.speaking ? 'Stop' : 'Read aloud'),
                ),
            ]),
            if (s.error != null) ...[
              const SizedBox(height: 8),
              Text(s.error!,
                  style: AppTypography.bodySmall(color: Palette.rose)),
            ],
            if (s.speechProblem != null) ...[
              const SizedBox(height: 8),
              Text(s.speechProblem!,
                  style: AppTypography.bodySmall(color: Palette.rose)),
            ],
            if (points.isNotEmpty) ...[
              const SizedBox(height: 10),
              for (final p in points) _PointCard(point: p),
              Text('Written by ${s.summary!.provider} · ${s.summary!.model}',
                  style: AppTypography.bodySmall(color: AppTokens.textMuted)),
            ],
          ]),
        );
      });
}

class _PointCard extends StatelessWidget {
  const _PointCard({required this.point});

  final BookingSummaryPoint point;

  @override
  Widget build(BuildContext context) {
    final color = _aboutColor(point.about);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: cardBox(
          color: color.withValues(alpha: 0.06),
          border: color.withValues(alpha: 0.35)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(999)),
                child: Text(_aboutLabel[point.about] ?? 'Team',
                    style: AppTypography.bodySmall(
                        color: AppTokens.textOnDark,
                        fontWeight: FontWeight.w700)),
              ),
              if (point.employee != null)
                Text(point.employee!,
                    style: AppTypography.bodySmall(
                        color: AppTokens.brandDark,
                        fontWeight: FontWeight.w700)),
              if (!point.checked)
                Text('plain figures',
                    style: AppTypography.bodySmall(color: AppTokens.textMuted)),
            ]),
        const SizedBox(height: 4),
        Text(point.text,
            style: AppTypography.bodyMedium(color: AppTokens.textPrimary)),
        if (point.why != null) ...[
          const SizedBox(height: 4),
          Text.rich(
              TextSpan(children: [
                const TextSpan(
                    text: 'Why: ',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                TextSpan(text: point.why),
              ]),
              style: AppTypography.bodySmall(color: AppTokens.textSecondary)),
        ],
        if (point.suggestion != null) ...[
          const SizedBox(height: 4),
          Text('→ ${point.suggestion}',
              style: AppTypography.bodySmall(
                  color: AppTokens.brandDark, fontWeight: FontWeight.w600)),
        ],
      ]),
    );
  }
}

// ── Statistics ───────────────────────────────────────────────────────────────

const _kindLabel = {
  'ARRIVAL': 'Arrival time',
  'WEEKDAY': 'Weekday',
  'DOMAIN': 'Customer',
  'MAILBOX': 'Mailbox'
};

/// Groups as rows: label, a bar of the median against the slowest group, median and count; slow ones in rose.
class _GroupBars extends StatelessWidget {
  const _GroupBars({required this.groups, required this.companyMedian});

  final List<StatGroup> groups;
  final double? companyMedian;

  @override
  Widget build(BuildContext context) {
    final shown = [
      for (final g in groups)
        if (g.bookings > 0) g
    ];
    if (shown.isEmpty) {
      return Text('No counted bookings.',
          style: AppTypography.bodySmall(color: AppTokens.textMuted));
    }
    final max = shown.fold<double>(
        1, (m, g) => (g.medianToSaleOrder ?? 0) > m ? g.medianToSaleOrder! : m);
    return Column(children: [
      for (final g in shown)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Builder(builder: (_) {
            final slow = companyMedian != null &&
                g.bookings >= 3 &&
                (g.medianToSaleOrder ?? 0) >= 1.5 * companyMedian!;
            return Row(children: [
              SizedBox(
                width: 110,
                child: Text(g.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        AppTypography.bodySmall(color: AppTokens.textPrimary)),
              ),
              const SizedBox(width: 6),
              Expanded(
                  child: _Bar(
                      share: barShare(g.medianToSaleOrder, max),
                      color: slow ? Palette.rose : AppTokens.brandGradientEnd)),
              const SizedBox(width: 8),
              SizedBox(
                width: 78,
                child: Text('${_m(g.medianToSaleOrder)} · ${g.bookings}',
                    textAlign: TextAlign.right,
                    style: AppTypography.bodySmall(
                        color: slow ? Palette.rose : AppTokens.brandDark,
                        fontWeight: FontWeight.w700)),
              ),
            ]);
          }),
        ),
    ]);
  }
}

class BookingInsightsSections extends StatelessWidget {
  const BookingInsightsSections(
      {super.key,
      required this.insights,
      required this.companyMedian,
      required this.isTablet});

  final BookingInsights insights;
  final double? companyMedian;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final counted = insights.counted;
    if (counted == 0) return const SizedBox.shrink();
    final spreadMax =
        insights.spread.fold<int>(1, (m, b) => b.bookings > m ? b.bookings : m);
    final cards = <Widget>[
      _SectionCard(
        title: 'How fast bookings became a sale order',
        icon: Icons.bar_chart,
        child: Column(children: [
          for (var i = 0; i < insights.spread.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(children: [
                SizedBox(
                    width: 96,
                    child: Text(insights.spread[i].label,
                        style: AppTypography.bodySmall(
                            color: AppTokens.textPrimary))),
                Expanded(
                  child: _Bar(
                    share: insights.spread[i].bookings == 0
                        ? 0
                        : barShare(insights.spread[i].bookings.toDouble(),
                            spreadMax.toDouble()),
                    color: i < 2
                        ? AppTokens.statusSuccess
                        : (i < 3 ? Palette.amberWarn : Palette.rose),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 64,
                  child: Text(
                      '${insights.spread[i].bookings} · ${(insights.spread[i].bookings * 100 / counted).round()}%',
                      textAlign: TextAlign.right,
                      style: AppTypography.bodySmall(
                          color: AppTokens.brandDark,
                          fontWeight: FontWeight.w700)),
                ),
              ]),
            ),
        ]),
      ),
      _SectionCard(
        title: 'By arrival time of the booking mail',
        icon: Icons.schedule,
        note: insights.officeHoursMedian != null &&
                insights.afterHoursMedian != null
            ? 'In office hours ${_m(insights.officeHoursMedian)} median · after office hours '
                '${_m(insights.afterHoursMedian)} (office time only)'
            : null,
        child: _GroupBars(
            groups: insights.byArrival, companyMedian: companyMedian),
      ),
      _SectionCard(
        title: 'By weekday',
        icon: Icons.calendar_month_outlined,
        child: _GroupBars(
            groups: insights.byWeekday, companyMedian: companyMedian),
      ),
      _SectionCard(
        title: 'Top customers (sender domain)',
        icon: Icons.public,
        child:
            _GroupBars(groups: insights.byDomain, companyMedian: companyMedian),
      ),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (insights.slowSpots.isNotEmpty)
        _SectionCard(
          title: 'Where bookings get slow',
          icon: Icons.warning_amber_rounded,
          color: Palette.rose.withValues(alpha: 0.05),
          border: Palette.rose.withValues(alpha: 0.3),
          child: Column(children: [
            for (final s in insights.slowSpots)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                decoration: cardBox(),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text((_kindLabel[s.kind] ?? s.kind).toUpperCase(),
                          style: AppTypography.bodySmall(
                              color: Palette.rose,
                              fontWeight: FontWeight.w700)),
                      Text(s.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.heading3(
                              color: AppTokens.brandDark)),
                      Text(
                          '${_m(s.medianToSaleOrder)} median${s.times == null ? '' : ' · ${s.times}x the team'} · '
                          '${s.bookings} bookings',
                          style: AppTypography.bodySmall(
                              color: AppTokens.textSecondary)),
                    ]),
              ),
          ]),
        )
      else
        _SectionCard(
          title: 'No slow spot',
          icon: Icons.check_circle_outline,
          color: AppTokens.statusSuccess.withValues(alpha: 0.06),
          child: Text(
              'No time, weekday, customer or mailbox with 3 or more bookings is 1.5x slower than the team.',
              style: AppTypography.bodySmall(color: AppTokens.textPrimary)),
        ),
      const SizedBox(height: 10),
      TileColumns(columns: isTablet ? 2 : 1, children: cards),
      const SizedBox(height: 10),
      _SectionCard(
        title: 'Bookings per day',
        icon: Icons.trending_up,
        note: 'The median to sale order is under each day.',
        child: _Trend(days: insights.daily),
      ),
    ]);
  }
}

class _Trend extends StatelessWidget {
  const _Trend({required this.days});

  final List<DayPoint> days;

  static final _day = DateFormat('d MMM');

  @override
  Widget build(BuildContext context) {
    final max = days.fold<int>(1, (m, d) => d.bookings > m ? d.bookings : m);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        for (final d in days)
          SizedBox(
            width: 52,
            child: Column(children: [
              Text(d.bookings == 0 ? '' : '${d.bookings}',
                  style: AppTypography.bodySmall(
                      color: AppTokens.brandDark, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              SizedBox(
                height: 64,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 22,
                    height: d.bookings == 0
                        ? 0
                        : (64 * d.bookings / max).clamp(4, 64).toDouble(),
                    decoration: BoxDecoration(
                        color:
                            AppTokens.brandGradientEnd.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(4)),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(_day.format(DateTime.parse(d.day)),
                  style: AppTypography.bodySmall(color: AppTokens.textMuted)),
              Text(d.bookings == 0 ? '—' : _m(d.medianToSaleOrder),
                  style: AppTypography.bodySmall(color: AppTokens.textMuted)),
            ]),
          ),
      ]),
    );
  }
}
