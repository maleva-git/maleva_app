import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

class TransportRepository {
  /// Fetches the transport data based on the type (Today vs Tomorrow)
  Future<dynamic> fetchTransportData({
    required int type,
    required Map<String, dynamic> body,
  }) async {
    // type 0 = PLANINGSearchDB, type 1 = PLANINGSearch
    String url = type == 0 ? objfun.PLANINGSearchDB : objfun.PLANINGSearch;

    return await ApiClient.postRequest(url, body);
  }
}