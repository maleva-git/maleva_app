import 'package:maleva/core/lookups/job_status_api.dart';
import 'package:maleva/core/files/attachments_api.dart';
import 'package:maleva/core/platform/barcode_scanner.dart';
import 'package:maleva/core/session/legacy_feature_context.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/stock/stock_in_api.dart';
import 'package:maleva/core/sale_order/sale_order_api.dart';

/// Stock Update (cargo arrives at a warehouse). The stock-in calls go to the
/// shared Java `/api/stock-ins` (ported from .NET StockApp); the sale order read and
/// the boarding officers are the shared sale order APIs (`/api/sale-orders/edit`,
/// `/api/vessel-plannings/sale-order-update`); job steps and image delete are other
/// features' calls.
class StockUpdateRepository {
  final BarcodeScanner scanner;
  final int comid;
  final int empRefId;
  final int driverLogin;
  final StockInApi? _stockApi;
  final SaleOrderApi? _saleOrderApi;
  StockUpdateRepository({
    this.scanner = const ExistingBarcodeScanner(),
    LegacyFeatureContext context = const LegacyFeatureContext(),
    StockInApi? stockApi,
    SaleOrderApi? saleOrderApi,
  }) : comid = context.preferenceCompanyId,
        empRefId = context.employeeId,
        driverLogin = context.driverLogin,
        _stockApi = stockApi,
        _saleOrderApi = saleOrderApi;

  StockInApi get _stock => _stockApi ?? sl<StockInApi>();
  SaleOrderApi get _saleOrders => _saleOrderApi ?? sl<SaleOrderApi>();

  // ─── Initialize ────────────────────────────────────────────────────────────
  // (No prefetch needed anymore)

  // ─── Scan Barcode ──────────────────────────────────────────────────────────
  Future<String?> scanBarcode() => scanner.scan();

  // ─── Load Stock Data (First Scan) ──────────────────────────────────────────
  /// The stock-in of the scanned label (Java fields: `id`, `numberOfPackages`,
  /// `barcodeLabelDisplay`, `status`, `saleOrderMasterRefId`). An unknown label
  /// throws with the server's message.
  Future<Map<String, dynamic>?> loadStockData(String barcodeLabel) => _stock.byLabel(comid, barcodeLabel);

  // ─── Load Job Details & Calculate Status & Boarding Officers ─────────────
  Future<Map<String, dynamic>?> loadJobDetails(int saleOrderId) async {
    final jobs = await _stock.saleOrders(comid, saleOrderId: saleOrderId);
    if (jobs.isEmpty) return null;

    final data = jobs.first;
    final soId = data['id'] as int;
    final jobMId = data['jobMasterRefId'] as int;
    final jStatus = data['jStatus'] as int;

    // Fetch Job Statuses
    final steps = await sl<JobStatusApi>().steps(jobMId);

    int statusId = 0;
    String statusName = '';

    // Status Transition Logic
    if (driverLogin == 1) {
      if (jStatus == 3) {
        statusId = 11;
      } else if (jStatus == 11) statusId = 19;
      else return null; // Invalid state
    } else {
      if (jStatus == 19) {
        statusId = 4;
      } else if (jStatus == 4) statusId = 7;
      else if (jStatus == 7) statusId = 5;
      else return null; // Invalid state
    }

    statusName = steps.statusName(statusId);

    // Boarding Officer Logic
    int boardId1 = 0;
    int boardId2 = 0;
    double boardAmt1 = 0.0;
    double boardAmt2 = 0.0;

    if (statusId == 7) {
      boardId1 = empRefId;
      boardAmt1 = 50;
    } else if (statusId == 5) {
      final master = (await _saleOrders.edit(id: soId)).master;
      boardId1 = master['lBoardingOfficerRefid'] as int? ?? 0;
      if (boardId1 != empRefId) {
        boardId2 = empRefId;
        boardAmt1 = 30;
        boardAmt2 = 30;
      }
    }

    return {
      'saleOrderId': soId,
      'jobId': jobMId,
      'statusId': statusId,
      'statusName': statusName,
      'boardOfficerId1': boardId1,
      'boardOfficerId2': boardId2,
      'boardOfficerAmt1': boardAmt1,
      'boardOfficerAmt2': boardAmt2,
    };
  }

  // ─── Delete Image ──────────────────────────────────────────────────────────
  Future<void> deleteImage(int saleOrderId, String folder, String imageName) async {
    await sl<AttachmentsApi>().delete([imageName], folder: 'SalesOrder', recordId: saleOrderId, subFolder: folder);
  }

  // ─── Save Stock Update ───────────────────────────────────────────────────
  /// The cargo is in warehouse [warehouseId]; the job takes [statusId]. Throws
  /// with the server's message when refused.
  Future<void> saveStockUpdate(int stockId, int statusId, int warehouseId, List<String> imageUrls) =>
      _stock.arrival(comid, stockId, statusId: statusId, portId: warehouseId, imageUrls: imageUrls);

  // ─── Update Boarding Officer ─────────────────────────────────────────────
  /// Status 7 makes this employee the loading boarding officer; status 5 adds them as
  /// the second one. The off-vessel officers are sent as the job has them (the update
  /// takes the whole picture); the server sets the amounts (50, or 30 each).
  Future<void> updateBoardingOfficer(int saleOrderId, int statusType, int boardOfficerId1, int boardOfficerId2, double boardOfficerAmt1, double boardOfficerAmt2) async {
    if (statusType != 7 && statusType != 5) return;
    if (statusType == 5 && boardOfficerId1 == empRefId) return;

    final master = (await _saleOrders.edit(id: saleOrderId)).master;
    await _saleOrders.vesselUpdate(
      saleOrderId,
      loadingOfficers: statusType == 7 ? [boardOfficerId1] : [boardOfficerId1, boardOfficerId2],
      offOfficers: SaleOrderApi.officers(master, 'O'),
    );
  }
}
