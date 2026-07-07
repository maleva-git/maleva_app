import 'dart:convert';
import 'package:maleva/core/network/dio_client.dart';
import 'package:maleva/core/utils/session_manager.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

class SalesOrderViewRepository {
  final DioClient _dioClient;
  final SessionManager _sessionManager;

  SalesOrderViewRepository(this._dioClient, this._sessionManager);

  Future<List<dynamic>> selectCustomer() async {
    final comid = objfun.storagenew.getInt('Comid') ?? 0;
    final url = "${objfun.apiSelectCustomer}$comid";
    final response = await _dioClient.dio.post(url, data: {});
        dynamic responseData = response.data;
    if (responseData is String) {
      if (responseData.trim().isEmpty) return [];
      responseData = jsonDecode(responseData);
    }
    if (responseData is List<dynamic>) {
      return responseData;
    }
    return [];
  }

  Future<List<dynamic>> selectEmployee(String type, String type1) async {
    final comid = objfun.storagenew.getInt('Comid') ?? 0;
    final url = "${objfun.apiSelectEmployee}$comid&type=$type&type1=$type1";
    final response = await _dioClient.dio.post(url, data: {});
        dynamic responseData = response.data;
    if (responseData is String) {
      if (responseData.trim().isEmpty) return [];
      responseData = jsonDecode(responseData);
    }
    if (responseData is List<dynamic>) {
      return responseData;
    }
    return [];
  }

  Future<List<dynamic>> selectJobStatus() async {
    final comid = objfun.storagenew.getInt('Comid') ?? 0;
    final url = "${objfun.apiSelectJobStatus}$comid";
    final response = await _dioClient.dio.post(url, data: {});
        dynamic responseData = response.data;
    if (responseData is String) {
      if (responseData.trim().isEmpty) return [];
      responseData = jsonDecode(responseData);
    }
    if (responseData is List<dynamic>) {
      return responseData;
    }
    return [];
  }

  Future<Map<String, dynamic>> loadComboS1(int type) async {
    final comid = objfun.storagenew.getInt('Comid') ?? 0;
    final url = "${objfun.apiGetComboS1}$comid&type=$type";
    final response = await _dioClient.dio.post(url, data: {});
        dynamic responseData = response.data;
    if (responseData is String) {
      if (responseData.trim().isEmpty) return {};
      responseData = jsonDecode(responseData);
    }
    if (responseData is Map<String, dynamic>) {
      return responseData;
    }
    return {};
  }

  Future<List<dynamic>> editSalesOrder(int id, int saleNo) async {
    final comid = objfun.storagenew.getInt('Comid') ?? 0;
    final url = "${objfun.apiEditSalesOrder}$id&SaleorderNo=$saleNo&Comid=$comid";
    final response = await _dioClient.dio.post(url, data: {});
        dynamic responseData = response.data;
    if (responseData is String) {
      if (responseData.trim().isEmpty) return [];
      responseData = jsonDecode(responseData);
    }
    if (responseData is List<dynamic>) {
      return responseData;
    }
    return [];
  }
}
