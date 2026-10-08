import 'package:maleva/core/router/app_router.dart';

/// Where a tapped push notification opens. Only the unread-mail notice (backend
/// add-my-unread-mail-notice, data `type=MAIL_UNREAD`) is routed; every other push keeps today's
/// behaviour (opens the app where it was).
const String myUnreadMailPath = '/my_unread_mail';
const String mailUnreadPushType = 'MAIL_UNREAD';

String? routeForPush(Map<String, dynamic>? data) =>
    data != null && data['type']?.toString() == mailUnreadPushType ? myUnreadMailPath : null;

/// The local notification's payload carries only the push type.
String? routeForPayload(String? payload) => payload == mailUnreadPushType ? myUnreadMailPath : null;

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
