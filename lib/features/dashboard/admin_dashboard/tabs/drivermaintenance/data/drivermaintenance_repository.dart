import 'package:flutter/foundation.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

class TruckMaintenanceRepository {
  Future<Map<String, dynamic>> fetchTruckData() async {
    final expDate = objfun.currentdate(objfun.commonexpirydays);
    final expApadBonam = objfun.currentdate(objfun.apadbonamexpirydays);
    final expServiceAlignGreece = objfun.currentdate(objfun.ExpServiceAligmentGreecedays);

    try {

      final master = {
        'Expdate': null,
        'ExpApadBonam': expApadBonam,
        'ExpServiceAligmentGreece': expServiceAlignGreece,
        'Id': objfun.DriverTruckRefId,
        'SFromDate': null,
        'Comid': AppPreferences.getComid(),
      };

      if (kDebugMode) debugPrint("➡️ Truck Payload: $master");

      final resultData = await ApiClient.postRequest(
        objfun.apiSelectTruckDetails,
        master,
      );

      List<TruckDetailsModel> details = [];
      if (resultData != null && resultData is List) {
        details = resultData
            .map((e) => TruckDetailsModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return {
        'truckDetails': details,
        'expDate': expDate,
        'expApadBonam': expApadBonam,
        'expServiceAlignGreece': expServiceAlignGreece,
      };
    } catch (e) {
      if (e.toString().contains('500')) {
        return {
          'truckDetails': <TruckDetailsModel>[],
          'expDate': expDate,
          'expApadBonam': expApadBonam,
          'expServiceAlignGreece': expServiceAlignGreece,
        };
      }
      throw Exception('Failed to load truck maintenance: $e');
    }
  }
}