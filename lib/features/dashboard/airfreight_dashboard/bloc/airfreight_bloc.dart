// admin_tab_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import 'boarding_event.dart';
import 'boarding_state.dart';


class AirfreightTabBloc extends Bloc<AirfreightTabEvent, AirfreightTabState> {
  AirfreightTabBloc() : super(AirfreightTabState(index: 0)) {
    on<AirfreightTabChanged>((event, emit) {
      emit(AirfreightTabState(index: event.index));
    });
  }
}
