import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

class DriverLicenseRepository {
  Future<Map<String, dynamic>> fetchLicenseData() async {
    try {
      final comId = AppPreferences.getComid();

      // 1. Fetch Driver Details
      final driverMaster = {
        'ExpDate':   '',
        'Id':        AppPreferences.getEmpRefId(),
        'SFromDate': null,
        'Comid':     comId,
      };

      final driverResult = await ApiClient.postRequest(
          objfun.apiSelectDriverDetails,
          driverMaster
      );

      // 2. Fetch Truck Details
      final truckMaster = {
        'Expdate':                  null,
        'ExpApadBonam':             objfun.currentdate(objfun.apadbonamexpirydays),
        'ExpServiceAligmentGreece': objfun.currentdate(objfun.ExpServiceAligmentGreecedays),
        'Id':                       AppPreferences.getDriverId(), // Assuming this maps to DriverTruckRefId
        'SFromDate':                null,
        'Comid':                    comId,
      };

      final truckResult = await ApiClient.postRequest(
          objfun.apiSelectTruckDetails,
          truckMaster
      );

      return {
        'driverList': driverResult is List ? driverResult : [],
        'truckList':  truckResult is List
            ? (truckResult).map((e) => TruckDetailsModel.fromJson(e)).toList()
            : <TruckDetailsModel>[],
        'expApadBonam': truckMaster['ExpApadBonam'],
        'expServiceAlignGreece': truckMaster['ExpServiceAligmentGreece'],
        'expDate': objfun.currentdate(objfun.commonexpirydays),
      };
    } catch (e) {
      throw Exception('Failed to load license data: $e');
    }
  }
}