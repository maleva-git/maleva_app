import 'package:maleva/core/network/api_constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
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

  /// Submits the PDO Verification with Multi-Part image files. Still the
  /// .NET InsertRTIStatus: its stored procedure is ported in the next phase.
  Future<bool> submitPDOVerification({
    required int comId,
    required List<Map<String, dynamic>> payload,
    required List<RTIDetailsViewModel> checkedDetails,
  }) async {
    final uri = Uri.parse("${ApiConstants.apiRTIDetailsInsert}$comId");
    final request = http.MultipartRequest("POST", uri);

    request.fields["objReceipt"] = jsonEncode(payload);
    request.fields["Comid"]      = comId.toString();

    // Attach image files dynamically
    for (final d in checkedDetails) {
      if (d.imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "Files_${d.Id}",
            d.imageFile!.path,
            filename: d.imageFile!.name,
          ),
        );
      }
    }

    final response = await request.send();
    return response.statusCode == 200;
  }
}