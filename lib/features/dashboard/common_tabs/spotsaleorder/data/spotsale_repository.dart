import 'package:maleva/core/network/api_constants.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
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

  /// Fetches Spot Sale Records for the View page
  Future<dynamic> fetchSpotSaleRecords({
    required int comId,
    required String fromDate,
    required String toDate,
  }) async {
    final url = "${ApiConstants.apiGetSpotSaleEntry}$comId&Fromdate=$fromDate&Todate=$toDate&Id=0";
    return await ApiClient.postRequest(url, null);
  }

  /// Submits a new Spot Sale Entry with multipart form data (Files + JSON)
  Future<bool> submitSpotSaleEntry({
    required List<Map<String, dynamic>> body,
    required int comId,
    File? image,
    File? pdf,
  }) async {
    final uri = Uri.parse("${ApiConstants.apiInsertSpotSaleEntry}?Comid=$comId");
    final request = http.MultipartRequest("POST", uri);

    request.fields["details"] = jsonEncode(body);
    request.fields["Comid"] = comId.toString();

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath("Files", image.path));
    }
    if (pdf != null) {
      request.files.add(await http.MultipartFile.fromPath("Files", pdf.path));
    }

    final response = await request.send();
    return response.statusCode == 200;
  }
}