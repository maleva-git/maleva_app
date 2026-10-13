import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/features/notifications/notification_look.dart';
import 'package:maleva/features/notifications/notification_routes.dart';
import 'package:maleva/features/notifications/notification_summary_cubit.dart';
import 'package:maleva/features/notifications/notifications_page.dart' show OpenRoute, pushRoute;

NotificationSummaryCubit? _sharedSummary() =>
    sl.isRegistered<NotificationSummaryCubit>() ? sl<NotificationSummaryCubit>() : null;

/// The dashboard's notice buttons, the two kinds kept apart (owner, 2026-10-13): the bell with a red
/// badge of the unread notices other than vessel ones (opens the Other tab), and, while vessel alerts
/// are open or vessel notices are unread, a ship button beside it (opens the Vessel tab) with a solid
/// red badge of the open alerts, or an amber badge of the unread vessel notices when no alert is open.
/// Calm as on the web (owner, 2026-10-13, "not make noise"): no animation, no glow.
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
                      ? _CountBadge(key: const Key('vessel_alert_badge'), count: alerts, color: NoticeColors.alert)
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

/// A small round solid count on a button: "99+" past 99.
class _CountBadge extends StatelessWidget {
  const _CountBadge({super.key, required this.count, required this.color});

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(count > 99 ? '99+' : '$count',
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, height: 1.1)),
      );
}
