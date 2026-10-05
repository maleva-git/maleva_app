import 'package:maleva/core/utils/json_read.dart';


class BillViewModel {
  int Id;
  String BillNoDisplay;
  String BillNoDisplay1;
  int BillNo;
  int PStatus;
  int Fileupload;
  String BillDate;
  String InvoiceNo;
  String InvoiceDate;
  String BillTime;
  String SaleType;
  String SupplierName;
  String EmployeeName;
  String? CashierName;
  String TruckName;
  String DriverName;
  String? BillStatus;
  String? Description;
  String? Remarks;
  double NetAmt;

  BillViewModel({
    required this.Id,
    required this.BillNoDisplay,
    required this.BillNoDisplay1,
    required this.BillNo,
    required this.PStatus,
    required this.Fileupload,
    required this.BillDate,
    required this.InvoiceNo,
    required this.InvoiceDate,
    required this.BillTime,
    required this.SaleType,
    required this.SupplierName,
    required this.EmployeeName,
    this.CashierName,
    required this.TruckName,
    required this.DriverName,
    this.BillStatus,
    this.Description,
    this.Remarks,
    required this.NetAmt,
  });

  /// A row of the shared Java `/api/bills-order/select-bills-order`.
  factory BillViewModel.fromJava(Map<String, dynamic> json) {
    dynamic f(String k) => JsonRead.field(json, k);
    return BillViewModel(
      Id: JsonRead.integer(f('id')),
      BillNoDisplay: JsonRead.string(f('billNoDisplay')),
      BillNoDisplay1: JsonRead.string(f('billNoDisplay1')),
      BillNo: JsonRead.integer(f('billNo')),
      PStatus: JsonRead.integer(f('pStatus')),
      Fileupload: JsonRead.integer(f('fileupload')),
      BillDate: JsonRead.string(f('billDate')),
      InvoiceNo: JsonRead.string(f('invoiceNo')),
      InvoiceDate: JsonRead.string(f('invoiceDate')),
      BillTime: JsonRead.string(f('billTime')),
      SaleType: JsonRead.string(f('saleType')),
      SupplierName: JsonRead.string(f('supplierName')),
      EmployeeName: JsonRead.string(f('employeeName')),
      TruckName: JsonRead.string(f('truckName')),
      DriverName: JsonRead.string(f('driverName')),
      BillStatus: JsonRead.stringOrNull(f('billStatus')),
      Description: JsonRead.stringOrNull(f('description')),
      NetAmt: JsonRead.number(f('netAmt')),
    );
  }

  /// ✅ Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'BillNoDisplay': BillNoDisplay,
      'BillNoDisplay1': BillNoDisplay1,
      'BillNo': BillNo,
      'PStatus': PStatus,
      'Fileupload': Fileupload,
      'BillDate': BillDate,
      'InvoiceNo': InvoiceNo,
      'InvoiceDate': InvoiceDate,
      'BillTime': BillTime,
      'SaleType': SaleType,
      'SupplierName': SupplierName,
      'EmployeeName': EmployeeName,
      'CashierName': CashierName,
      'TruckName': TruckName,
      'DriverName': DriverName,
      'BillStatus': BillStatus,
      'Description': Description,
      'Remarks': Remarks,
      'NetAmt': NetAmt,
    };
  }

  /// ✅ Empty constructor (optional)
  BillViewModel.Empty()
      : Id = 0,
        BillNoDisplay = "",
        BillNoDisplay1 = "",
        BillNo = 0,
        PStatus = 0,
        Fileupload = 0,
        BillDate = "",
        InvoiceNo = "",
        InvoiceDate = "",
        BillTime = "",
        SaleType = "",
        SupplierName = "",
        EmployeeName = "",
        CashierName = null,
        TruckName = "",
        DriverName = "",
        BillStatus = null,
        Description = null,
        Remarks = null,
        NetAmt = 0.0;
}