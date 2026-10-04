import 'package:get_it/get_it.dart';
import 'package:maleva/core/fuel/fuel_entry_api.dart';
import 'package:maleva/core/utils/json_read.dart';
import '../models/fuelentry_model.dart';

abstract class FuelEntryRepository {
  Future<List<FuelEntryModel>> getFuelEntries(String fromDate, String toDate);
  Future<bool> saveFuelEntry(FuelEntryModel model);
  Future<bool> deleteFuelEntry(int id);
}

/// The maintenance dashboard's fuel entries, on the shared Java
/// `/api/fuel-entries` (change `fuel-entry-on-shared-java-api`).
class FuelEntryRepositoryImpl implements FuelEntryRepository {
  FuelEntryRepositoryImpl({FuelEntryApi? api}) : _api = api ?? GetIt.instance<FuelEntryApi>();

  final FuelEntryApi _api;

  @override
  Future<List<FuelEntryModel>> getFuelEntries(String fromDate, String toDate) async {
    final rows = await _api.list(fromDate: fromDate, toDate: toDate);
    // the list holds active entries only; FStatus 2 rows stay hidden, as before
    return rows
        .where((r) => JsonRead.integer(JsonRead.field(r, 'fStatus')) != 2)
        .map(FuelEntryModel.fromJava)
        .toList();
  }

  @override
  Future<bool> saveFuelEntry(FuelEntryModel model) async {
    await _api.save(model.toJava());
    return true;
  }

  @override
  Future<bool> deleteFuelEntry(int id) async {
    await _api.delete(id);
    return true;
  }
}
