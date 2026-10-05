import 'package:maleva/core/fleet/gps_api.dart';
import 'package:maleva/core/utils/json_read.dart';


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

  /// A row of the shared Java `/api/gps/engine-hours`; the times shown as
  /// .NET showed them (`dd/MM/yyyy HH:mm:ss`), the raw ones kept in D*.
  EngineHoursdata.fromJava(Map<String, dynamic> json)
      : Id = JsonRead.integer(json['id']),
        DbeginTime = JsonRead.string(json['beginTime']),
        DendTime = JsonRead.string(json['endTime']),
        TruckName = JsonRead.string(json['truckName']),
        beginTime = GpsApi.display(json['beginTime']),
        endTime = GpsApi.display(json['endTime']),
        beginLocation = JsonRead.string(json['beginLocation']),
        endLocation = JsonRead.string(json['endLocation']),
        totalTime = JsonRead.string(json['totalTime']),
        inMotion = JsonRead.string(json['inMotion']),
        idling = JsonRead.string(json['idling']),
        mileage = JsonRead.string(json['mileage']),
        consumedbyFLSinidlerun = JsonRead.string(json['consumedByFlsInIdleRun']);

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