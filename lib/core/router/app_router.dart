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

import '../../features/dashboard/airfreight_dashboard/bloc/airfreight_bloc.dart';
import '../../features/dashboard/airfreight_dashboard/view/airfreight_dashboard.dart';

final GoRouter appRouter = GoRouter(
  navigatorKey: AppGlobals.navigatorKey,
  initialLocation: '/',
  observers: [AppNavigatorObserver()],
  routes: [
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
