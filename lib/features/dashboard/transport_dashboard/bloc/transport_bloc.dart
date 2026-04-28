
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/features/dashboard/transport_dashboard/bloc/transport_event.dart';
import 'package:maleva/features/dashboard/transport_dashboard/bloc/transport_state.dart';

class TransportTabBloc extends Bloc<TransportTabEvent, TransportTabState> {
  TransportTabBloc() : super(TransportTabState(index: 0)) {
    on<TransportTabEvents>((event, emit) {
      emit(TransportTabState(index: event.index));
    });
  }
}
