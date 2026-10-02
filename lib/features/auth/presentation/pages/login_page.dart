import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import 'login_design.dart';
import '../dashboard_routes.dart';
import '../../../../core/utils/app_preferences.dart';

class Appuserloginmobile extends StatelessWidget

{
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
    context.go(dashboardRouteFor(isDriver: state.driverLogin, roleId: AppPreferences.getRoleId()));
  }
}
