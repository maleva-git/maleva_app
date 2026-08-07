import 'package:flutter_bloc/flutter_bloc.dart';
import 'forwarding_agent_event.dart';
import 'forwarding_agent_state.dart';

class ForwardingAgentTabBloc extends Bloc<ForwardingAgentTabEvent, ForwardingAgentTabState> {
  ForwardingAgentTabBloc() : super(const ForwardingAgentTabState()) {
    on<ForwardingAgentTabChanged>((event, emit) {
      emit(state.copyWith(index: event.index));
    });
  }
}
