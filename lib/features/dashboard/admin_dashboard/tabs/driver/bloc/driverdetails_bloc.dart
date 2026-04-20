import 'package:flutter/Material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/models/model.dart';
import 'driverdetails_event.dart';
import 'driverdetails_state.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

class DriverBloc extends Bloc<DriverEvent, DriverState> {
  final BuildContext context;

  DriverBloc(this.context) : super(const DriverInitial()) {
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

      final Map<String, String> header = {
        'Content-Type': 'application/json; charset=UTF-8',
      };

      final resultData = await objfun.apiAllinoneSelectArray(
        objfun.apiSelectDriverDetails,
        master,
        header,
        context,
      );

      if (resultData != null && resultData != "" && resultData.length != 0) {
        final List<DriverDetailsModel> driverList = (resultData as List)
            .map((element) => DriverDetailsModel.fromJson(element))
            .toList()
            .cast<DriverDetailsModel>();

        emit(DriverLoaded(driverData: driverList));
      } else {
        emit(const DriverLoaded(driverData: []));
      }
    } catch (error, stackTrace) {
      emit(DriverError(errorMessage: error.toString()));
    }
  }
}