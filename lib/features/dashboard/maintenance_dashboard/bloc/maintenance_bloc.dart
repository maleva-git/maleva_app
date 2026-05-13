// admin_tab_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import 'maintenance_event.dart';
import 'maintenance_state.dart';


class MaintenanceTabBloc extends Bloc<MaintenanceTabEvent, MaintenanceTabState> {
  MaintenanceTabBloc() : super(MaintenanceTabState(index: 0)) {
    on<MaintenanceTabChanged>((event, emit) {
      emit(MaintenanceTabState(index: event.index));
    });
  }
}
