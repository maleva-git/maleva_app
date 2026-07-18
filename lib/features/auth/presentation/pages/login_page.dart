import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../dashboard/admin_dashboard/bloc/admin_tab_bloc.dart';
import '../../../dashboard/admin_dashboard/view/admin_dashboard.dart';
import '../../../dashboard/airfreight_dashboard/bloc/airfreight_bloc.dart';
import '../../../dashboard/airfreight_dashboard/view/airfreight_dashboard.dart';
import '../../../dashboard/boarding_dashboard/bloc/boarding_bloc.dart';
import '../../../dashboard/boarding_dashboard/view/boarding_dashboard.dart';
import '../../../dashboard/driver_dashboard/bloc/driver_bloc.dart';
import '../../../dashboard/driver_dashboard/view/driver_dashboard.dart';
import '../../../dashboard/forwarding_dashboard/bloc/forwarding_bloc.dart';
import '../../../dashboard/forwarding_dashboard/view/forwarding_dashboard.dart';
import '../../../dashboard/hradmin_dashboard/bloc/hradmin_bloc.dart';
import '../../../dashboard/hradmin_dashboard/view/hradmin_dashboard.dart';
import '../../../dashboard/maintenance_dashboard/bloc/maintenance_bloc.dart';
import '../../../dashboard/maintenance_dashboard/view/maintenance_dashboard.dart';
import '../../../dashboard/operation_dashboard/bloc/operation_bloc.dart';
import '../../../dashboard/operation_dashboard/view/operation_dashboard.dart';
import '../../../dashboard/operationadmin_dashboard/bloc/operationadmin_dashboard_bloc.dart';
import '../../../dashboard/operationadmin_dashboard/view/operationadmin_dashboard.dart';
import '../../../dashboard/payable_dashboard/bloc/payable_dasboard_bloc.dart';
import '../../../dashboard/payable_dashboard/view/payable_dashboard.dart';
import '../../../dashboard/receivable_dashboard/bloc/receivable_bloc.dart';
import '../../../dashboard/receivable_dashboard/view/receivable_dashboard.dart';
import '../../../dashboard/sales_dashboard/bloc/sales_bloc.dart';
import '../../../dashboard/sales_dashboard/view/salesdashboard_dashboard.dart';
import '../../../dashboard/subadmin_dashboard/bloc/subadmin_dashboard_bloc.dart';
import '../../../dashboard/subadmin_dashboard/view/subadmin_dashboard.dart';
import '../../../dashboard/transport_dashboard/bloc/transport_bloc.dart';
import '../../../dashboard/transport_dashboard/view/transport_dashboard.dart';
import '../../../dashboard/warehouse_dashboard/bloc/warehouse_bloc.dart';
import '../../../dashboard/warehouse_dashboard/view/warehouse_dashboard.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import 'login_design.dart';
import '../../../../core/utils/app_preferences.dart';

class Appuserloginmobile extends StatelessWidget {
  const Appuserloginmobile ({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {

        if (state.loginSuccess && state.role != null) {
          _navigateBasedOnRole(context, state);
        }

        if (state.errorMessage != null &&
            state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          return const MobileDesign();
        },
      ),
    );
  }


  
  void _navigateBasedOnRole(
      BuildContext context, LoginState state) {

    if (state.driverLogin) {
      context.go('/driver_dashboard');
      return;
    }

    int roleId = AppPreferences.getRoleId();

    switch (roleId) {
      case 100: // ADMIN
        context.go('/dashboard/admin');
        break;
      case 200: // ADMIN2
        context.go('/dashboard/admin');
        break;
      case 300: // SALES
        context.go('/dashboard/sales');
        break;
      case 400: // OPERATIONADMIN
        context.go('/dashboard/admin');
        break;
      case 500: // BOARDING
      case 600: // BOARDINGOFFICERADMIN
        context.go('/dashboard/boarding');
        break;
      case 800: // HRADMIN
        context.go('/dashboard/admin');
        break;
      case 900: // ACCOUNTS
        context.go('/dashboard/payable');
        break;
      case 1000: // TRANSPORTATION
        context.go('/dashboard/transport');
        break;
      case 1200: // RECEIVABLE
        context.go('/dashboard/receivable');
        break;
      case 1300: // MAINTENANCE
        context.go('/dashboard/maintenance');
        break;
      case 1400: // FORWARDING
        context.go('/dashboard/forwarding');
        break;
      case 1500: // AIR FREIGHT
        context.go('/dashboard/air_freight');
        break;
      default:
        context.go('/dashboard/admin');
        break;
    }
  }
}
