import 'package:get_it/get_it.dart';
import 'package:maleva/core/rti/rti_api.dart';

/// The RTI View tab, on the shared Java RTI APIs (change `rti-on-shared-java-api`).
class RTIViewRepository {
  RTIViewRepository({RtiApi? api}) : _api = api ?? GetIt.instance<RtiApi>();

  final RtiApi _api;

  Future<RtiList> fetchRTIRecords({
    required String fromDate,
    required String toDate,
  }) =>
      _api.withJobs(fromDate: fromDate, toDate: toDate);

  /// The RTI report PDF of RTI [rtiId].
  Future<String> fetchRTIPdfUrl({required int rtiId}) => _api.reportUrl(rtiId);
}
