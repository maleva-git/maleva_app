// admin_tab_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import 'boarding_event.dart';
import 'boarding_state.dart';


class BoardingTabBloc extends Bloc<BoardingTabEvent, BoardingTabState> {
  BoardingTabBloc() : super(BoardingTabState(index: 0)) {
    on<BoardingTabChanged>((event, emit) {
      emit(BoardingTabState(index: event.index));
    });
  }
}
