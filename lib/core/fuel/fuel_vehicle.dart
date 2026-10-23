import 'package:maleva/core/utils/json_read.dart';

/// A company vehicle the signed-in employee may enter fuel for, as the Java
/// `/api/fuel-vehicles/mine` answers it (`truckRefId`, `truckName`);
/// openspec change employee-fuel-vehicles.
class FuelVehicle {
  const FuelVehicle({required this.truckRefId, required this.truckName});

  factory FuelVehicle.fromJava(Map<String, dynamic> json) => FuelVehicle(
        truckRefId: JsonRead.integer(json['truckRefId']),
        truckName: JsonRead.string(json['truckName']).trim(),
      );

  final int truckRefId;
  final String truckName;
}
