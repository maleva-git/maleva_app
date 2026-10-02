import 'package:maleva/core/lookups/job_steps.dart';
import 'package:maleva/core/platform/barcode_scanner.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/network/legacy_json_transport.dart';
import 'package:maleva/core/session/legacy_feature_context.dart';
import 'package:maleva/core/models/shared/response_view_model.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/stock/stock_in_api.dart';

/// Stock Update (cargo arrives at a warehouse). The stock-in calls go to the
/// shared Java `/api/stock-ins` (ported from .NET StockApp); job steps, the sale
/// order read, image delete and the boarding officer save are other features' calls.
class StockUpdateRepository {
  final JsonTransport transport;
  final BarcodeScanner scanner;
  final int comid;
  final int empRefId;
  final int driverLogin;
  final StockInApi? _stockApi;
  StockUpdateRepository({
    this.transport = const ExistingHttpTransport(),
    this.scanner = const ExistingBarcodeScanner(),
    LegacyFeatureContext context = const LegacyFeatureContext(),
    StockInApi? stockApi,
  }) : comid = context.preferenceCompanyId,
        empRefId = context.employeeId,
        driverLogin = context.driverLogin,
        _stockApi = stockApi;

  StockInApi get _stock => _stockApi ?? sl<StockInApi>();

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
    final statusListRes = await transport.postRequest(
        "${ApiConstants.apiSelectAllJobStatus}$comid&Jobid=$jobMId", null);

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

    final statuses = JobSteps.statuses(statusListRes);
    if (statuses.isNotEmpty) {
      final match = statuses.firstWhere((s) => s['Status'] == statusId, orElse: () => null);
      if (match != null) statusName = match['StatusName'];
    }

    // Boarding Officer Logic
    int boardId1 = 0;
    int boardId2 = 0;
    double boardAmt1 = 0.0;
    double boardAmt2 = 0.0;

    if (statusId == 7) {
      boardId1 = empRefId;
      boardAmt1 = 50;
    } else if (statusId == 5) {
      final editRes = await transport.postRequest("${ApiConstants.apiEditSalesOrder}$soId&CNumber=0", null);
      if (editRes != null && editRes is List && editRes.isNotEmpty) {
        boardId1 = editRes[0]['LBoardingOfficerRefid'] ?? 0;
        if (boardId1 != empRefId) {
          boardId2 = empRefId;
          boardAmt1 = 30;
          boardAmt2 = 30;
        }
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
  Future<ResponseViewModel?> deleteImage(int saleOrderId, String folder, String imageName) async {
    final filePath = '/Upload/$comid/SalesOrder/$saleOrderId/$folder/$imageName';
    final header = {
      'Comid': comid.toString(),
      'Id': saleOrderId.toString(),
      'FolderName': 'SalesOrder',
      'FileName': filePath,
      'SubFolderName': folder,
    };

    final result = await transport.postRequest(ApiConstants.apiDeleteImage, null, headers: header);
    return result != null ? ResponseViewModel.fromJson(result) : null;
  }

  // ─── Save Stock Update ───────────────────────────────────────────────────
  /// The cargo is in warehouse [warehouseId]; the job takes [statusId]. Throws
  /// with the server's message when refused.
  Future<void> saveStockUpdate(int stockId, int statusId, int warehouseId, List<String> imageUrls) =>
      _stock.arrival(comid, stockId, statusId: statusId, portId: warehouseId, imageUrls: imageUrls);

  // ─── Update Boarding Officer ─────────────────────────────────────────────
  Future<void> updateBoardingOfficer(int saleOrderId, int statusType, int boardOfficerId1, int boardOfficerId2, double boardOfficerAmt1, double boardOfficerAmt2) async {
    if (statusType != 7 && statusType != 5) return;
    if (statusType == 5 && boardOfficerId1 == empRefId) return;

    Map<String, dynamic> master;
    if (statusType == 7) {
      master = {
        'Id': saleOrderId,
        'CompanyRefId': comid,
        'EmployeeRefId': empRefId == 0 ? null : empRefId,
        'LBoardingOfficerRefid': boardOfficerId1,
        'LBoardingAmount': boardOfficerAmt1,
      };
    } else {
      master = {
        'Id': saleOrderId,
        'CompanyRefId': comid,
        'EmployeeRefId': empRefId == 0 ? null : empRefId,
        'LBoardingOfficerRefid': boardOfficerId1,
        'LBoardingOfficer1Refid': boardOfficerId2,
        'LBoardingAmount': boardOfficerAmt1,
        'LBoardingAmount1': boardOfficerAmt2,
      };
    }

    await transport.postRequest(ApiConstants.apiUpdateBoardingOfficer, master);
  }
}