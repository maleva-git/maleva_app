import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

import '../../../../../../core/models/model.dart';
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
      final Map<String, dynamic> master = {
        'ExpDate': "",
        'Id': 0,
        'SFromDate': null,
        'Comid': objfun.Comid,
      };

      // ✅ REFACTORED: Using the injected repository
      final resultData = await repository.fetchDriverDetails(body: master);

      // No data check
      if (resultData == null || resultData == "" || (resultData is List && resultData.isEmpty)) {
        emit(const DriverLoaded(driverData: []));
        return;
      }

      // Has data -> map to model
      final List<DriverDetailsModel> driverList = (resultData as List)
          .map((element) => DriverDetailsModel.fromJson(element))
          .toList()
          .cast<DriverDetailsModel>();

      emit(DriverLoaded(driverData: driverList));

    } catch (error) {
      // ApiClient handles standardizing the exceptions
      emit(DriverError(errorMessage: error.toString()));
    }
  }
}