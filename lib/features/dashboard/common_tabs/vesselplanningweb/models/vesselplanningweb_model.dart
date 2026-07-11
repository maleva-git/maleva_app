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

  static String _parseString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  factory VesselPlanningWebModel.fromJson(Map<String, dynamic> json) {
    return VesselPlanningWebModel(
      id: _parseInt(json['Id']),
      saleOrderMasterRefId: _parseInt(json['SaleOrderMasterRefId']),
      origin: _parseString(json['Origin']),
      destination: _parseString(json['Destination']),
      jobNo: _parseString(json['JobNo']),
      jobDate: _parseString(json['JobDate']),
      jobStatus: _parseString(json['JobStatus']),
      deta: _parseString(json['DETA']),
      seta: _parseString(json['SETA']),
      eta: _parseString(json['ETA']),
      setb: _parseString(json['SETB']),
      etb: _parseString(json['ETB']),
      setd: _parseString(json['SETD']),
      etd: _parseString(json['ETD']),
      soeta: _parseString(json['SOETA']),
      oeta: _parseString(json['OETA']),
      soetb: _parseString(json['SOETB']),
      oetb: _parseString(json['OETB']),
      soetd: _parseString(json['SOETD']),
      oetd: _parseString(json['OETD']),
      spickupDate: _parseString(json['SPickupDate']),
      pickupDate: _parseString(json['PickupDate']),
      sdeliveryDate: _parseString(json['SDeliveryDate']),
      deliveryDate: _parseString(json['DeliveryDate']),
      sWareHouseEnterDate: _parseString(json['SWareHouseEnterDate']),
      wareHouseEnterDate: _parseString(json['WareHouseEnterDate']),
      sWareHouseExitDate: _parseString(json['SWareHouseExitDate']),
      wareHouseExitDate: _parseString(json['WareHouseExitDate']),
      wareHouseAddress: _parseString(json['WareHouseAddress']),
      pkg: _parseString(json['pkg']),
      loadingvesselname: _parseString(json['Loadingvesselname']),
      blCopy: _parseString(json['BLCopy']),
      truckSize: _parseString(json['TruckSize']),
      scn: _parseString(json['SCN']),
      lscn: _parseString(json['LSCN']),
      offvesselname: _parseString(json['Offvesselname']),
      commodity: _parseString(json['Commodity']),
      vessel: _parseString(json['Vessel']),
      oVessel: _parseString(json['OVessel']),
      sPort: _parseString(json['SPort']),
      oPort: _parseString(json['OPort']),
      jobName: _parseString(json['JobName']),
      awbNo: _parseString(json['AWBNo']),
      remarks1: _parseString(json['Remarks1']),
      cargo: _parseString(json['Cargo']),
      ptw: _parseString(json['PTW']),
      zb: _parseString(json['ZB']),
      zb2: _parseString(json['ZB2']),
      zbRef: _parseString(json['ZBRef']),
      zbRef2: _parseString(json['ZBRef2']),
      portCharges: _parseString(json['PortCharges']),
      portChargesRef: _parseString(json['PortChargesRef']),
      agentName: _parseString(json['AgentName']),
      agentPhone: _parseString(json['AgentPhone']),
      oAgentName: _parseString(json['OAgentName']),
      oAgentPhone: _parseString(json['OAgentPhone']),
      boardingOfficerRefid: _parseInt(json['BoardingOfficerRefid']),
      boardingOfficerName: _parseString(json['BoardingOfficerName']),
      boardingOfficer1Refid: _parseInt(json['BoardingOfficer1Refid']),
      boardingOfficerName1: _parseString(json['BoardingOfficerName1']),
      boardingAmount: _parseDouble(json['BoardingAmount']),
      boardingAmount1: _parseDouble(json['BoardingAmount1']),
      customerName: _parseString(json['CustomerName']),
      employeeName: _parseString(json['EmployeeName']),
      remarks: _parseString(json['Remarks']),
      isChecked: false,
    );
  }
}
