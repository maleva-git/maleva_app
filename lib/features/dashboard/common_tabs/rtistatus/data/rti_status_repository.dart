import 'package:maleva/core/utils/system_helpers.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'dart:io';
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/models/shared/response_view_model.dart';

class RTIStatusRepository {
  Future<List<String>> fetchImages(int saleOrderId, String folder) async {
    final imageDir = '/Upload/${AppPreferences.getComid()}/SalesOrder/$saleOrderId/$folder/';
    final response = await ApiClient.postRequest('${ApiConstants.apiGetImage}$imageDir', null);

    return (response is List) ? response.map((e) => e.toString()).toList() : [];
  }

  Future<String> uploadImage(File file, int saleOrderId, String folder) async {
    return await SystemHelpers.upload(file, ApiConstants.apiPostImage, saleOrderId, 'SalesOrder', folder);
  }

  Future<ResponseViewModel?> deleteImage(int saleOrderId, String folder, String imageName) async {
    final comid = AppPreferences.getComid();
    final filePath = '/Upload/$comid/SalesOrder/$saleOrderId/$folder/$imageName';

    final headers = {
      'Comid': comid.toString(),
      'Id': saleOrderId.toString(),
      'FolderName': 'SalesOrder',
      'FileName': filePath,
      'SubFolderName': folder,
    };

    final response = await ApiClient.postRequest(ApiConstants.apiDeleteImage, null, headers: headers);
    return response != null ? ResponseViewModel.fromJson(response) : null;
  }

  Future<ResponseViewModel?> sendRtiMail(Map<String, dynamic> master) async {
    final response = await ApiClient.postRequest(ApiConstants.apiRTIMail, master);
    return response != null ? ResponseViewModel.fromJson(response) : null;
  }
}