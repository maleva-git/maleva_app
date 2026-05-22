import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/drivermaintenance_repository.dart';
import 'drivermaintenance_event.dart';
import 'drivermaintenance_state.dart';


class TruckMaintDashBloc extends Bloc<TruckMaintDashEvent, TruckMaintDashState> {
  final TruckMaintenanceRepository repository;

  TruckMaintDashBloc({required this.repository}) : super(TruckMaintDashInitial()) {
    on<TruckMaintDashStarted>(_onStarted);
  }

  Future<void> _onStarted(
      TruckMaintDashStarted event, Emitter<TruckMaintDashState> emit) async {
    emit(TruckMaintDashLoading());
    try {
      final data = await repository.fetchTruckData();

      emit(TruckMaintDashLoaded(
        expDate: data['expDate'],
        expApadBonam: data['expApadBonam'],
        expServiceAlignGreece: data['expServiceAlignGreece'],
        truckDetails: data['truckDetails'],
      ));
    } catch (e) {
      emit(TruckMaintDashError(e.toString()));
    }
  }
}