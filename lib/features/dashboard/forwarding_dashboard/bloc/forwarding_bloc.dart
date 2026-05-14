// admin_tab_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import 'forwarding_event.dart';
import 'forwarding_state.dart';



class ForwardingTabBloc extends Bloc<ForwardingTabEvent, ForwardingTabState> {
  ForwardingTabBloc() : super(ForwardingTabState(index: 0)) {
    on<ForwardingTabChanged>((event, emit) {
      emit(ForwardingTabState(index: event.index));
    });
  }
}

