// admin_tab_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/features/dashboard/subadmin_dashboard/bloc/subadmin_dashboard_event.dart';
import 'package:maleva/features/dashboard/subadmin_dashboard/bloc/subadmin_dashboard_state.dart';


class SubAdminTabBloc extends Bloc<SubAdminTabEvent, SubAdminTabState> {
  SubAdminTabBloc() : super(SubAdminTabState(index: 0)) {
    on<TabChanged>((event, emit) {
      emit(SubAdminTabState(index: event.index));
    });
  }
}
