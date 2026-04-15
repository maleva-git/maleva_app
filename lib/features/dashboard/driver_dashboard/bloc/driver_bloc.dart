
import 'package:flutter_bloc/flutter_bloc.dart';
import 'driver_event.dart';
import 'driver_state.dart';

class DriverDashboardBloc extends Bloc<DriverDashboardEvent, DriverDashboardState> {

  DriverDashboardBloc() : super(DriverDashboardState(index: 0)) {
    on<TabChanged>((event, emit){
      if (state.index != event.index) {
        emit(DriverDashboardState(index: event.index));
      }
    });
  }

}