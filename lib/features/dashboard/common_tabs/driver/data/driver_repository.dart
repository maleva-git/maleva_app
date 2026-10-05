import 'package:get_it/get_it.dart';
import 'package:maleva/core/fleet/expiry_api.dart';
import 'package:maleva/core/models/shared/driver_details_model.dart';

/// Driver Details: every driver of the company, from the shared Java expiry
/// list (change `master-reports-on-shared-java-api`).
class DriverRepository {
  Future<List<DriverDetailsModel>> fetchDriverDetails() async =>
      (await GetIt.instance<ExpiryApi>().drivers()).map(DriverDetailsModel.fromJava).toList();
}
