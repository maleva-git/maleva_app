import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// Truck spare parts, summon and spot sale entries (lists and saves), from the
/// shared Java APIs ported from .NET TruckSparePartsApp (change
/// `truck-entries-on-shared-java-api`).
/// Lists answer the Java rows as they are (camelCase: `truckName`,
/// `entryDate`, `documentPath`, ...); a refusal is an [ApiFailure] with the
/// server's message. For a driver token the summon list is the truck on the
/// driver's record.
class TruckEntriesApi {
  TruckEntriesApi(this._dio, {required int Function() companyId}) : _companyId = companyId;

  final Dio _dio;
  final int Function() _companyId;

  int get companyId => _companyId();

  /// Spare parts entries dated in the days (`yyyy-MM-dd`): `id, truckId,
  /// truckName, spareParts, amount, documentPath, entryDate`.
  Future<List<Map<String, dynamic>>> spareParts({required String fromDate, required String toDate}) =>
      _list('/api/truck-spare-parts/entries', fromDate, toDate);

  /// Summons dated in the days: `id, truckId, truckName, summon, country,
  /// portPass, truckLcnMnt, levy, fuel, amount, documentPath, entryDate`.
  Future<List<Map<String, dynamic>>> summons({required String fromDate, required String toDate}) =>
      _list('/api/summons/entries', fromDate, toDate);

  /// Spot sale entries created in the days: `id, vehicleName, jobMasterRefId,
  /// jStatus, port, customerName, jobType, employeeName, awbNo, quantity,
  /// totalWeight, statusName, documentPath`.
  Future<List<Map<String, dynamic>>> spotSales({required String fromDate, required String toDate}) =>
      _list('/api/sport-sale-orders/entries', fromDate, toDate);

  /// Adds (id 0) or updates a spare parts entry with its documents; answers the id.
  Future<int> saveSpareParts({
    int id = 0,
    required int truckId,
    required String spareParts,
    required double amount,
    required String entryDate,
    String driverName = '',
    List<File> files = const [],
  }) =>
      _save('/api/truck-spare-parts/entries', {
        'id': id,
        'truckId': truckId,
        'driverName': driverName,
        'spareParts': spareParts,
        'amount': amount,
        'entryDate': entryDate,
      }, files);

  /// Adds (id 0) or updates a summon with its documents; answers the id. For
  /// a driver the server uses the truck on their record.
  Future<int> saveSummon({
    int id = 0,
    required int truckId,
    required String summon,
    required String country,
    required String portPass,
    required String truckLcnMnt,
    required String levy,
    required String fuel,
    required double amount,
    required String entryDate,
    String driverName = '',
    List<File> files = const [],
  }) =>
      _save('/api/summons/entries', {
        'id': id,
        'truckId': truckId,
        'driverName': driverName,
        'summon': summon,
        'country': country,
        'portPass': portPass,
        'truckLcnMnt': truckLcnMnt,
        'levy': levy,
        'fuel': fuel,
        'amount': amount,
        'entryDate': entryDate,
      }, files);

  /// Adds (id 0) or updates a spot sale entry with its documents; answers the id.
  Future<int> saveSpotSale({
    int id = 0,
    required int jobTypeId,
    required int jobStatusId,
    required int employeeId,
    required String vehicleName,
    required String awbNo,
    required String quantity,
    required String totalWeight,
    required String port,
    int customerId = 0,
    List<File> files = const [],
  }) =>
      _save('/api/sport-sale-orders/entries', {
        'id': id,
        'customerRefId': customerId,
        'jobMasterRefId': jobTypeId,
        'employeeRefId': employeeId,
        'jStatus': jobStatusId,
        'awbNo': awbNo,
        'quantity': quantity,
        'totalWeight': totalWeight,
        'vehicleName': vehicleName,
        'port': port,
      }, files);

  /// A multipart save: `entry` as a JSON part and one `files` part per document.
  Future<int> _save(String path, Map<String, dynamic> entry, List<File> files) async {
    final form = FormData();
    form.files.add(MapEntry('entry', MultipartFile.fromString(jsonEncode(entry), contentType: DioMediaType('application', 'json'))));
    for (final f in files) {
      form.files.add(MapEntry('files', await MultipartFile.fromFile(f.path, filename: f.uri.pathSegments.last)));
    }
    return JsonRead.integer(await _send(() => _dio.post<dynamic>(path, queryParameters: {'companyId': companyId}, data: form)));
  }

  Future<List<Map<String, dynamic>>> _list(String path, String fromDate, String toDate) async =>
      JsonRead.listOfMaps(await _send(() => _dio.get<dynamic>(path, queryParameters: {
            'companyId': companyId,
            'fromDate': _dateOnly(fromDate),
            'toDate': _dateOnly(toDate),
          })));

  static String _dateOnly(String v) => v.trim().length >= 10 ? v.trim().substring(0, 10) : v.trim();

  Future<dynamic> _send(Future<Response<dynamic>> Function() call) async {
    try {
      return JavaResponse.data((await call()).data);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }
}
