// admin_tab_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import 'operation_event.dart';
import 'operation_state.dart';


class OperationTabBloc extends Bloc<OperationTabEvent, OperationTabState> {
  OperationTabBloc() : super(OperationTabState(index: 0)) {
    on<OperationTabChanged>((event, emit) {
      emit(OperationTabState(index: event.index));
    });
  }
}
