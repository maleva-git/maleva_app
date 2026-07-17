import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class PettyCashDetailsModel {
  int Id;
  int SDId;
  int PettyCashMasterRefId;
  String Notes;
  String Items;
  String Amount;

  PettyCashDetailsModel({
    required this.Id,
    required this.SDId,
    required this.PettyCashMasterRefId,
    required this.Notes,
    required this.Items,
    required this.Amount,
  });

  factory PettyCashDetailsModel.fromJson(Map<String, dynamic> json) {
    return PettyCashDetailsModel(
      Id: json['Id'] ?? 0,
      SDId: json['SDId'] ?? 0,
      PettyCashMasterRefId: json['PettyCashMasterRefId'] ?? 0,
      Notes: json['Notes'] ?? '',
      Items: json['Items'] ?? '',
      Amount: json['Amount'] ?? '0.00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'SDId': SDId,
      'PettyCashMasterRefId': PettyCashMasterRefId,
      'Notes': Notes,
      'Items': Items,
      'Amount': Amount,
    };
  }

  PettyCashDetailsModel.Empty()
      : Id = 0,
        SDId = 0,
        PettyCashMasterRefId = 0,
        Notes = '',
        Items = '',
        Amount = '0.00';
}