import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/features/notifications/notification_look.dart';
import 'package:maleva/features/notifications/notification_routes.dart';
import 'package:maleva/features/notifications/notification_summary_cubit.dart';
import 'package:maleva/features/notifications/notifications_page.dart' show OpenRoute, pushRoute;
import 'package:maleva/features/vessel_changes/push_route.dart';

NotificationSummaryCubit? _sharedSummary() =>
    sl.isRegistered<NotificationSummaryCubit>() ? sl<NotificationSummaryCubit>() : null;

/// The dashboard's notice buttons, the two kinds kept apart (owner, 2026-10-13): the bell with a red
/// badge of the unread notices other than vessel ones (opens the Other tab), and, while vessel alerts
/// are open or vessel notices are unread, a ship button beside it (opens the Vessel tab) with a pulsing
/// red badge of the open alerts, or an amber badge of the unread vessel notices when no alert is open.
/// Loads on show and when the app comes back; reloads on every push (NotificationSignals).
class NotificationBellButton extends StatefulWidget {
  const NotificationBellButton({super.key, this.cubit, this.isTablet = false, this.onOpen});

  /// Defaults to the app's shared summary (DI); without one the bell is a plain button.
  final NotificationSummaryCubit? cubit;
  final bool isTablet;
  final OpenRoute? onOpen;

  @override
  State<NotificationBellButton> createState() => _NotificationBellButtonState();
}

class _NotificationBellButtonState extends State<NotificationBellButton> {
  late final NotificationSummaryCubit? _cubit = widget.cubit ?? _sharedSummary();
  AppLifecycleListener? _life;

  @override
  void initState() {
    super.initState();
    _cubit?.load();
    _life = AppLifecycleListener(onResume: () => _cubit?.load());
  }

  @override
  void dispose() {
    _life?.dispose();
    super.dispose();
  }

  void _open(String route) => (widget.onOpen ?? pushRoute)(context, route);

  @override
  Widget build(BuildContext context) {
    final size = widget.isTablet ? 28.0 : 26.0;
    final cubit = _cubit;
    if (cubit == null) {
      return IconButton(
        key: const Key('notification_bell'),
        tooltip: 'Notifications',
        icon: Icon(Icons.notifications_none_rounded, size: size),
        onPressed: () => _open(notificationsPath),
      );
    }
    return BlocBuilder<NotificationSummaryCubit, NotificationSummaryState>(
      bloc: cubit,
      builder: (context, s) {
        final unread = s.otherUnread;
        final alerts = s.alerts.length;
        final vesselUnread = s.vesselUnread;
        return Row(mainAxisSize: MainAxisSize.min, children: [
          if (alerts > 0 || vesselUnread > 0)
            IconButton(
              key: const Key('vessel_notice_button'),
              tooltip: [
                'Vessel notices',
                if (alerts > 0) plural(alerts, 'vessel alert'),
                if (vesselUnread > 0) '$vesselUnread unread',
              ].join(', '),
              onPressed: () => _open(notificationsVesselPath),
              icon: Stack(clipBehavior: Clip.none, children: [
                Icon(Icons.directions_boat_filled_rounded, size: size),
                Positioned(
                  right: -7,
                  top: -6,
                  child: alerts > 0
                      ? _Pulse(
                          child: _CountBadge(
                              key: const Key('vessel_alert_badge'), count: alerts, color: _alertRed, glow: true))
                      : _CountBadge(
                          key: const Key('vessel_unread_badge'), count: vesselUnread, color: NoticeColors.reminder),
                ),
              ]),
            ),
          IconButton(
            key: const Key('notification_bell'),
            tooltip: ['Notifications', if (unread > 0) '$unread unread'].join(', '),
            onPressed: () => _open(notificationsOtherPath),
            icon: Stack(clipBehavior: Clip.none, children: [
              Icon(unread > 0 ? Icons.notifications_rounded : Icons.notifications_none_rounded, size: size),
              if (unread > 0)
                Positioned(
                  right: -6,
                  top: -5,
                  child: _CountBadge(key: const Key('bell_unread_badge'), count: unread, color: NoticeColors.alert),
                ),
            ]),
          ),
        ]);
      },
    );
  }
}

const Color _alertRed = Color(0xFFFF3D00);

/// A small round count on a button: "99+" past 99.
class _CountBadge extends StatelessWidget {
  const _CountBadge({super.key, required this.count, required this.color, this.glow = false});

  final int count;
  final Color color;
  final bool glow;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: glow ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 6, spreadRadius: 1)] : null,
        ),
        alignment: Alignment.center,
        child: Text(count > 99 ? '99+' : '$count',
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, height: 1.1)),
      );
}

/// Pulses its child while vessel alerts are open.
class _Pulse extends StatefulWidget {
  const _Pulse({required this.child});

  final Widget child;

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
        scale: Tween(begin: 0.85, end: 1.15).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
        child: widget.child,
      );
}

/// The dashboard's vessel alert banner, at the very top of the body: red while the person's own vessel
/// ETA changes wait, blue while their own jobs need a PTP voyage picked (LINK alerts), amber for team
/// members' alerts not handled in time. Not dismissible: it goes when
/// the jobs are handled (the server re-checks them on every fetch).
class VesselAlertBanner extends StatefulWidget {
  const VesselAlertBanner({super.key, this.cubit, this.onOpen});

  final NotificationSummaryCubit? cubit;
  final OpenRoute? onOpen;

  @override
  State<VesselAlertBanner> createState() => _VesselAlertBannerState();
}

class _VesselAlertBannerState extends State<VesselAlertBanner> {
  late final NotificationSummaryCubit? _cubit = widget.cubit ?? _sharedSummary();

  @override
  void initState() {
    super.initState();
    _cubit?.load(); // shares the bell's request when both start together
  }

  @override
  Widget build(BuildContext context) {
    final cubit = _cubit;
    if (cubit == null) return const SizedBox.shrink();
    final open = widget.onOpen ?? pushRoute;
    return BlocBuilder<NotificationSummaryCubit, NotificationSummaryState>(
      bloc: cubit,
      builder: (context, s) {
        final mine = [
          for (final a in s.mineAlerts)
            if (!a.isLink) a
        ];
        final links = [
          for (final a in s.mineAlerts)
            if (a.isLink) a
        ];
        final team = s.teamAlerts;
        if (mine.isEmpty && links.isEmpty && team.isEmpty) return const SizedBox.shrink();
        final names = {for (final a in team) a.employeeName ?? '#${a.employeeId}'}.join(', ');
        return Column(mainAxisSize: MainAxisSize.min, children: [
          if (mine.isNotEmpty)
            _BannerRow(
              key: const Key('vessel_banner_mine'),
              background: NoticeColors.alert,
              foreground: Colors.white,
              icon: Icons.directions_boat_filled_rounded,
              text: mine.length == 1
                  ? '1 vessel ETA change needs action'
                  : '${mine.length} vessel ETA changes need action',
              onOpen: () => open(context, vesselChangesPath),
            ),
          if (links.isNotEmpty)
            _BannerRow(
              key: const Key('vessel_banner_link'),
              background: NoticeColors.vessel,
              foreground: Colors.white,
              icon: Icons.link_rounded,
              text: links.length == 1
                  ? 'Pick the PTP voyage: job ${links.single.jobNo ?? '-'}'
                  : '${links.length} jobs need their PTP voyage picked',
              // one job: its sale order screen; several: the Vessel tab with their cards
              onOpen: () => open(
                  context,
                  links.length == 1 && links.single.saleOrderId != null
                      ? saleOrderEditRoute(links.single.saleOrderId!)
                      : notificationsVesselPath),
            ),
          if (team.isNotEmpty)
            _BannerRow(
              key: const Key('vessel_banner_team'),
              background: NoticeColors.amberBanner,
              foreground: const Color(0xFF3E2723),
              icon: Icons.groups_rounded,
              text: '${plural(team.length, 'team vessel alert')} not handled ($names)',
              onOpen: () => open(context, vesselChangesTeamPath),
            ),
        ]);
      },
    );
  }
}

class _BannerRow extends StatelessWidget {
  const _BannerRow({
    super.key,
    required this.background,
    required this.foreground,
    required this.icon,
    required this.text,
    required this.onOpen,
  });

  final Color background;
  final Color foreground;
  final IconData icon;
  final String text;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => Material(
        color: background,
        child: InkWell(
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
            child: Row(children: [
              Icon(icon, color: foreground, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: foreground, fontWeight: FontWeight.w700, fontSize: 14)),
              ),
              TextButton(
                onPressed: onOpen,
                style: TextButton.styleFrom(foregroundColor: foreground),
                child: const Text('Open', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ]),
          ),
        ),
      );
}
