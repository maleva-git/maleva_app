import 'package:get_it/get_it.dart';
import 'package:maleva/core/fleet/gps_api.dart';
import 'package:maleva/features/transport/models/fuel_filling.dart';

/// From the shared Java GPS list (change `master-reports-on-shared-java-api`).
class FuelFillingsRepository {
  Future<List<FuelFilling>> fetchFuelFillingReport({required DateTime fromDate, required DateTime toDate}) async =>
      (await GetIt.instance<GpsApi>().fuelFillings(fromDate, toDate)).map(FuelFilling.fromJava).toList();
}
