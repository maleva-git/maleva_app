import 'package:get_it/get_it.dart';
import 'package:maleva/core/fleet/expiry_api.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/models/shared/truck_details_model.dart';

class TruckMaintenanceRepository {
  Future<Map<String, dynamic>> fetchTruckData() async {
    final expDate = AppGlobals.currentdate(AppGlobals.commonexpirydays);
    final expApadBonam = AppGlobals.currentdate(AppGlobals.apadbonamexpirydays);
    final expServiceAlignGreece = AppGlobals.currentdate(AppGlobals.ExpServiceAligmentGreecedays);

    try {

      // the driver's own truck: the server reads it from the driver's record
      final details = (await GetIt.instance<ExpiryApi>().trucks(truckId: AppGlobals.DriverTruckRefId))
          .map(TruckDetailsModel.fromJavaExpiry)
          .toList();

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