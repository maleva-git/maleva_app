import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/files/attachments_api.dart';
import 'package:maleva/core/utils/system_helpers.dart';
import 'dart:io';
import 'package:maleva/core/rti/rti_api.dart';

class RTIStatusRepository {
  Future<List<String>> fetchImages(int saleOrderId, String folder) =>
      sl<AttachmentsApi>().imageNames(folder: 'SalesOrder', recordId: saleOrderId, subFolder: folder);

  Future<String> uploadImage(File file, int saleOrderId, String folder) async {
    return await SystemHelpers.upload(file, saleOrderId, 'SalesOrder', folder);
  }

  Future<void> deleteImage(int saleOrderId, String folder, String imageName) async {
    await sl<AttachmentsApi>().delete([imageName], folder: 'SalesOrder', recordId: saleOrderId, subFolder: folder);
  }

  /// The job's RTI status on the shared Java API (it sets the driver status,
  /// then emails and WhatsApps the transport staff with the photos).
  Future<void> updateJobStatus(int saleOrderId, String statusName, List<String> imageUrls) =>
      sl<RtiApi>().updateJobStatus(saleOrderId, statusName, imageUrls);
}
