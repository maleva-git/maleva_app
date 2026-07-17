import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:maleva/core/models/shared/pattycash_master_model.dart';
import 'package:maleva/core/models/shared/patty_cash_details_model.dart';

class PattycashView {
  List<PattycashMasterModel> pattycashMasterModel;
  List<PattyCashDetailsModel> pattyCashDetailsModel;

  PattycashView({
    required this.pattycashMasterModel,
    required this.pattyCashDetailsModel,
  });

  factory PattycashView.fromJson(Map<String, dynamic> json) {
    return PattycashView(
      pattycashMasterModel:
      (json['PattycashMasterModel'] as List<dynamic>)
          .map((e) => PattycashMasterModel.fromJson(e))
          .toList(),
      pattyCashDetailsModel:
      (json['PattyCashDetailsModel'] as List<dynamic>)
          .map((e) => PattyCashDetailsModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'PattycashMasterModel':
    pattycashMasterModel.map((e) => e.toJson()).toList(),
    'PattyCashDetailsModel':
    pattyCashDetailsModel.map((e) => e.toJson()).toList(),
  };
}