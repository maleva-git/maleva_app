import 'package:get_it/get_it.dart';
import 'package:maleva/core/fleet/gps_api.dart';
import 'package:maleva/core/models/shared/engine_hoursdata.dart';

/// From the shared Java GPS list (change `master-reports-on-shared-java-api`).
class EngineHoursRepository {
  Future<List<EngineHoursdata>> fetchEngineHoursReport({required DateTime fromDate, required DateTime toDate}) async =>
      (await GetIt.instance<GpsApi>().engineHours(fromDate, toDate)).map(EngineHoursdata.fromJava).toList();
}
