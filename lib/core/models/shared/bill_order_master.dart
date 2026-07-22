
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

  factory BillOrderMaster.fromJson(Map<String, dynamic> json) {
    return BillOrderMaster(
      id: int.tryParse(json['Id']?.toString() ?? '') ?? 0,
      billNoDisplay: json['BillNoDisplay']?.toString() ?? '',
      billNoDisplay1: json['BillNoDisplay1']?.toString() ?? '',
      billNo: int.tryParse(json['BillNo']?.toString() ?? '') ?? 0,
      pStatus: int.tryParse(json['PStatus']?.toString() ?? '') ?? 0,
      billDate: json['BillDate']?.toString() ?? '',
      invoiceNo: json['InvoiceNo']?.toString() ?? '',
      invoiceDate: json['InvoiceDate']?.toString() ?? '',
      billTime: json['BillTime']?.toString() ?? '',
      saleType: json['SaleType']?.toString() ?? '',
      supplierName: json['SupplierName']?.toString() ?? '',
      employeeName: json['EmployeeName']?.toString() ?? '',
      cashierName: json['CashierName']?.toString(),
      truckName: json['TruckName']?.toString() ?? '',
      driverName: json['DriverName']?.toString() ?? '',
      billStatus: json['BillStatus']?.toString() ?? '',
      description: json['Description']?.toString() ?? '',
      remarks: json['Remarks']?.toString(),
      netAmt: double.tryParse(json['NetAmt']?.toString() ?? '') ?? 0.0,
    );
  }
}