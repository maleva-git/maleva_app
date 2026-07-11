import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/utils/app_globals.dart';

class StockTransferRepository {
  final int comid = AppPreferences.getComid();

  // ─── Fetch Warehouses ──────────────────────────────────────────────────────
  Future<List<dynamic>> fetchWarehouses() async {
    // Replace apiWareHouseCombo with your exact API endpoint for warehouses
    final response = await ApiClient.postRequest("${AppGlobals.apiWareHouseCombo}$comid", null);
    return response is List ? response : [];
  }

  // ─── Fetch Stock Data ──────────────────────────────────────────────────────
  Future<Map<String, dynamic>> fetchStockData(String barcodeLabel) async {
    final url = "${AppGlobals.apiEditStockIn}0&barcodeLabel=$barcodeLabel&Comid=$comid";
    final response = await ApiClient.postRequest(url, null);

    if (response != null) {
      final value = ResponseViewModel.fromJson(response);
      if (value.IsSuccess == true && value.data1 != null && value.data1.isNotEmpty) {
        return value.data1[0] as Map<String, dynamic>;
      } else {
        throw Exception(value.Message ?? 'Failed to fetch stock data');
      }
    }
    throw Exception('No data returned from server');
  }

  // ─── Update Stock Transfer ─────────────────────────────────────────────────
  Future<ResponseViewModel?> updateStockTransfer(int stockId, int portId) async {
    final url = "${AppGlobals.apiUpdateStockTransfer}$stockId&PortId=$portId&Comid=$comid";
    final response = await ApiClient.postRequest(url, <String, dynamic>{});
    return response != null ? ResponseViewModel.fromJson(response) : null;
  }

  // ─── Barcode Scanner Abstraction ───────────────────────────────────────────
  Future<String?> scanBarcode() async {
    await AppGlobals.barcodeScanning();
    if (AppGlobals.barcodeerror == true) return null;
    return AppGlobals.barcodestring as String;
  }
}