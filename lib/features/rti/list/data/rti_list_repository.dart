import 'package:maleva/core/fleet/driver_api.dart';
import 'package:maleva/core/fleet/truck_api.dart';
import 'package:maleva/core/rti/rti_api.dart';
import 'package:maleva/core/rti/rti_entry_api.dart';
import 'package:maleva/core/rti/rti_list_api.dart';
import 'package:maleva/core/session/app_session.dart';
import 'package:maleva/core/utils/json_read.dart';
import 'package:maleva/core/widgets/ui/formats.dart';
import 'package:maleva/core/widgets/ui/picker_sheet.dart';
import 'package:maleva/features/rti/list/models/rti_list_filter.dart';
import 'package:maleva/features/rti/list/models/rti_list_row.dart';

/// The RTI list's data on the shared Java API: the list (`/api/rti-masters/with-jobs`,
/// decision Q-RTI-LIST), the full RTI for the preview, the Driver / Truck pickers, WhatsApp
/// share and the report.
class RtiListRepository {
  RtiListRepository({
    required RtiListApi list,
    required RtiApi rti,
    required RtiEntryApi entry,
    required DriverApi drivers,
    required TruckApi trucks,
    required AppSession session,
  })  : _list = list,
        _rti = rti,
        _entry = entry,
        _drivers = drivers,
        _trucks = trucks,
        _session = session;

  final RtiListApi _list;
  final RtiApi _rti;
  final RtiEntryApi _entry;
  final DriverApi _drivers;
  final TruckApi _trucks;
  final AppSession _session;

  int get companyId => _session.companyId;

  /// EmployeeMaster id of the user; 0 for a driver login (the server then keeps the list to the
  /// driver's own RTIs).
  int get employeeId => _session.employeeId;

  bool get isDriver => _session.employeeId == 0;

  /// React's `buildParams`: dates, driver, truck, RTI number, and the user's employee id when
  /// "My RTIs" is on (0 otherwise).
  Future<List<RtiListRow>> list(RtiListFilter f) async {
    final rows = await _list.withJobs(
      fromDate: Fmt.ymd(f.fromDate),
      toDate: Fmt.ymd(f.toDate),
      driverId: f.driverId,
      truckId: f.truckId,
      employeeId: f.myRtis ? employeeId : 0,
      search: f.rtiNo.trim(),
    );
    return rows.map(RtiListRow.fromJava).toList();
  }

  Future<RtiPreviewData> preview(int rtiId) async {
    final rti = await _entry.load(rtiId);
    return RtiPreviewData.fromJava(rti.master, rti.lines);
  }

  Future<List<PickOption<int>>> drivers() async => _options(await _drivers.combo());

  Future<List<PickOption<int>>> trucks() async => _options(await _trucks.combo());

  static List<PickOption<int>> _options(List<Map<String, dynamic>> rows) => [
        for (final r in rows)
          if (JsonRead.integer(JsonRead.field(r, 'Id')) > 0)
            PickOption(value: JsonRead.integer(JsonRead.field(r, 'Id')), label: JsonRead.string(JsonRead.field(r, 'AccountName'))),
      ];

  Future<RtiShareResult> share(int rtiId) async => RtiShareResult.fromJava(await _rti.shareWhatsApp(rtiId));

  /// The report's full URL, or '' when the server sent none.
  Future<String> reportUrl(int rtiId) => _list.reportUrl(rtiId);
}
