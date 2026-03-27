import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/DashBoard/Admin2/Admin2Dashboard.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/DashBoard/User/UserDashboard.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import '../../../DashBoard/CustomerService/CustDashboard.dart';
import '../../../DashBoard/Driver/DriverDashboard.dart';
import '../../dashboard/admin_dashboard/bloc/admin_tab_bloc.dart';
import '../../dashboard/admin_dashboard/view/admin_dashboard.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
part 'package:maleva/features/auth/pages/login_design.dart';

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
          return mobiledesign();
        },
      ),
    );
  }


  void _navigateBasedOnRole(
      BuildContext context, LoginState state) {

    if (state.driverLogin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => const DriverDashboard()),
      );
      return;
    }

    switch (state.role) {
      case "ADMIN":
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => AdminTabBloc(),
              child: const NewAdminDashboard(),
            ),
          ),
        );

        break;

      case "ADMIN2":
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => const Admin2Dashboard()),
        );
        break;

      case "SALES":
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => const CustDashboard()),
        );
        break;

      default:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => const Homemobile()),
        );
    }
  }
}

