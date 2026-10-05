import 'package:maleva/core/fleet/truck_entries_api.dart';
import 'package:get_it/get_it.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'dart:io';
import 'package:maleva/core/network/api_client.dart';

class SpotSaleRepository {
  /// Fetches Job Types
  Future<dynamic> fetchJobTypes(int comId) async {
    return await ApiClient.postRequest("${ApiConstants.apiSelectJobType}$comId", null);
  }

  /// Fetches Job Statuses
  Future<dynamic> fetchJobStatus(int comId) async {
    return await ApiClient.postRequest("${ApiConstants.apiSelectJobStatus}$comId", null);
  }

  /// Spot sale entries created in the days, from the shared Java API (the Java rows).
  Future<List<Map<String, dynamic>>> fetchSpotSaleRecords({
    required String fromDate,
    required String toDate,
  }) =>
      GetIt.instance<TruckEntriesApi>().spotSales(fromDate: fromDate, toDate: toDate);

  /// Adds (id 0) or updates a spot sale entry with its image and PDF (Java
  /// port of SP_SoptSaleorder). Answers the id.
  Future<int> submitSpotSaleEntry({
    int id = 0,
    required int jobTypeId,
    required int jobStatusId,
    required int employeeId,
    required String vehicleName,
    required String awbNo,
    required String quantity,
    required String totalWeight,
    required String port,
    File? image,
    File? pdf,
  }) =>
      GetIt.instance<TruckEntriesApi>().saveSpotSale(
        id: id,
        jobTypeId: jobTypeId,
        jobStatusId: jobStatusId,
        employeeId: employeeId,
        vehicleName: vehicleName,
        awbNo: awbNo,
        quantity: quantity,
        totalWeight: totalWeight,
        port: port,
        files: [if (image != null) image, if (pdf != null) pdf],
      );
}
