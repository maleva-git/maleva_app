
class SaleOrderMasterModel {
  int Id;
  int CompanyRefId;
  String BillNoDisplay;
  String JobStatus;
  int BillNo;
  String BillDate;
  String BillTime;
  String SaleType;
  String CustomerName;
  String EmployeeName;
  String CashierName;
  String Remarks;
  String Origin;
  String Destination;
  String SPickupDate;
  String ETA;
  String SETA;
  String SETB;
  String SOETA;
  String SOETB;
  String SPort;
  String FlighTime;
  String Offvesselname;
  String Loadingvesselname;
  int JobMasterRefId;
  bool isETASelected;
  double NetAmt;

  SaleOrderMasterModel(
      this.Id,
      this.CompanyRefId,
      this.BillNoDisplay,
      this.JobStatus,
      this.BillNo,
      this.BillDate,
      this.BillTime,
      this.SaleType,
      this.CustomerName,
      this.EmployeeName,
      this.CashierName,
      this.Remarks,
      this.Origin,
      this.Destination,
      this.SPickupDate,
      this.ETA,
      this.SETA,
      this.SETB,
      this.SOETA,
      this.SOETB,
      this.SPort,
      this.FlighTime,
      this.Offvesselname,
      this.Loadingvesselname,
      this.JobMasterRefId,
      this.NetAmt,
      {this.isETASelected = false}
      );

  SaleOrderMasterModel.fromJson(Map<String, dynamic> json)
      : Id = int.tryParse(json['Id']?.toString() ?? '') ?? 0,
        CompanyRefId = int.tryParse(json['CompanyRefId']?.toString() ?? '') ?? 0,
        BillNoDisplay = json['BillNoDisplay'] ?? '',
        JobStatus = json['JobStatus'] ?? '',
        BillNo = int.tryParse(json['BillNo']?.toString() ?? '') ?? 0,
        BillDate = json['BillDate'] ?? '',
        BillTime = json['BillTime'] ?? '',
        SaleType = json['SaleType'] ?? '',
        CustomerName = json['CustomerName'] ?? '',
        EmployeeName = json['EmployeeName'] ?? '',
        CashierName = json['CashierName'] ?? '',
        Remarks = json['Remarks'] ?? '',
        Origin = json['Origin'] ?? '',
        Destination = json['Destination'] ?? '',
        SPickupDate = json['SPickupDate'] ?? '',
        ETA = json['ETA'] ?? '',
        SETA = json['SETA'] ?? '',
        SETB = json['SETB'] ?? '',
        SOETA = json['SOETA'] ?? '',
        SOETB = json['SOETB'] ?? '',
        SPort = json['SPort'] ?? '',
        FlighTime = json['FlighTime'] ?? '',
        Offvesselname = json['Offvesselname'] ?? '',
        Loadingvesselname = json['Loadingvesselname'] ?? '',
        JobMasterRefId = int.tryParse(json['JobMasterRefId']?.toString() ?? '') ?? 0,
        isETASelected = false,
        NetAmt = double.parse(json['NetAmt'].toString());
  // method
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'CompanyRefId' : CompanyRefId,
      'BillNoDisplay': BillNoDisplay,
      'JobStatus': JobStatus,
      'BillNo': BillNo,
      'BillDate': BillDate,
      'BillTime': BillTime,
      'SaleType': SaleType,
      'CustomerName': CustomerName,
      'EmployeeName': EmployeeName,
      'CashierName': CashierName,
      'Remarks': Remarks,
      'Origin': Origin,
      'Destination': Destination,
      'SPickupDate': SPickupDate,
      'ETA': ETA,
      'SETA': SETA,
      'SETB': SETB,
      'SOETA': SOETA,
      'SOETB': SOETB,
      'SPort': SPort,
      'FlighTime': FlighTime,
      'Offvesselname': Offvesselname,
      'Loadingvesselname': Loadingvesselname,
      'JobMasterRefId': JobMasterRefId,
      'NetAmt': NetAmt,
    };
  }

  SaleOrderMasterModel.Empty()
      : Id = 0,
        CompanyRefId = 0,
        BillNoDisplay = '',
        JobStatus = '',
        BillNo = 0,
        BillDate = '',
        BillTime = '',
        SaleType = '',
        CustomerName = '',
        EmployeeName = '',
        CashierName = '',
        Remarks = '',
        Origin = '',
        Destination = '',
        SPickupDate = '',
        ETA = '',
        isETASelected = false,
        SETA = '',
        SETB = '',
        SOETA = '',
        SOETB = '',
        SPort = '',
        FlighTime = '',
        Offvesselname = '',
        Loadingvesselname = '',
        JobMasterRefId = 0,
        NetAmt = 0.0;
}