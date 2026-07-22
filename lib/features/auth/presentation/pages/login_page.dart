import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
