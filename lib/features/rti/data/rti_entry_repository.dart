import 'package:maleva/core/fleet/driver_api.dart';
import 'package:maleva/core/fleet/truck_api.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/rti/rti_entry_api.dart';
import 'package:maleva/core/rti/rti_job_lookup_api.dart';
import 'package:maleva/core/session/app_session.dart';
import 'package:maleva/core/utils/json_read.dart';
import 'package:maleva/features/rti/data/rti_mapper.dart';
import 'package:maleva/features/rti/data/rti_save_payload.dart';
import 'package:maleva/features/rti/models/js_values.dart';
import 'package:maleva/features/rti/models/rti_form.dart';
import 'package:maleva/features/rti/models/rti_job_row.dart';
import 'package:maleva/features/rti/models/rti_stop.dart';

/// An RTI as the form shows it. [stops] is null when the server sent no route activities
/// (a revise of an RTI with no lines answers `routeActivities: null`, RV4).
class RtiLoaded {
  const RtiLoaded({required this.form, required this.grid, required this.stops});

  final RtiForm form;
  final List<RtiJobRow> grid;
  final List<RtiStop>? stops;
}

/// The pickers of the form: drivers and trucks with their expiry dates, and employees.
class RtiReferences {
  const RtiReferences({this.drivers = const [], this.trucks = const [], this.employees = const []});

  final List<Map<String, dynamic>> drivers;
  final List<Map<String, dynamic>> trucks;
  final List<RtiEmployee> employees;
}

/// The RTI entry on the shared Java APIs, as React's `rtiApi` + `RTIService` use them.
class RtiEntryRepository {
  RtiEntryRepository({
    required RtiEntryApi api,
    required RtiJobLookupApi lookup,
    required DriverApi drivers,
    required TruckApi trucks,
    required AppSession session,
  })  : _api = api,
        _lookup = lookup,
        _drivers = drivers,
        _trucks = trucks,
        _session = session;

  final RtiEntryApi _api;
  final RtiJobLookupApi _lookup;
  final DriverApi _drivers;
  final TruckApi _trucks;
  final AppSession _session;

  int get companyId => _session.companyId;
  int get employeeId => _session.employeeId;

  /// The number the next RTI most likely gets (`RTI%09d`); the server assigns the real one.
  Future<String> nextNumber() => _api.nextNumberPreview();

  /// `RTIService.loadRTIById`: the master, its lines (each with its sale order's job no.,
  /// customer and date) and its stops. A sale order that cannot be read leaves the line's own values.
  Future<RtiLoaded> load(int id) async {
    final r = await _api.load(id);
    final ids = {
      for (final d in r.lines)
        if (Js.fieldNumber(d, ['saleOrderMasterRefId']) > 0) Js.fieldNumber(d, ['saleOrderMasterRefId']).toInt(),
    };
    final orders = <int, Map<String, dynamic>>{};
    await Future.wait(ids.map((soId) async {
      try {
        orders[soId] = RtiMapper.saleOrderMaster(await _lookup.saleOrder(soId));
      } catch (_) {}
    }));
    return RtiLoaded(
      form: RtiMapper.form(r.master),
      grid: [for (final d in r.lines) RtiMapper.fromDetail(d, orders[Js.fieldNumber(d, ['saleOrderMasterRefId']).toInt()])],
      stops: [for (final a in JsonRead.listOfMaps(JsonRead.field(r.master, 'routeActivities'))) RtiMapper.stop(a)],
    );
  }

  /// `RTIService.reviseFromSaleOrder`: the RTI re-read from its sales orders; nothing is saved.
  Future<RtiLoaded> revise(int id) async {
    final r = await _api.revise(id);
    if (r.master.isEmpty) throw const ApiFailure('Failed to load revise data.');
    final acts = JsonRead.field(r.master, 'routeActivities');
    return RtiLoaded(
      form: RtiMapper.form(r.master),
      grid: [for (final d in r.lines) RtiMapper.fromDetail(d)],
      stops: acts == null ? null : [for (final a in JsonRead.listOfMaps(acts)) RtiMapper.stop(a)],
    );
  }

  /// `RTIService.fillItemsByJobNo` (`R/services/rtiService.ts:503-563`): the sale orders whose
  /// number is exactly [jobNo] (BillNoDisplay, CNumberDisplay or JobNo, any case), each
  /// read in full. Null when none.
  Future<List<RtiJobRow>?> lookupJob(String jobNo) async {
    final wanted = jobNo.trim();
    if (wanted.isEmpty || companyId == 0) return null;
    final rows = await _lookup.searchSaleMasters(wanted);
    final matches = [
      for (final r in rows)
        if (Js.fieldText(r, ['BillNoDisplay', 'CNumberDisplay', 'JobNo']).toLowerCase() == wanted.toLowerCase())
          (
            id: Js.fieldNumber(r, ['Id']).toInt(),
            jobNo: Js.fieldText(r, ['BillNoDisplay', 'CNumberDisplay', 'JobNo']),
            jobDate: Js.fieldText(r, ['BillDate', 'JobDate']),
            customerName: Js.fieldText(r, ['CustomerName']),
          ),
    ];
    if (matches.isEmpty) return null;
    final out = await Future.wait(matches.map((m) async {
      final fallback = RtiMapper.fromLookup(m);
      if (m.id == 0) return fallback;
      try {
        final so = RtiMapper.saleOrderMaster(await _lookup.saleOrder(m.id));
        final id = Js.number([JsonRead.field(so, 'id'), m.id]).toInt();
        if (id == 0) return fallback;
        return RtiMapper.fromSaleOrder(so).copyWith(saleOrderMasterRefId: id, editMode: 1);
      } catch (_) {
        return fallback;
      }
    }));
    return out.isEmpty ? null : out;
  }

  /// `rtiApi.save`: POST a new RTI or PUT a saved one. Answers its id and number.
  Future<({int id, String rtiNo})> save(RtiSavePayload payload) async {
    if (Js.number([payload.master['companyRefId']]) == 0) {
      throw const ApiFailure('Company is required before saving RTI.');
    }
    final body = RtiSavePayloadBuilder.request(payload);
    final details = (body.remove('rtiDetails') as List).cast<Map<String, dynamic>>();
    final stops = (body.remove('routeActivities') as List).cast<Map<String, dynamic>>();
    final Map<String, dynamic> saved;
    try {
      saved = await _api.save(body, details, routeActivities: stops);
    } on ApiFailure catch (e) {
      throw ApiFailure(e.message.trim().isEmpty ? 'Failed to save RTI.' : e.message, statusCode: e.statusCode);
    }
    final id = Js.number([JsonRead.field(saved, 'id'), body['id']]).toInt();
    if (id == 0) throw const ApiFailure('RTI save did not return a valid master id.');
    return (id: id, rtiNo: Js.text([JsonRead.field(saved, 'CNumberDisplay'), body['CNumberDisplay']]));
  }

  /// `DELETE /api/rti-masters/{id}`.
  Future<void> delete(int id) async {
    try {
      await _api.delete(id);
    } on ApiFailure catch (e) {
      throw ApiFailure(e.message.trim().isEmpty ? 'Failed to delete RTI.' : e.message, statusCode: e.statusCode);
    }
  }

  /// Drivers and trucks (with their expiry dates) and the employees for the agent picker.
  Future<RtiReferences> references() async {
    final results = await Future.wait([_drivers.allDetails(), _trucks.allDetailCombo(), _lookup.employees()]);
    return RtiReferences(
      drivers: results[0],
      trucks: results[1],
      employees: [
        for (final e in results[2])
          RtiEmployee(
            id: Js.fieldNumber(e, ['id', 'employeeId']).toInt(),
            fullName: Js.fieldText(e, ['employeeName', 'name']),
            mobileNo: Js.fieldText(e, ['phone', 'mobile', 'mobileNo', 'phoneNumber']).isEmpty
                ? null
                : Js.fieldText(e, ['phone', 'mobile', 'mobileNo', 'phoneNumber']),
          ),
      ],
    );
  }

  /// The truck as the licence check reads it (`GET /api/truck-masters/{id}`); null on failure.
  Future<Map<String, dynamic>?> truck(int id) async {
    try {
      return await _lookup.truck(id);
    } catch (_) {
      return null;
    }
  }
}
