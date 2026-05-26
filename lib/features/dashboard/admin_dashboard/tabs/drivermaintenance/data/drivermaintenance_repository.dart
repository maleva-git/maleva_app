import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

class TruckMaintenanceRepository {
  Future<Map<String, dynamic>> fetchTruckData() async {
    try {
      final expDate = objfun.currentdate(objfun.commonexpirydays);
      final expApadBonam = objfun.currentdate(objfun.apadbonamexpirydays);
      final expServiceAlignGreece = objfun.currentdate(objfun.ExpServiceAligmentGreecedays);

      final master = {
        'Expdate': null,
        'ExpApadBonam': expApadBonam,
        'ExpServiceAligmentGreece': expServiceAlignGreece,
        'Id': AppPreferences.getDriverId(), // Using your new centralized pref
        'SFromDate': null,
        'Comid': AppPreferences.getComid(),
      };

      final resultData = await ApiClient.postRequest(
        objfun.apiSelectTruckDetails,
        master,
      );

      List<TruckDetailsModel> details = [];
      if (resultData != null && resultData is List) {
        details = (resultData)
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
      throw Exception('Failed to load truck maintenance: $e');
    }
  }
}