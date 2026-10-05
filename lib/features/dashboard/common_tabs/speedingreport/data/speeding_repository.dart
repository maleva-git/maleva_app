import 'package:get_it/get_it.dart';
import 'package:maleva/core/fleet/gps_api.dart';
import 'package:maleva/core/models/shared/speeding_view.dart';

/// From the shared Java GPS list (change `master-reports-on-shared-java-api`).
class SpeedingRepository {
  Future<List<SpeedingView>> fetchSpeedingReport({required DateTime fromDate, required DateTime toDate}) async =>
      (await GetIt.instance<GpsApi>().speedReports(fromDate, toDate)).map(SpeedingView.fromJava).toList();
}
