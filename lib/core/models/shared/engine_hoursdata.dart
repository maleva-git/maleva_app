import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class EngineHoursdata {
  int Id;
  String DbeginTime;
  String DendTime;
  String TruckName;
  String beginTime;
  String endTime;
  String beginLocation;
  String endLocation;
  String totalTime;
  String inMotion;
  String idling;
  String mileage;
  String consumedbyFLSinidlerun;
  EngineHoursdata(this.Id, this.DbeginTime, this.DendTime, this.TruckName,this.beginTime, this.endTime ,this.beginLocation,this.endLocation,this.totalTime,this.inMotion,this.idling,this.mileage,this.consumedbyFLSinidlerun);

  EngineHoursdata.fromJson(Map<String, dynamic> json)
      : Id = int.tryParse(json['Id'].toString()) ?? 0,
        DbeginTime = json['DbeginTime']?.toString() ?? '',
        DendTime = json['DendTime']?.toString() ?? '',
        TruckName = json['TruckName']?.toString() ?? '',
        beginTime = json['beginTime']?.toString() ?? '',
        endTime = json['endTime']?.toString() ?? '',
        beginLocation = json['beginLocation']?.toString() ?? '',
        endLocation = json['endLocation']?.toString() ?? '',
        totalTime = json['totalTime']?.toString() ?? '',
        inMotion = json['inMotion']?.toString() ?? '',
        idling = json['idling']?.toString() ?? '',
        mileage = json['mileage']?.toString() ?? '',
        consumedbyFLSinidlerun = json['consumedbyFLSinidlerun']?.toString() ?? '';

  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'DbeginTime': DbeginTime ,
      'DendTime': DendTime,
      'TruckName': TruckName,
      'beginTime': beginTime,
      'endTime': endTime,
      'beginLocation': beginLocation,
      'endLocation': endLocation,
      'totalTime': totalTime,
      'inMotion': inMotion,
      'idling': idling,
      'mileage': mileage,
      'consumedbyFLSinidlerun': consumedbyFLSinidlerun,
    };
  }

  EngineHoursdata.Empty()
      : Id = 0,
        DbeginTime = '',
        DendTime = '',
        TruckName = '',
        beginTime = '',
        endTime = '',
        beginLocation = '',
        endLocation = '',
        totalTime = '',
        inMotion = '',
        idling = '',
        mileage = '',
        consumedbyFLSinidlerun = '';
}