import 'package:maleva/core/models/shared/pattycash_master_model.dart';
import 'package:maleva/core/models/shared/patty_cash_details_model.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/network/legacy_json_transport.dart';
import 'package:maleva/core/session/legacy_feature_context.dart';

/// One page's loaded data. Preserve incremental assignment on parse failures.
class ChangeStatusLoader {
  final LegacyArrayTransport transport;
  final LegacyFeatureContext context;
  ChangeStatusLoader({required this.transport,
    this.context = const LegacyFeatureContext()});

  List<PattycashMasterModel> masters = [];
  List<PattyCashDetailsModel> details = [];

  Future<void> load() async {
    final result = await transport.select(
      '${ApiConstants.apiGetpettycash}${context.globalCompanyId}', null,
      {'Content-Type': 'application/json; charset=UTF-8'});
    if (result != null && result.isNotEmpty) {
      final data = result[0];
      if (data != null) {
        if (data['PattycashMasterModel'] != null) {
          masters = (data['PattycashMasterModel'] as List)
              .map((item) => PattycashMasterModel.fromJson(item)).toList();
        }
        if (data['PattyCashDetailsModel'] != null) {
          details = (data['PattyCashDetailsModel'] as List)
              .map((item) => PattyCashDetailsModel.fromJson(item)).toList();
        }
      }
    }
  }
}
