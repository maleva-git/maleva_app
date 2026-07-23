import 'package:maleva/core/network/api_constants.dart';


import '../../../../../core/network/api_client.dart';

class SaleOrderRepository {

  Future<dynamic> updateSaleOrderMaster(dynamic toSave) async {
    // We use the exact URL variable you had in objfun
    const String url = ApiConstants.apiUpdateSaleOrderMaster;

    // ApiClient.postRequest will automatically add the Comid, Userid, Token, etc.
    // So you don't need to manually pass headers anymore.
    final response = await ApiClient.postRequest(
      url,
      toSave,
    );

    return response;
  }
}