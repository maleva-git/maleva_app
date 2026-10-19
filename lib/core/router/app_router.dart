import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// App Globals and Observers
import '../utils/app_globals.dart';
import '../logging/app_navigator_observer.dart';
import '../../main.dart'; // To get MyHomePage

// Splash and Auth
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../di/injection.dart';

// Drivers
import '../../features/dashboard/driver_dashboard/bloc/driver_bloc.dart';
import '../../features/dashboard/driver_dashboard/view/driver_dashboard.dart';

// Dashboards (Role-based)
import '../../features/dashboard/admin_dashboard/bloc/admin_tab_bloc.dart';
import '../../features/dashboard/admin_dashboard/view/admin_dashboard.dart';
import '../../features/dashboard/ceo_dashboard/view/ceo_dashboard_page.dart';

import '../../features/dashboard/subadmin_dashboard/bloc/subadmin_dashboard_bloc.dart';
import '../../features/dashboard/subadmin_dashboard/view/subadmin_dashboard.dart';

import '../../features/dashboard/sales_dashboard/bloc/sales_bloc.dart';
import '../../features/dashboard/sales_dashboard/view/salesdashboard_dashboard.dart';

import '../../features/dashboard/operationadmin_dashboard/bloc/operationadmin_dashboard_bloc.dart';
import '../../features/dashboard/operationadmin_dashboard/view/operationadmin_dashboard.dart';

import '../../features/dashboard/boarding_dashboard/bloc/boarding_bloc.dart';
import '../../features/dashboard/boarding_dashboard/view/boarding_dashboard.dart';

import '../../features/dashboard/hradmin_dashboard/bloc/hradmin_bloc.dart';
import '../../features/dashboard/hradmin_dashboard/view/hradmin_dashboard.dart';

import '../../features/dashboard/payable_dashboard/bloc/payable_dasboard_bloc.dart';
import '../../features/dashboard/payable_dashboard/view/payable_dashboard.dart';

import '../../features/dashboard/transport_dashboard/bloc/transport_bloc.dart';
import '../../features/dashboard/transport_dashboard/view/transport_dashboard.dart';

import '../../features/dashboard/receivable_dashboard/bloc/receivable_bloc.dart';
import '../../features/dashboard/receivable_dashboard/view/receivable_dashboard.dart';

import '../../features/dashboard/maintenance_dashboard/bloc/maintenance_bloc.dart';
import '../../features/dashboard/maintenance_dashboard/view/maintenance_dashboard.dart';

import '../../features/dashboard/forwarding_dashboard/bloc/forwarding_bloc.dart';
import '../../features/dashboard/forwarding_dashboard/view/forwarding_dashboard.dart';
import '../../features/dashboard/forwarding_agent_dashboard/bloc/forwarding_agent_bloc.dart';
import '../../features/dashboard/forwarding_agent_dashboard/view/forwarding_agent_dashboard.dart';

import '../../features/dashboard/airfreight_dashboard/bloc/airfreight_bloc.dart';
import '../../features/dashboard/airfreight_dashboard/view/airfreight_dashboard.dart';

import '../../features/dashboard/unauthorized/unauthorized_page.dart';
import '../../features/mail_monitor/mine/my_unread_mail_views.dart';
import '../../features/mail_monitor/mine/push_route.dart';
import '../../features/forwarding_requests/view/forwarding_requests_page.dart';
import '../../features/vessel_changes/push_route.dart';
import '../../features/vessel_changes/vessel_changes_page.dart';
import '../employee_notifications/employee_notifications_models.dart';
import '../../features/notifications/notification_routes.dart';
import '../../features/notifications/notifications_page.dart';
import '../../features/transaction/salesorder/add/view/salesorderadd_tab.dart';

final GoRouter appRouter = GoRouter(
  navigatorKey: AppGlobals.navigatorKey,
  initialLocation: '/',
  observers: [AppNavigatorObserver()],
  routes: [
    // "My unread mail" (add-my-unread-mail-notice): opened from the dashboard bar or a tapped notice
    GoRoute(
      path: myUnreadMailPath,
      name: 'my_unread_mail',
      builder: (context, state) => const MyUnreadMailPage(),
    ),
    // Vessel changes (vessel-master-and-ptp-schedule): jobs whose dates differ from PTP, opened from a
    // tapped VESSEL_ETA_CHANGED notice, the notifications page or the dashboard banner (`?scope=team`
    // opens "My team")
    GoRoute(
      path: vesselChangesPath,
      name: 'vessel_changes',
      builder: (context, state) =>
          VesselChangesPage(initialScope: vesselScopeFromQuery(state.uri.queryParameters['scope'])),
    ),
    // Notifications (bell and ship): a Vessel tab (open alerts pinned, vessel ETA notices) and an Other
    // tab (every other notice); `?tab=vessel|other` picks the tab
    GoRoute(
      path: notificationsPath,
      name: 'notifications',
      builder: (context, state) =>
          NotificationsPage(initialTab: NoticeGroup.fromWire(state.uri.queryParameters['tab'])),
    ),
    // A job's sale order screen (vessel-master-and-ptp-schedule): opened from a VESSEL_LINK_NEEDED notice
    // or LINK alert ("Pick the PTP voyage"), or a vessel notice whose link is `/sale-order/edit/{id}`; a bad
    // id shows the Vessel tab of the notifications instead of a new order
    GoRoute(
      path: '$saleOrderEditPath/:id',
      name: 'sale_order_edit',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null || id <= 0) return const NotificationsPage(initialTab: NoticeGroup.vessel);
        return SalesOrdersAdd(saleOrderId: id);
      },
    ),
    // Forwarding requests (forwarding-requests-on-shared-java-api): the team's list and
    // Customer Service's own requests, opened from a tapped notice or the drawer
    GoRoute(
      path: forwardingRequestsPath,
      name: 'forwarding_requests',
      builder: (context, state) => const ForwardingRequestsPage(),
    ),
    GoRoute(
      path: myForwardingRequestsPath,
      name: 'my_forwarding_requests',
      builder: (context, state) => const ForwardingRequestsPage(mine: true),
    ),
    GoRoute(
      path: '/unauthorized',
      name: 'unauthorized',
      builder: (context, state) => const UnauthorizedPage(),
    ),
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const MyHomePage(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => BlocProvider(
        create: (_) => sl<LoginBloc>(),
        child: const Appuserloginmobile(),
      ),
    ),
    GoRoute(
      path: '/driver_dashboard',
      name: 'driver_dashboard',
      builder: (context, state) => BlocProvider(
        create: (_) => DriverDashboardBloc(),
        child: const DriverDashboard(),
      ),
    ),
    GoRoute(
      path: '/dashboard/admin',
      name: 'admin_dashboard',
      builder: (context, state) => BlocProvider(
        create: (_) => AdminTabBloc(),
        child: const NewAdminDashboard(),
      ),
    ),
    // the CEO (role 100 with permission 1): change ceo-analytics-dashboard
    GoRoute(
      path: '/dashboard/ceo',
      name: 'ceo_dashboard',
      builder: (context, state) => const CeoDashboardPage(),
    ),
    GoRoute(
      path: '/dashboard/subadmin',
      name: 'subadmin_dashboard',
      builder: (context, state) => BlocProvider(
        create: (_) => SubAdminTabBloc(),
        child: const SubAdminDashboard(),
      ),
    ),
    GoRoute(
      path: '/dashboard/sales',
      name: 'sales_dashboard',
      builder: (context, state) => BlocProvider(
        create: (_) => SalesDashboardBloc(),
        child: const SalesDashboard(),
      ),
    ),
    GoRoute(
      path: '/dashboard/operation_admin',
      name: 'operation_admin_dashboard',
      builder: (context, state) => BlocProvider(
        create: (_) => OperationAdminTabBloc(),
        child: const OperationAdminDashboard(),
      ),
    ),
    GoRoute(
      path: '/dashboard/boarding',
      name: 'boarding_dashboard',
      builder: (context, state) => BlocProvider(
        create: (_) => BoardingTabBloc(),
        child: const BoardingDashboard(),
      ),
    ),
    GoRoute(
      path: '/dashboard/hr_admin',
      name: 'hr_admin_dashboard',
      builder: (context, state) => BlocProvider(
        create: (_) => HrAdminTabBloc(),
        child: const HrAdminDashboard(),
      ),
    ),
    GoRoute(
      path: '/dashboard/payable',
      name: 'payable_dashboard',
      builder: (context, state) => BlocProvider(
        create: (_) => PayableTabBloc(),
        child: const PayableDashboard(),
      ),
    ),
    GoRoute(
      path: '/dashboard/transport',
      name: 'transport_dashboard',
      builder: (context, state) => BlocProvider(
        create: (_) => TransportTabBloc(),
        child: const TransportDashboard(),
      ),
    ),
    GoRoute(
      path: '/dashboard/receivable',
      name: 'receivable_dashboard',
      builder: (context, state) => BlocProvider(
        create: (_) => ReceivableTabBloc(),
        child: const ReceivableDashboard(),
      ),
    ),
    GoRoute(
      path: '/dashboard/maintenance',
      name: 'maintenance_dashboard',
      builder: (context, state) => BlocProvider(
        create: (_) => MaintenanceTabBloc(),
        child: const MaintenanceDashboard(),
      ),
    ),
    GoRoute(
      path: '/dashboard/forwarding_agent',
      name: 'forwarding_agent_dashboard',
      builder: (context, state) => BlocProvider(
        create: (_) => ForwardingAgentTabBloc(),
        child: const ForwardingAgentDashboard(),
      ),
    ),
    GoRoute(
      path: '/dashboard/forwarding',
      name: 'forwarding_dashboard',
      builder: (context, state) => BlocProvider(
        create: (_) => ForwardingTabBloc(),
        child: const ForwardingDashboard(),
      ),
    ),
    GoRoute(
      path: '/dashboard/air_freight',
      name: 'air_freight_dashboard',
      builder: (context, state) => BlocProvider(
        create: (_) => AirfreightTabBloc(),
        child: const AirfreightDashboard(),
      ),
    ),
  ],
);
