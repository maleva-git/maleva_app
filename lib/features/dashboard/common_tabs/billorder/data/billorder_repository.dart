import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/utils/app_globals.dart';

class BillOrderRepository {

  // Notice we removed the constructor!
  // Since AppPreferences and ApiClient use static methods, we don't need dependency injection for them here.

  Future<List<BillViewModel>> fetchBillOrders(String fromDate, String toDate) async {
    try {
      // 1. Get Comid securely using your new static getter
      final int comid = AppPreferences.getComid();

      // 2. Construct the API URL using existing constants
      final String apiUrl = "${AppGlobals.apiBillorderview}$comid&Fromdate=$fromDate&Todate=$toDate";

      // 3. Make the static API call
      final responseData = await ApiClient.postRequest(
        apiUrl,
        null,
      );

      // 4. Parse the data safely
      if (responseData != null && responseData is List && responseData.isNotEmpty) {
        return responseData
            .map((e) => BillViewModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}