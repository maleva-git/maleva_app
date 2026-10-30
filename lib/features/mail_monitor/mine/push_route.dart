import 'package:maleva/core/router/app_router.dart';
import 'package:maleva/features/dashboard/payable_dashboard/reminders/reminder_route.dart';
import 'package:maleva/features/dashboard/forwarding_agent_dashboard/push_route.dart';
import 'package:maleva/features/forwarding_requests/push_route.dart';
import 'package:maleva/features/vessel_changes/push_route.dart';

/// Where a tapped push notification opens: the unread-mail notice (backend
/// add-my-unread-mail-notice, data `type=MAIL_UNREAD`) and the forwarding request notices
/// (`type=FORWARDING_*`, see forwarding_requests/push_route.dart) and the vessel change notice
/// (`type=VESSEL_ETA_CHANGED`, see vessel_changes/push_route.dart); every other push keeps today's
/// behaviour (opens the app where it was).
const String myUnreadMailPath = '/my_unread_mail';
const String mailUnreadPushType = 'MAIL_UNREAD';

String? routeForPush(Map<String, dynamic>? data) {
  if (data == null) return null;
  if (data['type']?.toString() == mailUnreadPushType) return myUnreadMailPath;
  return payableReminderRoute(data['type']?.toString(), data['link']?.toString()) ??
      vesselChangesRouteForPush(data) ??
      forwardingRouteForPush(data) ??
      rtiActivitiesRouteForType(data['type']?.toString());
}

/// The local notification's payload carries only the push type.
String? routeForPayload(String? payload) =>
    payload == mailUnreadPushType
        ? myUnreadMailPath
        : payableReminderRoute(payload, null) ??
            vesselChangesRouteForType(payload) ??
            forwardingRouteForType(payload) ??
            rtiActivitiesRouteForType(payload);

/// A route from a notice that opened the app; opened once the person reaches a dashboard (after sign-in).
class PendingPushRoute {
  PendingPushRoute._();

  static String? value;

  static String? take() {
    final v = value;
    value = null;
    return v;
  }
}

/// Opens a notice's screen in the running app (it is signed in when a notice arrives while open).
void openPushRoute(String? route) {
  if (route != null) appRouter.push(route);
}

/// Opens [PendingPushRoute] as soon as the router shows an employee dashboard, so a notice that started
/// the app lands on its screen after the splash and sign-in. Installed once from main.dart.
void installPendingPushRouteOpener() {
  appRouter.routerDelegate.addListener(() {
    final path = appRouter.routerDelegate.currentConfiguration.uri.path;
    if (path.startsWith('/dashboard/') && PendingPushRoute.value != null) {
      final route = PendingPushRoute.take()!;
      Future.microtask(() => appRouter.push(route));
    }
  });
}
