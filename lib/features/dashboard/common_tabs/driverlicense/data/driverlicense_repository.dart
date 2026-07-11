import 'package:flutter/foundation.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_globals.dart';

class DriverLicenseRepository {
  Future<Map<String, dynamic>> fetchLicenseData() async {
    final currentCommonExpDate = AppGlobals.currentdate(AppGlobals.commonexpirydays);

    try {

      final driverMaster = {
        'ExpDate': "",
        'Id': AppGlobals.EmpRefId,
        'SFromDate': null,
        'Comid': AppGlobals.Comid,
      };

      if (kDebugMode) debugPrint("➡️ Driver License Payload: $driverMaster");

      final driverResult = await ApiClient.postRequest(
          AppGlobals.apiSelectDriverDetails,
          driverMaster
      );

      return {
        'driverList': driverResult is List ? driverResult : [],
        'truckList':  <TruckDetailsModel>[],
        'expApadBonam': '',
        'expServiceAlignGreece': '',
        'expDate': currentCommonExpDate,
      };
    } catch (e) {

      if (e.toString().contains('500')) {
        debugPrint("Backend sent 500. Handling gracefully.");
        return {
          'driverList': [],
          'truckList': <TruckDetailsModel>[],
          'expApadBonam': '',
          'expServiceAlignGreece': '',
          'expDate': currentCommonExpDate,
        };
      }
      throw Exception('Failed to load license data: $e');
    }
  }
}