import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

class StockInEntryRepository {
  final int comid = AppPreferences.getComid();

  // ─── Initial Startup Data ──────────────────────────────────────────────────
  Future<Map<String, dynamic>> fetchInitialData(int billType) async {
    final maxStockRes = await ApiClient.postRequest("${objfun.apiMaxStockNo}$comid", null);
    final stockJobRes = await ApiClient.postRequest("${objfun.apiSelectStockJob}$comid", null);

    // Equivalent to OnlineApi.GetJobNoForwarding(null, billType)
    final jobNoRes = await ApiClient.postRequest("${objfun.apiGetJobNo}$comid&JobType=$billType", null);

    String maxNum = '';
    if (maxStockRes != null && maxStockRes is List && maxStockRes.isNotEmpty) {
      maxNum = maxStockRes[0]['MaxNo']?.toString() ?? '';
    }

    return {
      'maxStockNo': maxNum,
      'stockJobList': stockJobRes is List ? stockJobRes : [],
      'jobNoList': jobNoRes is List ? jobNoRes : [],
    };
  }

  // ─── Fetch Job List by Bill Type ───────────────────────────────────────────
  Future<List<dynamic>> fetchJobNoList(int billType) async {
    final jobNoRes = await ApiClient.postRequest("${objfun.apiGetJobNo}$comid&Type=$billType", null);
    return jobNoRes is List ? jobNoRes : [];
  }

  // ─── Fetch Job Details & Parse Packages ────────────────────────────────────
  Future<Map<String, dynamic>> fetchJobDetails(int saleOrderId) async {
    final result = await ApiClient.postRequest("${objfun.apiSaleOrderDetailsLoad}$comid&Id=$saleOrderId", null);

    String shipName = '';
    String customerName = '';
    String jobDate = '';
    int jobMasterId = 0;
    int weightPkg = 0;
    List<dynamic> jobStatuses = [];

    if (result != null) {
      final value = ResponseViewModel.fromJson(result);
      if (value.IsSuccess == true && value.data1 != null && value.data1.isNotEmpty) {
        final data = value.data1[0];
        customerName = data['CustomerName'] ?? '';
        shipName = customerName.isNotEmpty ? (data['LoadingVesselName'] ?? '') : (data['OffVesselName'] ?? '');
        jobDate = data['SSaleDate'] ?? '';
        jobMasterId = data['JobMasterRefId'] ?? 0;

        // Parse packages count from quantity string
        final qty = data['Quantity']?.toString() ?? '0';
        final match = RegExp(r'\d+').stringMatch(qty);
        weightPkg = int.tryParse(match ?? '0') ?? 0;

        // Fetch dependent Job Statuses
        final statusRes = await ApiClient.postRequest("${objfun.apiSelectAllJobStatus}$comid&JobMasterRefId=$jobMasterId", null);
        jobStatuses = statusRes is List ? statusRes : [];
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
  Future<ResponseViewModel?> deleteImage(int saleOrderId, String folder, String imageName) async {
    final filePath = '/Upload/$comid/SalesOrder/$saleOrderId/$folder/$imageName';
    final header = {
      'Comid': comid.toString(),
      'Id': saleOrderId.toString(),
      'FolderName': 'SalesOrder',
      'FileName': filePath,
      'SubFolderName': folder,
    };

    final result = await ApiClient.postRequest(objfun.apiDeleteimage, null, headers: header);
    return result != null ? ResponseViewModel.fromJson(result) : null;
  }

  // ─── Save Stock In ─────────────────────────────────────────────────────────
  Future<ResponseViewModel?> saveStockIn(List<Map<String, dynamic>> master) async {
    final result = await ApiClient.postRequest('${objfun.apiInsertStockIn}$comid', master);
    return result != null ? ResponseViewModel.fromJson(result) : null;
  }
}