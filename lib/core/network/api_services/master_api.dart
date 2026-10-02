// core/network/api_services/master_api.dart
// Master data — Customer, Employee, Location, JobType, Truck, Driver, etc.
// Multiple BLoC pages same master data use pannuvanga —
// so oru common class la vaichirukkom

import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/models/shared/employee_model.dart';
import 'package:maleva/core/models/shared/ware_house_model.dart';
import 'package:maleva/core/models/shared/location_model.dart';
import 'package:maleva/features/operations/models/job_status_model.dart';
import 'package:maleva/core/models/shared/get_truck_model.dart';

class MasterApi {
  MasterApi._();


  // ─── Location ─────────────────────────────────────────────────────────────
  static Future<List<LocationModel>> getLocations() async {
    final comid  = AppPreferences.getComid();
    final result = await ApiClient.postRequest(
      '${ApiConstants.apiSelectLocation}$comid', null,
    );
    return (result as List).map((e) => LocationModel.fromJson(e)).toList();
  }

  // ─── Employee ─────────────────────────────────────────────────────────────
  static Future<List<EmployeeModel>> getEmployees({
    String type  = '',
    String type1 = '',
  }) async {
    final comid  = AppPreferences.getComid();
    final result = await ApiClient.postRequest(
      '${ApiConstants.apiSelectEmployee}$comid&type=$type&type1=$type1', null,
    );
    return (result as List).map((e) => EmployeeModel.fromJson(e)).toList();
  }

  // ─── Job Status ───────────────────────────────────────────────────────────
  static Future<List<JobStatusModel>> getJobStatuses() async {
    final comid  = AppPreferences.getComid();
    final result = await ApiClient.postRequest(
      '${ApiConstants.apiSelectJobStatus}$comid', null,
    );
    return (result as List).map((e) => JobStatusModel.fromJson(e)).toList();
  }








  // ─── WareHouse / Port ─────────────────────────────────────────────────────
  static Future<List<WareHouseModel>> getWarehouses() async {
    final comid  = AppPreferences.getComid();
    final result = await ApiClient.postRequest(
      '${ApiConstants.apiWareHouseCombo}$comid', null,
    );
    final data = result as List;
    return data.map((e) => WareHouseModel.fromJson(e)).toList();
  }

  static Future<List<WareHouseModel>> getStockJobs() async {
    final comid  = AppPreferences.getComid();
    final result = await ApiClient.postRequest(
      '${ApiConstants.apiSelectStockJob}$comid', null,
    );
    final data = result['Data1'] as List;
    return data.map((e) => WareHouseModel.fromJson(e)).toList();
  }

  // ─── Truck ────────────────────────────────────────────────────────────────
  static Future<List<GetTruckModel>> getTrucks() async {
    final comid  = AppPreferences.getComid();
    final result = await ApiClient.postRequest(
      '${ApiConstants.apiGetTruckList}$comid&type=', null,
    );
    return (result as List).map((e) => GetTruckModel.fromJson(e)).toList();
  }


  // ─── Driver ───────────────────────────────────────────────────────────────
  static Future<List<GetTruckModel>> getDrivers() async {
    final comid  = AppPreferences.getComid();
    final result = await ApiClient.postRequest(
      '${ApiConstants.apiGetDriverList}$comid&type=', null,
    );
    return (result as List).map((e) => GetTruckModel.fromJson(e)).toList();
  }
}