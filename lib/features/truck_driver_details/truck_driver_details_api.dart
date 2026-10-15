import 'package:dio/dio.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

import 'truck_driver_details_models.dart';

/// The shared Java `GET /api/truck-driver-details?companyId&truckId&driverId`
/// the web page uses. Employee token; the server keeps it to the company.
class TruckDriverDetailsApi {
  TruckDriverDetailsApi(this._dio, {required int Function() companyId}) : _companyId = companyId;

  final Dio _dio;
  final int Function() _companyId;

  Future<SheetVehicle?> vehicle(int truckId) async {
    final data = await _get({'truckId': truckId});
    final json = JsonRead.map(data['vehicle']);
    return json.isEmpty ? null : SheetVehicle.fromJava(json);
  }

  Future<SheetDriver?> driver(int driverId) async {
    final data = await _get({'driverId': driverId});
    final json = JsonRead.map(data['driver']);
    return json.isEmpty ? null : SheetDriver.fromJava(json);
  }

  Future<Map<String, dynamic>> _get(Map<String, dynamic> ids) async {
    try {
      final response = await _dio.get<dynamic>('/api/truck-driver-details',
          queryParameters: {'companyId': _companyId(), ...ids});
      return JsonRead.map(JavaResponse.data(response.data));
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }
}
