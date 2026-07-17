import 'package:maleva/core/network/api_constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/models/shared/r_t_i_details_view_model.dart';

class PDORepository {
  /// Fetches PDO / RTI Records
  Future<dynamic> fetchPDORecords({
    required int comId,
    required String fromDate,
    required String toDate,
    required int driverId,
    required int truckId,
    required int employeeId,
    required String search,
  }) async {
    final url = "${ApiConstants.apiSelectRTIView}$comId"
        "&Fromdate=$fromDate&Todate=$toDate"
        "&DId=$driverId&TId=$truckId&Employeeid=$employeeId"
        "&Search=$search";

    return await ApiClient.postRequest(url, null);
  }

  /// Submits the PDO Verification with Multi-Part image files
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