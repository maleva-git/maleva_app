
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

  factory PattyCashDetailsModel.fromJson(Map<String, dynamic> json) {
    return PattyCashDetailsModel(
      Id: json['Id'],
      sdId: json['SDId'],
      pettyCashMasterRefId: json['PettyCashMasterRefId'],
      notes: json['Notes'],
      items: json['Items'],
      amount: json['Amount'],
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