import 'package:dio/dio.dart';
import 'package:maleva/core/lookups/master_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// Customer pickers, from the shared Java `GET /api/customers/options` (the
/// port of .NET CustomerApp/GetCustomer; change `lookups-on-shared-java-api`):
/// the company's active customers by name, `{id, customerName, companyCode,
/// label}` where `label` is the name with its code.
class CustomerApi {
  CustomerApi(this._dio, {required int Function() companyId}) : _companyId = companyId;

  final Dio _dio;
  final int Function() _companyId;

  Future<List<Map<String, dynamic>>> options() async => JsonRead.listOfMaps(await MasterResponse.data(
      () => _dio.get<dynamic>('/api/customers/options', queryParameters: {'companyId': _companyId()})));
}
