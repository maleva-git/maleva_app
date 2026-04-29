// admin_tab_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/features/dashboard/receivable_dashboard/bloc/receivable_event.dart';
import 'package:maleva/features/dashboard/receivable_dashboard/bloc/receivable_state.dart';


class ReceivableTabBloc extends Bloc<ReceivableTabEvent, ReceivableTabState> {
  ReceivableTabBloc() : super(ReceivableTabState(index: 0)) {
    on<ReceivableTabChanged>((event, emit) {
      emit(ReceivableTabState(index: event.index));
    });
  }
}
