// admin_tab_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/features/dashboard/payable_dashboard/bloc/payable_dashboard_event.dart';
import 'package:maleva/features/dashboard/payable_dashboard/bloc/payable_dashboard_state.dart';


class PayableTabBloc extends Bloc<PayableTabEvent, PayableTabState> {
  PayableTabBloc() : super(PayableTabState(index: 0)) {
    on<PTabChanged>((event, emit) {
      emit(PayableTabState(index: event.index));
    });
  }
}
