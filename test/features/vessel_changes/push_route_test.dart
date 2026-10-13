import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/features/forwarding_requests/view/forwarding_requests_page.dart';
import 'package:maleva/features/mail_monitor/mine/push_route.dart';
import 'package:maleva/features/notifications/notification_routes.dart';
import 'package:maleva/features/vessel_changes/push_route.dart';

/// A tapped VESSEL_ETA_CHANGED notice opens Vessel changes (vessel-master-and-ptp-schedule, task 4.1).
void main() {
  test('the vessel change push and its local notification payload open /vessel_changes', () {
    const data = {'type': 'VESSEL_ETA_CHANGED', 'link': '/vessel-changes'};
    expect(vesselChangesRouteForPush(data), vesselChangesPath);
    expect(routeForPush(data), '/vessel_changes');
    expect(routeForPush({'type': 'VESSEL_ETA_CHANGED'}), vesselChangesPath);
    expect(routeForPayload('VESSEL_ETA_CHANGED'), vesselChangesPath);
  });

  test('cold start: the route waits in PendingPushRoute until the dashboard shows', () {
    PendingPushRoute.value = routeForPush({'type': 'VESSEL_ETA_CHANGED', 'link': '/vessel-changes'});
    expect(PendingPushRoute.take(), vesselChangesPath);
    expect(PendingPushRoute.take(), isNull);
  });

  test('MAIL_UNREAD, FORWARDING_* and other pushes are unchanged', () {
    expect(routeForPush({'type': 'MAIL_UNREAD', 'total': '5'}), myUnreadMailPath);
    expect(routeForPayload('MAIL_UNREAD'), myUnreadMailPath);
    expect(routeForPush({'type': 'FORWARDING_REQUESTED', 'link': '/forwarding/requests'}), forwardingRequestsPath);
    expect(routeForPush({'type': 'FORWARDING_SUBMITTED', 'link': '/forwarding/my-requests'}), myForwardingRequestsPath);
    expect(routeForPush({'type': 'FORWARDING_APPROVED'}), myForwardingRequestsPath);
    expect(routeForPayload('FORWARDING_CANCELLED'), forwardingRequestsPath);
    expect(routeForPayload('FORWARDING_RELEASED'), myForwardingRequestsPath);
    expect(routeForPush({'type': 'PLANNING'}), isNull);
    expect(routeForPush(null), isNull);
    expect(routeForPayload(''), isNull);
    expect(routeForPayload(null), isNull);
    expect(vesselChangesRouteForType('MAIL_UNREAD'), isNull);
  });

  test("a leader's \"Not handled\" push (link scope=team) opens Vessel changes on My team (task 4.4)", () {
    const data = {'type': 'VESSEL_ETA_CHANGED', 'link': '/vessel-changes?scope=team'};
    expect(vesselChangesRouteForPush(data), '/vessel_changes?scope=team');
    expect(routeForPush(data), vesselChangesTeamPath);
    // the local notification shown while the app is open keeps the scope
    expect(localPayloadForPush(data), vesselTeamPayload);
    expect(routeForPayload(localPayloadForPush(data)), vesselChangesTeamPath);
    expect(localPayloadForPush({'type': 'VESSEL_ETA_CHANGED', 'link': '/vessel-changes'}), 'VESSEL_ETA_CHANGED');
    expect(localPayloadForPush({'type': 'MAIL_UNREAD'}), 'MAIL_UNREAD');
    expect(vesselScopeFromQuery('team'), 'team');
    expect(vesselScopeFromQuery(null), 'me');
    expect(vesselChangesRouteForLink('/vessel-changes'), vesselChangesPath);
    expect(vesselChangesRouteForLink(null), vesselChangesPath);
  });

  group('VESSEL_LINK_NEEDED and PTP_SCHEDULE_STALE (owner, 2026-10-13)', () {
    test('VESSEL_LINK_NEEDED opens the job\'s sale order screen, also from its local notification', () {
      const data = {'type': 'VESSEL_LINK_NEEDED', 'link': '/sale-order/edit/51234'};
      expect(routeForPush(data), '/sale_order_edit/51234');
      expect(routeForPush(data), saleOrderEditRoute(51234));
      final payload = localPayloadForPush(data);
      expect(payload, 'VESSEL_LINK_NEEDED@/sale_order_edit/51234');
      expect(routeForPayload(payload), '/sale_order_edit/51234');
    });

    test('VESSEL_LINK_NEEDED without a usable job link opens the Vessel tab', () {
      expect(routeForPush({'type': 'VESSEL_LINK_NEEDED'}), notificationsVesselPath);
      expect(routeForPush({'type': 'VESSEL_LINK_NEEDED', 'link': '/sale-order/edit/abc'}), notificationsVesselPath);
      expect(routeForPayload('VESSEL_LINK_NEEDED'), notificationsVesselPath);
      expect(routeForPayload(localPayloadForPush({'type': 'VESSEL_LINK_NEEDED'})), notificationsVesselPath);
    });

    test('PTP_SCHEDULE_STALE opens Vessel changes (it has "Read PTP now")', () {
      const data = {'type': 'PTP_SCHEDULE_STALE', 'link': '/ptp-schedule'};
      expect(routeForPush(data), vesselChangesPath);
      expect(routeForPush({'type': 'PTP_SCHEDULE_STALE'}), vesselChangesPath);
      expect(routeForPayload(localPayloadForPush(data)), vesselChangesPath);
      expect(routeForPayload('PTP_SCHEDULE_STALE'), vesselChangesPath);
    });

    test('a VESSEL_ETA_CHANGED for a job without employee (link /sale-order/edit/{id}) opens that job', () {
      const data = {'type': 'VESSEL_ETA_CHANGED', 'link': '/sale-order/edit/51300'};
      expect(routeForPush(data), '/sale_order_edit/51300');
      expect(routeForPayload(localPayloadForPush(data)), '/sale_order_edit/51300');
      // several jobs: /vessel-changes as before
      expect(routeForPush({'type': 'VESSEL_ETA_CHANGED', 'link': '/vessel-changes'}), vesselChangesPath);
    });

    test('the job id of a React link', () {
      expect(saleOrderIdFromLink('/sale-order/edit/51234'), 51234);
      expect(saleOrderIdFromLink('/sale-order/edit/0'), isNull);
      expect(saleOrderIdFromLink('/sale-order/edit/'), isNull);
      expect(saleOrderIdFromLink('/sale-order/view/51234'), isNull);
      expect(saleOrderIdFromLink('/vessel-changes'), isNull);
      expect(saleOrderIdFromLink(null), isNull);
    });

    test('a payload naming a non-vessel type or a non-route is ignored', () {
      expect(vesselChangesRouteForType('MAIL_UNREAD@/sale_order_edit/1'), isNull);
      expect(vesselChangesRouteForType('VESSEL_LINK_NEEDED@https://evil.test'), isNull);
      expect(isVesselPushType('VESSEL_LINK_NEEDED'), isTrue);
      expect(isVesselPushType('PTP_SCHEDULE_STALE'), isTrue);
      expect(isVesselPushType('MAIL_UNREAD'), isFalse);
    });
  });
}
