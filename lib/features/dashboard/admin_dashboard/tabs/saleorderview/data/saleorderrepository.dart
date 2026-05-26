

import '../../../../../../core/network/api_client.dart';
import '../../../../../../core/utils/clsfunction.dart' as objfun;

class SaleOrderRepository {

  Future<dynamic> updateSaleOrderMaster(dynamic toSave) async {
    // We use the exact URL variable you had in objfun
    final String url = objfun.apiUpdateSaleOrderMaster;

    // ApiClient.postRequest will automatically add the Comid, Userid, Token, etc.
    // So you don't need to manually pass headers anymore.
    final response = await ApiClient.postRequest(
      url,
      toSave,
    );

    return response;
  }
}