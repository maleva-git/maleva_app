import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/files/attachments_api.dart';
import 'package:maleva/core/sale_order/sale_order_api.dart';

/// Forwarding (SMK) update on the shared Java sale order API: the job picker
/// (`/job-numbers`, every bill type), the job (`/edit`) and `PUT /{id}/forwarding`.
class FWUpdateRepository {
  FWUpdateRepository({SaleOrderApi? saleOrders}) : _saleOrderApi = saleOrders;

  final SaleOrderApi? _saleOrderApi;
  SaleOrderApi get _saleOrders => _saleOrderApi ?? sl<SaleOrderApi>();

  /// Every job: `[{id, cNumber, forwardingSMKNo, forwardingSMKNo2, forwardingSMKNo3, ...}]`.
  Future<List<Map<String, dynamic>>> fetchJobNoList() => _saleOrders.jobNumbers(3);

  /// The job's master (Java names: `forwardingEnterRef2`, `sealbyRefid3`, ...).
  Future<Map<String, dynamic>> fetchJob(int saleOrderId) async => (await _saleOrders.edit(id: saleOrderId)).master;

  /// The job's photos under [smkKey], from the shared Java `/api/attachments`.
  Future<List<String>> fetchImages(int saleOrderId, String smkKey) =>
      sl<AttachmentsApi>().imageNames(folder: 'SalesOrder', recordId: saleOrderId, subFolder: smkKey);

  /// Deletes one photo (shared Java `/api/attachments`); throws when refused.
  Future<void> deleteImage(int saleOrderId, String smkUpload, String networkImg) async {
    await sl<AttachmentsApi>().delete([networkImg], folder: 'SalesOrder', recordId: saleOrderId, subFolder: smkUpload);
  }

  /// Only the given fields change; a null text or a 0 officer is left as it is.
  Future<void> updateForwarding(int saleOrderId, Map<String, dynamic> fields) =>
      _saleOrders.updateForwarding(saleOrderId, fields);
}
