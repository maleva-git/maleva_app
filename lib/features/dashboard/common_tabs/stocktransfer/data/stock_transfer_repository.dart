import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/platform/barcode_scanner.dart';
import 'package:maleva/core/session/legacy_feature_context.dart';
import 'package:maleva/core/stock/stock_in_api.dart';

/// Stock Transfer, on the shared Java `/api/stock-ins` (ported from .NET StockApp).
class StockTransferRepository {
  final BarcodeScanner scanner;
  final int comid;
  final StockInApi? _stockApi;
  StockTransferRepository({
    this.scanner = const ExistingBarcodeScanner(),
    LegacyFeatureContext context = const LegacyFeatureContext(),
    StockInApi? stockApi,
  })  : comid = context.preferenceCompanyId,
        _stockApi = stockApi;

  StockInApi get _stock => _stockApi ?? sl<StockInApi>();

  /// Active warehouses (`id`, `portName`).
  Future<List<Map<String, dynamic>>> fetchWarehouses() => _stock.warehouses(comid);

  /// The stock-in of the scanned label (`id`, `numberOfPackages`,
  /// `barcodeLabelDisplay`, `portMasterRefId`, `portName`). An unknown label
  /// throws with the server's message.
  Future<Map<String, dynamic>> fetchStockData(String barcodeLabel) => _stock.byLabel(comid, barcodeLabel);

  /// Moves the stock-in to warehouse [portId]; throws with the server's message when refused.
  Future<void> updateStockTransfer(int stockId, int portId) => _stock.transfer(comid, stockId, portId);

  // ─── Barcode Scanner Abstraction ───────────────────────────────────────────
  Future<String?> scanBarcode() => scanner.scan();
}
