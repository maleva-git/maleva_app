// admin_tab_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/features/dashboard/warehouse_dashboard/bloc/warehouse_event.dart';
import 'package:maleva/features/dashboard/warehouse_dashboard/bloc/warehouse_state.dart';

class WareHouseTabBloc extends Bloc<WareHouseEvent, WareHouseTabState> {
  WareHouseTabBloc() : super(WareHouseTabState(index: 0)) {
    on<WarehouseTabChanged>((event, emit) {
      emit(WareHouseTabState(index: event.index));
    });
  }
}
