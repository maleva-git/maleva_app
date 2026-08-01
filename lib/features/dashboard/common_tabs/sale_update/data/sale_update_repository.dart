import 'dart:convert';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/network/dio_client.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/models/shared/response_view_model.dart';
import 'package:maleva/core/network/api_constants.dart';
import '../models/sale_order_update_model.dart';
import 'package:intl/intl.dart';

class SaleUpdateRepository {
  Future<List<SaleOrderUpdateModel>> searchSaleOrders({
    required DateTime fromDate,
    required DateTime toDate,
    required int customerId,
  }) async {
    final int comId = AppGlobals.storagenew.getInt('Comid') ?? 0;
    final String formattedFrom = DateFormat('yyyy-MM-dd').format(fromDate);
    final String formattedTo = DateFormat('yyyy-MM-dd').format(toDate);

    final url = '${ApiConstants.port}/api/SaleOrderApp/SearchSaleOrderForUpdate?FromDate=$formattedFrom&ToDate=$formattedTo&CustomerId=$customerId&Comid=$comId';

    final dioClient = sl<DioClient>();
    final response = await dioClient.dio.post(url);

    if (response.statusCode == 200) {
      if (response.data != null) {
        List<dynamic> jsonList = response.data;
        return jsonList.map((e) => SaleOrderUpdateModel.fromJson(e)).toList();
      }
      return [];
    } else {
      throw Exception('Failed to search sale orders');
    }
  }

  Future<void> updateSaleOrderFields({
    required int id,
    required String remarks1,
    required String origin,
    required String destination,
  }) async {
    final url = '${ApiConstants.port}/api/SaleOrderApp/UpdateSaleOrderFields';
    
    final payload = {
      'Id': id,
      'Remarks1': remarks1,
      'Origin': origin,
      'Destination': destination,
    };

    final dioClient = sl<DioClient>();
    final response = await dioClient.dio.post(url, data: payload);

    if (response.statusCode == 200) {
      final ResponseViewModel apiResponse = ResponseViewModel.fromJson(response.data);
      if (apiResponse.IsSuccess != true) {
        throw Exception(apiResponse.Message ?? 'Failed to update sale order');
      }
    } else {
      throw Exception('Failed to update sale order');
    }
  }
}
