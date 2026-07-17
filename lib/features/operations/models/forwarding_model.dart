import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class ForwardingModel {
  int Id;
  int CNumber;
  String ForwardingEnterRef;
  String ForwardingEnterRef2;
  String ForwardingEnterRef3;

  ForwardingModel(this.Id, this.CNumber,this.ForwardingEnterRef, this.ForwardingEnterRef2, this.ForwardingEnterRef3);

  ForwardingModel.fromJson(Map<String, dynamic> json)
      : Id = int.tryParse(json['Id']?.toString() ?? '') ?? 0,
        CNumber = int.tryParse(json['CNumber']?.toString() ?? '') ?? 0,
        ForwardingEnterRef = json['ForwardingEnterRef'].toString(),
        ForwardingEnterRef2 = json['ForwardingEnterRef2'].toString(),
        ForwardingEnterRef3 = json['ForwardingEnterRef3'].toString();
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'CNumber': CNumber,
      'ForwardingEnterRef': ForwardingEnterRef,
      'ForwardingEnterRef2': ForwardingEnterRef2,
      'ForwardingEnterRef3': ForwardingEnterRef3,
    };
  }

  ForwardingModel.Empty()
      : Id = 0,
        CNumber = 0,
        ForwardingEnterRef = '',
        ForwardingEnterRef2 = '',
        ForwardingEnterRef3 = '';
}