
class PlanningMasterModel {
  int Id;
  int PLANINGNo;
  String PLANINGNoDisplay;
  String PLANINGDate;
  String Remarks;
  PlanningMasterModel(
      this.Id,
      this.PLANINGNo,
      this.PLANINGNoDisplay,
      this.PLANINGDate,
      this.Remarks,
      );
  PlanningMasterModel.fromJson(Map<String, dynamic> json)
      : Id = int.tryParse(json['Id']?.toString() ?? '') ?? 0,
        PLANINGNo = int.tryParse(json['PLANINGNo']?.toString() ?? '') ?? 0,
        PLANINGNoDisplay = json['PLANINGNoDisplay'] ?? '',
        PLANINGDate = json['PLANINGDate'] ?? '',
        Remarks = json['Remarks'] ?? '';
  // method
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'PLANINGNo': PLANINGNo,
      'PLANINGNoDisplay': PLANINGNoDisplay,
      'PLANINGDate': PLANINGDate,
      'Remarks': Remarks,
    };
  }

  PlanningMasterModel.Empty()
      : Id = 0,
        PLANINGNo = 0,
        PLANINGNoDisplay = '',
        PLANINGDate = '',
        Remarks = '';
}