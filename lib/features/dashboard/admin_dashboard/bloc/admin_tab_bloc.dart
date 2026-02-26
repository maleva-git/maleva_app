// admin_tab_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'admin_tab_event.dart';
import 'admin_tab_state.dart';

class AdminTabBloc extends Bloc<AdminTabEvent, AdminTabState> {
  AdminTabBloc() : super(AdminTabState(index: 0)) {
    on<TabChanged>((event, emit) {
      emit(AdminTabState(index: event.index));
    });
  }
}
