
class RTIMasterViewModel {
  int Id;
  int RTINo;
  int TruckMasterRefId;
  String RTIDate;
  String RTINoDisplay;
  String DriverName;
  String TruckName;
  String Remarks;
  double Amount;

  RTIMasterViewModel(
      this.Id, this.RTINo,this.TruckMasterRefId,this.RTINoDisplay, this.RTIDate, this.DriverName, this.TruckName, this.Remarks, this.Amount);

  RTIMasterViewModel.fromJson(Map<String, dynamic> json)
      : Id = int.tryParse(json['Id']?.toString() ?? '') ?? 0,
        RTINo = int.tryParse(json['RTINo']?.toString() ?? '') ?? 0,
        TruckMasterRefId = int.tryParse(json['TruckMasterRefId']?.toString() ?? '') ?? 0,
        RTINoDisplay = json['RTINoDisplay'] ?? '',
        RTIDate = json['RTIDate'] ?? '',
        DriverName = json['DriverName'] ?? '',
        TruckName = json['TruckName'] ?? '',
        Remarks = json['Remarks'] ?? '',
        Amount = double.parse(json['Amount'].toString());
  // method
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'RTINo': RTINo,
      'TruckMasterRefId': TruckMasterRefId,
      'RTINoDisplay': RTINoDisplay,
      'RTIDate': RTIDate,
      'DriverName': DriverName,
      'TruckName': TruckName,
      'Remarks': Remarks,
      'Amount': Amount
    };
  }

  RTIMasterViewModel.Empty()
      : Id = 0,
        RTINo = 0,
        TruckMasterRefId = 0,
        RTINoDisplay = '',
        RTIDate = '',
        DriverName = '',
        TruckName = '',
        Remarks = '',
        Amount = 0.0;
}