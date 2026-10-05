import 'package:maleva/core/fleet/truck_entries_api.dart';
import 'package:maleva/core/network/legacy_api_repository.dart';
import 'package:maleva/core/di/injection.dart';
import 'dart:io';


class SparePartsRepository {
  /// Loads the global truck list
  Future<void> fetchTrucks() async {
    // We pass null for context so it safely runs in the background
    await sl<LegacyApiRepository>().SelectTruckList(null, null);}

  /// Spare parts entries dated in the days, from the shared Java API (the Java rows).
  Future<List<Map<String, dynamic>>> fetchSparePartsRecords({
    required String fromDate,
    required String toDate,
  }) =>
      sl<TruckEntriesApi>().spareParts(fromDate: fromDate, toDate: toDate);

  /// Adds a spare parts entry with its image and PDF (Java port of
  /// SP_TruckSpareParts; the documents are stored with the entry).
  Future<int> submitSpareParts({
    required int truckId,
    required String spareParts,
    required double amount,
    required String entryDate,
    File? image,
    File? pdf,
  }) =>
      sl<TruckEntriesApi>().saveSpareParts(
        truckId: truckId,
        spareParts: spareParts,
        amount: amount,
        entryDate: entryDate,
        files: [if (image != null) image, if (pdf != null) pdf],
      );
}
