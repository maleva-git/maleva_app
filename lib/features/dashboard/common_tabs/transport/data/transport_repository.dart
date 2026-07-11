import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_globals.dart';

class TransportRepository {
  /// Fetches the transport data based on the type (Today vs Tomorrow)
  Future<dynamic> fetchTransportData({
    required int type,
    required Map<String, dynamic> body,
  }) async {
    // type 0 = PLANINGSearchDB, type 1 = PLANINGSearch
    String url = type == 0 ? AppGlobals.PLANINGSearchDB : AppGlobals.PLANINGSearch;

    return await ApiClient.postRequest(url, body);
  }
}