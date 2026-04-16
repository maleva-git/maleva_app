import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/models/model.dart';

import 'driverlicense_event.dart';
import 'driverlicense_state.dart';







class DriverLicenseExpiryBloc
    extends Bloc<DriverLicenseExpiryEvent, DriverLicenseExpiryState> {
  DriverLicenseExpiryBloc() : super(DriverLicenseExpiryInitial()) {
    on<DriverLicenseExpiryStarted>(_onStarted);
  }

  Future<void> _onStarted(
      DriverLicenseExpiryStarted event,
      Emitter<DriverLicenseExpiryState> emit) async {
    emit(DriverLicenseExpiryLoading());
    try {
      final header = {'Content-Type': 'application/json; charset=UTF-8'};

      // ── Step 1: loadDriverdata() — Driver License Expiry ──────────────────
      final driverMaster = {
        'ExpDate':   '',
        'Id':        objfun.EmpRefId,
        'SFromDate': null,
        'Comid':     objfun.Comid,
      };

      final driverResult = await objfun.apiAllinoneSelectArray(
          objfun.apiSelectDriverDetails, driverMaster, header, null);

      List<dynamic> driverList = [];
      if (driverResult != '' && driverResult.length != 0) {
        driverList = List<dynamic>.from(driverResult as List);
      }

      // ── Step 2: loadTruckdata() — Truck Maintenance ───────────────────────
      final expDate               = objfun.currentdate(objfun.commonexpirydays);
      final expApadBonam          = objfun.currentdate(objfun.apadbonamexpirydays);
      final expServiceAlignGreece =
      objfun.currentdate(objfun.ExpServiceAligmentGreecedays);

      final truckMaster = {
        'Expdate':                  null,
        'ExpApadBonam':             expApadBonam,
        'ExpServiceAligmentGreece': expServiceAlignGreece,
        'Id':                       objfun.DriverTruckRefId,
        'SFromDate':                null,
        'Comid':                    objfun.Comid,
      };

      final truckResult = await objfun.apiAllinoneSelectArray(
          objfun.apiSelectTruckDetails, truckMaster, header, null);

      List<TruckDetailsModel> truckList = [];
      if (truckResult != '' && truckResult.length != 0) {
        truckList = (truckResult as List)
            .map((e) => TruckDetailsModel.fromJson(e))
            .cast<TruckDetailsModel>()
            .toList();
        objfun.TruckDetailsList = truckList;
      }

      emit(DriverLicenseExpiryLoaded(
        driverExpiryList:      driverList,
        truckDetails:          truckList,
        expDate:               expDate,
        expApadBonam:          expApadBonam,
        expServiceAlignGreece: expServiceAlignGreece,
      ));
    } catch (e) {
      emit(DriverLicenseExpiryError(e.toString()));
    }
  }
}