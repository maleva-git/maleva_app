
class PettyCashMasterModel {
  int Id;
  int CompanyRefId;
  int EmployeeRefId;
  String CNumberDisplay;
  String EmployeeName;
  String PettyCashDate;
  String PaymentStatus;
  int CNumber;
  int Status;
  String Amount;

  PettyCashMasterModel({
    required this.Id,
    required this.CompanyRefId,
    required this.EmployeeRefId,
    required this.CNumberDisplay,
    required this.EmployeeName,
    required this.PettyCashDate,
    required this.PaymentStatus,
    required this.CNumber,
    required this.Status,
    required this.Amount,
  });

  factory PettyCashMasterModel.fromJson(Map<String, dynamic> json) {
    return PettyCashMasterModel(
      Id: json['Id'] ?? 0,
      CompanyRefId: json['CompanyRefId'] ?? 0,
      EmployeeRefId: json['EmployeeRefId'] ?? 0,
      CNumberDisplay: json['CNumberDisplay'] ?? '',
      EmployeeName: json['EmployeeName'] ?? '',
      PettyCashDate: json['PettyCashDate'] ?? '',
      PaymentStatus: json['PaymentStatus'] ?? '',
      CNumber: json['CNumber'] ?? 0,
      Status: json['Status'] ?? 0,
      Amount: json['Amount'] ?? '0.00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'CompanyRefId': CompanyRefId,
      'EmployeeRefId': EmployeeRefId,
      'CNumberDisplay': CNumberDisplay,
      'EmployeeName': EmployeeName,
      'PettyCashDate': PettyCashDate,
      'PaymentStatus': PaymentStatus,
      'CNumber': CNumber,
      'Status': Status,
      'Amount': Amount,
    };
  }

  PettyCashMasterModel.Empty()
      : Id = 0,
        CompanyRefId = 0,
        EmployeeRefId = 0,
        CNumberDisplay = '',
        EmployeeName = '',
        PettyCashDate = '',
        PaymentStatus = '',
        CNumber = 0,
        Status = 0,
        Amount = '0.00';
}