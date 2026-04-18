// lib/features/dashboard/admin_dashboard/tabs/invoice/bloc/forecast/forecast_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/sales_forecast_repository.dart';
import '../../domain/models/sales_forecast_model.dart';

abstract class ForecastEvent {}
class LoadSalesForecast extends ForecastEvent {
  final int type;
  LoadSalesForecast(this.type);
}

abstract class ForecastState {}
class ForecastInitial extends ForecastState {}
class ForecastLoading extends ForecastState {}
class ForecastNoData extends ForecastState {} // State 1
class ForecastInsufficient extends ForecastState { // State 2
  final List<SalesDataPoint> data;
  ForecastInsufficient(this.data);
}
class ForecastLoaded extends ForecastState { // State 3
  final List<SalesDataPoint> data;
  ForecastLoaded(this.data);
}
class ForecastError extends ForecastState {
  final String message;
  ForecastError(this.message);
}

class ForecastBloc extends Bloc<ForecastEvent, ForecastState> {
  final SalesForecastRepository repository;

  ForecastBloc({required this.repository}) : super(ForecastInitial()) {
    on<LoadSalesForecast>((event, emit) async {
      emit(ForecastLoading());
      try {
        final response = await repository.getSalesAndForecast(event.type);

        if (response.status == "NO_DATA") {
          emit(ForecastNoData());
        } else if (response.status == "INSUFFICIENT") {
          emit(ForecastInsufficient(response.data));
        } else {
          emit(ForecastLoaded(response.data));
        }
      } catch (e) {
        emit(ForecastError(e.toString()));
      }
    });
  }
}