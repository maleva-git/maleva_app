
import 'package:maleva/core/utils/json_read.dart';

class PattyCashDetailsModel {
  int Id;
  int sdId;
  int pettyCashMasterRefId;
  String? notes;
  String? items;
  String? amount;

  PattyCashDetailsModel({
    required this.Id,
    required this.sdId,
    required this.pettyCashMasterRefId,
    this.notes,
    this.items,
    this.amount,
  });

  /// A line of the shared Java petty cash (`search` details or `edit` lines;
  /// an `edit` line has no master id, so [masterId] gives it).
  factory PattyCashDetailsModel.fromJava(Map<String, dynamic> json, {int masterId = 0}) {
    dynamic f(String k) => JsonRead.field(json, k);
    return PattyCashDetailsModel(
      Id: JsonRead.integer(f('id')),
      sdId: 0,
      pettyCashMasterRefId: JsonRead.intOrNull(f('pettyCashMasterRefId')) ?? masterId,
      notes: JsonRead.stringOrNull(f('notes')),
      items: JsonRead.stringOrNull(f('items')),
      amount: JsonRead.stringOrNull(f('amount')),
    );
  }

  Map<String, dynamic> toJson() => {
    'Id': Id,
    'SDId': sdId,
    'PettyCashMasterRefId': pettyCashMasterRefId,
    'Notes': notes,
    'Items': items,
    'Amount': amount,
  };
}