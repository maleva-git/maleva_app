import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/DashBoard/User/UserDashboard.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import '../../../core/theme/tokens.dart';
import '../../dashboard/admin_dashboard/bloc/admin_tab_bloc.dart';
import '../../dashboard/admin_dashboard/view/admin_dashboard.dart';
import '../../dashboard/airfrieght_dashboard/bloc/airfreight_bloc.dart';
import '../../dashboard/airfrieght_dashboard/view/airfrieght_dashboard.dart';
import '../../dashboard/driver_dashboard/bloc/driver_bloc.dart';
import '../../dashboard/driver_dashboard/view/driver_dashboard.dart';
import '../../dashboard/operationadmin_dashboard/bloc/operationadmin_dashboard_bloc.dart';
import '../../dashboard/operationadmin_dashboard/view/operationadmin_dashboard.dart';
import '../../dashboard/subadmin_dashboard/bloc/subadmin_dashboard_bloc.dart';
import '../../dashboard/subadmin_dashboard/view/subadmin_dashboard.dart';
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
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //       builder: (_) => const DriverDashboard()),
      // );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => DriverDashboardBloc(),
            child: const DriverDashboard(),
          ),
        ),
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
      case "SALES":
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => SalesDashboardBloc(),
              child: const SalesDashboard(),
            ),
          ),
        );

        break;
    // else if( objfun.storagenew.getString('RulesType') == "ACCOUNTS")
    // {
    // Navigator.push(context, MaterialPageRoute(builder: (context) => const PayableDashbord()));
    // }



      case "ADMIN2":
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => SubAdminTabBloc(),
              child: const SubAdminDashboard(),
            ),
          ),
        );
        break;

    // else if(objfun.storagenew.getString('RulesType') == "TRANSPORTATION")
    // {
    // Navigator.push(context, MaterialPageRoute(builder: (context) => const TransportDashboard()));
    // }
    // else if(objfun.storagenew.getString('RulesType') == "OPERATIONADMIN")
    // {
    // Navigator.push(context, MaterialPageRoute(builder: (context) => const OperationAdminDashboard()));
    // }
    // else if(objfun.storagenew.getString('RulesType') == "HR")
    // {
    // Navigator.push(context, MaterialPageRoute(builder: (context) => const MaintenanceDashboard()));
    // }
    // else if(objfun.storagenew.getString('RulesType') == "AIR FRIEGHT")
    // {
    // Navigator.push(context, MaterialPageRoute(builder: (context) => const AirFrieghtDashboard()));
    // }
    // else if(objfun.storagenew.getString('RulesType') == "BOARDING"  || objfun.storagenew.getString('RulesType') == "OPERATION")
    // {
    // Navigator.push(context, MaterialPageRoute(builder: (context) => const BoardingDashboard()));
    // }
    // else if( objfun.storagenew.getString('RulesType') == "FORWARDING" )
    // {
    // Navigator.push(context, MaterialPageRoute(builder: (context) => const ForwardingDashboard()));
    // }
    // else if( objfun.storagenew.getString('RulesType') == "RECEIVABLE" )
    // {
    // Navigator.push(context, MaterialPageRoute(builder: (context) => const ReceivableDashboard()));
    // }
    // else if( objfun.storagenew.getString('RulesType') == "HRADMIN")
    // {
    // Navigator.push(context, MaterialPageRoute(builder: (context) => const HrDashboard()));
    // }
    // else if( objfun.storagenew.getString('RulesType') == "WAREHOUSE")
    // {
    // Navigator.push(context, MaterialPageRoute(builder: (context) => const Warehousedashboard()));
    // }

      case "OPERATIONADMIN":
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => OperationAdminTabBloc(),
              child: const OperationAdminDashboard(),
            ),
          ),
        );
        break;
       // case "SALES":
       //   Navigator.pushReplacement(
       //     context,
       //     MaterialPageRoute(
       //         builder: (_) => const CustDashboard()),
       //   );
       //   break;

      default:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => const Homemobile()),
        );
    }
  }
}

