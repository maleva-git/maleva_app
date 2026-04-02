// admin_tab_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import 'operationadmin_dashboard_event.dart';
import 'operationadmin_dashboard_state.dart';


class OperationAdminTabBloc extends Bloc<OperationAdminTabEvent, OperationAdminTabState> {
  OperationAdminTabBloc() : super(OperationAdminTabState(index: 0)) {
    on<TabChanged>((event, emit) {
      emit(OperationAdminTabState(index: event.index));
    });
  }
}

