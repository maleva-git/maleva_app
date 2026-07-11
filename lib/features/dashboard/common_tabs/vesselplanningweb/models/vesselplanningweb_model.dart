class VesselPlanningWebModel {
  int id;
  int saleOrderMasterRefId;
  String origin;
  String destination;
  String jobNo;
  String jobDate;
  String jobStatus;
  String deta;
  String seta;
  String eta;
  String setb;
  String etb;
  String setd;
  String etd;
  String soeta;
  String oeta;
  String soetb;
  String oetb;
  String soetd;
  String oetd;
  String spickupDate;
  String pickupDate;
  String sdeliveryDate;
  String deliveryDate;
  String sWareHouseEnterDate;
  String wareHouseEnterDate;
  String sWareHouseExitDate;
  String wareHouseExitDate;
  String wareHouseAddress;
  String pkg;
  String loadingvesselname;
  String blCopy;
  String truckSize;
  String scn;
  String lscn;
  String offvesselname;
  String commodity;
  String vessel;
  String oVessel;
  String sPort;
  String oPort;
  String jobName;
  String awbNo;
  String remarks1;
  String cargo;
  String ptw;
  String zb;
  String zb2;
  String zbRef;
  String zbRef2;
  String portCharges;
  String portChargesRef;
  String agentName;
  String agentPhone;
  String oAgentName;
  String oAgentPhone;
  int boardingOfficerRefid;
  String boardingOfficerName;
  int boardingOfficer1Refid;
  String boardingOfficerName1;
  double boardingAmount;
  double boardingAmount1;
  String customerName;
  String employeeName;
  String remarks;
  bool isChecked;

  VesselPlanningWebModel({
    required this.id,
    required this.saleOrderMasterRefId,
    required this.origin,
    required this.destination,
    required this.jobNo,
    required this.jobDate,
    required this.jobStatus,
    required this.deta,
    required this.seta,
    required this.eta,
    required this.setb,
    required this.etb,
    required this.setd,
    required this.etd,
    required this.soeta,
    required this.oeta,
    required this.soetb,
    required this.oetb,
    required this.soetd,
    required this.oetd,
    required this.spickupDate,
    required this.pickupDate,
    required this.sdeliveryDate,
    required this.deliveryDate,
    required this.sWareHouseEnterDate,
    required this.wareHouseEnterDate,
    required this.sWareHouseExitDate,
    required this.wareHouseExitDate,
    required this.wareHouseAddress,
    required this.pkg,
    required this.loadingvesselname,
    required this.blCopy,
    required this.truckSize,
    required this.scn,
    required this.lscn,
    required this.offvesselname,
    required this.commodity,
    required this.vessel,
    required this.oVessel,
    required this.sPort,
    required this.oPort,
    required this.jobName,
    required this.awbNo,
    required this.remarks1,
    required this.cargo,
    required this.ptw,
    required this.zb,
    required this.zb2,
    required this.zbRef,
    required this.zbRef2,
    required this.portCharges,
    required this.portChargesRef,
    required this.agentName,
    required this.agentPhone,
    required this.oAgentName,
    required this.oAgentPhone,
    required this.boardingOfficerRefid,
    required this.boardingOfficerName,
    required this.boardingOfficer1Refid,
    required this.boardingOfficerName1,
    required this.boardingAmount,
    required this.boardingAmount1,
    required this.customerName,
    required this.employeeName,
    required this.remarks,
    this.isChecked = false,
  });

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  factory VesselPlanningWebModel.fromJson(Map<String, dynamic> json) {
    return VesselPlanningWebModel(
      id: _parseInt(json['Id']),
      saleOrderMasterRefId: _parseInt(json['SaleOrderMasterRefId']),
      origin: json['Origin'] ?? '',
      destination: json['Destination'] ?? '',
      jobNo: json['JobNo'] ?? '',
      jobDate: json['JobDate'] ?? '',
      jobStatus: json['JobStatus'] ?? '',
      deta: json['DETA'] ?? '',
      seta: json['SETA'] ?? '',
      eta: json['ETA'] ?? '',
      setb: json['SETB'] ?? '',
      etb: json['ETB'] ?? '',
      setd: json['SETD'] ?? '',
      etd: json['ETD'] ?? '',
      soeta: json['SOETA'] ?? '',
      oeta: json['OETA'] ?? '',
      soetb: json['SOETB'] ?? '',
      oetb: json['OETB'] ?? '',
      soetd: json['SOETD'] ?? '',
      oetd: json['OETD'] ?? '',
      spickupDate: json['SPickupDate'] ?? '',
      pickupDate: json['PickupDate'] ?? '',
      sdeliveryDate: json['SDeliveryDate'] ?? '',
      deliveryDate: json['DeliveryDate'] ?? '',
      sWareHouseEnterDate: json['SWareHouseEnterDate'] ?? '',
      wareHouseEnterDate: json['WareHouseEnterDate'] ?? '',
      sWareHouseExitDate: json['SWareHouseExitDate'] ?? '',
      wareHouseExitDate: json['WareHouseExitDate'] ?? '',
      wareHouseAddress: json['WareHouseAddress'] ?? '',
      pkg: json['pkg'] ?? '',
      loadingvesselname: json['Loadingvesselname'] ?? '',
      blCopy: json['BLCopy'] ?? '',
      truckSize: json['TruckSize'] ?? '',
      scn: json['SCN'] ?? '',
      lscn: json['LSCN'] ?? '',
      offvesselname: json['Offvesselname'] ?? '',
      commodity: json['Commodity'] ?? '',
      vessel: json['Vessel'] ?? '',
      oVessel: json['OVessel'] ?? '',
      sPort: json['SPort'] ?? '',
      oPort: json['OPort'] ?? '',
      jobName: json['JobName'] ?? '',
      awbNo: json['AWBNo'] ?? '',
      remarks1: json['Remarks1'] ?? '',
      cargo: json['Cargo'] ?? '',
      ptw: json['PTW'] ?? '',
      zb: json['ZB'] ?? '',
      zb2: json['ZB2'] ?? '',
      zbRef: json['ZBRef'] ?? '',
      zbRef2: json['ZBRef2'] ?? '',
      portCharges: json['PortCharges'] ?? '',
      portChargesRef: json['PortChargesRef'] ?? '',
      agentName: json['AgentName'] ?? '',
      agentPhone: json['AgentPhone'] ?? '',
      oAgentName: json['OAgentName'] ?? '',
      oAgentPhone: json['OAgentPhone'] ?? '',
      boardingOfficerRefid: _parseInt(json['BoardingOfficerRefid']),
      boardingOfficerName: json['BoardingOfficerName'] ?? '',
      boardingOfficer1Refid: _parseInt(json['BoardingOfficer1Refid']),
      boardingOfficerName1: json['BoardingOfficerName1'] ?? '',
      boardingAmount: _parseDouble(json['BoardingAmount']),
      boardingAmount1: _parseDouble(json['BoardingAmount1']),
      customerName: json['CustomerName'] ?? '',
      employeeName: json['EmployeeName'] ?? '',
      remarks: json['Remarks'] ?? '',
      isChecked: false,
    );
  }
}
