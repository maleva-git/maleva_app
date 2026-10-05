import 'package:maleva/core/finance/petty_cash_api.dart';
import 'package:maleva/core/models/shared/pattycash_master_model.dart';
import 'package:maleva/core/models/shared/patty_cash_details_model.dart';

/// The Change Status page's petty cash: the one record and its lines (shared
/// Java `/api/petty-cash-masters/edit`). The .NET call it replaced loaded the
/// whole company's petty cash, without the dates .NET required.
class ChangeStatusLoader {
  final PettyCashApi api;
  ChangeStatusLoader({required this.api});

  List<PattycashMasterModel> masters = [];
  List<PattyCashDetailsModel> details = [];

  Future<void> load(int id) async {
    final master = PattycashMasterModel.fromJava(await api.edit(id), companyId: api.companyId);
    masters = [master];
    details = master.pattyCashDetails;
  }
}
