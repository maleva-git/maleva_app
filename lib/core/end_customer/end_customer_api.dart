import 'package:dio/dio.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// `EndCustomerDto`: the customer of our customer (Daikin on a CIVA job). `active` 1 is shown in lists.
class EndCustomer {
  const EndCustomer({required this.id, required this.name, this.active = 1});

  factory EndCustomer.fromJava(Map<String, dynamic> m) => EndCustomer(
        id: JsonRead.integer(m['id']),
        name: JsonRead.string(m['endCustomerName']),
        active: JsonRead.integer(m['active'], fallback: 1),
      );

  final int id;
  final String name;
  final int active;
}

/// End customers on the shared Java API (`/api/end-customers`, backend change
/// `sale-order-end-customer`; the same endpoints React uses). The company comes from the token.
/// Each failure arrives as an [ApiFailure] with the server's own message.
class EndCustomerApi {
  EndCustomerApi(this._dio);

  final Dio _dio;

  static const _base = '/api/end-customers';

  /// The customer's active end customers, by name.
  Future<List<EndCustomer>> forCustomer(int customerId) =>
      _send(() => _dio.get<dynamic>('$_base/customer/$customerId'))
          .then((d) => JsonRead.listOfMaps(d).map(EndCustomer.fromJava).toList());

  /// "Add new": the end customer of that name (made when missing), linked to the customer.
  Future<EndCustomer> quickAdd(int customerId, String name) =>
      _send(() => _dio.post<dynamic>('$_base/customer/$customerId/quick-add', data: {'endCustomerName': name.trim()}))
          .then((d) => EndCustomer.fromJava(JsonRead.map(d)));

  Future<dynamic> _send(Future<Response<dynamic>> Function() call) async {
    try {
      return JavaResponse.data((await call()).data);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }
}
