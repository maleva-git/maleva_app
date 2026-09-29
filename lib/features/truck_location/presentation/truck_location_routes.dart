import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/di/injection.dart';

import 'bloc/truck_location_bloc.dart';
import 'pages/truck_location_board_page.dart';

/// The only place the Truck Location screen is built with its bloc, so the
/// menu never touches the service locator.
class TruckLocationRoutes {
  TruckLocationRoutes._();

  static Route<void> board() {
    return MaterialPageRoute<void>(
      builder: (_) => BlocProvider<TruckLocationBloc>(
        create: (_) => sl<TruckLocationBloc>()..add(const TruckLocationStarted()),
        child: const TruckLocationBoardPage(),
      ),
    );
  }
}
