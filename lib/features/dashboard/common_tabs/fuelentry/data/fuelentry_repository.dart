
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import '../../../../../core/network/api_constants.dart';
import '../models/fuelentry_model.dart';

abstract class FuelEntryRepository {
  Future<List<FuelEntryModel>> getFuelEntries(String fromDate, String toDate);
  Future<bool> saveFuelEntry(FuelEntryModel model);
  Future<bool> deleteFuelEntry(int id);
}

class FuelEntryRepositoryImpl implements FuelEntryRepository {
  @override
  Future<List<FuelEntryModel>> getFuelEntries(String fromDate, String toDate) async {
    final comid = AppPreferences.getComid();
    final body = {
      "Comid": comid,
      "Fromdate": fromDate,
      "Todate": toDate
    };
    final result = await ApiClient.postRequest('${ApiConstants.port}/api/FuelEntryApp/SelectFuelEntry', body);
    if (result != null && result is List) {
      return result.map((e) => FuelEntryModel.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Future<bool> saveFuelEntry(FuelEntryModel model) async {
    final comid = AppPreferences.getComid();
    model.comid = comid;
    final body = [model.toJson()];
    final result = await ApiClient.postRequest('${ApiConstants.port}/api/FuelEntryApp/InsertFuelEntry', body, headers: {"Comid": comid.toString()});
    return result != null;
  }

  @override
  Future<bool> deleteFuelEntry(int id) async {
    final comid = AppPreferences.getComid();
    final result = await ApiClient.postRequest('${ApiConstants.port}/api/FuelEntryApp/DeleteFuelEntry?Id=$id&Comid=$comid&Mobile=1', null);
    return result != null;
  }
}
