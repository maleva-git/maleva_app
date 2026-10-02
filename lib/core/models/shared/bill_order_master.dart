
class BillOrderMaster {
  final int id;
  final String billNoDisplay;
  final String billNoDisplay1;
  final int billNo;
  final int pStatus;
  final String billDate;
  final String invoiceNo;
  final String invoiceDate;
  final String billTime;
  final String saleType;
  final String supplierName;
  final String employeeName;
  final String? cashierName;
  final String truckName;
  final String driverName;
  final String billStatus;
  final String description;
  final String? remarks;
  final double netAmt;

  BillOrderMaster({
    required this.id,
    required this.billNoDisplay,
    required this.billNoDisplay1,
    required this.billNo,
    required this.pStatus,
    required this.billDate,
    required this.invoiceNo,
    required this.invoiceDate,
    required this.billTime,
    required this.saleType,
    required this.supplierName,
    required this.employeeName,
    this.cashierName,
    required this.truckName,
    required this.driverName,
    required this.billStatus,
    required this.description,
    this.remarks,
    required this.netAmt,
  });

  /// A row of the Java `POST /api/bills-order/select-bills-order-view` (camelCase).
  factory BillOrderMaster.fromJava(Map<String, dynamic> json) {
    return BillOrderMaster(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      billNoDisplay: json['billNoDisplay']?.toString() ?? '',
      billNoDisplay1: json['billNoDisplay1']?.toString() ?? '',
      billNo: int.tryParse(json['billNo']?.toString() ?? '') ?? 0,
      pStatus: int.tryParse(json['pStatus']?.toString() ?? '') ?? 0,
      billDate: json['billDate']?.toString() ?? '',
      invoiceNo: json['invoiceNo']?.toString() ?? '',
      invoiceDate: json['invoiceDate']?.toString() ?? '',
      billTime: json['billTime']?.toString() ?? '',
      saleType: json['saleType']?.toString() ?? '',
      supplierName: json['supplierName']?.toString() ?? '',
      employeeName: json['employeeName']?.toString() ?? '',
      cashierName: json['cashierName']?.toString(),
      truckName: json['truckName']?.toString() ?? '',
      driverName: json['driverName']?.toString() ?? '',
      billStatus: json['billStatus']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      remarks: json['remarks']?.toString(),
      netAmt: double.tryParse(json['netAmt']?.toString() ?? '') ?? 0.0,
    );
  }
}