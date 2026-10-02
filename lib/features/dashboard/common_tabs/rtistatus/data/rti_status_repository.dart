import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/files/attachments_api.dart';
import 'package:maleva/core/utils/system_helpers.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'dart:io';
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/models/shared/response_view_model.dart';

class RTIStatusRepository {
  Future<List<String>> fetchImages(int saleOrderId, String folder) =>
      sl<AttachmentsApi>().imageNames(folder: 'SalesOrder', recordId: saleOrderId, subFolder: folder);

  Future<String> uploadImage(File file, int saleOrderId, String folder) async {
    return await SystemHelpers.upload(file, saleOrderId, 'SalesOrder', folder);
  }

  Future<void> deleteImage(int saleOrderId, String folder, String imageName) async {
    await sl<AttachmentsApi>().delete([imageName], folder: 'SalesOrder', recordId: saleOrderId, subFolder: folder);
  }

  Future<ResponseViewModel?> sendRtiMail(Map<String, dynamic> master) async {
    final response = await ApiClient.postRequest(ApiConstants.apiRTIMail, master);
    return response != null ? ResponseViewModel.fromJson(response) : null;
  }
}