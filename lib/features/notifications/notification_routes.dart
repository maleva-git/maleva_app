import 'package:maleva/core/employee_notifications/employee_notifications_models.dart';
import 'package:maleva/features/dashboard/payable_dashboard/reminders/reminder_route.dart';
import 'package:maleva/features/dashboard/forwarding_agent_dashboard/push_route.dart';
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
/// (forwarding_requests/push_route.dart), the 06:00 RTI notice RTI Activities; any other notice opens nothing.
String? routeForNotice(EmployeeNotification n) {
  final reminder = payableReminderRoute(n.kind, n.linkPath);
  if (reminder != null) return reminder;
  if (NoticeKind.isVessel(n.kind)) return vesselRouteFor(type: n.kind, link: n.linkPath, saleOrderId: n.saleOrderId);
  if (n.kind.startsWith(NoticeKind.forwardingPrefix)) {
    return forwardingRouteForPush({'type': n.kind, if (n.linkPath != null) 'link': n.linkPath});
  }
  return rtiActivitiesRouteForType(n.kind);
}

/// How a notice looks in the list.
enum NoticeTone { notHandled, reminder, vessel, linkNeeded, ptpStale, forwarding, leave, other }

NoticeTone toneOf(EmployeeNotification n) {
  if (NoticeKind.isVessel(n.kind)) {
    final title = n.title.trimLeft().toLowerCase();
    if (title.startsWith('not handled')) return NoticeTone.notHandled;
    if (title.startsWith('reminder')) return NoticeTone.reminder;
    if (n.kind == NoticeKind.vesselLinkNeeded) return NoticeTone.linkNeeded;
    // a schedule that needs reading or uploading (PTP or MMSW not updating, the Westports upload due)
    if (n.kind == NoticeKind.ptpScheduleStale ||
        n.kind == NoticeKind.mmswScheduleStale ||
        n.kind == NoticeKind.westportsUploadDue) {
      return NoticeTone.ptpStale;
    }
    return NoticeTone.vessel;
  }
  if (n.kind.startsWith(NoticeKind.forwardingPrefix)) return NoticeTone.forwarding;
  if (n.kind.startsWith(NoticeKind.leavePrefix)) return NoticeTone.leave;
  return NoticeTone.other;
}
