import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/features/dashboard/common_tabs/vesselplanningweb/models/vesselplanningweb_model.dart';
import 'package:maleva/features/dashboard/common_tabs/vesselplanningweb/view/vesselplanningweb_tab.dart';

/// The card shows the loading vessel's NAME (Java `Loadingvesselname`, the web's "Load Vessel"),
/// not only its type (`Vessel`, e.g. CONTAINER).
void main() {
  VesselPlanningWebModel row(Map<String, dynamic> json) => VesselPlanningWebModel.fromJson(json);

  test('name with its type', () {
    expect(loadingVesselText(row({'Loadingvesselname': 'MSC ANNA', 'Vessel': 'CONTAINER'})), 'MSC ANNA (CONTAINER)');
  });

  test('name only', () {
    expect(loadingVesselText(row({'Loadingvesselname': 'MSC ANNA', 'Vessel': ''})), 'MSC ANNA');
  });

  test('no name: the type, as before', () {
    expect(loadingVesselText(row({'Loadingvesselname': '', 'Vessel': 'CONTAINER'})), 'CONTAINER');
  });
}
