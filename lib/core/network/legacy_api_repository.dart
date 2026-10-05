import 'package:maleva/core/fleet/driver_api.dart';
import 'package:maleva/core/fleet/truck_api.dart';
import 'package:maleva/core/lookups/agent_api.dart';
import 'package:maleva/core/lookups/product_api.dart';
import 'dart:io';
import 'package:maleva/core/lookups/job_status_api.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/stock/stock_in_api.dart';
import 'package:maleva/core/rti/rti_api.dart';
import 'package:maleva/core/lookups/location_api.dart';
import 'package:maleva/core/lookups/customer_api.dart';
import 'package:maleva/core/lookups/job_type_api.dart';
import 'package:maleva/core/employee/employee_api.dart';
import 'package:get_it/get_it.dart';
import 'package:maleva/core/models/shared/agent_company_model.dart';
import 'package:maleva/features/operations/models/job_type_model.dart';
import 'package:maleva/core/models/shared/get_truck_model.dart';
import 'package:maleva/core/models/shared/customer_model.dart';
import 'package:maleva/core/models/shared/ware_house_model.dart';
import 'package:maleva/core/models/shared/agent_model.dart';
import 'package:maleva/features/operations/models/job_status_model.dart';
import 'package:maleva/core/models/shared/product_model.dart';
import 'package:maleva/core/models/shared/location_model.dart';

/// The picker helpers screens call to fill the `AppGlobals` lists
/// (`SelectCustomer`, `SelectTruckList`, ...). Each reads its shared Java API
/// (the typed clients in `lib/core/lookups` and `lib/core/fleet`). The .NET
/// HTTP plumbing this class once held (`apiAllinone*`, `post`, the legacy
/// client and the URL routing) is removed: the app calls no .NET API (change
/// `remove-legacy-network`).
class LegacyApiRepository {
  LegacyApiRepository();

Future SelectCustomer(context) async {
  // the shared Java /api/customers/options (was .NET CustomerApp/GetCustomer)
  AppGlobals.CustomerList.clear();
  try {
    AppGlobals.CustomerList = (await GetIt.instance<CustomerApi>().options()).map(CustomerModel.fromJava).toList();
  } catch (e) {
    print("API Error: $e");
  }
}

Future SelectLocation(context) async {
  // the shared Java /api/location-master/company/{id}/active (was .NET LocationApp/SelectLocation)
  AppGlobals.LocationList.clear();
  try {
    final rows = await GetIt.instance<LocationApi>().locations();
    AppGlobals.LocationList = rows.map(LocationModel.fromJava).toList();
  } catch (e) {
    print("API Error: $e");
  }
}

Future SelectWareHouse(context) async {
  // the shared Java GET /api/stock-ins/warehouses (ported from .NET StockApp/SelectPortList)
  AppGlobals.WareHouseList.clear();
  try {
    final comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    final rows = await GetIt.instance<StockInApi>().warehouses(comid);
    AppGlobals.WareHouseList = rows.map(WareHouseModel.fromJava).toList();
  } catch (e) {
    print("API Error: $e");
  }
}

Future SelectEmployee(context, String type, String type1) async {
  // the shared Java employee list (employee-lookups-on-shared-java-api)
  try {
    AppGlobals.EmployeeList = await GetIt.instance<EmployeeApi>().dropdown(type: type, type1: type1);
  } catch (e) {
    AppGlobals.EmployeeList = [];
    print("API Error: $e");
  }
}

Future SelectJobStatus(context) async {
  // the shared Java /api/job-status-master/select/{companyId}/ (was .NET JobStatusApp/SelectJobStatus)
  AppGlobals.JobStatusList.clear();
  try {
    AppGlobals.JobStatusList = (await GetIt.instance<JobStatusApi>().statuses()).map(JobStatusModel.fromJava).toList();
  } catch (e) {
    print("API Error: $e");
  }
}

Future SelectJobType(context) async {
  // the shared Java /api/job-type-master/jobtypes/{companyId} (was .NET JobTypeApp/SelectJobType)
  AppGlobals.JobTypeList.clear();
  try {
    AppGlobals.JobTypeList = (await GetIt.instance<JobTypeApi>().jobTypes()).map(JobTypeModel.fromJava).toList();
  } catch (e) {
    print("API Error: $e");
  }
}

Future SelectAllJobStatus(context, int Jobid) async {
  // the shared Java job-type steps (was .NET JobTypeApp/SelectJobAllData)
  AppGlobals.JobAllStatusList.clear();
  try {
    final steps = await GetIt.instance<JobStatusApi>().steps(Jobid);
    AppGlobals.JobAllStatusList = steps.statuses;
    AppGlobals.JobTypeDetailsList = steps.details;
  } catch (e) {
    print("API Error: $e");
  }
}

Future SelectAgentCompany(context) async {
  // the shared Java /api/agent-companies/company/{companyId} (was .NET AgentCompanyApp/SelectAgentCompany)
  AppGlobals.AgentCompanyList.clear();
  try {
    AppGlobals.AgentCompanyList = (await GetIt.instance<AgentApi>().agentCompanies()).map(AgentCompanyModel.fromJava).toList();
  } catch (e) {
    print("API Error: $e");
  }
}

Future SelectAgentAll(context, int AgentCompanyId) async {
  // the shared Java /api/agents/select-all (was .NET AgentApp/SelectAgentAll)
  AppGlobals.AgentAllList.clear();
  try {
    AppGlobals.AgentAllList =
        (await GetIt.instance<AgentApi>().agents(agentCompanyId: AgentCompanyId)).map(AgentModel.fromJava).toList();
  } catch (e) {
    print("API Error: $e");
  }
}

Future SelectProductList(context) async {
  // the shared Java /api/item-masters/company/{companyId}/products (was .NET ItemApp/GetProductList)
  AppGlobals.ProductList.clear();
  try {
    AppGlobals.ProductList = (await GetIt.instance<ProductApi>().products()).map(ProductModel.fromJava).toList();
  } catch (e) {
    print("API Error: $e");
  }
}


Future<void> GetRTINoForwarding(BuildContext ?context, int billId) async {
  // every RTI number of the company, from the shared Java RTI API
  try {
    AppGlobals.JobNoList = await GetIt.instance<RtiApi>().numbers();
  } catch (e) {
    AppGlobals.JobNoList = [];
    print("API Error: $e");
  }
}

Future SelectTruckList(context,String? Type) async {
  // the shared Java /api/truck-combo (was .NET TruckApp/GetTruck)
  AppGlobals.GetTruckList.clear();
  try {
    AppGlobals.GetTruckList = (await GetIt.instance<TruckApi>().combo(type: Type)).map(GetTruckModel.fromJava).toList();
  } catch (e) {
    print("API Error: $e");
  }
}


Future SelectDriverList(context,String? Type) async {
  // the shared Java /api/driver-combo (was .NET DriverApp/GetDriver)
  AppGlobals.GetDriverList.clear();
  try {
    AppGlobals.GetDriverList = (await GetIt.instance<DriverApi>().combo()).map(GetTruckModel.fromJava).toList();
  } catch (e) {
    print("API Error: $e");
  }
}

Future<List<String>> GetEmployeeport(context) async {
  // the employee's ports, from the shared Java APIs (employee-lookups-on-shared-java-api)
  try {
    final empId = AppGlobals.storagenew.getInt('EmpRefId') ?? 0;
    return await GetIt.instance<EmployeeApi>().portNames(empId);
  } catch (error) {
    debugPrint("Error fetching employee ports: $error");
  }
  return [];
}

}
