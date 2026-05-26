import 'package:flutter/material.dart';
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

      case


      "ACCOUNTS":
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => PayableTabBloc(),
              child: const PayableDashboard(),
            ),
          ),
        );
        break;

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
      case "TRANSPORTATION":
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => TransportTabBloc(),
              child: const TransportDashboard(),
            ),
          ),
        );
        break;
      case "HRADMIN":
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => HrAdminTabBloc(),
              child: const HrAdminDashboard(),
            ),
          ),
        );
        break;
      case "HR":
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => MaintenanceTabBloc(),
              child: const MaintenanceDashboard(),
            ),
          ),
        );
        break;
      case "OPERATION":
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => OperationTabBloc(),
              child: const OperationDashboard(),
            ),
          ),
        );
        break;
      case "BOARDING":
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => BoardingTabBloc(),
              child: const BoardingDashboard(),
            ),
          ),
        );
        break;
      case "AIR FRIEGHT":
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => AirfreightTabBloc(),
              child: const AirfreightDashboard(),
            ),
          ),
        );
        break;

      case "FORWARDING":
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => ForwardingTabBloc(),
              child: const ForwardingDashboard(),
            ),
          ),
        );
        break;

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

      case "WAREHOUSE":
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => WareHouseTabBloc(),
              child: const WareHouseDashboard(),
            ),
          ),
        );
        break;

      case "RECEIVABLE":
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => ReceivableTabBloc(),
              child: const ReceivableDashboard(),
            ),
          ),
        );
        break;



      default:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => SubAdminTabBloc(),
              child: const SubAdminDashboard(),
            ),
          ),
        );
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //       builder: (_) => const Homemobile()),
        // );
    }
  }
}

