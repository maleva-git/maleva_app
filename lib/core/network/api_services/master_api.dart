// core/network/api_services/master_api.dart
// Master data — Customer, Employee, Location, JobType, Truck, Driver, etc.
// Multiple BLoC pages same master data use pannuvanga —
// so oru common class la vaichirukkom

import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/utils/app_preferences.dart';

class MasterApi {
  MasterApi._();

  // ─── Customer ─────────────────────────────────────────────────────────────
  static Future<List<CustomerModel>> getCustomers() async {
    final comid  = AppPreferences.getComid();
    final result = await ApiClient.postRequest(
      '${ApiConstants.apiSelectCustomer}$comid', null,
    );
    return (result as List).map((e) => CustomerModel.fromJson(e)).toList();
  }

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

  // ─── Job Type ─────────────────────────────────────────────────────────────
  static Future<List<JobTypeModel>> getJobTypes() async {
    final comid  = AppPreferences.getComid();
    final result = await ApiClient.postRequest(
      '${ApiConstants.apiSelectJobType}$comid', null,
    );
    return (result as List).map((e) => JobTypeModel.fromJson(e)).toList();
  }

  // ─── All Job Status + Job Type Details (single API) ──────────────────────
  static Future<Map<String, dynamic>> getAllJobStatusDetails(int jobId) async {
    final comid  = AppPreferences.getComid();
    final result = await ApiClient.postRequest(
      '${ApiConstants.apiSelectAllJobStatus}$comid&Jobid=$jobId', null,
    );
    final list      = result as List;
    final statusDetails = list[0]['JobStatusDetails'] as List;
    final typeDetails   = list[0]['JobTypeDetails'] as List;
    return {
      'statuses': statusDetails.map((e) => JobAllStatusModel.fromJson(e)).toList(),
      'typeDetails': typeDetails.map((e) => JobTypeDetailsModel.fromJson(e)).toList(),
    };
  }

  // ─── Agent Company ────────────────────────────────────────────────────────
  static Future<List<AgentCompanyModel>> getAgentCompanies() async {
    final comid  = AppPreferences.getComid();
    final result = await ApiClient.postRequest(
      '${ApiConstants.apiSelectAgentCompany}$comid', null,
    );
    return (result as List).map((e) => AgentCompanyModel.fromJson(e)).toList();
  }

  // ─── Agent ────────────────────────────────────────────────────────────────
  static Future<List<AgentModel>> getAgents(int agentCompanyId) async {
    final comid  = AppPreferences.getComid();
    final result = await ApiClient.postRequest(
      '${ApiConstants.apiSelectAgentAll}$comid&Jobid=$agentCompanyId', null,
    );
    return (result as List).map((e) => AgentModel.fromJson(e)).toList();
  }

  // ─── Products ─────────────────────────────────────────────────────────────
  static Future<List<ProductModel>> getProducts() async {
    final comid  = AppPreferences.getComid();
    final result = await ApiClient.postRequest(
      '${ApiConstants.apiGetProductList}$comid', null,
    );
    return (result as List).map((e) => ProductModel.fromJson(e)).toList();
  }

  // ─── Address ──────────────────────────────────────────────────────────────
  static Future<List<dynamic>> getAddressList() async {
    final comid  = AppPreferences.getComid();
    final result = await ApiClient.postRequest(
      '${ApiConstants.apiSelectAddressList}$comid', null,
    );
    return result as List;
  }

  static Future<List<AddressDetailsModel>> getAddressDetails(String keyword) async {
    final comid  = AppPreferences.getComid();
    final result = await ApiClient.postRequest(
      '${ApiConstants.apiSelectAddressDetails}$comid&KeyWord=$keyword', null,
    );
    return (result as List).map((e) => AddressDetailsModel.fromJson(e)).toList();
  }

  // ─── WareHouse / Port ─────────────────────────────────────────────────────
  static Future<List<WareHouseModel>> getWarehouses() async {
    final comid  = AppPreferences.getComid();
    final result = await ApiClient.postRequest(
      '${ApiConstants.apiWareHouseCombo}$comid', null,
    );
    final data = result['Data1'] as List;
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

  static Future<List<TruckDetailsModel>> getTruckDetails({
    required int keyword,
    required String column,
  }) async {
    final comid  = AppPreferences.getComid();
    final result = await ApiClient.postRequest(
      '${ApiConstants.apiEditTruckDetails}$comid&Startindex=0&PageCount=0&Keyword=$keyword&Column=$column&type=',
      null,
    );
    return (result as List).map((e) => TruckDetailsModel.fromJson(e)).toList();
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