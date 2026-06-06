import 'package:flutter/foundation.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

class DriverLicenseRepository {
  Future<Map<String, dynamic>> fetchLicenseData() async {
    final currentCommonExpDate = objfun.currentdate(objfun.commonexpirydays);

    try {

      final driverMaster = {
        'ExpDate': "",
        'Id': objfun.EmpRefId,
        'SFromDate': null,
        'Comid': objfun.Comid,
      };

      if (kDebugMode) debugPrint("➡️ Driver License Payload: $driverMaster");

      final driverResult = await ApiClient.postRequest(
          objfun.apiSelectDriverDetails,
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