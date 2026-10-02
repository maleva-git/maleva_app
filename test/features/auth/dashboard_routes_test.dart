import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/features/auth/presentation/dashboard_routes.dart';

void main() {
  test('every mapped role opens its dashboard', () {
    const expected = {
      100: '/dashboard/admin',
      200: '/dashboard/admin',
      300: '/dashboard/sales',
      400: '/dashboard/admin',
      500: '/dashboard/boarding',
      600: '/dashboard/boarding',
      800: '/dashboard/admin',
      900: '/dashboard/payable',
      1000: '/dashboard/transport',
      1200: '/dashboard/receivable',
      1300: '/dashboard/maintenance',
      1400: '/dashboard/forwarding_agent',
      1500: '/dashboard/air_freight',
    };
    expected.forEach((role, route) {
      expect(dashboardRouteFor(isDriver: false, roleId: role), route, reason: 'role $role');
    });
  });

  test('a driver opens the driver dashboard whatever the role', () {
    expect(dashboardRouteFor(isDriver: true, roleId: 0), '/driver_dashboard');
    expect(dashboardRouteFor(isDriver: true, roleId: 300), '/driver_dashboard');
  });

  test('an unmapped role opens the unauthorized page', () {
    expect(dashboardRouteFor(isDriver: false, roleId: 0), '/unauthorized');
    expect(dashboardRouteFor(isDriver: false, roleId: 700), '/unauthorized');
  });

  test('role 200 opens the admin dashboard on restore too (was sub-admin)', () {
    expect(dashboardRouteFor(isDriver: false, roleId: 200), '/dashboard/admin');
  });
}
