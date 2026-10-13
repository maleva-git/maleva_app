import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/mailmonitor/mail_monitor_api.dart';
import 'package:maleva/core/mailmonitor/response_report_models.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/theme/status_tone.dart';
import 'package:maleva/core/theme/tokens.dart';
import 'package:maleva/core/widgets/ui/states.dart';
import 'package:maleva/core/widgets/ui/status_pill.dart';

import 'booking_insights.dart';
import 'booking_rules.dart';
import 'booking_summary_cubit.dart';
import 'booking_speed_cubit.dart';
import 'response_rules.dart';
import 'response_widgets.dart';
import 'summary_speaker.dart';

/// Booking speed (change mail-reading-and-booking-speed): from a customer's booking mail to the sale order
/// and to the job-number reply, per employee, in office time. The web's `/mail-monitor/booking-speed` on the
/// same Java API; the server ranks, the app only shows.
class BookingSpeedPage extends StatelessWidget {
  const BookingSpeedPage(
      {super.key, this.api, this.clock, this.range, this.preset, this.speaker});

  /// For tests; the app uses the registered [MailMonitorApi] and the device voice.
  final MailMonitorApi? api;
  final SummarySpeaker? speaker;
  final DateTime Function()? clock;

  /// The range the reply report showed, so both pages agree.
  final ReportRange? range;
  final RangePreset? preset;

  @override
  Widget build(BuildContext context) {
    final source = api ?? sl<MailMonitorApi>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (_) => BookingSpeedCubit(source,
                clock: clock, range: range, preset: preset)
              ..load()),
        BlocProvider(
            create: (_) =>
                BookingSummaryCubit(source, speaker ?? TtsSummarySpeaker())),
      ],
      child: Scaffold(
        backgroundColor: AppTokens.surfacePage,
        appBar: AppBar(title: const Text('Booking speed')),
        body: _BookingView(clock: clock ?? DateTime.now, api: source),
      ),
    );
  }
}

String _minutes(num? m) => minutesText(m);

final _time = DateFormat('d MMM, HH:mm');

/// Malaysia time of an instant ("7 Oct, 10:15").
String _myTime(DateTime? t) =>
    t == null ? '—' : _time.format(t.toUtc().add(const Duration(hours: 8)));

class _BookingView extends StatelessWidget {
  const _BookingView({required this.clock, required this.api});

  final DateTime Function() clock;

  /// Opens a waiting booking mail read-only.
  final MailMonitorApi api;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isTablet = constraints.maxWidth >= 600;
      return BlocConsumer<BookingSpeedCubit, BookingSpeedState>(
          listenWhen: (a, b) => a.range != b.range,
          listener: (context, _) => context.read<BookingSummaryCubit>().clear(),
          builder: (context, s) {
            final cubit = context.read<BookingSpeedCubit>();
            final report = s.report;
            final pad = EdgeInsets.fromLTRB(
                isTablet ? 20 : 12, 8, isTablet ? 20 : 12, 24);
            final ranges = _Ranges(state: s, clock: clock);

            if (report == null) {
              return ListView(padding: pad, children: [
                ranges,
                const SizedBox(height: 12),
                if (s.loading)
                  const SizedBox(
                      height: 420,
                      child: SkeletonList(count: 4, padding: EdgeInsets.zero))
                else
                  ErrorState(
                      title: _errorTitle(s.errorCode),
                      message: s.error,
                      onRetry: cubit.load),
              ]);
            }

            final c = report.company;
            final people = [
              for (final e in report.employees)
                if (e.employee != noEmployee) e
            ];
            final ranked = [
              for (final e in people)
                if (e.ranked) e
            ];
            final unranked = [
              for (final e in people)
                if (!e.ranked) e
            ];
            final missing = report.employees
                .where((e) => e.employee == noEmployee)
                .firstOrNull;
            final slowest = people.fold<double>(
                1,
                (m, e) =>
                    (e.medianToSaleOrder ?? 0) > m ? e.medianToSaleOrder! : m);
            final jobs = report.newestJobs;
            final tiles = [
              NumberTile(
                label: 'Bookings counted',
                value: '${c.bookings}',
                note:
                    '${c.existingJobs} existing ${c.existingJobs == 1 ? 'job' : 'jobs'} left out',
                icon: Icons.mark_email_read_outlined,
              ),
              NumberTile(
                label: 'Mail → sale order',
                value: _minutes(c.medianToSaleOrder),
                note: 'median · average ${_minutes(c.avgToSaleOrder)}',
                icon: Icons.receipt_long_outlined,
                valueColor: AppTokens.statusSuccess,
              ),
              NumberTile(
                label: 'Mail → job number reply',
                value: _minutes(c.medianToReply),
                note: 'median · average ${_minutes(c.avgToReply)}',
                icon: Icons.reply_outlined,
                valueColor: AppTokens.statusSuccess,
              ),
              NumberTile(
                label: 'Fastest employee',
                value: ranked.isEmpty ? 'Not yet' : ranked.first.employee,
                note: ranked.isEmpty
                    ? 'Needs ${report.minBookingsToRank} bookings with an employee'
                    : '${_minutes(ranked.first.medianToSaleOrder)} median to sale order',
                icon: Icons.emoji_events_outlined,
              ),
            ];

            return RefreshIndicator(
              color: AppTokens.brandGradientStart,
              onRefresh: cubit.load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: pad,
                children: [
                  ranges,
                  if (s.loading)
                    const LinearProgressIndicator(
                        minHeight: 2, color: AppTokens.brandGradientStart),
                  if (s.error != null) ...[
                    const SizedBox(height: 8),
                    Text(s.error!,
                        style: AppTypography.bodySmall(color: Palette.rose)),
                  ],
                  const SizedBox(height: 12),
                  TileColumns(
                      columns: isTablet ? 4 : 2,
                      minCellHeight: 124,
                      children: tiles),
                  const SizedBox(height: 12),
                  WaitingBookingsCard(report: report, api: api),
                  if (report.checkReady) ...[
                    const SizedBox(height: 12),
                    PendingSaleOrdersCard(report: report, api: api),
                  ],
                  if (report.bookingMails != null &&
                      report.bookingMails!.mails + report.bookingMails!.rejected > 0) ...[
                    const SizedBox(height: 12),
                    BookingMailsCard(stats: report.bookingMails!, isTablet: isTablet),
                  ],
                  if (c.bookings > 0) ...[
                    const SizedBox(height: 12),
                    BookingSummaryCard(
                        range: ReportRange(report.from, report.to)),
                  ],
                  const SizedBox(height: 14),
                  if (report.employees.isEmpty)
                    const EmptyState(
                      icon: Icons.inbox_outlined,
                      title: 'No bookings yet',
                      message:
                          'No booking replies with a job number in this range. Bookings are recorded from the day '
                          'the backend update runs.',
                    )
                  else ...[
                    if (missing != null) ...[
                      _NoEmployeeNotice(group: missing),
                      const SizedBox(height: 12),
                    ],
                    if (ranked.isNotEmpty) ...[
                      const _Title('Fastest to sale order'),
                      TileColumns(
                        columns: isTablet ? 3 : 1,
                        children: [
                          for (var i = 0; i < ranked.length && i < 3; i++)
                            _PodiumCard(
                                place: i,
                                employee: ranked[i],
                                slowest: slowest),
                        ],
                      ),
                      if (ranked.length > 3) ...[
                        const SizedBox(height: 8),
                        _RowsCard(children: [
                          for (var i = 3; i < ranked.length; i++)
                            _SpeedRow(
                                rank: i + 1,
                                employee: ranked[i],
                                slowest: slowest),
                        ]),
                      ],
                    ],
                    if (unranked.isNotEmpty) ...[
                      _Title(
                          'Fewer than ${report.minBookingsToRank} bookings · shown, not ranked'),
                      _RowsCard(children: [
                        for (final e in unranked)
                          _SpeedRow(employee: e, slowest: slowest)
                      ]),
                    ],
                  ],
                  if (report.insights != null) ...[
                    const SizedBox(height: 14),
                    const _Title('Statistics'),
                    BookingInsightsSections(
                        insights: report.insights!,
                        companyMedian: c.medianToSaleOrder,
                        isTablet: isTablet),
                  ],
                  if (jobs.isNotEmpty) _JobsSection(jobs: jobs),
                  const SizedBox(height: 10),
                  Text(
                    'A booking is a customer mail answered from the Sent folder with a job number (MY or TR and 9 digits) '
                    'in the subject. Times run from the first customer mail of that conversation to the sale order\'s '
                    'creation and to the job-number reply, counting office hours only. The employee is the one chosen '
                    'on the sale order (employee master). A sale order made before the mail (an existing job) is shown but not '
                    'counted. Updated every 15 minutes.',
                    style: AppTypography.bodySmall(color: AppTokens.textMuted),
                  ),
                ],
              ),
            );
          });
    });
  }

  static String _errorTitle(int? code) => switch (code) {
        403 => 'Only the Super Admin can see booking speed',
        503 => 'Booking speed is not set up yet',
        _ => 'Booking speed could not be loaded',
      };
}

class _Ranges extends StatelessWidget {
  const _Ranges({required this.state, required this.clock});

  final BookingSpeedState state;
  final DateTime Function() clock;

  Future<void> _pickDates(BuildContext context) async {
    final cubit = context.read<BookingSpeedCubit>();
    final today = malaysiaDay(clock());
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(today.year - 2),
      lastDate: today,
      initialDateRange: DateTimeRange(
          start: DateTime.parse(state.range.from),
          end: DateTime.parse(state.range.to)),
      helpText: 'Booking dates',
    );
    if (picked != null) await cubit.chooseDates(picked.start, picked.end);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BookingSpeedCubit>();
    final shown = state.report == null
        ? state.range
        : ReportRange(state.report!.from, state.report!.to);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTokens.brandGradientStart, AppTokens.brandGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(reportRadius),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
            'From booking mail to sale order and job-number reply, per employee, in office time.',
            style: AppTypography.bodySmall(
                color: AppTokens.textOnDark.withValues(alpha: 0.85))),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final p in RangePreset.values)
            HeaderPill(
                label: presetLabel(p),
                selected: state.preset == p,
                onTap: () => cubit.choosePreset(p)),
          HeaderPill(
            label: state.preset == null ? 'Custom dates' : 'Pick dates',
            icon: Icons.date_range_outlined,
            selected: state.preset == null,
            onTap: () => _pickDates(context),
          ),
        ]),
        const SizedBox(height: 8),
        Text('Bookings received ${rangeText(shown)}',
            style: AppTypography.bodySmall(
                color: AppTokens.textOnDark, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 6),
        child: Text(text,
            style: AppTypography.heading3(color: AppTokens.brandDark)),
      );
}

/// Gold, silver and bronze from the app palette.
const _podium = [Palette.amberGold, Palette.grey400, Palette.amber];
const _places = ['1st', '2nd', '3rd'];

class _Avatar extends StatelessWidget {
  const _Avatar(this.name, {this.size = 36});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
            color: AppTokens.brandLight, shape: BoxShape.circle),
        child: Text(initials(name),
            style: AppTypography.bodySmall(
                color: AppTokens.brandGradientStart,
                fontWeight: FontWeight.w700)),
      );
}

/// A speed bar against the slowest ranked employee.
class _Bar extends StatelessWidget {
  const _Bar({required this.value, required this.slowest, required this.color});

  final double? value;
  final double slowest;
  final Color color;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          height: 6,
          child: Stack(children: [
            const Positioned.fill(
                child: ColoredBox(color: AppTokens.surfaceBorder)),
            FractionallySizedBox(
              widthFactor: barShare(value, slowest),
              child: ColoredBox(color: color),
            ),
          ]),
        ),
      );
}

/// Bookings whose sale order names no employee: counted for the company, credited to nobody.
class _NoEmployeeNotice extends StatelessWidget {
  const _NoEmployeeNotice({required this.group});

  final EmployeeSpeed group;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: cardBox(
            color: Palette.amberWarn.withValues(alpha: 0.1),
            border: Palette.amberWarn.withValues(alpha: 0.45)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.person_off_outlined,
              size: 18, color: Palette.amberGold),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(children: [
                TextSpan(
                  text:
                      '${group.bookings} ${group.bookings == 1 ? 'booking has' : 'bookings have'} no employee on '
                      'the sale order',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                    text:
                        ' (median ${_minutes(group.medianToSaleOrder)} to sale order). Their times count for the '
                        'company but nobody is credited. Choose the employee on the sale order and they will be '
                        'counted here.'),
              ]),
              style: AppTypography.bodySmall(color: AppTokens.textPrimary),
            ),
          ),
        ]),
      );
}

/// One of the three fastest: place, initials, both medians and the bar.
class _PodiumCard extends StatelessWidget {
  const _PodiumCard(
      {required this.place, required this.employee, required this.slowest});

  final int place;
  final EmployeeSpeed employee;
  final double slowest;

  @override
  Widget build(BuildContext context) {
    final e = employee;
    final color = _podium[place];
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: cardBox(
          color: color.withValues(alpha: 0.07),
          border: color.withValues(alpha: 0.45)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _Avatar(e.employee),
          const SizedBox(width: 10),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(e.employee,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.heading3(color: AppTokens.brandDark)),
              Text('${e.bookings} bookings',
                  style: AppTypography.bodySmall(color: AppTokens.textMuted)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(999)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(place == 0 ? Icons.emoji_events : Icons.military_tech,
                  size: 12, color: AppTokens.textOnDark),
              const SizedBox(width: 3),
              Text(_places[place],
                  style: AppTypography.bodySmall(
                      color: AppTokens.textOnDark,
                      fontWeight: FontWeight.w700)),
            ]),
          ),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
              child: _Figure(
                  label: 'To sale order',
                  value: _minutes(e.medianToSaleOrder),
                  note: 'avg ${_minutes(e.avgToSaleOrder)}',
                  color: AppTokens.statusSuccess)),
          Expanded(
              child: _Figure(
                  label: 'To job no. reply',
                  value: _minutes(e.medianToReply),
                  note: 'avg ${_minutes(e.avgToReply)}')),
        ]),
        const SizedBox(height: 8),
        _Bar(
            value: e.medianToSaleOrder,
            slowest: slowest,
            color: AppTokens.statusSuccess),
      ]),
    );
  }
}

class _RowsCard extends StatelessWidget {
  const _RowsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        decoration: cardBox(),
        child: Column(children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppTokens.surfaceBorder),
            children[i],
          ],
        ]),
      );
}

/// An employee below the podium (or not ranked): rank, name, bookings, median bar, fastest / slowest.
class _SpeedRow extends StatelessWidget {
  const _SpeedRow({required this.employee, required this.slowest, this.rank});

  final EmployeeSpeed employee;
  final double slowest;

  /// Null when not ranked.
  final int? rank;

  @override
  Widget build(BuildContext context) {
    final e = employee;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 22,
          child: Text(rank == null ? '–' : '$rank',
              textAlign: TextAlign.right,
              style: AppTypography.bodySmall(
                  color: AppTokens.textMuted, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 8),
        _Avatar(e.employee, size: 28),
        const SizedBox(width: 8),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(e.employee,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMedium(
                        color: AppTokens.brandDark,
                        fontWeight: FontWeight.w700)),
              ),
              Text('${e.bookings} bookings',
                  style: AppTypography.bodySmall(color: AppTokens.textMuted)),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              Text(_minutes(e.medianToSaleOrder),
                  style: AppTypography.bodySmall(
                      color: AppTokens.brandDark, fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('reply ${_minutes(e.medianToReply)}',
                  style: AppTypography.bodySmall(color: AppTokens.textMuted)),
            ]),
            const SizedBox(height: 3),
            _Bar(
                value: e.medianToSaleOrder,
                slowest: slowest,
                color: rank == null
                    ? AppTokens.surfaceBorder
                    : AppTokens.brandGradientEnd),
            const SizedBox(height: 3),
            Text(
                'fastest ${_minutes(e.fastestToSaleOrder)} · slowest ${_minutes(e.slowestToSaleOrder)}',
                style: AppTypography.bodySmall(color: AppTokens.textMuted)),
          ]),
        ),
      ]),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure(
      {required this.label,
      required this.value,
      required this.note,
      this.color});

  final String label;
  final String value;
  final String note;
  final Color? color;

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall(
                color: AppTokens.textMuted, fontWeight: FontWeight.w600)),
        Text(value,
            style: AppTypography.heading2(color: color ?? AppTokens.brandDark)),
        Text(note,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall(color: AppTokens.textMuted)),
      ]);
}

/// The jobs with status chips and a search (the web's filters), newest booking first.
class _JobsSection extends StatefulWidget {
  const _JobsSection({required this.jobs});

  final List<BookingJob> jobs;

  @override
  State<_JobsSection> createState() => _JobsSectionState();
}

class _JobsSectionState extends State<_JobsSection> {
  static const _shown = 50;
  BookingStatus? _status;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final jobs = widget.jobs;
    final filtered = filterJobs(jobs, _status, _query);
    int count(BookingStatus? s) =>
        s == null ? jobs.length : jobs.where((j) => j.status == s).length;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const _Title('Jobs · newest booking first'),
      Wrap(spacing: 6, runSpacing: 6, children: [
        for (final (status, label) in const [
          (null, 'All'),
          (BookingStatus.booked, 'Counted'),
          (BookingStatus.existingJob, 'Existing job'),
          (BookingStatus.noSaleOrder, 'No sale order'),
        ])
          ChoiceChip(
            label: Text('$label (${count(status)})'),
            selected: _status == status,
            onSelected: (_) => setState(() => _status = status),
            selectedColor: AppTokens.brandLight,
          ),
      ]),
      const SizedBox(height: 8),
      TextField(
        onChanged: (v) => setState(() => _query = v),
        decoration: const InputDecoration(
          isDense: true,
          prefixIcon: Icon(Icons.search, size: 18),
          hintText: 'Job no., employee, mailbox',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 8),
      if (filtered.isEmpty)
        Text('No job matches.',
            style: AppTypography.bodySmall(color: AppTokens.textMuted))
      else
        for (final j in filtered.take(_shown)) _JobCard(job: j),
      if (filtered.length > _shown)
        Text(
            'The newest $_shown are shown; the web page lists and exports all.',
            style: AppTypography.bodySmall(color: AppTokens.textMuted)),
    ]);
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({required this.job});

  final BookingJob job;

  @override
  Widget build(BuildContext context) {
    final j = job;
    final (label, tone) = switch (j.status) {
      BookingStatus.booked => ('Counted', StatusTone.success),
      BookingStatus.existingJob => ('Existing job', StatusTone.neutral),
      BookingStatus.noSaleOrder => ('No sale order', StatusTone.warning),
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: cardBox(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(j.jobNumber,
                  style: AppTypography.heading3(color: AppTokens.brandDark)),
              Text(
                  [
                    j.employee.isEmpty ? noEmployee : j.employee,
                    if (j.mailbox != null) j.mailbox!
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall(
                      color: j.employee.isEmpty || j.employee == noEmployee
                          ? Palette.amberGold
                          : AppTokens.textMuted)),
            ]),
          ),
          StatusPill(label, tone: tone),
        ]),
        const SizedBox(height: 6),
        Text(
          'Mail ${_myTime(j.bookingReceivedAt)}${j.afterHours ? ' (after hours)' : ''} · '
          'Sale order ${_myTime(j.saleOrderCreatedAt)} · Reply ${_myTime(j.jobReplyAt)}',
          style: AppTypography.bodySmall(color: AppTokens.textSecondary),
        ),
        if (j.status == BookingStatus.booked)
          Text(
              '${_minutes(j.minutesToSaleOrder)} to sale order · ${_minutes(j.minutesToReply)} to reply',
              style: AppTypography.bodySmall(
                  color: AppTokens.brandDark, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
