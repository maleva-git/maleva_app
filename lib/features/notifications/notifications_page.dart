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
import 'package:maleva/features/vessel_changes/vessel_changes_cubit.dart' show vesselTimeText;

/// Opens an app route (GoRouter in the app; a recorder in tests).
typedef OpenRoute = void Function(BuildContext context, String route);

void pushRoute(BuildContext context, String route) => GoRouter.of(context).push(route);

/// The page's own Material 3 look, seeded from the app's blue (the rest of the app is still Material 2).
ThemeData notificationsTheme() => ThemeData(useMaterial3: true, colorSchemeSeed: Palette.blue700);

/// Notifications (change vessel-master-and-ptp-schedule), in two separate tabs (owner, 2026-10-13:
/// vessel ETA notices are never mixed with the others). Vessel: open vessel ETA alerts pinned on top
/// until the jobs are handled, then the vessel ETA notices. Other: every other notice. Each tab groups
/// its notices Today / Earlier and has its own count and "Mark all read". Opened from the dashboard
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
class _NoticeTab extends StatelessWidget {
  const _NoticeTab({super.key, required this.group, required this.open, required this.now});

  final NoticeGroup group;
  final OpenRoute open;
  final DateTime Function() now;

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
              children: [
                if (_vessel) ...[..._alertSection(context, state, cubit), const SizedBox(height: 24)],
                ..._noticeSection(context, state, cubit),
              ],
            ),
          );
        },
      );

  List<Widget> _alertSection(BuildContext context, NotificationsState state, NotificationsCubit cubit) {
    final alerts = state.alerts ?? const <VesselAlert>[];
    return [
      _SectionHeader(
        key: const Key('action_needed_header'),
        title: 'Action needed',
        icon: Icons.push_pin_rounded,
        color: alerts.isEmpty ? null : NoticeColors.alert,
        count: alerts.length,
      ),
      const SizedBox(height: 8),
      if (state.alertsError != null)
        _InlineError(
            key: const Key('vessel_alerts_error'),
            title: 'Could not check vessel alerts',
            message: state.alertsError!,
            onRetry: cubit.load)
      else if (alerts.isEmpty)
        const _AllClear()
      else
        for (final a in alerts)
          if (a.isLink)
            _LinkAlertCard(
              key: ValueKey('link_alert_${a.id}'),
              alert: a,
              now: now(),
              onOpenJob: a.saleOrderId == null ? null : () => open(context, saleOrderEditRoute(a.saleOrderId!)),
              onClose: () => cubit.closeAlert(a),
            )
          else
            _AlertCard(alert: a, now: now(), onUpdate: () => open(context, _routeFor(a))),
    ];
  }

  /// "Update jobs": the job's sale order screen for jobs without employee (one job named), else Vessel
  /// changes in the alert's scope.
  static String _routeFor(VesselAlert a) {
    if (a.unassigned && a.saleOrderId != null) return saleOrderEditRoute(a.saleOrderId!);
    return a.mine ? vesselChangesPath : vesselChangesTeamPath;
  }

  List<Widget> _noticeSection(BuildContext context, NotificationsState state, NotificationsCubit cubit) {
    final inbox = state.inboxOf(group);
    final error = state.errorOf(group);
    if (inbox == null) {
      return [
        _InlineError(
            key: Key('${group.wire}_notices_error'),
            title: _vessel ? 'Could not load vessel notices' : 'Could not load notifications',
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
    Widget tile(EmployeeNotification n) => _NoticeTile(
          notice: n,
          time: relativeTime(n.createdAt, today),
          onTap: () {
            unawaited(cubit.markRead(n));
            final route = routeForNotice(n);
            if (route != null) open(context, route);
          },
        );
    final w = group.wire;
    return [
      Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 4,
        children: [
          _SectionHeader(
            key: Key('${w}_notices_header'),
            title: _vessel ? 'Vessel notices' : 'Other notices',
            icon: _vessel ? Icons.directions_boat_filled_rounded : Icons.notifications_none_rounded,
            count: state.unreadOf(group),
          ),
          TextButton.icon(
            key: Key('mark_all_read_$w'),
            onPressed: state.canMarkAll(group) ? () => cubit.markAllRead(group) : null,
            icon: const Icon(Icons.done_all_rounded, size: 20),
            label: Text(_vessel ? 'Mark all vessel notices read' : 'Mark all read'),
          ),
        ],
      ),
      const SizedBox(height: 4),
      if (error != null)
        _InlineError(
            title: _vessel ? 'Could not update vessel notices' : 'Could not update notifications',
            message: error,
            onRetry: cubit.load),
      if (items.isEmpty) _EmptyNotices(group: group),
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({super.key, required this.title, this.icon, this.color, this.count});

  final String title;
  final IconData? icon;
  final Color? color;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.onSurfaceVariant;
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

/// One open vessel alert: stays here until the jobs match PTP or are dismissed on Vessel changes.
class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alert, required this.now, required this.onUpdate});

  final VesselAlert alert;
  final DateTime now;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = alert.mine ? NoticeColors.alert : NoticeColors.team;
    final eta =
        'PTP ETA ${vesselTimeText(alert.arriveAt)}${alert.arriveEstimated && alert.arriveAt != null ? ' est.' : ''}';
    return Container(
      key: ValueKey('vessel_alert_${alert.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Color.alphaBlend(accent.withValues(alpha: 0.06), theme.colorScheme.surface),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.45), width: 1.2),
        boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(width: 6, color: accent),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration:
                        BoxDecoration(color: accent.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(14)),
                    child: Icon(Icons.directions_boat_filled_rounded, color: accent, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(alert.vesselText,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(eta,
                          style: theme.textTheme.bodyMedium?.copyWith(color: accent, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                  if (!alert.mine && !alert.unassigned) ...[
                    const SizedBox(width: 8),
                    Chip(
                      key: ValueKey('team_chip_${alert.id}'),
                      avatar: Icon(Icons.groups_rounded, size: 16, color: accent),
                      label: Text('Team: ${alert.employeeName ?? '#${alert.employeeId}'}'),
                      labelStyle: TextStyle(color: accent, fontWeight: FontWeight.w700, fontSize: 12),
                      side: BorderSide(color: accent.withValues(alpha: 0.5)),
                      backgroundColor: accent.withValues(alpha: 0.08),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ]),
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 6, children: [
                  if (alert.unassigned) _NoEmployeeBadge(alertId: alert.id, color: accent),
                  _Fact(
                      icon: Icons.warning_amber_rounded,
                      text: '${plural(alert.jobs, 'job')} not updated',
                      color: accent),
                  _Fact(icon: Icons.schedule_rounded, text: 'since ${sinceText(alert.sentAt, now)}'),
                  if (alert.reminders > 0)
                    _Fact(icon: Icons.notifications_active_outlined, text: 'Reminded ${alert.reminders}×'),
                  if (alert.mine && alert.escalated)
                    const _Fact(icon: Icons.supervisor_account_outlined, text: 'Leader told'),
                ]),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    key: ValueKey('update_jobs_${alert.id}'),
                    style: FilledButton.styleFrom(backgroundColor: accent, foregroundColor: Colors.white),
                    onPressed: onUpdate,
                    icon: const Icon(Icons.edit_calendar_rounded, size: 18),
                    label: const Text('Update jobs'),
                  ),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

/// The jobs of an alert have no employee (sent to a Super Admin; `employeeName` "No employee").
class _NoEmployeeBadge extends StatelessWidget {
  const _NoEmployeeBadge({required this.alertId, required this.color});

  final int alertId;
  final Color color;

  @override
  Widget build(BuildContext context) => KeyedSubtree(
        key: ValueKey('no_employee_$alertId'),
        child: _Fact(icon: Icons.person_off_outlined, text: 'No employee', color: color),
      );
}

/// A LINK alert: a job at PTP not linked to its PTP voyage. Stays until the job is linked (on its sale
/// order screen, "Open job") or closed with "Not this vessel" (`POST /api/vessel-changes/alerts/{id}/close`).
class _LinkAlertCard extends StatefulWidget {
  const _LinkAlertCard({super.key, required this.alert, required this.now, required this.onClose, this.onOpenJob});

  final VesselAlert alert;
  final DateTime now;

  /// Null when the alert names no job: "Open job" is hidden.
  final VoidCallback? onOpenJob;

  /// Answers the server's refusal message, or null when it closed.
  final Future<String?> Function() onClose;

  @override
  State<_LinkAlertCard> createState() => _LinkAlertCardState();
}

class _LinkAlertCardState extends State<_LinkAlertCard> {
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

  @override
  Widget build(BuildContext context) {
    final alert = widget.alert;
    final theme = Theme.of(context);
    final accent = alert.mine ? NoticeColors.vessel : NoticeColors.team;
    final suggested = alert.voyage == null && alert.arriveAt == null
        ? 'No PTP voyage suggested'
        : 'PTP: ${alert.voyage ?? alert.vesselName}'
            '${alert.arriveAt == null ? '' : ' · arrives ${vesselTimeText(alert.arriveAt)}'}'
            '${alert.arriveEstimated && alert.arriveAt != null ? ' est.' : ''}';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Color.alphaBlend(accent.withValues(alpha: 0.06), theme.colorScheme.surface),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.45), width: 1.2),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(width: 6, color: accent),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration:
                        BoxDecoration(color: accent.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(14)),
                    child: Icon(Icons.link_rounded, color: accent, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Pick the PTP voyage: job ${alert.jobNo ?? '-'}',
                          key: ValueKey('link_alert_title_${alert.id}'),
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(alert.vesselName,
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text(suggested,
                          key: ValueKey('link_alert_suggested_${alert.id}'),
                          style: theme.textTheme.bodyMedium?.copyWith(color: accent, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                  if (!alert.mine && !alert.unassigned) ...[
                    const SizedBox(width: 8),
                    Chip(
                      key: ValueKey('team_chip_${alert.id}'),
                      avatar: Icon(Icons.groups_rounded, size: 16, color: accent),
                      label: Text('Team: ${alert.employeeName ?? '#${alert.employeeId}'}'),
                      labelStyle: TextStyle(color: accent, fontWeight: FontWeight.w700, fontSize: 12),
                      side: BorderSide(color: accent.withValues(alpha: 0.5)),
                      backgroundColor: accent.withValues(alpha: 0.08),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ]),
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 6, children: [
                  if (alert.unassigned) _NoEmployeeBadge(alertId: alert.id, color: accent),
                  _Fact(icon: Icons.schedule_rounded, text: 'since ${sinceText(alert.sentAt, widget.now)}'),
                  if (alert.reminders > 0)
                    _Fact(icon: Icons.notifications_active_outlined, text: 'Reminded ${alert.reminders}×'),
                  if (alert.mine && alert.escalated)
                    const _Fact(icon: Icons.supervisor_account_outlined, text: 'Leader told'),
                ]),
                const SizedBox(height: 12),
                Wrap(alignment: WrapAlignment.end, spacing: 8, runSpacing: 6, children: [
                  OutlinedButton.icon(
                    key: ValueKey('close_alert_${alert.id}'),
                    onPressed: _closing ? null : _close,
                    icon: _closing
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Not this vessel'),
                  ),
                  if (widget.onOpenJob != null)
                    FilledButton.icon(
                      key: ValueKey('open_job_${alert.id}'),
                      style: FilledButton.styleFrom(backgroundColor: accent, foregroundColor: Colors.white),
                      onPressed: widget.onOpenJob,
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      label: const Text('Open job'),
                    ),
                ]),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.text, this.color});

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = color ?? scheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 15, color: c),
        const SizedBox(width: 5),
        Flexible(
          child: Text(text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.5, color: c, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}

class _AllClear extends StatelessWidget {
  const _AllClear();

  @override
  Widget build(BuildContext context) => Container(
        key: const Key('no_vessel_alerts'),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: NoticeColors.allClear.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(children: [
          Icon(Icons.check_circle_rounded, color: NoticeColors.allClear, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text('No vessel alerts – all jobs match PTP',
                style: TextStyle(color: NoticeColors.allClear, fontWeight: FontWeight.w600)),
          ),
        ]),
      );
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

class _EmptyNotices extends StatelessWidget {
  const _EmptyNotices({required this.group});

  final NoticeGroup group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vessel = group == NoticeGroup.vessel;
    return Padding(
      key: Key('${group.wire}_notices_empty'),
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(children: [
        Icon(vessel ? Icons.directions_boat_outlined : Icons.notifications_off_outlined,
            size: 52, color: theme.colorScheme.outline),
        const SizedBox(height: 12),
        Text(vessel ? 'No vessel ETA notices yet.' : 'No other notices yet.',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(
            vessel
                ? 'Vessel ETA changes for your jobs will show here.'
                : 'Forwarding and other notices will show here.',
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
