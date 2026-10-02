import 'package:maleva/core/files/attachments_api.dart';
import 'package:maleva/core/network/dio_client.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/utils/session_manager.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/stock/stock_in_api.dart';
import 'package:maleva/core/sale_order/sale_order_api.dart';

/// Stock In Entry. The stock-in calls go to the shared Java `/api/stock-ins`
/// (ported from .NET StockApp); the job picker is `/api/sale-orders/job-numbers`
/// (`[{id, cNumber, ...}]`); job steps and image delete are other features' calls.
class StockInEntryRepository {
  final DioClient _dioClient;
  final SessionManager _sessionManager;
  final StockInApi? _stockApi;
  final SaleOrderApi? _saleOrderApi;

  StockInEntryRepository(this._dioClient, this._sessionManager, {StockInApi? stockApi, SaleOrderApi? saleOrderApi})
      : _stockApi = stockApi,
        _saleOrderApi = saleOrderApi;

  StockInApi get _stock => _stockApi ?? sl<StockInApi>();
  SaleOrderApi get _saleOrders => _saleOrderApi ?? sl<SaleOrderApi>();

  int get _comid => _sessionManager.companyId;

  // ─── Initial Startup Data ──────────────────────────────────────────────────
  Future<Map<String, dynamic>> fetchInitialData(int billType) async {
    final maxNum = await _stock.nextNumber(_comid);
    final stockJobs = await _stock.stockJobs(_comid);
    return {
      'maxStockNo': maxNum,
      'stockJobList': stockJobs,
      'jobNoList': await _saleOrders.jobNumbers(billType),
    };
  }

  // ─── Fetch Job List by Bill Type ───────────────────────────────────────────
  Future<List<dynamic>> fetchJobNoList(int billType) => _saleOrders.jobNumbers(billType);

  // ─── Fetch Job Details ─────────────────────────────────────────────────────
  Future<Map<String, dynamic>> fetchJobDetails(int saleOrderId) async {
    final jobs = await _stock.saleOrders(_comid, saleOrderId: saleOrderId);

    String shipName = '';
    String customerName = '';
    String jobDate = '';
    int jobMasterId = 0;
    int weightPkg = 0;
    List<dynamic> jobStatuses = [];

    if (jobs.isNotEmpty) {
      final data = jobs.first;
      customerName = data['customerName'] ?? '';
      shipName = customerName.isNotEmpty ? (data['loadingVesselName'] ?? '') : (data['offVesselName'] ?? '');
      jobDate = data['sSaleDate'] ?? '';
      jobMasterId = data['jobMasterRefId'] ?? 0;

      final qty = data['quantity']?.toString() ?? '0';
      final match = RegExp(r'\d+').stringMatch(qty);
      weightPkg = int.tryParse(match ?? '0') ?? 0;

      try {
        final statusRes = await _dioClient.dio.post("${ApiConstants.apiSelectAllJobStatus}$_comid&Jobid=$jobMasterId", data: {});

        if (statusRes.data != null && statusRes.data is List && statusRes.data.isNotEmpty) {
          var firstItem = statusRes.data[0];
          if (firstItem != null && firstItem['JobStatusDetails'] != null) {
            jobStatuses = firstItem['JobStatusDetails'];
          }
        }
      } catch (e) {
        // ignore
      }
    }

    return {
      'shipName': shipName,
      'customerName': customerName,
      'jobDate': jobDate,
      'jobMasterId': jobMasterId,
      'weightPkg': weightPkg,
      'jobStatuses': jobStatuses,
    };
  }

  // ─── Delete Image ──────────────────────────────────────────────────────────
  Future<void> deleteImage(int saleOrderId, String folder, String imageName) async {
    await sl<AttachmentsApi>().delete([imageName], folder: 'SalesOrder', recordId: saleOrderId, subFolder: folder);
  }

  // ─── Save Stock In ─────────────────────────────────────────────────────────
  /// Saves the rows (Java fields); answers the stock-in id. A refusal throws
  /// with the server's message.
  Future<int> saveStockIn(List<Map<String, dynamic>> rows) => _stock.save(_comid, rows);

  /// What the labels carry (`numberOfPackages`, `jobNo`, `sSaleDate`, `vesselName`).
  Future<Map<String, dynamic>> label(int stockId) => _stock.label(_comid, stockId);
}
