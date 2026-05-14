// admin_tab_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import 'airfreight_event.dart';
import 'airfreight_state.dart';



class AirfreightTabBloc extends Bloc<AirfreightTabEvent, AirfreightTabState> {
  AirfreightTabBloc() : super(AirfreightTabState(index: 0)) {
    on<AirfreightTabChanged>((event, emit) {
      emit(AirfreightTabState(index: event.index));
    });
  }
}
