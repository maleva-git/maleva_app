import 'package:maleva/core/platform/barcode_scanner.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/network/legacy_json_transport.dart';
import 'package:maleva/core/session/legacy_feature_context.dart';
import 'package:maleva/core/models/shared/response_view_model.dart';

class StockTransferRepository {
  final JsonTransport transport;
  final BarcodeScanner scanner;
  final int comid;
  StockTransferRepository({
    this.transport = const ExistingHttpTransport(),
    this.scanner = const ExistingBarcodeScanner(),
    LegacyFeatureContext context = const LegacyFeatureContext(),
  }) : comid = context.preferenceCompanyId;

  // ─── Fetch Warehouses ──────────────────────────────────────────────────────
  Future<List<dynamic>> fetchWarehouses() async {
    // Replace apiWareHouseCombo with your exact API endpoint for warehouses
    final response = await transport.postRequest("${ApiConstants.apiWareHouseCombo}$comid", null);
    return response is List ? response : [];
  }

  // ─── Fetch Stock Data ──────────────────────────────────────────────────────
  Future<Map<String, dynamic>> fetchStockData(String barcodeLabel) async {
    final url = "${ApiConstants.apiEditStockIn}0&barcodeLabel=$barcodeLabel&Comid=$comid";
    final response = await transport.postRequest(url, null);

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
    final url = "${ApiConstants.apiUpdateStockTransfer}$stockId&PortId=$portId&Comid=$comid";
    final response = await transport.postRequest(url, <String, dynamic>{});
    return response != null ? ResponseViewModel.fromJson(response) : null;
  }

  // ─── Barcode Scanner Abstraction ───────────────────────────────────────────
  Future<String?> scanBarcode() => scanner.scan();
}