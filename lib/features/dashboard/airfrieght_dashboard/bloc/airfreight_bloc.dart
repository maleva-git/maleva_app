import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/features/dashboard/airfrieght_dashboard/bloc/airfreight_event.dart';
import 'airfreight_state.dart';

class SalesDashboardBloc extends Bloc<SalesDashboardEvent, SalesDashboardState> {

  SalesDashboardBloc() : super(SalesDashboardState(index: 0)) {
    on<TabChanged>((event, emit){
      emit(SalesDashboardState(index: event.index));
    });
  }

}