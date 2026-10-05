import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/driver_repository.dart';
import 'driverdetails_event.dart';
import 'driverdetails_state.dart';

class DriverBloc extends Bloc<DriverEvent, DriverState> {
  // ❌ REMOVED: final BuildContext context;
  final DriverRepository repository; // ✅ Injected Repository

  DriverBloc({required this.repository}) : super(const DriverInitial()) {
    on<LoadDriverEvent>(_onLoadDriver);
  }

  Future<void> _onLoadDriver(
      LoadDriverEvent event,
      Emitter<DriverState> emit,
      ) async {
    emit(const DriverLoading());

    try {
      final driverList = await repository.fetchDriverDetails();
      emit(DriverLoaded(driverData: driverList));

    } catch (error) {
      // ApiClient handles standardizing the exceptions
      emit(DriverError(errorMessage: error.toString()));
    }
  }
}