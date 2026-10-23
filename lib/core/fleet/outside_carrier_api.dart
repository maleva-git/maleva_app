import 'package:dio/dio.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// A subcontractor's truck number (fleet D2): `OutsideVehicleDto` of the shared Java API.
class OutsideVehicle {
  const OutsideVehicle({required this.id, required this.plateNo, this.sizeClass, this.existing = false});

  final int id;
  final String plateNo;
  final String? sizeClass;

  /// The add found the number already in the list.
  final bool existing;

  factory OutsideVehicle.fromJava(Map<String, dynamic> m) => OutsideVehicle(
        id: JsonRead.integer(JsonRead.field(m, 'id')),
        plateNo: JsonRead.string(JsonRead.field(m, 'plateNo')),
        sizeClass: JsonRead.stringOrNull(JsonRead.field(m, 'sizeClass')),
        existing: JsonRead.boolean(JsonRead.field(m, 'existing')),
      );
}

/// An outside driver (fleet D2). Personal data (mobile, IC / passport): shown on screen only, never logged.
class OutsideDriver {
  const OutsideDriver({required this.id, required this.name, required this.mobileNo, this.existing = false});

  final int id;
  final String name;
  final String mobileNo;
  final bool existing;

  factory OutsideDriver.fromJava(Map<String, dynamic> m) => OutsideDriver(
        id: JsonRead.integer(JsonRead.field(m, 'id')),
        name: JsonRead.string(JsonRead.field(m, 'driverName')),
        mobileNo: JsonRead.string(JsonRead.field(m, 'mobileNo')),
        existing: JsonRead.boolean(JsonRead.field(m, 'existing')),
      );

  @override
  String toString() => 'OutsideDriver($id)';
}

/// Outside truck numbers and outside drivers, from the shared Java API the web uses (fleet D2,
/// backend `OutsideCarrierController`; app change `d2-carrier-by-id`):
/// - `GET /api/outside-vehicles?companyId&truckRefId` — one subcontractor's truck numbers;
/// - `POST /api/outside-vehicles?companyId` `{truckMasterRefId, plateNo, sizeClass}` — returns the one already there
///   (`existing`) or refuses a number under another company with its name;
/// - `GET /api/outside-drivers?companyId`, `POST /api/outside-drivers?companyId`
///   `{driverName, mobileNo, idType, idNo}`.
/// The company comes from the sign-in on the server; a refusal is an [ApiFailure] with the server's message.
class OutsideCarrierApi {
  OutsideCarrierApi(this._dio, {required int Function() companyId}) : _companyId = companyId;

  final Dio _dio;
  final int Function() _companyId;

  /// Sizes of the shared truck size list (`TruckSizeClass`).
  static const sizeClasses = ['1TON', '3TON', '5TON', '10TON', '20FT', '40FT', 'SPECIAL'];

  Future<List<OutsideVehicle>> vehicles(int truckRefId) async => JsonRead.listOfMaps(JavaResponse.data(await _call(() =>
          _dio.get<dynamic>('/api/outside-vehicles', queryParameters: {'companyId': _companyId(), 'truckRefId': truckRefId}))))
      .map(OutsideVehicle.fromJava)
      .toList();

  Future<OutsideVehicle> addVehicle({required int truckRefId, required String plateNo, required String sizeClass}) async =>
      OutsideVehicle.fromJava(JsonRead.map(JavaResponse.data(await _call(() => _dio.post<dynamic>('/api/outside-vehicles',
          queryParameters: {'companyId': _companyId()},
          data: {'truckMasterRefId': truckRefId, 'plateNo': plateNo, 'sizeClass': sizeClass})))));

  Future<List<OutsideDriver>> drivers() async => JsonRead.listOfMaps(JavaResponse.data(await _call(() =>
          _dio.get<dynamic>('/api/outside-drivers', queryParameters: {'companyId': _companyId()}))))
      .map(OutsideDriver.fromJava)
      .toList();

  Future<OutsideDriver> addDriver({required String name, required String mobileNo, String? idType, String? idNo}) async =>
      OutsideDriver.fromJava(JsonRead.map(JavaResponse.data(await _call(() => _dio.post<dynamic>('/api/outside-drivers',
          queryParameters: {'companyId': _companyId()},
          data: {
            'driverName': name,
            'mobileNo': mobileNo,
            if (idNo != null && idNo.trim().isNotEmpty) 'idType': idType,
            if (idNo != null && idNo.trim().isNotEmpty) 'idNo': idNo,
          })))));

  Future<dynamic> _call(Future<Response<dynamic>> Function() call) async {
    try {
      return (await call()).data;
    } on DioException catch (e) {
      final body = e.response?.data;
      if (body is String && body.trim().isNotEmpty) {
        throw ApiFailure(body.trim().replaceFirst(RegExp(r'^Error:\s*'), ''), statusCode: e.response?.statusCode);
      }
      throw JavaResponse.fromDio(e);
    }
  }
}
