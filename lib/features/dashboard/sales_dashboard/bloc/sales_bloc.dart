import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/features/dashboard/sales_dashboard/bloc/sales_event.dart';
import 'sales_state.dart';

class SalesDashboardBloc extends Bloc<SalesDashboardEvent, SalesDashboardState> {

  SalesDashboardBloc() : super(SalesDashboardState(index: 0)) {
    on<TabChanged>((event, emit){
      if (state.index != event.index) {
        emit(SalesDashboardState(index: event.index));
      }
    });
  }

}