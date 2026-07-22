import 'package:maleva/core/network/api_constants.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;

class SparePartsRepository {
  /// Loads the global truck list
  Future<void> fetchTrucks() async {
    // We pass null for context so it safely runs in the background
    await OnlineApi.SelectTruckList(null, null);}

  /// Fetches Spare Parts records for the View page
  Future<dynamic> fetchSparePartsRecords({
    required int comId,
    required String fromDate,
    required String toDate,
  }) async {
    final url = "${ApiConstants.apiGetSpareParts}$comId&Fromdate=$fromDate&Todate=$toDate";
    return await ApiClient.postRequest(url, null);
  }

  /// Submits a new Spare Parts Entry with multipart form data (Files + JSON)
  Future<bool> submitSpareParts({
    required List<Map<String, dynamic>> body,
    required int comId,
    File? image,
    File? pdf,
  }) async {
    final uri = Uri.parse("${ApiConstants.apiInsertSpareParts}?Comid=$comId");
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