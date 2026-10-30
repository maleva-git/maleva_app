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
      1100: '/dashboard/payable',
      1200: '/dashboard/receivable',
      1300: '/dashboard/maintenance',
      1400: '/dashboard/forwarding_agent',
      1500: '/dashboard/air_freight',
    };
    expected.forEach((role, route) {
      expect(dashboardRouteFor(isDriver: false, roleId: role, permissionId: 0), route, reason: 'role $role');
    });
  });

  test('role 100 with permission 1 (the CEO) opens the CEO dashboard', () {
    expect(dashboardRouteFor(isDriver: false, roleId: 100, permissionId: 1), '/dashboard/ceo');
  });

  test('other role 100 users keep the admin dashboard', () {
    expect(dashboardRouteFor(isDriver: false, roleId: 100, permissionId: 0), '/dashboard/admin');
    expect(dashboardRouteFor(isDriver: false, roleId: 100, permissionId: 2), '/dashboard/admin');
  });

  test('permission 1 alone does not make a CEO', () {
    expect(dashboardRouteFor(isDriver: false, roleId: 200, permissionId: 1), '/dashboard/admin');
    expect(dashboardRouteFor(isDriver: false, roleId: 300, permissionId: 1), '/dashboard/sales');
  });

  test('a driver opens the driver dashboard whatever the role', () {
    expect(dashboardRouteFor(isDriver: true, roleId: 0, permissionId: 0), '/driver_dashboard');
    expect(dashboardRouteFor(isDriver: true, roleId: 300, permissionId: 0), '/driver_dashboard');
    expect(dashboardRouteFor(isDriver: true, roleId: 100, permissionId: 1), '/driver_dashboard');
  });

  test('an unmapped role opens the unauthorized page', () {
    expect(dashboardRouteFor(isDriver: false, roleId: 0, permissionId: 0), '/unauthorized');
    expect(dashboardRouteFor(isDriver: false, roleId: 700, permissionId: 1), '/unauthorized');
  });

  test('role 200 opens the admin dashboard on restore too (was sub-admin)', () {
    expect(dashboardRouteFor(isDriver: false, roleId: 200, permissionId: 0), '/dashboard/admin');
  });
}
