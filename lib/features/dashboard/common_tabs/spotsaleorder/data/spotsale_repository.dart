import 'package:maleva/features/operations/models/job_status_model.dart';
import 'package:maleva/core/lookups/job_status_api.dart';
import 'package:maleva/features/operations/models/job_type_model.dart';
import 'package:maleva/core/lookups/job_type_api.dart';
import 'package:maleva/core/fleet/truck_entries_api.dart';
import 'package:get_it/get_it.dart';
import 'dart:io';

class SpotSaleRepository {
  /// Job types (shared Java /api/job-type-master/jobtypes/{companyId}).
  Future<List<JobTypeModel>> fetchJobTypes() async =>
      (await GetIt.instance<JobTypeApi>().jobTypes()).map(JobTypeModel.fromJava).toList();

  /// The company's job statuses (shared Java job status master).
  Future<List<JobStatusModel>> fetchJobStatus() async =>
      (await GetIt.instance<JobStatusApi>().statuses()).map(JobStatusModel.fromJava).toList();

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
