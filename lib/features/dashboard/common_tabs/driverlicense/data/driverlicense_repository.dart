import 'package:get_it/get_it.dart';
import 'package:maleva/core/fleet/expiry_api.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/models/shared/truck_details_model.dart';

class DriverLicenseRepository {
  Future<Map<String, dynamic>> fetchLicenseData() async {
    final currentCommonExpDate = AppGlobals.currentdate(AppGlobals.commonexpirydays);

    try {

      // the driver's own record: the server takes it from the driver's token
      final driverResult = await GetIt.instance<ExpiryApi>().drivers(driverId: AppGlobals.EmpRefId);

      return {
        'driverList': driverResult,
        'truckList':  <TruckDetailsModel>[],
        'expApadBonam': '',
        'expServiceAlignGreece': '',
        'expDate': currentCommonExpDate,
      };
    } catch (e) {
      throw Exception('Failed to load license data: $e');
    }
  }
}