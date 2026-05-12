// admin_tab_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import 'hradmin_event.dart';
import 'hradmin_state.dart';


class HrAdminTabBloc extends Bloc<HrAdminTabEvent, HrAdminTabState> {
  HrAdminTabBloc() : super(HrAdminTabState(index: 0)) {
    on<HrAdminTabChanged>((event, emit) {
      emit(HrAdminTabState(index: event.index));
    });
  }
}
