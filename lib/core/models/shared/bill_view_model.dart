import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

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

  /// ✅ Create from JSON
  factory BillViewModel.fromJson(Map<String, dynamic> json) {
    return BillViewModel(
      Id: json['Id'] ?? 0,
      BillNoDisplay: json['BillNoDisplay'] ?? "",
      BillNoDisplay1: json['BillNoDisplay1'] ?? "",
      BillNo: json['BillNo'] ?? 0,
      PStatus: json['PStatus'] ?? 0,
      Fileupload: json['Fileupload'] ?? 0,
      BillDate: json['BillDate'] ?? "",
      InvoiceNo: json['InvoiceNo'] ?? "",
      InvoiceDate: json['InvoiceDate'] ?? "",
      BillTime: json['BillTime'] ?? "",
      SaleType: json['SaleType'] ?? "",
      SupplierName: json['SupplierName'] ?? "",
      EmployeeName: json['EmployeeName'] ?? "",
      CashierName: json['CashierName'],
      TruckName: json['TruckName'] ?? "",
      DriverName: json['DriverName'] ?? "",
      BillStatus: json['BillStatus'],
      Description: json['Description'],
      Remarks: json['Remarks'],
      NetAmt: (json['NetAmt'] ?? 0).toDouble(),
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