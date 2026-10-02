import 'package:dio/dio.dart';
import 'package:maleva/core/network/dio_client.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/utils/session_manager.dart';
import 'package:maleva/core/models/shared/response_view_model.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/stock/stock_in_api.dart';

/// Stock In Entry. The stock-in calls go to the shared Java `/api/stock-ins`
/// (ported from .NET StockApp); the job list, job steps, sale order edit and
/// image delete are other features' calls.
class StockInEntryRepository {
  final DioClient _dioClient;
  final SessionManager _sessionManager;
  final StockInApi? _stockApi;

  StockInEntryRepository(this._dioClient, this._sessionManager, {StockInApi? stockApi}) : _stockApi = stockApi;

  StockInApi get _stock => _stockApi ?? sl<StockInApi>();

  int get _comid => _sessionManager.companyId;

  // ─── Initial Startup Data ──────────────────────────────────────────────────
  Future<Map<String, dynamic>> fetchInitialData(int billType) async {
    final maxNum = await _stock.nextNumber(_comid);
    final stockJobs = await _stock.stockJobs(_comid);
    final jobNoRes = await _dioClient.dio.post("${ApiConstants.apiGetJobNo}$_comid&JobType=$billType", data: {});

    return {
      'maxStockNo': maxNum,
      'stockJobList': stockJobs,
      'jobNoList': (jobNoRes.data is List) ? jobNoRes.data : [],
    };
  }

  // ─── Fetch Job List by Bill Type ───────────────────────────────────────────
  Future<List<dynamic>> fetchJobNoList(int billType) async {
    final jobNoRes = await _dioClient.dio.post("${ApiConstants.apiGetJobNo}$_comid&Type=$billType", data: {});
    return (jobNoRes.data != null && jobNoRes.data is List) ? jobNoRes.data : [];
  }

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

  // ─── Fetch Sales Order For Edit ────────────────────────────────────────────
  Future<Map<String, dynamic>> fetchSalesOrderForEdit(int id, int saleNo) async {
    try {
      final endpoint = "${ApiConstants.apiEditSalesOrder}$id&SaleorderNo=$saleNo&Comid=$_comid";
      final response = await _dioClient.dio.post(endpoint, data: {});
      if (response.data != null && response.data.isNotEmpty) {
         final item = response.data[0];
         return {
            'masterList': item['EditMasterDetails'] ?? [],
            'detailsList': item['EditItemDetails'] ?? [],
         };
      }
    } catch (e) {
      // ignore
    }
    return {
      'masterList': [],
      'detailsList': [],
    };
  }

  // ─── Delete Image ──────────────────────────────────────────────────────────
  Future<ResponseViewModel?> deleteImage(int saleOrderId, String folder, String imageName) async {
    final filePath = '/Upload/$_comid/SalesOrder/$saleOrderId/$folder/$imageName';
    final options = Options(headers: {
      'Comid': _comid.toString(),
      'Id': saleOrderId.toString(),
      'FolderName': 'SalesOrder',
      'FileName': filePath,
      'SubFolderName': folder,
    });

    try {
      final result = await _dioClient.dio.post(ApiConstants.apiDeleteImage, options: options, data: {});
      if (result.data != null) {
        return ResponseViewModel.fromJson(result.data);
      }
    } catch (e) {
      // ignore
    }
    return null;
  }

  // ─── Save Stock In ─────────────────────────────────────────────────────────
  /// Saves the rows (Java fields); answers the stock-in id. A refusal throws
  /// with the server's message.
  Future<int> saveStockIn(List<Map<String, dynamic>> rows) => _stock.save(_comid, rows);

  /// What the labels carry (`numberOfPackages`, `jobNo`, `sSaleDate`, `vesselName`).
  Future<Map<String, dynamic>> label(int stockId) => _stock.label(_comid, stockId);
}
