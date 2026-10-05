import 'package:maleva/core/lookups/job_status_api.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/files/attachments_api.dart';
import 'package:maleva/core/sale_order/sale_order_api.dart';

/// Job status (boarding) update. The job list, the job, the update and the
/// boarding mail are the shared Java sale order API; the job steps are the
/// job type lookup.
class JobStatusUpdateRepository {
  JobStatusUpdateRepository({SaleOrderApi? saleOrders}) : _saleOrderApi = saleOrders;

  final SaleOrderApi? _saleOrderApi;
  SaleOrderApi get _saleOrders => _saleOrderApi ?? sl<SaleOrderApi>();

  /// `[{id, cNumber, ...}]`; [type] 0 forwarding (MY), 1 transport (TR), 3 all.
  Future<List<Map<String, dynamic>>> fetchJobs(int type) => _saleOrders.jobNumbers(type);

  /// The job's status (id and name), job type and Boarding photos.
  Future<Map<String, dynamic>> fetchJobData(int saleOrderId, int cNumber) async {
    final master = (await _saleOrders.edit(id: saleOrderId, saleOrderNo: cNumber)).master;
    final int statusId = master['jStatus'] as int? ?? 0;
    final int jobMasterId = master['jobMasterRefId'] as int? ?? 0;
    var statusName = '';

    if (statusId != 0) {
      statusName = (await sl<JobStatusApi>().steps(jobMasterId)).statusName(statusId);
    }

    final images = await sl<AttachmentsApi>().imageNames(folder: 'SalesOrder', recordId: saleOrderId, subFolder: 'Boarding');

    return {
      'statusId': statusId,
      'statusName': statusName,
      'jobMasterId': jobMasterId,
      'images': images,
    };
  }

  Future<void> deleteImage(int saleOrderId, String imageName) async {
    await sl<AttachmentsApi>().delete([imageName], folder: 'SalesOrder', recordId: saleOrderId, subFolder: 'Boarding');
  }

  /// The status and boarding start/end (`PUT /api/sale-orders/{id}/boarding`).
  Future<void> updateBoardingDetails(int saleOrderId, {required int statusId, DateTime? start, DateTime? end}) =>
      _saleOrders.updateBoarding(saleOrderId, statusId: statusId, start: start, end: end);

  /// The boarding status email and WhatsApp (`POST /api/sale-orders/{id}/boarding-mail`).
  Future<void> sendBoardingMail(int saleOrderId, {required String statusName, required List<String> imageUrls}) =>
      _saleOrders.sendBoardingMail(saleOrderId, statusName: statusName, imageUrls: imageUrls);
}
