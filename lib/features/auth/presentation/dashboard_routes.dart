/// The dashboard a session opens, for manual login and for session restore alike.
///
/// The manual-login map (owner decision, clarification Q01): role 200 opens the
/// admin dashboard and an unmapped role the unauthorized page. The splash used
/// to send 200 to `/dashboard/subadmin` and unmapped roles to the admin
/// dashboard; that route now has no entry point.
String dashboardRouteFor({required bool isDriver, required int roleId}) {
  if (isDriver) return '/driver_dashboard';
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
