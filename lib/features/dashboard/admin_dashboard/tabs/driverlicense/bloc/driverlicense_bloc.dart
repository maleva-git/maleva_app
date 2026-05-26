import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/driverlicense_repository.dart';
import 'driverlicense_event.dart';
import 'driverlicense_state.dart';

class DriverLicenseExpiryBloc extends Bloc<DriverLicenseExpiryEvent, DriverLicenseExpiryState> {
  final DriverLicenseRepository repository;

  DriverLicenseExpiryBloc({required this.repository}) : super(DriverLicenseExpiryInitial()) {
    on<DriverLicenseExpiryStarted>(_onStarted);
  }

  Future<void> _onStarted(
      DriverLicenseExpiryStarted event,
      Emitter<DriverLicenseExpiryState> emit) async {
    emit(DriverLicenseExpiryLoading());
    try {
      final data = await repository.fetchLicenseData();

      emit(DriverLicenseExpiryLoaded(
        driverExpiryList:      data['driverList'],
        truckDetails:          data['truckList'],
        expDate:               data['expDate'],
        expApadBonam:          data['expApadBonam'],
        expServiceAlignGreece: data['expServiceAlignGreece'],
      ));
    } catch (e) {
      emit(DriverLicenseExpiryError(e.toString()));
    }
  }
}