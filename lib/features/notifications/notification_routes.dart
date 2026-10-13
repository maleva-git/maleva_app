import 'package:maleva/core/employee_notifications/employee_notifications_models.dart';
import 'package:maleva/features/forwarding_requests/push_route.dart';
import 'package:maleva/features/vessel_changes/push_route.dart';

/// The in-app notifications page: a Vessel tab (alerts pinned on top, then the vessel notices of
/// [NoticeKind.vesselKinds]) and an Other tab (every other notice). `?tab=vessel|other` picks the tab it opens on.
const String notificationsPath = '/notifications';

/// The notifications page on its Vessel tab (the dashboard's ship button).
const String notificationsVesselPath = '$notificationsPath?tab=vessel';

/// The notifications page on its Other tab (the dashboard bell).
const String notificationsOtherPath = '$notificationsPath?tab=other';

/// Where a tapped notice opens: a vessel notice by its link ([vesselRouteFor]: Vessel changes in the
/// link's scope, the job's sale order screen for `/sale-order/edit/{id}` or a `SALE_ORDER` ref, Vessel
/// changes for `/ptp-schedule`, else the Vessel tab), a forwarding notice its forwarding list
/// (forwarding_requests/push_route.dart); any other notice opens nothing.
String? routeForNotice(EmployeeNotification n) {
  if (NoticeKind.isVessel(n.kind)) return vesselRouteFor(type: n.kind, link: n.linkPath, saleOrderId: n.saleOrderId);
  if (n.kind.startsWith(NoticeKind.forwardingPrefix)) {
    return forwardingRouteForPush({'type': n.kind, if (n.linkPath != null) 'link': n.linkPath});
  }
  return null;
}

/// How a notice looks in the list.
enum NoticeTone { notHandled, reminder, vessel, linkNeeded, ptpStale, forwarding, other }

NoticeTone toneOf(EmployeeNotification n) {
  if (NoticeKind.isVessel(n.kind)) {
    final title = n.title.trimLeft().toLowerCase();
    if (title.startsWith('not handled')) return NoticeTone.notHandled;
    if (title.startsWith('reminder')) return NoticeTone.reminder;
    if (n.kind == NoticeKind.vesselLinkNeeded) return NoticeTone.linkNeeded;
    if (n.kind == NoticeKind.ptpScheduleStale) return NoticeTone.ptpStale;
    return NoticeTone.vessel;
  }
  if (n.kind.startsWith(NoticeKind.forwardingPrefix)) return NoticeTone.forwarding;
  return NoticeTone.other;
}
