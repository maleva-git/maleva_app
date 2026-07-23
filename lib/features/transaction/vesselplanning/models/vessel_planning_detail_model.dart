
class VesselPlanningDetailModel {
  final int vesselPlaningMasterRefId;
  final String jobNo;
  final String customerName;
  final String loadingVesselName;
  final String oPort;
  final String jobName;
  final String jobStatus;
  final String pkg;
  final String remarks;
  final String soEta;
  final String sEta;
  final String soEtb;
  final String sEtb;
  final String soEtd;
  final String sEtd;

  VesselPlanningDetailModel({
    required this.vesselPlaningMasterRefId,
    required this.jobNo,
    required this.customerName,
    required this.loadingVesselName,
    required this.oPort,
    required this.jobName,
    required this.jobStatus,
    required this.pkg,
    required this.remarks,
    required this.soEta,
    required this.sEta,
    required this.soEtb,
    required this.sEtb,
    required this.soEtd,
    required this.sEtd,
  });

  factory VesselPlanningDetailModel.fromJson(Map<String, dynamic> json) {
    return VesselPlanningDetailModel(
      vesselPlaningMasterRefId: json['VESSELPLANINGMasterRefId'] ?? 0,
      jobNo: json['JobNo']?.toString() ?? '',
      customerName: json['CustomerName']?.toString() ?? '',
      loadingVesselName: json['Loadingvesselname']?.toString() ?? '',
      oPort: json['OPort']?.toString() ?? '',
      jobName: json['JobName']?.toString() ?? '',
      jobStatus: json['JobStatus']?.toString() ?? '',
      pkg: json['pkg']?.toString() ?? '',
      remarks: json['Remarks']?.toString() ?? '',
      soEta: json['SOETA']?.toString() ?? '',
      sEta: json['SETA']?.toString() ?? '',
      soEtb: json['SOETB']?.toString() ?? '',
      sEtb: json['SETB']?.toString() ?? '',
      soEtd: json['SOETD']?.toString() ?? '',
      sEtd: json['SETD']?.toString() ?? '',
    );
  }
}