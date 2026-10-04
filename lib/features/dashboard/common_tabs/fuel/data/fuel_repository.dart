import 'package:get_it/get_it.dart';
import 'package:maleva/core/fuel/fuel_entry_api.dart';
import 'package:maleva/features/transport/models/fuelselect_model.dart';

/// The Fuel Difference report's rows, from the shared Java `/api/fuel-entries`
/// (change `fuel-entry-on-shared-java-api`).
class FuelRepository {
  FuelRepository({FuelEntryApi? api}) : _api = api ?? GetIt.instance<FuelEntryApi>();

  final FuelEntryApi _api;

  Future<List<FuelselectModel>> fetchFuelDifference({
    required String fromDate,
    required String toDate,
  }) async =>
      (await _api.list(fromDate: fromDate, toDate: toDate)).map(FuelselectModel.fromJava).toList();
}
