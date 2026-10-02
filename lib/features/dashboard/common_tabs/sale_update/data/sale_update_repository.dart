import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/sale_order/sale_order_api.dart';
import '../models/sale_order_update_model.dart';

/// Sale update (trip remarks, origin, destination), on the shared Java
/// `GET /api/sale-orders/trips` and `PUT /api/sale-orders/{id}/trip`
/// (ported from .NET `SearchSaleOrderForUpdate` / `UpdateSaleOrderFields`).
class SaleUpdateRepository {
  SaleUpdateRepository({SaleOrderApi? saleOrders}) : _saleOrderApi = saleOrders;

  final SaleOrderApi? _saleOrderApi;
  SaleOrderApi get _saleOrders => _saleOrderApi ?? sl<SaleOrderApi>();

  Future<List<SaleOrderUpdateModel>> searchSaleOrders({
    required DateTime fromDate,
    required DateTime toDate,
    required int customerId,
  }) async =>
      [for (final row in await _saleOrders.trips(from: fromDate, to: toDate, customerId: customerId)) SaleOrderUpdateModel.fromJava(row)];

  Future<void> updateSaleOrderFields({
    required int id,
    required String remarks1,
    required String origin,
    required String destination,
  }) =>
      _saleOrders.updateTrip(id, remarks1: remarks1, origin: origin, destination: destination);
}
