import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class ForwardingSalaryModel {
  int id;
  String rtiNoDisplay;

  ForwardingSalaryModel({
    required this.id,
    required this.rtiNoDisplay,
  });

  factory ForwardingSalaryModel.fromJson(Map<String, dynamic> json) {
    return ForwardingSalaryModel(
      id: int.tryParse(json['Id'].toString()) ?? 0,
      rtiNoDisplay: json['RTINoDisplay']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'Id': id,
    'RTINoDisplay': rtiNoDisplay,
  };

  ForwardingSalaryModel.empty()
      : id = 0,
        rtiNoDisplay = '';
}