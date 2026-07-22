
class VesselPlanningMasterModel {
  int Id;
  int VESSELPLANINGNo;
  String VESSELPLANINGNoDisplay;
  String VESSELPLANINGDate;
  String Remarks;
  String FDate;
  String TDate;
  String Search;
  VesselPlanningMasterModel(
      this.Id,
      this.VESSELPLANINGNo,
      this.VESSELPLANINGNoDisplay,
      this.VESSELPLANINGDate,
      this.Remarks,
      this.FDate,
      this.TDate,
      this.Search,
      );
  VesselPlanningMasterModel.fromJson(Map<String, dynamic> json)
      : Id = int.tryParse(json['Id']?.toString() ?? '') ?? 0,
        VESSELPLANINGNo = int.tryParse(json['VESSELPLANINGNo']?.toString() ?? '') ?? 0,
        VESSELPLANINGNoDisplay = json['VESSELPLANINGNoDisplay'] ?? '',
        VESSELPLANINGDate = json['VESSELPLANINGDate'] ?? '',
        Remarks = json['Remarks'] ?? '',
        FDate = json['FDate'] ?? '',
        TDate = json['TDate'] ?? '',
        Search = json['Search'] ?? '';
  // method
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'VESSELPLANINGNo': VESSELPLANINGNo,
      'VESSELPLANINGNoDisplay': VESSELPLANINGNoDisplay,
      'VESSELPLANINGDate': VESSELPLANINGDate,
      'Remarks': Remarks,
      'FDate': FDate,
      'TDate': TDate,
      'Search': Search,
    };
  }

  VesselPlanningMasterModel.Empty()
      : Id = 0,
        VESSELPLANINGNo = 0,
        VESSELPLANINGNoDisplay = '',
        VESSELPLANINGDate = '',
        Remarks = '',
        FDate = '',
        TDate = '',
        Search = '';
}