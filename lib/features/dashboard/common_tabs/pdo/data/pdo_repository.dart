import 'dart:io';
import 'package:get_it/get_it.dart';
import 'package:maleva/core/rti/rti_api.dart';
import 'package:maleva/core/models/shared/r_t_i_details_view_model.dart';

class PDORepository {
  /// The PDO / RTI records, from the shared Java RTI list (a driver token
  /// gets its own RTIs only; change `rti-on-shared-java-api`).
  Future<RtiList> fetchPDORecords({
    required String fromDate,
    required String toDate,
    required int driverId,
    required int truckId,
    required int employeeId,
    required String search,
  }) =>
      GetIt.instance<RtiApi>().withJobs(
        fromDate: fromDate,
        toDate: toDate,
        driverId: driverId,
        truckId: truckId,
        employeeId: employeeId,
        search: search,
      );

  /// Saves the PDO verification of the checked lines with their photos
  /// (Java port of InsertRTIStatus / SP_RTIStatus).
  Future<bool> submitPDOVerification({
    required List<Map<String, dynamic>> payload,
    required List<RTIDetailsViewModel> checkedDetails,
  }) async {
    final photos = <int, File>{
      for (final d in checkedDetails)
        if (d.imageFile != null) d.Id: File(d.imageFile!.path),
    };
    await GetIt.instance<RtiApi>().saveStatuses(payload, photos: photos);
    return true;
  }
}
