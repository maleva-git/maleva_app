import 'package:maleva/features/forwarding_requests/view/forwarding_requests_page.dart';

/// Where a forwarding request push (backend `forwarding-request-followup`, data `type=FORWARDING_*`,
/// `link=/forwarding/requests|/forwarding/my-requests`) opens. The team's notices open the planning
/// list; the requester's notices open "My Forwarding Requests".
const Set<String> _teamTypes = {'FORWARDING_REQUESTED', 'FORWARDING_OVERDUE', 'FORWARDING_CANCELLED'};

String? forwardingRouteForPush(Map<String, dynamic>? data) {
  if (data == null) return null;
  final link = data['link']?.toString() ?? '';
  if (link == '/forwarding/requests') return forwardingRequestsPath;
  if (link == '/forwarding/my-requests') return myForwardingRequestsPath;
  return forwardingRouteForType(data['type']?.toString());
}

/// The local notification's payload carries only the push type.
String? forwardingRouteForType(String? type) {
  if (type == null || !type.startsWith('FORWARDING_')) return null;
  return _teamTypes.contains(type) ? forwardingRequestsPath : myForwardingRequestsPath;
}
