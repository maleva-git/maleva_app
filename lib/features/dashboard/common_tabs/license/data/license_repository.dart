import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/fleet/driver_api.dart';
import 'package:maleva/core/models/shared/license_view_model.dart';

/// The drivers' licences: the company's first 100 drivers that are not deleted
/// (shared Java `/api/driver-masters/search`, was .NET DriverApp/SelectDriver).
class LicenseRepository {
  Future<List<LicenseViewModel>> fetchLicenseRecords() async {
    final rows = await sl<DriverApi>().search(pageCount: 100);
    return rows.map(LicenseViewModel.fromJava).toList();
  }
}
