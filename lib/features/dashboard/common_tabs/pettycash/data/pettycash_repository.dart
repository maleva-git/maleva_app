import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/finance/petty_cash_api.dart';
import 'package:maleva/core/models/shared/patty_cash_details_model.dart';
import 'package:maleva/core/models/shared/pattycash_master_model.dart';
import 'package:maleva/core/utils/json_read.dart';

/// The period's petty cash and its lines (shared Java
/// `/api/petty-cash-masters/search`, was .NET BIllorderApp/SelectpetticashApp).
class PettyCashRepository {
  Future<({List<PattycashMasterModel> masters, List<PattyCashDetailsModel> details})> fetchPettyCashData({
    required String fromDate,
    required String toDate,
  }) async {
    final api = sl<PettyCashApi>();
    final data = await api.search(fromDate: fromDate, toDate: toDate);
    return (
      masters: [
        for (final m in JsonRead.listOfMaps(data['pettyCashMaster']))
          PattycashMasterModel.fromJava(m, companyId: api.companyId),
      ],
      details: [
        for (final d in JsonRead.listOfMaps(data['pettyCashDetails'])) PattyCashDetailsModel.fromJava(d),
      ],
    );
  }
}
