import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/models/model.dart';

import 'drivermaintenance_event.dart';
import 'drivermaintenance_state.dart';



class TruckMaintDashBloc
    extends Bloc<TruckMaintDashEvent, TruckMaintDashState> {
  TruckMaintDashBloc() : super(TruckMaintDashInitial()) {
    on<TruckMaintDashStarted>(_onStarted);
  }

  Future<void> _onStarted(
      TruckMaintDashStarted event,
      Emitter<TruckMaintDashState> emit) async {
    emit(TruckMaintDashLoading());
    try {
      final expDate               = objfun.currentdate(objfun.commonexpirydays);
      final expApadBonam          = objfun.currentdate(objfun.apadbonamexpirydays);
      final expServiceAlignGreece = objfun.currentdate(objfun.ExpServiceAligmentGreecedays);

      final master = {
        'Expdate':                null,
        'ExpApadBonam':           expApadBonam,
        'ExpServiceAligmentGreece': expServiceAlignGreece,
        'Id':                     objfun.DriverTruckRefId,
        'SFromDate':              null,
        'Comid':                  objfun.Comid,
      };
      final header = {'Content-Type': 'application/json; charset=UTF-8'};

      final resultData = await objfun.apiAllinoneSelectArray(
          objfun.apiSelectTruckDetails, master, header, null);

      List<TruckDetailsModel> details = [];
      if (resultData != '' && resultData.length != 0) {
        details = (resultData as List)
            .map((e) => TruckDetailsModel.fromJson(e))
            .cast<TruckDetailsModel>()
            .toList();
        objfun.TruckDetailsList = details;
      }

      emit(TruckMaintDashLoaded(
        expDate:               expDate,
        expApadBonam:          expApadBonam,
        expServiceAlignGreece: expServiceAlignGreece,
        truckDetails:          details,
      ));
    } catch (e) {
      emit(TruckMaintDashError(e.toString()));
    }
  }
}