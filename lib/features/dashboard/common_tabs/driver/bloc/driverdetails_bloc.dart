import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/utils/app_globals.dart';

import '../../../../../core/models/model.dart';
import '../data/driver_repository.dart';
import 'driverdetails_event.dart';
import 'driverdetails_state.dart';
import 'package:maleva/core/models/shared/driver_details_model.dart';
import 'package:maleva/core/models/shared/response_view_model.dart';

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
        'Comid': AppGlobals.Comid,
      };

      // ✅ REFACTORED: Using the injected repository
      final resultData = await repository.fetchDriverDetails(body: master);

      // No data check
      if (resultData == null || resultData == "") {
        emit(const DriverLoaded(driverData: []));
        return;
      }

      if (resultData is List) {
        final List<DriverDetailsModel> driverList = resultData
            .map((element) => DriverDetailsModel.fromJson(element as Map<String, dynamic>))
            .toList();
        emit(DriverLoaded(driverData: driverList));
      } else if (resultData is Map<String, dynamic>) {
        final value = ResponseViewModel.fromJson(resultData);
        if (value.IsSuccess == true && value.data1 != null) {
          final List<DriverDetailsModel> driverList = (value.data1 as List)
              .map((element) => DriverDetailsModel.fromJson(element as Map<String, dynamic>))
              .toList();
          emit(DriverLoaded(driverData: driverList));
        } else {
          emit(const DriverLoaded(driverData: []));
        }
      } else {
        emit(const DriverLoaded(driverData: []));
      }

    } catch (error) {
      // ApiClient handles standardizing the exceptions
      emit(DriverError(errorMessage: error.toString()));
    }
  }
}