import 'package:maleva/core/fleet/driver_api.dart';
import 'package:maleva/core/fleet/truck_api.dart';
import 'package:maleva/core/lookups/job_status_api.dart';
// core/network/api_services/master_api.dart
// Master data — Customer, Employee, Location, JobType, Truck, Driver, etc.
// Multiple BLoC pages same master data use pannuvanga —
// so oru common class la vaichirukkom

import 'package:maleva/core/di/injection.dart';
import 'package:maleva/features/operations/models/job_status_model.dart';
import 'package:maleva/core/models/shared/get_truck_model.dart';

class MasterApi {
  MasterApi._();


  // ─── Job Status ───────────────────────────────────────────────────────────
  static Future<List<JobStatusModel>> getJobStatuses() async {
    // the shared Java job statuses (was .NET JobStatusApp/SelectJobStatus)
    return (await sl<JobStatusApi>().statuses()).map(JobStatusModel.fromJava).toList();
  }









  // ─── Truck ────────────────────────────────────────────────────────────────
  static Future<List<GetTruckModel>> getTrucks() async {
    // the shared Java /api/truck-combo (was .NET TruckApp/GetTruck)
    return (await sl<TruckApi>().combo()).map(GetTruckModel.fromJava).toList();
  }


  // ─── Driver ───────────────────────────────────────────────────────────────
  static Future<List<GetTruckModel>> getDrivers() async {
    // the shared Java /api/driver-combo (was .NET DriverApp/GetDriver)
    return (await sl<DriverApi>().combo()).map(GetTruckModel.fromJava).toList();
  }
}