import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class SpeedingView {
  int Id;
  String truckName;
  String vehicle;
  String time;
  String dtime;
  String location;
  String count;
  String filled;
  String driver ;
  SpeedingView(this.Id, this.truckName, this.vehicle, this.time,this.dtime, this.location ,this.count,this.filled,this.driver);

  SpeedingView.fromJson(Map<String, dynamic> json)
      : Id = int.tryParse(json['Id'].toString()) ?? 0,
        truckName = json['truckName']?.toString() ?? '',
        time = json['time']?.toString() ?? '',
        vehicle = json['vehicle']?.toString() ?? '',
        dtime = json['dtime']?.toString() ?? '',
        location = json['location']?.toString() ?? '',
        count = json['count']?.toString() ?? '',
        filled = json['filled']?.toString() ?? '',
        driver = json['driver']?.toString() ?? '';
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'truckName': truckName,
      'time': time,
      'vehicle': vehicle,
      'dtime': dtime,
      'location': location,
      'count': count,
      'filled': filled,
      'driver': driver,
    };
  }

  SpeedingView.Empty()
      : Id = 0,
        truckName = '',
        time = '',
        vehicle = '',
        dtime = '',
        location = '',
        count = '',
        filled = '',
        driver = '';
}