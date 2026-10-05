import 'package:get_it/get_it.dart';
import 'package:maleva/core/fleet/expiry_api.dart';
import 'package:maleva/core/models/shared/truck_details_model.dart';

/// Truck Details: the trucks with a date due by [until], from the shared Java
/// expiry list (change `master-reports-on-shared-java-api`).
class TruckRepository {
  Future<List<TruckDetailsModel>> fetchTruckDetails({required DateTime until}) async =>
      (await GetIt.instance<ExpiryApi>().trucks(until: until)).map(TruckDetailsModel.fromJavaExpiry).toList();
}
