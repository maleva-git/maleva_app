import 'package:maleva/core/fleet/truck_entries_api.dart';
import 'package:maleva/core/network/legacy_api_repository.dart';
import 'package:maleva/core/di/injection.dart';
import 'dart:io';


class SummonRepository {
  /// Loads the global truck list
  Future<void> fetchTrucks() async {
    // We pass null for context so it safely runs in the background
    await sl<LegacyApiRepository>().SelectTruckList(null, null);}

  /// Summons dated in the days, from the shared Java API (the Java rows; a
  /// driver gets the truck on their record).
  Future<List<Map<String, dynamic>>> fetchSummonRecords({
    required String fromDate,
    required String toDate,
  }) =>
      sl<TruckEntriesApi>().summons(fromDate: fromDate, toDate: toDate);

  /// Adds a summon with its image and PDF (Java port of SP_Summon; for a
  /// driver the server uses the truck on their record). Answers the id.
  Future<int> submitSummon({
    required int truckId,
    required String summon,
    required String country,
    required String portPass,
    required String truckLcnMnt,
    required String levy,
    required String fuel,
    required double amount,
    required String entryDate,
    File? image,
    File? pdf,
  }) =>
      sl<TruckEntriesApi>().saveSummon(
        truckId: truckId,
        summon: summon,
        country: country,
        portPass: portPass,
        truckLcnMnt: truckLcnMnt,
        levy: levy,
        fuel: fuel,
        amount: amount,
        entryDate: entryDate,
        files: [if (image != null) image, if (pdf != null) pdf],
      );
}
