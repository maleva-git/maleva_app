import 'package:maleva/core/fleet/gps_api.dart';
import 'package:maleva/core/utils/json_read.dart';


class FuelFilling {
  int Id;
  String truckName;
  String vehicle;
  String time;
  String dtime;
  String location;
  String count;
  String filled;
  String driver ;
  FuelFilling(this.Id, this.truckName, this.vehicle, this.time,this.dtime, this.location ,this.count,this.filled,this.driver);

  /// A row of the shared Java GPS list; the time shown as .NET showed it
  /// (`dd/MM/yyyy HH:mm:ss`), the raw one kept in [dtime].
  FuelFilling.fromJava(Map<String, dynamic> json)
      : Id = JsonRead.integer(json['id']),
        truckName = JsonRead.string(json['truckName']),
        time = GpsApi.display(json['time']),
        vehicle = JsonRead.string(json['vehicle']),
        dtime = JsonRead.string(json['time']),
        location = JsonRead.string(json['location']),
        count = JsonRead.string(json['count']),
        filled = JsonRead.string(json['filled']),
        driver = JsonRead.string(json['driver']);

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

  FuelFilling.Empty()
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