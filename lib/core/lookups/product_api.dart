import 'package:dio/dio.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// The product picker, from the shared Java
/// `GET /api/item-masters/company/{companyId}/products` (the port of .NET
/// ItemApp/GetProductList; change `product-lookups-on-shared-java-api`): the
/// company's active products by name, `{id, productName, productCode,
/// saleRate, purRate, mrp}`. That endpoint answers the list itself.
class ProductApi {
  ProductApi(this._dio, {required int Function() companyId}) : _companyId = companyId;

  final Dio _dio;
  final int Function() _companyId;

  Future<List<Map<String, dynamic>>> products() async {
    try {
      final response = await _dio.get<dynamic>('/api/item-masters/company/${_companyId()}/products');
      return JsonRead.listOfMaps(response.data);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }
}
