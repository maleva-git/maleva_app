import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:maleva/core/models/shared/patty_cash_details_model.dart';

class PattycashMasterModel {
  int Id;
  int companyRefId;
  int employeeRefId;
  String? cNumberDisplay;
  String? employeeName;
  DateTime pettyCashDate;
  String? paymentStatus;
  int cNumber;
  int status;
  String? amount;
  List<PattyCashDetailsModel> pattyCashDetails;

  PattycashMasterModel({
    required this.Id,
    required this.companyRefId,
    required this.employeeRefId,
    this.cNumberDisplay,
    this.employeeName,
    required this.pettyCashDate,
    this.paymentStatus,
    required this.cNumber,
    required this.status,
    this.amount,
    required this.pattyCashDetails,
  });

  factory PattycashMasterModel.fromJson(Map<String, dynamic> json) {
    return PattycashMasterModel(
      Id: json['Id'],
      companyRefId: json['CompanyRefId'],
      employeeRefId: json['EmployeeRefId'],
      cNumberDisplay: json['CNumberDisplay'],
      employeeName: json['EmployeeName'],
      pettyCashDate: DateTime.parse(json['PettyCashDate']),
      paymentStatus: json['PaymentStatus'],
      cNumber: json['CNumber'],
      status: json['Status'],
      amount: json['Amount'],
      pattyCashDetails: json['PattyCashDetails'] != null
          ? (json['PattyCashDetails'] as List<dynamic>)
          .map((e) => PattyCashDetailsModel.fromJson(e))
          .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'Id': Id,
    'CompanyRefId': companyRefId,
    'EmployeeRefId': employeeRefId,
    'CNumberDisplay': cNumberDisplay,
    'EmployeeName': employeeName,
    'PettyCashDate': pettyCashDate.toIso8601String(),
    'PaymentStatus': paymentStatus,
    'CNumber': cNumber,
    'Status': status,
    'Amount': amount,
    'PattyCashDetails':
    pattyCashDetails.map((e) => e.toJson()).toList(),
  };
}