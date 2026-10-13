import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/employee_notifications/employee_notifications_api.dart';
import 'package:maleva/core/employee_notifications/employee_notifications_models.dart';
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/vessel_changes/vessel_changes_api.dart';
import 'package:maleva/core/vessel_changes/vessel_changes_models.dart';
import 'package:maleva/features/notifications/notification_look.dart';
import 'package:maleva/features/notifications/notification_routes.dart';
import 'package:maleva/features/notifications/notifications_cubit.dart';
import 'package:maleva/features/vessel_changes/push_route.dart';

/// Opens an app route (GoRouter in the app; a recorder in tests).
typedef OpenRoute = void Function(BuildContext context, String route);

void pushRoute(BuildContext context, String route) => GoRouter.of(context).push(route);

/// The page's own Material 3 look, seeded from the app's blue (the rest of the app is still Material 2).
ThemeData notificationsTheme() => ThemeData(useMaterial3: true, colorSchemeSeed: Palette.blue700);

/// Notifications (change vessel-master-and-ptp-schedule), in two separate tabs (owner, 2026-10-13:
/// vessel ETA notices are never mixed with the others). Vessel: open vessel ETA alerts pinned on top
/// until the jobs are handled, then the vessel notices, both as calm as the web's vessel bell (owner,
/// 2026-10-13, "not make noise"). Other: every other notice, grouped Today / Earlier. Each tab has its
/// own count and "Mark all read". Opened from the dashboard
/// bell (Other) and ship (Vessel); [initialTab] comes from the route's `?tab=vessel|other`.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key, this.notices, this.vessels, this.onOpen, this.now, this.initialTab});

  final EmployeeNotificationsApi? notices;
  final VesselChangesApi? vessels;
  final OpenRoute? onOpen;

  /// The clock for "Today" and relative times (tests fix it).
  final DateTime Function()? now;

  /// The tab to open on; without one the page opens on Vessel when alerts are open (or cannot be
  /// checked) or vessel notices are unread, else on Other.
  final NoticeGroup? initialTab;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) =>
            NotificationsCubit(notices ?? sl<EmployeeNotificationsApi>(), vessels ?? sl<VesselChangesApi>())..load(),
        child: Theme(
          data: notificationsTheme(),
          child: _NotificationsView(open: onOpen ?? pushRoute, now: now ?? DateTime.now, initialTab: initialTab),
        ),
      );
}

/// The tabs, in order.
const List<NoticeGroup> _tabOrder = [NoticeGroup.vessel, NoticeGroup.other];

class _NotificationsView extends StatefulWidget {
  const _NotificationsView({required this.open, required this.now, this.initialTab});

  final OpenRoute open;
  final DateTime Function() now;
  final NoticeGroup? initialTab;

  @override
  State<_NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<_NotificationsView> with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(
      length: _tabOrder.length, vsync: this, initialIndex: _tabOrder.indexOf(widget.initialTab ?? NoticeGroup.vessel));

  /// The tab is settled: asked for by the route, or picked once after the first load.
  late bool _tabSettled = widget.initialTab != null;

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  /// After the first load (no tab asked for): Vessel when something waits there, else Other; never
  /// when the person already switched tabs.
  void _pickTab(NotificationsState s) {
    if (_tabSettled || s.loading) return;
    _tabSettled = true;
    if (_tabs.index != 0 || _tabs.indexIsChanging) return;
    final vessel = s.vesselCount > 0 || s.alertsError != null || s.vesselUnread > 0;
    if (!vessel) _tabs.index = _tabOrder.indexOf(NoticeGroup.other);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return BlocListener<NotificationsCubit, NotificationsState>(
      listener: (_, s) => _pickTab(s),
      child: Scaffold(
        backgroundColor: scheme.surface,
        appBar: AppBar(
          title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w700)),
          bottom: TabBar(
            controller: _tabs,
            tabs: [
              BlocBuilder<NotificationsCubit, NotificationsState>(builder: (_, s) {
                final alerts = s.vesselCount;
                return _TabLabel(
                  key: const Key('tab_vessel'),
                  icon: Icons.directions_boat_filled_rounded,
                  text: 'Vessel',
                  badgeKey: const Key('tab_vessel_badge'),
                  count: alerts > 0 ? alerts : s.vesselUnread,
                  // red: open alerts (action needed); amber: only unread vessel notices
                  badgeColor: alerts > 0 ? NoticeColors.alert : NoticeColors.reminder,
                );
              }),
              BlocBuilder<NotificationsCubit, NotificationsState>(
                builder: (_, s) => _TabLabel(
                  key: const Key('tab_other'),
                  icon: Icons.notifications_none_rounded,
                  text: 'Other',
                  badgeKey: const Key('tab_other_badge'),
                  count: s.otherUnread,
                  badgeColor: NoticeColors.alert,
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabs,
          children: [
            for (final g in _tabOrder)
              _NoticeTab(
                  key: PageStorageKey('notifications_tab_${g.wire}'), group: g, open: widget.open, now: widget.now),
          ],
        ),
      ),
    );
  }
}

/// A tab's label: icon, name and its own count.
class _TabLabel extends StatelessWidget {
  const _TabLabel({
    super.key,
    required this.icon,
    required this.text,
    required this.badgeKey,
    required this.count,
    required this.badgeColor,
  });

  final IconData icon;
  final String text;
  final Key badgeKey;
  final int count;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) => Tab(
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 20),
          const SizedBox(width: 6),
          Flexible(
            child: Text(text,
                maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              key: badgeKey,
              constraints: const BoxConstraints(minWidth: 20),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(10)),
              alignment: Alignment.center,
              child: Text(count > 99 ? '99+' : '$count',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
            ),
          ],
        ]),
      );
}

/// One tab's content: Vessel = the pinned "Action needed" alerts, then the vessel notices; Other = the
/// other notices. Each with pull-to-refresh, its own error with a retry and its own empty state.
class _NoticeTab extends StatefulWidget {
  const _NoticeTab({super.key, required this.group, required this.open, required this.now});

  final NoticeGroup group;
  final OpenRoute open;
  final DateTime Function() now;

  @override
  State<_NoticeTab> createState() => _NoticeTabState();
}

class _NoticeTabState extends State<_NoticeTab> {
  /// "Show all N" alert rows (Vessel tab).
  bool _allAlerts = false;

  /// "Show all" vessel notices instead of the unread ones only.
  bool _allNotices = false;

  NoticeGroup get group => widget.group;
  OpenRoute get open => widget.open;
  DateTime now() => widget.now();

  bool get _vessel => group == NoticeGroup.vessel;

  @override
  Widget build(BuildContext context) => BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          final cubit = context.read<NotificationsCubit>();
          if (_vessel ? state.vesselFailed : state.otherFailed) {
            return _ErrorView(
              key: Key('${group.wire}_tab_error'),
              title: _vessel ? 'Could not load vessel notices' : 'Could not load notifications',
              message: (_vessel ? state.alertsError ?? state.vesselError : state.otherError) ?? '',
              onRetry: cubit.load,
            );
          }
          final nothingYet = _vessel ? state.alerts == null && state.vesselInbox == null : state.otherInbox == null;
          if (nothingYet) return const Center(child: CircularProgressIndicator());
          return RefreshIndicator(
            onRefresh: cubit.load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: _vessel
                  ? [
                      ..._alertSection(context, state, cubit),
                      const SizedBox(height: 20),
                      ..._vesselNoticeSection(context, state, cubit),
                    ]
                  : _noticeSection(context, state, cubit),
            ),
          );
        },
      );

  /// "Action needed" (as the web's vessel bell): a quiet heading and compact rows, mine first, the
  /// first [firstVesselRows] then "Show all N".
  List<Widget> _alertSection(BuildContext context, NotificationsState state, NotificationsCubit cubit) {
    final alerts = state.alerts ?? const <VesselAlert>[];
    final shown = _allAlerts ? alerts : alerts.take(firstVesselRows).toList();
    return [
      _QuietHeading(key: const Key('action_needed_header'), title: 'Action needed', count: alerts.length),
      const SizedBox(height: 4),
      if (state.alertsError != null)
        _InlineError(
            key: const Key('vessel_alerts_error'),
            title: 'Could not check vessel alerts',
            message: state.alertsError!,
            onRetry: cubit.load)
      else if (alerts.isEmpty)
        const _MutedLine(key: Key('no_vessel_alerts'), text: 'No vessel alerts – all your jobs match PTP.')
      else ...[
        _Rows(children: [
          for (final a in shown)
            if (a.isLink)
              _LinkAlertRow(
                key: ValueKey('link_alert_${a.id}'),
                alert: a,
                now: now(),
                onOpenJob: a.saleOrderId == null ? null : () => open(context, saleOrderEditRoute(a.saleOrderId!)),
                onClose: () => cubit.closeAlert(a),
              )
            else
              _AlertRow(alert: a, now: now(), onTap: () => open(context, _routeFor(a))),
        ]),
        if (alerts.length > firstVesselRows)
          _QuietButton(
            key: const Key('show_all_alerts'),
            text: _allAlerts ? 'Show fewer' : 'Show all ${alerts.length}',
            onPressed: () => setState(() => _allAlerts = !_allAlerts),
          ),
      ],
    ];
  }

  /// An ETA row's tap (what "Update jobs" did): the job's sale order screen for jobs without employee
  /// (one job named), else Vessel changes in the alert's scope.
  static String _routeFor(VesselAlert a) {
    if (a.unassigned && a.saleOrderId != null) return saleOrderEditRoute(a.saleOrderId!);
    return a.mine ? vesselChangesPath : vesselChangesTeamPath;
  }

  void _openNotice(BuildContext context, NotificationsCubit cubit, EmployeeNotification n) {
    unawaited(cubit.markRead(n));
    final route = routeForNotice(n);
    if (route != null) open(context, route);
  }

  /// The vessel notices (as the web's vessel bell): the unread ones (at most [firstVesselRows]) until
  /// "Show all"; a "Not handled" notice is left out while its team alert row shows above.
  List<Widget> _vesselNoticeSection(BuildContext context, NotificationsState state, NotificationsCubit cubit) {
    final inbox = state.vesselInbox;
    final error = state.vesselError;
    if (inbox == null) {
      return [
        _InlineError(
            key: const Key('vessel_notices_error'),
            title: 'Could not load vessel notices',
            message: error ?? '',
            onRetry: cubit.load),
      ];
    }
    final teamVessels = [
      for (final a in state.alerts ?? const <VesselAlert>[])
        if (!a.mine) a.vesselName
    ];
    // the safety net: a notice of the other group is never shown here
    final all = withoutShownEscalations([
      for (final n in inbox.items)
        if (group.holds(n)) n
    ], teamVessels);
    final shown = noticesToShow(all, showAll: _allNotices);
    final canExpand = all.length > noticesToShow(all, showAll: false).length;
    final unread = state.vesselUnread;
    final today = now();
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return [
      // wraps on a narrow phone instead of overflowing
      Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const _QuietHeading(key: Key('vessel_notices_header'), title: 'Vessel notices'),
          Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 4, children: [
            Text(unread > 0 ? '$unread unread' : 'nothing unread',
                key: const Key('vessel_unread_text'), style: TextStyle(fontSize: 12, color: muted)),
            if (state.canMarkAll(group))
              _QuietButton(
                key: const Key('mark_all_read_vessel'),
                text: 'Mark all read',
                tooltip: 'Mark all vessel notices read',
                onPressed: () => cubit.markAllRead(group),
              ),
          ]),
        ],
      ),
      if (error != null) _InlineError(title: 'Could not update vessel notices', message: error, onRetry: cubit.load),
      if (shown.isNotEmpty)
        _Rows(children: [
          for (final n in shown)
            _VesselNoticeRow(
                notice: n, time: relativeTime(n.createdAt, today), onTap: () => _openNotice(context, cubit, n)),
        ]),
      if (all.isEmpty)
        const _MutedLine(key: Key('vessel_notices_empty'), text: 'No vessel notices yet.')
      else if (!_allNotices && shown.isEmpty)
        const _MutedLine(key: Key('vessel_nothing_unread'), text: 'Nothing unread.'),
      if (canExpand)
        _QuietButton(
          key: const Key('vessel_notices_toggle'),
          text: _allNotices ? 'Show unread only' : 'Show all',
          onPressed: () => setState(() => _allNotices = !_allNotices),
        ),
    ];
  }

  List<Widget> _noticeSection(BuildContext context, NotificationsState state, NotificationsCubit cubit) {
    final inbox = state.inboxOf(group);
    final error = state.errorOf(group);
    if (inbox == null) {
      return [
        _InlineError(
            key: Key('${group.wire}_notices_error'),
            title: 'Could not load notifications',
            message: error ?? '',
            onRetry: cubit.load),
      ];
    }
    // the safety net: a notice of the other group is never shown here
    final items = [
      for (final n in inbox.items)
        if (group.holds(n)) n
    ];
    final today = now();
    final todays = <EmployeeNotification>[];
    final earlier = <EmployeeNotification>[];
    for (final n in items) {
      final at = n.createdAt;
      (at != null && sameDay(at, today) ? todays : earlier).add(n);
    }
    Widget tile(EmployeeNotification n) =>
        _NoticeTile(notice: n, time: relativeTime(n.createdAt, today), onTap: () => _openNotice(context, cubit, n));
    final w = group.wire;
    return [
      Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 4,
        children: [
          _SectionHeader(
            key: Key('${w}_notices_header'),
            title: 'Other notices',
            icon: Icons.notifications_none_rounded,
            count: state.unreadOf(group),
          ),
          TextButton.icon(
            key: Key('mark_all_read_$w'),
            onPressed: state.canMarkAll(group) ? () => cubit.markAllRead(group) : null,
            icon: const Icon(Icons.done_all_rounded, size: 20),
            label: const Text('Mark all read'),
          ),
        ],
      ),
      const SizedBox(height: 4),
      if (error != null) _InlineError(title: 'Could not update notifications', message: error, onRetry: cubit.load),
      if (items.isEmpty) const _EmptyNotices(),
      if (todays.isNotEmpty) ...[
        _SectionHeader(key: Key('${w}_today_header'), title: 'Today'),
        const SizedBox(height: 4),
        for (final n in todays) tile(n),
        const SizedBox(height: 16),
      ],
      if (earlier.isNotEmpty) ...[
        _SectionHeader(key: Key('${w}_earlier_header'), title: 'Earlier'),
        const SizedBox(height: 4),
        for (final n in earlier) tile(n),
      ],
    ];
  }
}

/// The Other tab's section heading (the Vessel tab uses the quiet [_QuietHeading]).
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({super.key, required this.title, this.icon, this.count});

  final String title;
  final IconData? icon;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = theme.colorScheme.onSurfaceVariant;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      if (icon != null) ...[Icon(icon, size: 18, color: c), const SizedBox(width: 6)],
      Text(title.toUpperCase(),
          style: theme.textTheme.labelLarge?.copyWith(color: c, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
      if (count != null && count! > 0) ...[
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(10)),
          child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
        ),
      ],
    ]);
  }
}

/// A Vessel tab heading: small grey text in normal case, with a small grey count.
class _QuietHeading extends StatelessWidget {
  const _QuietHeading({super.key, required this.title, this.count = 0});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Flexible(
          child: Text(title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: muted)),
        ),
        if (count > 0) ...[
          const SizedBox(width: 6),
          Text(count > 99 ? '99+' : '$count',
              key: const Key('action_needed_count'), style: TextStyle(fontSize: 12, color: muted)),
        ],
      ]),
    );
  }
}

/// A small muted line ("Nothing unread.", "No vessel alerts – ...").
class _MutedLine extends StatelessWidget {
  const _MutedLine({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(text, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      );
}

/// A quiet text action ("Show all", "Open job", "Not this vessel"): small, blue, no fill.
class _QuietButton extends StatelessWidget {
  const _QuietButton({super.key, required this.text, required this.onPressed, this.tooltip, this.busy = false});

  final String text;
  final VoidCallback? onPressed;
  final String? tooltip;

  /// Shows a small spinner before the text (and the button is off) while the action runs.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final button = TextButton(
      onPressed: busy ? null : onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
      child: busy
          ? Row(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5)),
              const SizedBox(width: 6),
              Flexible(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis)),
            ])
          : Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

/// Compact rows on the page's surface, split by thin dividers (no card, no shadow).
class _Rows extends StatelessWidget {
  const _Rows({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final line = Theme.of(context).colorScheme.outlineVariant;
    return DecoratedBox(
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: line, width: 0.5), bottom: BorderSide(color: line, width: 0.5))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) Divider(height: 1, thickness: 0.5, color: line),
          children[i],
        ],
      ]),
    );
  }
}

/// An alert row's frame: its only colour, a thin left border ([alertToneOf]).
class _ToneBorder extends StatelessWidget {
  const _ToneBorder({super.key, required this.alert, required this.child});

  final VesselAlert alert;
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(border: Border(left: BorderSide(color: alertToneOf(alert), width: 3))),
        child: child,
      );
}

/// Line 1 of an alert row: what it is about, a "No employee" label, and the sent time on the right.
class _AlertTitle extends StatelessWidget {
  const _AlertTitle({required this.alert, required this.text, required this.now, this.textKey});

  final VesselAlert alert;
  final String text;
  final DateTime now;
  final Key? textKey;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final sent = alertSentLabel(alert.sentAt, now);
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Expanded(
        child: Row(children: [
          Flexible(
            child: Text(text,
                key: textKey,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: scheme.onSurface)),
          ),
          if (alert.unassigned) ...[
            const SizedBox(width: 6),
            _NoEmployeeLabel(alertId: alert.id),
          ],
        ]),
      ),
      if (sent.isNotEmpty) ...[
        const SizedBox(width: 8),
        Text(sent,
            key: ValueKey('alert_sent_${alert.id}'),
            style: TextStyle(
                fontSize: 12, color: scheme.onSurfaceVariant, fontFeatures: const [FontFeature.tabularFigures()])),
      ],
    ]);
  }
}

/// Line 2 of an alert row: plain muted details joined by " · ", ending with the team member's name for an
/// escalated alert (`team_chip_<id>`; nothing when the name is empty). At most two lines, then "…".
class _AlertDetails extends StatelessWidget {
  const _AlertDetails({required this.alert, required this.parts, this.textKey});

  final VesselAlert alert;
  final List<String> parts;
  final Key? textKey;

  @override
  Widget build(BuildContext context) {
    final team = alertTeamName(alert);
    final text = [...parts, if (team != null) team].where((p) => p.isNotEmpty).join(' · ');
    final details = Text(text,
        key: textKey,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 12.5, height: 1.3, color: Theme.of(context).colorScheme.onSurfaceVariant));
    return team == null ? details : KeyedSubtree(key: ValueKey('team_chip_${alert.id}'), child: details);
  }
}

/// One open ETA alert, pinned until the jobs match PTP or are dismissed on Vessel changes. The whole row
/// opens them (Vessel changes in the alert's scope, or the one job named).
class _AlertRow extends StatelessWidget {
  const _AlertRow({required this.alert, required this.now, required this.onTap});

  final VesselAlert alert;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final arrival = alertArrival(alert);
    return _ToneBorder(
      key: ValueKey('vessel_alert_${alert.id}'),
      alert: alert,
      child: InkWell(
        key: ValueKey('update_jobs_${alert.id}'),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _AlertTitle(alert: alert, text: alert.vesselText, now: now, textKey: ValueKey('alert_title_${alert.id}')),
            const SizedBox(height: 2),
            _AlertDetails(
              alert: alert,
              textKey: ValueKey('alert_details_${alert.id}'),
              parts: [
                'PTP ETA ${arrival.isEmpty ? 'not given' : arrival}',
                '${plural(alert.jobs, 'job')} not updated',
              ],
            ),
          ]),
        ),
      ),
    );
  }
}

/// The jobs of an alert have no employee (sent to a Super Admin; `employeeName` "No employee"): a small
/// neutral label.
class _NoEmployeeLabel extends StatelessWidget {
  const _NoEmployeeLabel({required this.alertId});

  final int alertId;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: ValueKey('no_employee_$alertId'),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(4)),
      child: Text('No employee',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: scheme.onSurfaceVariant)),
    );
  }
}

/// A LINK alert: a job at PTP not linked to its PTP voyage. Stays until the job is linked (on its sale
/// order screen, "Open job") or closed with "Not this vessel" (`POST /api/vessel-changes/alerts/{id}/close`).
class _LinkAlertRow extends StatefulWidget {
  const _LinkAlertRow({super.key, required this.alert, required this.now, required this.onClose, this.onOpenJob});

  final VesselAlert alert;
  final DateTime now;

  /// Null when the alert names no job: "Open job" is hidden.
  final VoidCallback? onOpenJob;

  /// Answers the server's refusal message, or null when it closed.
  final Future<String?> Function() onClose;

  @override
  State<_LinkAlertRow> createState() => _LinkAlertRowState();
}

class _LinkAlertRowState extends State<_LinkAlertRow> {
  bool _closing = false;

  Future<void> _close() async {
    setState(() => _closing = true);
    final error = await widget.onClose();
    if (!mounted) return;
    setState(() => _closing = false);
    if (error != null) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
        key: ValueKey('close_alert_error_${widget.alert.id}'),
        content: Text(error.isEmpty ? 'Could not close the alert' : 'Could not close the alert: $error'),
      ));
    }
  }

  /// "MAERSK NOBERG → 642N, ETA 19 Oct 00:00 (est.)", or the vessel and "No PTP voyage suggested".
  static List<String> _suggestion(VesselAlert alert) {
    final voyage = alert.voyage?.trim() ?? '';
    if (voyage.isEmpty) return [alert.vesselName, 'No PTP voyage suggested'];
    final arrival = alertArrival(alert);
    return ['${alert.vesselName} → $voyage${arrival.isEmpty ? '' : ', ETA $arrival'}'];
  }

  @override
  Widget build(BuildContext context) {
    final alert = widget.alert;
    return _ToneBorder(
      alert: alert,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 8, 4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _AlertTitle(
            alert: alert,
            text: 'Pick PTP voyage · job ${alert.jobNo ?? ''}'.trim(),
            now: widget.now,
            textKey: ValueKey('link_alert_title_${alert.id}'),
          ),
          const SizedBox(height: 2),
          _AlertDetails(alert: alert, parts: _suggestion(alert), textKey: ValueKey('link_alert_suggested_${alert.id}')),
          Wrap(spacing: 4, children: [
            if (widget.onOpenJob != null)
              _QuietButton(key: ValueKey('open_job_${alert.id}'), text: 'Open job', onPressed: widget.onOpenJob),
            _QuietButton(
                key: ValueKey('close_alert_${alert.id}'), text: 'Not this vessel', busy: _closing, onPressed: _close),
          ]),
        ]),
      ),
    );
  }
}

/// One vessel notice (as the web): a small blue dot while unread, a small grey ship (red only for
/// system problems), the title (medium while unread), one line of body and the time.
class _VesselNoticeRow extends StatelessWidget {
  const _VesselNoticeRow({required this.notice, required this.time, required this.onTap});

  final EmployeeNotification notice;
  final String time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final unread = !notice.read;
    final body = notice.body?.trim() ?? '';
    return InkWell(
      key: ValueKey('notice_${notice.id}'),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: SizedBox(
              width: 6,
              height: 6,
              child: unread
                  ? DecoratedBox(
                      key: ValueKey('unread_dot_${notice.id}'),
                      decoration: const BoxDecoration(color: NoticeColors.vessel, shape: BoxShape.circle),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(Icons.directions_boat_outlined,
                key: ValueKey('notice_icon_${notice.id}'),
                size: 16,
                color: isSystemNotice(notice) ? NoticeColors.alert : scheme.outline),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: Text(
                    notice.title,
                    key: ValueKey('notice_title_${notice.id}'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: unread ? FontWeight.w500 : FontWeight.w400,
                      color: unread ? scheme.onSurface : scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(time, style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant)),
              ]),
              if (body.isNotEmpty)
                Text(body,
                    key: ValueKey('notice_body_${notice.id}'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant)),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _NoticeTile extends StatelessWidget {
  const _NoticeTile({required this.notice, required this.time, required this.onTap});

  final EmployeeNotification notice;
  final String time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final unread = !notice.read;
    final tone = toneOf(notice);
    final c = colorForTone(tone, scheme);
    return Padding(
      key: ValueKey('notice_${notice.id}'),
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: unread ? scheme.primaryContainer.withValues(alpha: 0.45) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: c.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(12)),
                child: Icon(iconForTone(tone), color: c, size: 22, key: ValueKey('notice_icon_${notice.id}')),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                      child: Text(
                        notice.title,
                        key: ValueKey('notice_title_${notice.id}'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: unread ? FontWeight.w800 : FontWeight.w500,
                          color: tone == NoticeTone.notHandled ? NoticeColors.alert : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(time, style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
                  ]),
                  if (notice.body != null) ...[
                    const SizedBox(height: 3),
                    Text(notice.body!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                  ],
                ]),
              ),
              if (unread)
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 6),
                  child: Container(
                    key: ValueKey('unread_dot_${notice.id}'),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
                  ),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}

/// The Other tab's empty state (the Vessel tab says "No vessel notices yet." in a muted line).
class _EmptyNotices extends StatelessWidget {
  const _EmptyNotices();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      key: const Key('other_notices_empty'),
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(children: [
        Icon(Icons.notifications_off_outlined, size: 52, color: theme.colorScheme.outline),
        const SizedBox(height: 12),
        Text('No other notices yet.', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Forwarding and other notices will show here.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ]),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({super.key, required this.title, required this.message, required this.onRetry});

  final String title;
  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
      decoration: BoxDecoration(color: scheme.errorContainer, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Icon(Icons.error_outline_rounded, color: scheme.onErrorContainer),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(color: scheme.onErrorContainer, fontWeight: FontWeight.w700)),
            if (message.isNotEmpty) Text(message, style: TextStyle(color: scheme.onErrorContainer, fontSize: 12.5)),
          ]),
        ),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ]),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({super.key, required this.title, required this.message, required this.onRetry});

  final String title;
  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.cloud_off_rounded, size: 52, color: theme.colorScheme.error),
          const SizedBox(height: 12),
          Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 16),
          FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh_rounded), label: const Text('Retry')),
        ]),
      ),
    );
  }
}
