/// The dashboard a session opens, for manual login and for session restore alike.
///
/// The manual-login map (owner decision, clarification Q01): role 200 opens the
/// admin dashboard and an unmapped role the unauthorized page. The splash used
/// to send 200 to `/dashboard/subadmin` and unmapped roles to the admin
/// dashboard; that route now has no entry point.
///
/// The CEO (role 100 with permission id 1, change `ceo-analytics-dashboard`)
/// opens the CEO analytics dashboard; every other role 100 user keeps the
/// admin dashboard. The server checks the same rule on every CEO endpoint.
String dashboardRouteFor({required bool isDriver, required int roleId, required int permissionId}) {
  if (isDriver) return '/driver_dashboard';
  if (isCeo(roleId: roleId, permissionId: permissionId)) return '/dashboard/ceo';
  switch (roleId) {
    case 100: // SUPERADMIN
    case 200: // ADMIN
    case 400: // OPERATIONADMIN
    case 800: // HR
      return '/dashboard/admin';
    case 300: // CUSTOMERSERVICE (sales)
      return '/dashboard/sales';
    case 500: // BOARDINGOFFICER
    case 600: // BOARDINGOFFICERADMIN
      return '/dashboard/boarding';
    case 900: // ACCOUNTS
      return '/dashboard/payable';
    case 1000: // TRANSPORTATION
      return '/dashboard/transport';
    case 1200: // RECEIVABLE
      return '/dashboard/receivable';
    case 1300: // MAINTENANCE
      return '/dashboard/maintenance';
    case 1400: // FORWARDING AGENT
      return '/dashboard/forwarding_agent';
    case 1500: // AIR FREIGHT
      return '/dashboard/air_freight';
    default:
      return '/unauthorized';
  }
}

/// Role 100 (SUPERADMIN) with permission id 1: the CEO.
bool isCeo({required int roleId, required int permissionId}) => roleId == 100 && permissionId == 1;
